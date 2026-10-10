"""Independent complete A/Other resource App sequence, source-derived only."""
import importlib.util
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
PREVIOUS = HERE.parent / "resource-app-oracle-v1/expected.py"
spec = importlib.util.spec_from_file_location("independent_app_model", PREVIOUS)
app = importlib.util.module_from_spec(spec)
spec.loader.exec_module(app)
def model(omit_rendered=False):
    return dict(empty=app.scenario(0, omit_rendered), nonempty=app.scenario(2, omit_rendered), otherEmpty=app.scenario(0, omit_rendered), otherNonempty=app.scenario(2, omit_rendered))
def stdout(value):
    return "Report{" + ", ".join(json.dumps(v) for v in value.values()) + "}\n"
def split_model(omit_rendered=False):
    return dict(empty=app.scenario(0, omit_rendered), nonempty=app.scenario(2, omit_rendered))

if __name__ == "__main__":
    for name, omit in [("normal", False), ("presentation-mutant", True)]:
        value = model(omit)
        (HERE / (name + "-expected.json")).write_text(json.dumps(value, indent=2) + "\n")
        (HERE / (name + "-expected.stdout")).write_text(stdout(value))

    for name in ["a", "other"]:
        value = split_model()
        (HERE / (name + "-expected.json")).write_text(json.dumps(value, indent=2) + "\n")
        (HERE / (name + "-expected.stdout")).write_text(stdout(value))
