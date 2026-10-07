"""Keep the always-loaded router small, timeless and locally navigable."""
from pathlib import Path
import re
import sys


LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
HISTORY = re.compile(
    r"\b\d{4}-\d{2}-\d{2}\b|\b[0-9a-fA-F]{40}\b|#\d+\b|"
    r"\b(?:delivered|withdrawn|superseded|formerly|historical|approved|unapproved)\b",
    re.IGNORECASE,
)


def check(root):
    errors = []
    router = root / "AGENTS.md"
    source = router.read_text()
    if len(source.split()) > 100 or len(source.splitlines()) > 12:
        errors.append("AGENTS.md exceeds the navigation budget (100 words, 12 lines)")
    if HISTORY.search(source):
        errors.append("AGENTS.md contains historical state")
    for line in source.splitlines():
        if line.strip() and not line.startswith("# "):
            if not line.startswith("- ") or not LINK.search(line):
                errors.append("AGENTS.md content must be navigation bullets with links")
    for name in ("AGENTS.md", "CODING_STANDARDS.md", "docs/agent-workflow.md",
                 "docs/next-core-checkpoint.md"):
        path = root / name
        for target in LINK.findall(path.read_text()):
            if re.match(r"[a-zA-Z][\w+.-]*:", target) or target.startswith("/"):
                continue
            local, _, anchor = target.partition("#")
            destination = path.parent / local if local else path
            if not destination.is_file():
                errors.append(f"{name}: missing local target {target}")
            elif anchor:
                headings = re.findall(r"^#+\s+(.+)$", destination.read_text(), re.MULTILINE)
                anchors = {re.sub(r"[^\w\- ]", "", title.lower()).replace(" ", "-")
                           for title in headings}
                if anchor not in anchors:
                    errors.append(f"{name}: missing heading {target}")
    return errors


if __name__ == "__main__":
    failures = check(Path(__file__).resolve().parents[1])
    for failure in failures:
        print(failure, file=sys.stderr)
    sys.exit(bool(failures))
