#!/usr/bin/env python3
"""Serial finite handoff controls; no timing comparison or inherited result."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--start');p.add_argument('--retained-only',action='store_true');p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent
subjects=[('one-raw',['--observer','raw']),('two',['--scenario','two']),('two-raw',['--scenario','two','--observer','raw']),('none',['--scenario','no-ledger']),('none-raw',['--scenario','no-ledger','--observer','raw']),('alias',['--scenario','two','--alias-main']),('alias-raw',['--scenario','two','--alias-main','--observer','raw']),('missing',['--scenario','missing']),('missing-raw',['--scenario','missing','--observer','raw']),('absent',['--selection','Absent']),('present',['--selection','Present']),('optional',['--selection','Optional']),('retained',['--retain-views']),('recovery',['--scenario','no-ledger','--force-recovery']),('recovery-raw',['--scenario','no-ledger','--force-recovery','--observer','raw']),('lost-owner',['--mutation','drop-detached']),('order',['--scenario','two','--mutation','reverse-order']),('pair-undo',['--mutation','drop-pair-undo']),('pending',['--pattern','main-only','--mutation','drop-pending']),('recovery-owner',['--scenario','no-ledger','--force-recovery','--mutation','drop-recovered'])]
if a.retained_only:subjects=[('retained-one',['--retain-views']),('retained-one-raw',['--retain-views','--observer','raw']),('retained-two',['--retain-views','--scenario','two']),('retained-two-raw',['--retain-views','--scenario','two','--observer','raw'])]
if a.start:
 names=[x[0] for x in subjects];assert a.start in names;subjects=subjects[names.index(a.start):]
r={'status':'INCOMPLETE','scope':'Fresh serial literal pre/post observations and actual compiling mutations, no speed acceptance','subjects':[]}
for name,args in subjects:
 folder=a.output/name;argv=[sys.executable,str(here/'run.py'),'--overlay',str(a.overlay),'--output',str(folder),*args];done=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True);(a.output/(name+'.log')).write_text(done.stdout)
 evidence=json.loads((folder/'evidence.json').read_text());r['subjects'].append({'name':name,'argv':argv,'exit':done.returncode,'status':evidence['status'],'evidencePath':str(folder/'evidence.json'),'evidenceSHA256':hashlib.sha256((folder/'evidence.json').read_bytes()).hexdigest()});(a.output/'matrix.json').write_text(json.dumps(r,indent=2)+'\n');print(name,done.returncode,evidence['status'],flush=True)
 if done.returncode:sys.exit(1)
r['subjectCount']=len(subjects);r['status']='FRESH_HANDOFF_FINITE_MATRIX_BOTH_SCHEMAS_BACKENDS_PASS';(a.output/'matrix.json').write_text(json.dumps(r,indent=2)+'\n')
