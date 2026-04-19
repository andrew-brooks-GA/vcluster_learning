#!/usr/bin/env python3
"""
scripts/router-equivalence-report.py

Phase 6 — compares parent-side rubric verdicts against the historical
haiku-reviewer verdicts pulled from session transcripts. Produces the
acceptance report.

Inputs:
  docs/historical-drafts.json     — output of extract-historical-drafts.py
  docs/parent-side-verdicts.json  — list of {draft_tool_use_id, verdict}
                                    where verdict is "PASS" or "FAIL[:...]"

Output:
  docs/router-equivalence-<date>.md

Acceptance thresholds (plan):
  - agreement >= 95%
  - false-PASS == 0   (parent says PASS, haiku says FAIL — DANGEROUS)
  - false-FAIL acceptable (parent says FAIL, haiku says PASS — costs latency,
    not quality; just routes to reviewer = no win on those turns)
"""
from __future__ import annotations
import json
import sys
from datetime import date
from pathlib import Path


def norm(v):
    if v is None:
        return None
    v = v.strip().upper()
    if v.startswith("PASS"):
        return "PASS"
    if v.startswith("FAIL"):
        return "FAIL"
    return None


def main():
    base = Path(__file__).resolve().parents[1]
    drafts_path = base / "docs" / "historical-drafts.json"
    parent_path = base / "docs" / "parent-side-verdicts.json"
    out_path = base / "docs" / f"router-equivalence-{date.today().isoformat()}.md"

    if not drafts_path.exists():
        print(f"ERROR: missing {drafts_path}", file=sys.stderr); sys.exit(1)
    if not parent_path.exists():
        print(f"ERROR: missing {parent_path}", file=sys.stderr); sys.exit(1)

    drafts = json.loads(drafts_path.read_text(encoding="utf-8"))
    parent = json.loads(parent_path.read_text(encoding="utf-8"))

    parent_by_id = {p["draft_tool_use_id"]: p for p in parent}

    paired = []
    for d in drafts:
        h = norm(d.get("reviewer_verdict"))
        if h is None:
            continue
        p = parent_by_id.get(d["draft_tool_use_id"])
        if p is None:
            continue
        pv = norm(p.get("verdict"))
        if pv is None:
            continue
        paired.append({
            "draft_id": d["draft_tool_use_id"],
            "session": d["session"],
            "haiku": h,
            "parent": pv,
            "draft_preview": (d.get("draft", "")[:160]).replace("\n", " "),
            "haiku_text": d.get("reviewer_text", ""),
            "parent_reasoning": p.get("reasoning", ""),
        })

    n = len(paired)
    if n == 0:
        print("ERROR: no paired records", file=sys.stderr); sys.exit(1)

    agree = sum(1 for r in paired if r["haiku"] == r["parent"])
    false_pass = [r for r in paired if r["parent"] == "PASS" and r["haiku"] == "FAIL"]
    false_fail = [r for r in paired if r["parent"] == "FAIL" and r["haiku"] == "PASS"]

    agreement_pct = 100.0 * agree / n
    threshold_met = agreement_pct >= 95.0 and len(false_pass) == 0

    lines = []
    lines.append(f"# Router Equivalence Report — {date.today().isoformat()}")
    lines.append("")
    lines.append(f"**Sample size:** {n} paired drafts (parent-side verdict + haiku reviewer verdict).")
    lines.append(f"**Source drafts:** {drafts_path.relative_to(base)}")
    lines.append(f"**Parent-side verdicts:** {parent_path.relative_to(base)}")
    lines.append("")
    lines.append("## Verdict matrix")
    lines.append("")
    lines.append("| | haiku PASS | haiku FAIL |")
    lines.append("|---|---|---|")
    pp = sum(1 for r in paired if r["parent"] == "PASS" and r["haiku"] == "PASS")
    pf = len(false_pass)
    fp = len(false_fail)
    ff = sum(1 for r in paired if r["parent"] == "FAIL" and r["haiku"] == "FAIL")
    lines.append(f"| **parent PASS** | {pp} (agree) | {pf} (FALSE-PASS — dangerous) |")
    lines.append(f"| **parent FAIL** | {fp} (false-FAIL — latency cost only) | {ff} (agree) |")
    lines.append("")
    lines.append(f"**Agreement:** {agree} / {n} = **{agreement_pct:.1f}%**")
    lines.append(f"**False-PASS count:** {len(false_pass)} (must be 0 for deployment)")
    lines.append(f"**False-FAIL count:** {len(false_fail)} (acceptable — routes to reviewer, no quality loss)")
    lines.append("")
    lines.append("## Acceptance thresholds (per plan)")
    lines.append("")
    lines.append("- Agreement ≥ 95%: " + ("PASS" if agreement_pct >= 95.0 else "FAIL"))
    lines.append("- False-PASS == 0: " + ("PASS" if len(false_pass) == 0 else "FAIL"))
    lines.append("")
    lines.append(f"**Deployment decision:** {'PROCEED — deploy router' if threshold_met else 'BLOCK — leave router undeployed; iterate on parent-side eval prompt'}")
    lines.append("")

    if false_pass:
        lines.append("## False-PASS cases (dangerous — parent missed a haiku FAIL)")
        lines.append("")
        for r in false_pass:
            lines.append(f"### {r['draft_id']}  (session {r['session']})")
            lines.append("")
            lines.append("**Draft preview:**")
            lines.append(f"> {r['draft_preview']}")
            lines.append("")
            lines.append("**Haiku reviewer said:**")
            lines.append("```")
            lines.append((r['haiku_text'] or "")[:500])
            lines.append("```")
            lines.append("")
            lines.append("**Parent reasoning:**")
            lines.append("```")
            lines.append((r['parent_reasoning'] or "")[:500])
            lines.append("```")
            lines.append("")

    if false_fail:
        lines.append("## False-FAIL cases (parent over-routed — latency cost only)")
        lines.append("")
        for r in false_fail[:5]:
            lines.append(f"- `{r['draft_id']}` (session {r['session']}) — `{r['draft_preview'][:100]}`")
        if len(false_fail) > 5:
            lines.append(f"- ...and {len(false_fail)-5} more.")
        lines.append("")

    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote: {out_path}")
    print(f"Agreement: {agreement_pct:.1f}%   false-PASS: {len(false_pass)}   false-FAIL: {len(false_fail)}")
    print(f"Decision:  {'PROCEED' if threshold_met else 'BLOCK'}")


if __name__ == "__main__":
    main()
