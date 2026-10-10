"""Correct imported nominal Report transport; frozen body oracle unchanged."""
import importlib.util
from pathlib import Path

HERE = Path(__file__).resolve().parent
ORIGINAL = HERE.parent / "ordinary-mixed-app-oracle-v1" / "model.py"
spec = importlib.util.spec_from_file_location("original_mixed", ORIGINAL)
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)


def report(cursor=0, companion=False):
    # full-entry imports ./full-consumer.bend. book_load assigns namespace
    # full-consumer; parse_name namespaces Report; show_main retains c.k;
    # backend name_key renders ':' as '.', so output is full-consumer.Report.
    raw = original.report(cursor, companion)
    assert raw.startswith(b"Report{")
    return b"full-consumer." + raw
