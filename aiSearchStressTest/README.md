# AI Search Stress Test (k6)

This folder contains a k6 load test for the LiveLabs ORDS embedding endpoint.

## Prereqs
- k6 installed
- Network access via Oracle proxy (AnyConnect PAC). Use a proxy (example below).
- OAuth access to the ORDS token endpoint (see internal team guidance).

## Environment variables
Set these before running:

```bash
export CLIENT_ID='FILL_IN'
export CLIENT_SECRET='FILL_IN'
# Optional:
# export SCOPE='...'
# export TOKEN_URL='https://livelabs-dev.oracle.com/ords/dbpm/oauth/token'
# export API_URL='https://livelabs-dev.oracle.com/ords/dbpm/livelabs/stressTestEmbed'
# export THINK_TIME=1
# export VECTOR_FIELD='vector'   # if response is an object and the vector is in a specific key
# export QUERY_TEXTS='hello world,apex search,vector test'
# export LOG_SAMPLE_RATE=0.1     # 0 disables (default), 1 logs all, 0.1 logs 10%
```

### Proxy (required on VPN)
Because AnyConnect uses a PAC proxy, k6/curl must be told explicitly:

```bash
export HTTPS_PROXY=http://tw-proxy-sjc.oraclecorp.com:80
export HTTP_PROXY=http://tw-proxy-sjc.oraclecorp.com:80
```

```bash
unset HTTPS_PROXY
unset HTTP_PROXY
```

## Run a smoke test (1 request)

```bash
SMOKE=1 k6 run loadtest.js
```

## Run the default load profile

```bash
k6 run loadtest.js
```

```bash
LOG_SAMPLE_RATE=1 \                                                                      
  k6 run --log-format raw --console-output results.jsonl --summary-export summary.json loadtest.js
```

Default stages:
- 30s ramp to 10 VUs
- 2m hold at 50 VUs
- 30s ramp down to 0

You can override with CLI flags, e.g.:

```bash
k6 run --vus 100 --duration 2m loadtest.js
```

## Response validation
The script verifies:
- HTTP status is 200
- The response contains a non-empty vector

By default it checks:
- If the JSON response is an array, it uses that as the vector
- If the response is an object, it tries keys: Vector, vector, embedding, embeddings, data
- If the vector is returned as a string like "[1,2,3]", it will parse it
- Or you can set VECTOR_FIELD to the exact key

## Per-request logging (optional)
If you want a per-request log, set LOG_SAMPLE_RATE and use console output + summary export.
Example (log all requests):

```bash
LOG_SAMPLE_RATE=1 \
  k6 run --log-format raw --console-output results2.jsonl --summary-export summary.json loadtest.js
```

Each line is JSON with:
- queryText
- first 100 chars of response body
- status
- duration_ms
- vector_ok and vector_len

## Notes
- The test fetches a bearer token once in `setup()` and reuses it for all VUs.
- If your access tokens expire quickly, we can refresh periodically per VU.
- Do not commit secrets into files.
