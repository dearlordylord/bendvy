"""Finite Lifecycle actual terminal list-count model, sealed before subject."""
from pathlib import Path
import json
for schema in ["motion","health"]:
 for count in [64,256,1024]:
  samples=[{"kind":"main-seed","undo":count,"commands":count,"events":0},{"kind":"foreign-seed","undo":1,"commands":1,"events":0}]
  samples += [{"kind":"reserve","undo":1,"commands":1,"events":0} for _ in range(64)]
  samples += [{"kind":"dispose","undo":0,"commands":2,"events":0} for _ in range(64)]
  Path(__file__).with_name(schema+str(count)+".stats.json").write_text(json.dumps({"samples":samples},separators=(",",":"))+"\n")
