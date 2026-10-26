"""Independent finite model for the ordinary query lifecycle filter consumer."""
from pathlib import Path
import runpy

query = runpy.run_path(str(Path(__file__).resolve().parents[1] / "parallel-query" / "oracle.py"))


def scenario():
    # Seeds were inserted at legitimate tick zero. The first invocation sees them.
    # Later invocations have cursor >= every added/changed stamp, so select none.
    outputs = dict(query["INITIAL_OUTPUTS"])
    changed = {}
    for index in (1, 17):
        token, value = outputs[index]
        outputs[index] = token + 1, value + query["INPUTS"][index][1]
        changed[index] = 1
    system = "namespace=1,id=1,name=query,access=[input, output],cursor=0:3,local=903:3"
    original = query["world"](1, 18, outputs, changed, True, 3)
    foreign = query["world"](2, 0, query["INITIAL_OUTPUTS"], {}, False, 0)
    return ("statuses=[success/[],success/[],success/[]];admission=refused;"
            f"system={{{system}}};original={{{original}}};foreign={{{foreign}}}")


if __name__ == "__main__":
    for label in ("First/added/serial", "First/added/parallel",
                  "Second/changed/serial", "Second/changed/parallel"):
        print(label + "=" + scenario())
