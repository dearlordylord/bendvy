"""Cheap complete count3/source-boundary controls precede streaming preparation.
Executed failed giant attempt remains immutable; this entry never repeats giant parsing.
"""
import gzip,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
runpy.run_path(str(HERE/"test-boundary.py"),run_name="__main__")
if (HERE/"synthetic.stdout.gz").exists():
    # Verify the retained full artifact incrementally; no decoded object graph.
    record=json.loads((HERE/"PREPARATION.json").read_text());digest=hashlib.sha256();size=0
    with gzip.open(HERE/"synthetic.stdout.gz","rb") as stream:
        while chunk:=stream.read(1<<20):digest.update(chunk);size+=len(chunk)
    if digest.hexdigest()!=record["rawSHA256"] or size!=record["rawBytes"]:
        raise ValueError("Retained complete synthetic changed")
    print("Cheap controls then complete retained streaming hash PASS")
else:
    runpy.run_path(str(HERE/"stream-synthetic.py"),run_name="__main__")
