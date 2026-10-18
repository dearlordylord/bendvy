"""Sparse logical Tx terminals independently derived from source, no subject inputs."""
from pathlib import Path
import json
for schema in ["motion","health"]:
 for count in [64,256,1024]:
  selected=len([index for index in range(count) if index%8==0])
  samples=[{"kind":"seed","undo":count,"commands":count,"events":0}]
  samples += [{"kind":"query-loop","undo":2*selected,"commands":0,"events":0} for _ in range(64)]
  Path(__file__).with_name(schema+str(count)+".stats.json").write_text(json.dumps({"samples":samples},separators=(",",":"))+"\n")
