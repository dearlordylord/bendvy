from pathlib import Path
import json,shutil,hashlib
D=Path(__file__).resolve().parent;R=D.parents[2];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for role in ['baseline','candidate']:
 old=D/'stages'/role;target=D/'protocol-stages'/role;assert not target.exists();shutil.copytree(old,target,symlinks=True);p=target/'stage.json';s=json.loads(p.read_text())
 for source in [D/'complete.py',Path(__file__).resolve()]:s['sources'][str(source.relative_to(R))]=sha(source)
 s['status']='COMBINED_1_2_4_SEMANTICS_TIMING_PROTOCOL_PREPARED_ONLY';p.write_text(json.dumps(s,indent=2)+'\n')
