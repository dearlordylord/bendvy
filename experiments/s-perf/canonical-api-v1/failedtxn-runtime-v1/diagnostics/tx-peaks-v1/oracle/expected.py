"""FailedTxn actual warmup/measured seed terminal expectation from source."""
from pathlib import Path
import json
for schema in ["motion","health"]:
 for count in [64,256,1024]:
  samples=[{"kind":phase+"-seed","undo":count,"commands":count,"events":0} for phase in ["warmup","measured"]]
  Path(__file__).with_name(schema+str(count)+".stats.json").write_text(json.dumps({"samples":samples},separators=(",",":"))+"\n")
