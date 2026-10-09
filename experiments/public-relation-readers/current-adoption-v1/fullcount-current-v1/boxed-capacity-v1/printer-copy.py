"""Exact admitted printer replacement; no application/source algorithm changes."""
from pathlib import Path
HERE=Path(__file__).resolve().parent
PRINTER=HERE.parent/"iterative-printer-v1"
def patch(source):
    old=(PRINTER/"original-printer.mjs").read_text().split("\nexport {show_val};")[0].strip().encode()
    new=(PRINTER/"printer.mjs").read_text().split("\nexport {show_val};")[0].strip().encode()
    if source.count(old)!=1:raise ValueError("Expected exactly one original pinned printer")
    result=source.replace(old,new,1)
    if result.replace(new,old,1)!=source:raise ValueError("Printer-only inverse join failed")
    return result
