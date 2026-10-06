#!/usr/bin/env python3
"""Check unchanged exact29 Bend access fixtures; not an emitted rejection claim."""
import argparse,json,hashlib,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});h=Path(__file__).resolve().parent;s=json.load(open(h/'source-build-pins.json'));sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for n,d in s['sources'].items():assert sha(Path(s['sourceRoot'])/n)==d
records=[]
for source in sorted((h/'source-access').glob('*.bend')):
 assert sha(source)==json.load(open(h/'source-access-pins.json'))[source.name]
 cmd=['bend',str(source),'--check-only'];r=subprocess.run(cmd,text=True,capture_output=True,timeout=5);expected=source.stem.startswith('positive');assert (r.returncode==0)==expected,(source,r.stdout,r.stderr);(a.output/(source.stem+'.txt')).write_text(r.stdout+r.stderr);records.append({'name':source.stem,'inputSHA256':sha(source),'command':cmd,'limitSeconds':5,'exit':r.returncode,'expected':'pass' if expected else 'reject','diagnostic':r.stdout+r.stderr})
(a.output/'evidence.json').write_text(json.dumps({'status':'TWO_POSITIVES_SIX_NEGATIVES_PASS','scope':'Fresh Bend checks against unchanged exact29 baseline; source capability checks only, not emitted JS rejection/refinement. Archived fixture bodies unchanged, import prefixes rebound.','cpu':[8],'records':records},indent=2)+'\n');print('SOURCE_TWO_POSITIVES_SIX_NEGATIVES_PASS')
