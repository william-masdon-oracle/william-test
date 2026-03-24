import re
import json
import html as htmlmod
from pathlib import Path
from urllib.parse import quote, urlencode
from urllib.request import build_opener, Request, HTTPCookieProcessor
import http.cookiejar

BASE_URL = "https://livelabs-dev.oracle.com/ords/r/dbpm/livelabs102/livelabs-workshop-cards"
AJAX_URL = "https://livelabs-dev.oracle.com/ords/wwv_flow.ajax"

INPUT_MD = Path(__file__).with_name("ai-search-test-cases.md")
OUTPUT_MD = Path(__file__).with_name("ai-search-test-results.md")


def parse_test_cases(md_text: str):
    cases = []
    lines = md_text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("## TC-"):
            title = line.strip().lstrip("# ")
            tc_id = title.split(" ")[1]
            # find prompt
            prompt = ""
            j = i + 1
            while j < len(lines) and lines[j].strip() != "Prompt:":
                j += 1
            if j < len(lines) and lines[j].strip() == "Prompt:":
                j += 1
                prompt_lines = []
                while j < len(lines) and lines[j].strip() != "":
                    prompt_lines.append(lines[j])
                    j += 1
                prompt = "\n".join(prompt_lines).strip()
            cases.append({"tc_id": tc_id, "title": title, "prompt": prompt})
            i = j
        else:
            i += 1
    return cases


def extract_hidden_value(pattern: str, html_text: str, label: str):
    m = re.search(pattern, html_text)
    if not m:
        raise RuntimeError(f"Missing {label} in HTML.")
    return htmlmod.unescape(m.group(1))


def extract_input_value(html_text: str, element_id: str):
    patterns = [
        rf'id="{re.escape(element_id)}"[^>]*value="([^"]*)"',
        rf'value="([^"]*)"[^>]*id="{re.escape(element_id)}"',
    ]
    for pat in patterns:
        m = re.search(pat, html_text)
        if m:
            return htmlmod.unescape(m.group(1))
    raise RuntimeError(f"Missing input value for {element_id}.")


def extract_data_for_value(html_text: str, item_name: str):
    # input[data-for="ITEM"] value="checksum"
    pat = rf'data-for="{re.escape(item_name)}"[^>]*value="([^"]*)"'
    m = re.search(pat, html_text)
    if m:
        return htmlmod.unescape(m.group(1))
    # try reversed order
    pat = rf'value="([^"]*)"[^>]*data-for="{re.escape(item_name)}"'
    m = re.search(pat, html_text)
    if m:
        return htmlmod.unescape(m.group(1))
    raise RuntimeError(f"Missing checksum (data-for) for {item_name}.")


def extract_ajax_identifier(html_text: str):
    ajax_id = None
    for m in re.finditer(r'ajaxIdentifier":"([^"]+)"', html_text):
        segment = html_text[m.start():m.start() + 300]
        if 'attribute01":"#SEARCH' in segment:
            ajax_id = m.group(1).encode('utf-8').decode('unicode_escape')
            break
    if not ajax_id:
        raise RuntimeError("Missing ajaxIdentifier for SEARCH process.")
    return ajax_id


def fetch_ai_answer(prompt: str):
    cj = http.cookiejar.CookieJar()
    opener = build_opener(HTTPCookieProcessor(cj))

    # 1) Load page with search param to establish session + SEARCH value
    page_url = f"{BASE_URL}?clear=100&search={quote(prompt)}"
    html_text = opener.open(page_url).read().decode("utf-8", "ignore")

    # 2) Extract required hidden values and ajax identifier
    p_instance = extract_hidden_value(r'name="p_instance" value="(\d+)"', html_text, "p_instance")
    p_page_submission_id = extract_hidden_value(r'name="p_page_submission_id" value="([^"]+)"', html_text, "p_page_submission_id")
    p_context = extract_hidden_value(r'value="([^"]+)" id="pContext"', html_text, "p_context")
    ajax_id = extract_ajax_identifier(html_text)

    # 3) Build pageItems payload with checksums (required for session state protection)
    p_salt = extract_input_value(html_text, "pSalt")
    p_page_items_protected = extract_input_value(html_text, "pPageItemsProtected")
    p_page_items_row_version = extract_input_value(html_text, "pPageItemsRowVersion")
    p_page_form_region_checksums_raw = extract_input_value(html_text, "pPageFormRegionChecksums")
    try:
        p_page_form_region_checksums = json.loads(p_page_form_region_checksums_raw)
    except json.JSONDecodeError:
        p_page_form_region_checksums = []

    search_value = extract_input_value(html_text, "SEARCH")
    search_checksum = extract_data_for_value(html_text, "SEARCH")

    p_json = {
        "salt": p_salt,
        "pageItems": {
            "itemsToSubmit": [
                {"n": "SEARCH", "v": search_value, "ck": search_checksum}
            ],
            "protected": p_page_items_protected,
            "rowVersion": p_page_items_row_version,
            "formRegionChecksums": p_page_form_region_checksums,
        },
    }

    # 4) Call APEX AJAX process with pageItems + checksums
    payload = {
        "p_flow_id": "102",
        "p_flow_step_id": "100",
        "p_instance": p_instance,
        "p_page_submission_id": p_page_submission_id,
        "p_request": f"PLUGIN={ajax_id}",
        "p_json": json.dumps(p_json),
        "p_context": p_context,
    }
    data = urlencode(payload).encode("utf-8")
    req = Request(AJAX_URL, data=data)
    req.add_header("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")

    resp_text = opener.open(req).read().decode("utf-8", "ignore")

    try:
        resp_json = json.loads(resp_text)
    except json.JSONDecodeError:
        return page_url, resp_text, ["Failed to parse JSON response from APEX."]

    if "error" in resp_json:
        return page_url, resp_text, [f"APEX error: {resp_json['error']}"]

    answer = ""
    if isinstance(resp_json.get("item"), list):
        for item in resp_json["item"]:
            if item.get("id") == "P100_AI_ANSWER":
                answer = item.get("value", "")
                break

    return page_url, answer, []


def assess_response(case, response_html: str):
    feedback = []
    text_lower = response_html.lower()

    if not response_html.strip():
        feedback.append("No response captured (P100_AI_ANSWER empty).")
        return feedback

    has_html_tags = bool(re.search(r"<\s*(div|p|span|a)\b", response_html, re.IGNORECASE))
    if not has_html_tags:
        feedback.append("Response is not HTML (expected <div>/<p>/<a> tags).")

    has_links = "<a " in text_lower
    has_wid_link = "wid=" in text_lower
    if not has_links or not has_wid_link:
        feedback.append("Missing required hyperlinks to workshops/sprints (expected <a href=...wid=ID>).")

    # Exact title match checks
    if "Exact title match" in case["title"]:
        prompt_norm = case["prompt"].strip().lower()
        if prompt_norm and prompt_norm not in text_lower:
            feedback.append("Exact-title match not mentioned in response.")

    # No-match checks for specific prompts
    if any(tok in case["prompt"].lower() for tok in ["sourdough", "asdlkjasd", "qwerty"]):
        if not re.search(r"no\s+relevant|not\s+related|no\s+workshops|no\s+results", text_lower):
            feedback.append("No-match query should state no relevant results; response appears to recommend unrelated content.")

    return feedback


def main():
    md_text = INPUT_MD.read_text(encoding="utf-8")
    cases = parse_test_cases(md_text)
    if not cases:
        raise SystemExit("No test cases parsed from input file.")

    results = []
    for case in cases:
        print(f"Running {case['tc_id']} -> {case['prompt']}")
        try:
            url_used, response_html, errors = fetch_ai_answer(case["prompt"])
        except Exception as exc:
            url_used, response_html, errors = "", "", [f"Exception: {exc}"]

        feedback = errors + assess_response(case, response_html)

        results.append({
            "case": case,
            "response_html": response_html.strip(),
            "feedback": feedback,
            "url": url_used,
        })

    # Write output markdown
    out_lines = [
        "# AI Search Test Results (Automated)",
        "",
        f"Source test cases: {INPUT_MD.name}",
        "",
        "---",
        "",
    ]

    for item in results:
        case = item["case"]
        out_lines.append(f"## {case['title']}")
        out_lines.append("Prompt:")
        out_lines.append(case["prompt"])
        out_lines.append("")
        out_lines.append("URL Used:")
        out_lines.append(item["url"])
        out_lines.append("")
        out_lines.append("Response (HTML):")
        out_lines.append("```")
        out_lines.append(item["response_html"])
        out_lines.append("```")
        out_lines.append("")
        out_lines.append("Feedback:")
        if item["feedback"]:
            for fb in item["feedback"]:
                out_lines.append(f"- {fb}")
        else:
            out_lines.append("- No issues detected by automated checks.")
        out_lines.append("")
        out_lines.append("---")
        out_lines.append("")

    OUTPUT_MD.write_text("\n".join(out_lines), encoding="utf-8")
    print(f"Wrote results to {OUTPUT_MD}")


if __name__ == "__main__":
    main()
