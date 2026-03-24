import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';
import encoding from 'k6/encoding';

const TOKEN_URL = __ENV.TOKEN_URL || 'https://livelabs-dev.oracle.com/ords/dbpm/oauth/token';
const API_URL = __ENV.API_URL || 'https://livelabs-dev.oracle.com/ords/dbpm/livelabs/stressTestEmbed';
const CLIENT_ID = __ENV.CLIENT_ID;
const CLIENT_SECRET = __ENV.CLIENT_SECRET;
const SCOPE = __ENV.SCOPE; // optional
const THINK_TIME = Number(__ENV.THINK_TIME || 1);
const QUERY_TEXTS = __ENV.QUERY_TEXTS; // optional comma-separated list
const VECTOR_FIELD = __ENV.VECTOR_FIELD; // optional, e.g. "vector" or "embedding"
const LOG_SAMPLE_RATE = Number(__ENV.LOG_SAMPLE_RATE || 0); // 0 disables, 1 logs all, 0.1 logs 10%

const DEFAULT_STAGES = [
  { duration: '30s', target: 10 },
  { duration: '2m', target: 50 },
  { duration: '30s', target: 0 },
];

export const options = __ENV.SMOKE === '1'
  ? { vus: 1, iterations: 1 }
  : {
      stages: DEFAULT_STAGES,
      thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<1500'],
      },
    };

const vectorPass = new Counter('vector_pass');
const vectorFail = new Counter('vector_fail');

const WORDS = [
  'apex', 'oracle', 'livelabs', 'embedding', 'search', 'vector', 'database',
  'model', 'query', 'performance', 'stress', 'test', 'latency', 'scaling',
  'semantic', 'index', 'ai', 'context', 'workshop', 'tutorial',
];

function randomQueryText() {
  if (QUERY_TEXTS) {
    const items = QUERY_TEXTS.split(',').map(s => s.trim()).filter(Boolean);
    if (items.length > 0) {
      const pick = items[Math.floor(Math.random() * items.length)];
      return `${pick} ${__VU}-${__ITER}-${Date.now()}`;
    }
  }

  const len = 3 + Math.floor(Math.random() * 6);
  const parts = [];
  for (let i = 0; i < len; i += 1) {
    parts.push(WORDS[Math.floor(Math.random() * WORDS.length)]);
  }
  // add a suffix to reduce caching effects
  parts.push(`req${__VU}-${__ITER}-${Date.now()}`);
  return parts.join(' ');
}

function shouldLogSample() {
  if (!LOG_SAMPLE_RATE || LOG_SAMPLE_RATE <= 0) return false;
  if (LOG_SAMPLE_RATE >= 1) return true;
  return Math.random() < LOG_SAMPLE_RATE;
}

function parseVectorString(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) {
    return null;
  }
  const inner = trimmed.slice(1, -1).trim();
  if (!inner) return [];
  const parts = inner.split(',').map((p) => p.trim()).filter(Boolean);
  const nums = parts.map((p) => Number(p));
  if (nums.some((n) => Number.isNaN(n))) return null;
  return nums;
}

function extractVector(body) {
  if (!body) return null;

  if (Array.isArray(body)) {
    return body;
  }

  if (VECTOR_FIELD && body[VECTOR_FIELD]) {
    const val = body[VECTOR_FIELD];
    return Array.isArray(val) ? val : parseVectorString(val) || val;
  }

  // try common keys if VECTOR_FIELD not set
  for (const key of ['Vector', 'vector', 'embedding', 'embeddings', 'data']) {
    if (body[key]) {
      const val = body[key];
      return Array.isArray(val) ? val : parseVectorString(val) || val;
    }
  }

  return null;
}

function getAccessToken() {
  if (!CLIENT_ID || !CLIENT_SECRET) {
    throw new Error('Missing CLIENT_ID or CLIENT_SECRET environment variables');
  }

  const basicAuth = 'Basic ' + encoding.b64encode(`${CLIENT_ID}:${CLIENT_SECRET}`);
  const payload = SCOPE
    ? `grant_type=client_credentials&scope=${encodeURIComponent(SCOPE)}`
    : 'grant_type=client_credentials';

  const res = http.post(TOKEN_URL, payload, {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': basicAuth,
    },
  });

  check(res, {
    'token status is 200': (r) => r.status === 200,
  });

  const body = res.json();
  if (!body || !body.access_token) {
    throw new Error(`Token response missing access_token. Status: ${res.status}`);
  }

  return body.access_token;
}

export function setup() {
  const token = getAccessToken();
  return { token };
}

export default function (data) {
  const queryText = randomQueryText();
  const payload = JSON.stringify({ queryText });

  const res = http.post(API_URL, payload, {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${data.token}`,
    },
  });

  const okStatus = res.status === 200;
  let okVector = false;
  let vectorLength = null;

  if (okStatus) {
    try {
      const body = res.json();
      const vector = extractVector(body);
      const parsed = Array.isArray(vector) ? vector : parseVectorString(vector);
      if (Array.isArray(parsed)) {
        vectorLength = parsed.length;
        okVector = parsed.length > 0;
      } else if (typeof vector === 'string') {
        okVector = vector.trim().length > 2; // at least "[]"
      }
    } catch (e) {
      okVector = false;
    }
  }

  check(res, {
    'status is 200': () => okStatus,
    'vector is non-empty': () => okVector,
  });

  if (okVector) {
    vectorPass.add(1);
  } else {
    vectorFail.add(1);
  }

  if (shouldLogSample()) {
    const preview = res.body ? res.body.slice(0, 100) : '';
    console.log(JSON.stringify({
      ts: new Date().toISOString(),
      vu: __VU,
      iter: __ITER,
      queryText,
      status: res.status,
      duration_ms: res.timings.duration,
      vector_ok: okVector,
      vector_len: vectorLength,
      body_preview: preview,
    }));
  }

  sleep(THINK_TIME);
}
