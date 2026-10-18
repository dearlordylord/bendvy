from pathlib import Path
import hashlib,json,subprocess,sys
b=Path(__file__).parent;d=json.loads((b/"INDEX.json").read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for e in d["epochs"]:
 for key in ["manifest","verifier","verification"]:assert sha(b/e[key])==e[key+"SHA256"]
 r=json.loads((b/e["verification"]).read_text());assert r["exitCode"]==0
 subprocess.run([sys.executable,str(b/e["verifier"]),str((b/e["manifest"]).parent)],check=True)
print("PASS two source epochs;",sha(b/"INDEX.json"))
