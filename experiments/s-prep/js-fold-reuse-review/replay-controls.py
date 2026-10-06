#!/usr/bin/env python3
"""Run pinned authored controls on independent CPU8; only harness paths/CPU differ."""
import argparse,pathlib,hashlib,json,subprocess
p=argparse.ArgumentParser();p.add_argument('--recipe',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir();src=(a.recipe/'controls.py').read_text();s=src
for before,after in [('H=Path(__file__).resolve().parent','H=Path('+repr(str(a.recipe.resolve()))+')'),('os.sched_setaffinity(0,{7})','os.sched_setaffinity(0,{8})'),("'cpu':7","'cpu':8")]:
 assert s.count(before)==1;s=s.replace(before,after)
runner=a.output/'runner.py';runner.write_text(s);cmd=['python3',str(runner),'--output',str(a.output/'controls')];v=subprocess.run(cmd,capture_output=True,text=True,timeout=60);(a.output/'run.txt').write_text(v.stdout+v.stderr);r={'originalRunnerSHA256':hashlib.sha256(src.encode()).hexdigest(),'localRunnerSHA256':hashlib.sha256(s.encode()).hexdigest(),'changes':'Only recipe location, affinity CPU7 to8, matching receipt CPU field; controller/candidate/oracle bodies unchanged','command':cmd,'exit':v.returncode,'controlsReceiptSHA256':hashlib.sha256((a.output/'controls/evidence.json').read_bytes()).hexdigest()};(a.output/'adaptation.json').write_text(json.dumps(r,indent=2)+'\n');assert v.returncode==0,v.stdout+v.stderr
