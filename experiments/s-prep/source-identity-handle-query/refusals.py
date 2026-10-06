#!/usr/bin/env python3
"""Finite fail-closed materializer controls; no source/compiler edits."""
import argparse,json,pathlib,shutil,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
here=pathlib.Path(__file__).resolve().parent;base=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-v1');cases=[]
for name in ['existing-output','changed-source','stale-embedded-cache','stale-specialized-hash']:
 source=base;destination=a.output/(name+'-result')
 if name=='existing-output':destination.mkdir()
 else:
  source=a.output/(name+'-input');shutil.copytree(base,source)
  if name=='changed-source':
   q=source/'experiments/s-integrate/query.bend';q.write_text(q.read_text()+'\n# changed pin\n')
  else:
   overlay=json.loads((source/'overlay.json').read_text());cache=json.loads((source/'cache-specialization.json').read_text())
   if name=='stale-embedded-cache':overlay['cacheSpecialization']['runtimeClosureSHA256']='0'*64
   else:cache['specializedClosureSHA256']='0'*64;overlay['cacheSpecialization']=cache
   (source/'overlay.json').write_text(json.dumps(overlay));(source/'cache-specialization.json').write_text(json.dumps(cache))
 argv=[sys.executable,str(here/'materialize.py'),'--input',str(source),'--output',str(destination)]
 r=subprocess.run(argv,text=True,capture_output=True,timeout=5);assert r.returncode!=0
 assert name=='existing-output' or not destination.exists()
 cases.append({'name':name,'argv':argv,'capSeconds':5,'exit':r.returncode,'output':r.stdout+r.stderr,'refusedBeforeOutputCreation':name=='existing-output' or not destination.exists()})
(a.output/'evidence.json').write_text(json.dumps({'status':'FOUR_FAIL_CLOSED_REFUSALS_PASS','cases':cases},indent=2)+'\n')
print('FOUR_FAIL_CLOSED_REFUSALS_PASS')
