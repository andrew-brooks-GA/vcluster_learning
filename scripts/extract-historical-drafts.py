#!/usr/bin/env python3
"""
scripts/extract-historical-drafts.py

Phase 6 helper — scrapes Claude Code session transcripts (jsonl) for
socratic-drafter outputs paired with the reviewer's verdict on that draft.
Output is a JSON list usable by the equivalence harness.

Each record:
  {
    "session": "<session-uuid>",
    "draft_tool_use_id": "<id>",
    "drafter_input": "<the prompt the parent sent to the drafter>",
    "draft": "<the drafter's output text>",
    "reviewer_verdict": "PASS" | "FAIL:..." | None,
    "reviewer_text": "<full reviewer output>"
  }

Usage:
  python scripts/extract-historical-drafts.py [transcripts_dir] [output_path]

Defaults:
  transcripts_dir = $HOME/.claude/projects/D--GitRepos-vcluster-learning
  output_path     = docs/historical-drafts.json
"""

from __future__ import annotations
import json
import os
import sys
from pathlib import Path


def first_text(content):
    """Tool_result.content can be a string or a list of {type:text,text:...} blocks."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for b in content:
            if isinstance(b, dict) and b.get("type") == "text":
                parts.append(b.get("text", ""))
            elif isinstance(b, str):
                parts.append(b)
        return "\n".join(parts)
    return ""


def parse_verdict(text: str) -> str | None:
    """Heuristic: first line containing PASS or FAIL."""
    if not text:
        return None
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("PASS") or s.startswith("FAIL"):
            return s.split(None, 1)[0].rstrip(":,.")
    # Sometimes verdict is buried — search anywhere.
    if "PASS" in text and "FAIL" not in text:
        return "PASS"
    if "FAIL" in text:
        return "FAIL"
    return None


def extract_from_session(path: Path):
    """Yield draft records from one session jsonl."""
    # Two-pass: first build maps of {tool_use_id -> drafter input} from assistant
    # tool_use blocks, and {tool_use_id -> tool_result text} from user blocks.
    # Then pair: each drafter call's result is a draft; the immediately
    # following reviewer call's result is its verdict.

    drafter_inputs: dict[str, str] = {}      # tool_use_id -> prompt text
    drafter_results: dict[str, str] = {}     # tool_use_id -> draft text
    reviewer_inputs: dict[str, str] = {}
    reviewer_results: dict[str, str] = {}
    # Ordering: list of (turn_index, kind, tool_use_id) so we can pair drafter→reviewer.
    timeline: list[tuple[int, str, str]] = []

    with path.open(encoding="utf-8") as f:
        for i, line in enumerate(f):
            try:
                obj = json.loads(line)
            except Exception:
                continue
            t = obj.get("type")
            if t == "assistant":
                msg = obj.get("message", {})
                content = msg.get("content", [])
                if not isinstance(content, list):
                    continue
                for block in content:
                    if not isinstance(block, dict):
                        continue
                    if block.get("type") == "tool_use" and block.get("name") == "Agent":
                        sub = block.get("input", {}).get("subagent_type")
                        prompt = block.get("input", {}).get("prompt", "")
                        tid = block.get("id", "")
                        if sub == "socratic-drafter":
                            drafter_inputs[tid] = prompt
                            timeline.append((i, "drafter", tid))
                        elif sub == "socratic-reviewer":
                            reviewer_inputs[tid] = prompt
                            timeline.append((i, "reviewer", tid))
            elif t == "user":
                msg = obj.get("message", {})
                content = msg.get("content", [])
                if not isinstance(content, list):
                    continue
                for block in content:
                    if not isinstance(block, dict):
                        continue
                    if block.get("type") == "tool_result":
                        tid = block.get("tool_use_id", "")
                        if tid in drafter_inputs:
                            drafter_results[tid] = first_text(block.get("content"))
                        elif tid in reviewer_inputs:
                            reviewer_results[tid] = first_text(block.get("content"))

    # Pair timeline: for each drafter, the next reviewer in timeline order is its verdict.
    session_id = path.stem
    pending_drafters: list[str] = []
    for _, kind, tid in timeline:
        if kind == "drafter":
            pending_drafters.append(tid)
        elif kind == "reviewer" and pending_drafters:
            d_tid = pending_drafters.pop(0)
            reviewer_text = reviewer_results.get(tid, "")
            yield {
                "session": session_id,
                "draft_tool_use_id": d_tid,
                "drafter_input": drafter_inputs.get(d_tid, ""),
                "draft": drafter_results.get(d_tid, ""),
                "reviewer_tool_use_id": tid,
                "reviewer_text": reviewer_text,
                "reviewer_verdict": parse_verdict(reviewer_text),
            }
    # Drafters without a paired reviewer: still emit, with None verdict.
    for d_tid in pending_drafters:
        yield {
            "session": session_id,
            "draft_tool_use_id": d_tid,
            "drafter_input": drafter_inputs.get(d_tid, ""),
            "draft": drafter_results.get(d_tid, ""),
            "reviewer_tool_use_id": None,
            "reviewer_text": "",
            "reviewer_verdict": None,
        }


def main():
    default_dir = Path.home() / ".claude" / "projects" / "D--GitRepos-vcluster-learning"
    default_out = Path("docs") / "historical-drafts.json"

    src = Path(sys.argv[1]) if len(sys.argv) > 1 else default_dir
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else default_out

    if not src.exists():
        print(f"ERROR: transcripts dir not found: {src}", file=sys.stderr)
        sys.exit(1)

    records = []
    sessions_with_drafts = 0
    for jsonl in sorted(src.glob("*.jsonl")):
        session_records = list(extract_from_session(jsonl))
        if session_records:
            sessions_with_drafts += 1
            records.extend(session_records)

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(records, indent=2, ensure_ascii=False), encoding="utf-8")

    paired = sum(1 for r in records if r["reviewer_verdict"] is not None)
    pass_count = sum(1 for r in records if r["reviewer_verdict"] == "PASS")
    fail_count = sum(1 for r in records if r["reviewer_verdict"] and r["reviewer_verdict"].startswith("FAIL"))

    print(f"Scanned:       {len(list(src.glob('*.jsonl')))} jsonl files in {src}")
    print(f"Sessions with drafter activity: {sessions_with_drafts}")
    print(f"Drafts extracted:               {len(records)}")
    print(f"  paired with reviewer verdict: {paired}")
    print(f"    PASS:                       {pass_count}")
    print(f"    FAIL (any anti-pattern):    {fail_count}")
    print(f"Output: {out}")


if __name__ == "__main__":
    main()
