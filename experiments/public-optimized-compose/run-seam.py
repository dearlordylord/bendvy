"""Execute the frozen generic handoff with a real public affine Column owner."""
import json
import pathlib
import subprocess
import tempfile
from freeze import ROOT, freeze

with tempfile.TemporaryDirectory(prefix="bendvy-compose30-") as temporary:
    stage = pathlib.Path(temporary) / "stage"
    receipt = freeze(stage)
    source = (ROOT / "experiments/public-optimized-compose/column-seam.bend.in").read_text()
    (stage / "seam.bend").write_text(source.replace("@@ROOT@@", str(ROOT)))
    extracted = (ROOT / "experiments/public-optimized-compose/extracted/handoff.bend").resolve()
    extracted_source = source.replace("import ./experiments/s-integrate/query.bend as Q", "import " + str(extracted) + " as Q").replace("import ./experiments/s-integrate/storage.bend as S", "import " + str(extracted) + " as S")
    (stage / "extracted-seam.bend").write_text(extracted_source.replace("@@ROOT@@", str(ROOT)))
    commands = [
        (["bend", str(stage / "seam.bend"), "--check-only"], 5),
        (["bend", str(stage / "seam.bend")], 5),
        (["bend", str(stage / "seam.bend"), "-o", str(stage / "seam.js")], 30),
        (["node", str(stage / "seam.js")], 5),
    ]
    commands += [(["bend", str(stage / "extracted-seam.bend"), "--check-only"], 5),
                 (["bend", str(stage / "extracted-seam.bend")], 5),
                 (["bend", str(stage / "extracted-seam.bend"), "-o", str(stage / "extracted-seam.js")], 30),
                 (["node", str(stage / "extracted-seam.js")], 5)]
    receipt["commands"] = []
    for command, limit in commands:
        result = subprocess.run(command, timeout=limit, capture_output=True, text=True)
        receipt["commands"].append({"command": command, "limit": limit,
                                    "exit": result.returncode, "stdout": result.stdout,
                                    "stderr": result.stderr})
        if result.returncode:
            raise RuntimeError(result.stderr)
        if command[0] == "node" or len(command) == 2:
            assert result.stdout.strip() == "7", result.stdout
    receipt["scope"] = "two-slot real affine public Column extraction/recovery seam; not Workshop integration"
    print(json.dumps(receipt, indent=2))
