"""Literal container derivation only; original independent TS model remains authoritative."""
from pathlib import Path
import json
HERE=Path(__file__).parent
if __name__=='__main__':print(json.dumps((HERE/'expected.stdout').read_text(),ensure_ascii=False,indent=2))
