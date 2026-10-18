"""Source-derived Dense terminal logical-list counts; no subject inputs."""
from pathlib import Path
import json
for schema, sizes in [("motion", [256, 1024]), ("health", [64, 256, 1024])]:
 for count in sizes:
  samples = [{"kind":"seed","undo":count,"commands":count,"events":0}]
  samples += [{"kind":"query-loop","undo":2*count,"commands":0,"events":0} for _ in range(64)]
  Path(__file__).with_name(schema+str(count)+".stats.json").write_text(json.dumps({"samples":samples},separators=(",",":"))+"\n")
