#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,subprocess,os,signal
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');F=Path('/tmp/bendvy-followup-selective-frozen-v1');p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();freeze=json.loads((F/'freeze.json').read_text());assert all(sha(F/n)==h for n,h in freeze.items());assert all(sha(H/'recipe'/Path(n).name)==h for n,h in freeze.items() if n.startswith('recipe/'))
r={'status':'INCOMPLETE','scope':'Independent finite selective seven-store review on b0 source only; no4baa, timing, compiler adoption or universal alias proof','freeze':freeze,'freezeSHA256':sha(F/'freeze.json'),'reviewRecipeSHA256':sha(Path(__file__)),'commands':[],'schemas':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 argv=list(map(str,argv));x=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:o=x.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);o=x.communicate()[0];(a.output/(label+'.txt')).write_text(o);r['commands'].append({'argv':argv,'limit':limit,'status':'TIMEOUT'});save();raise
 f=a.output/(label+'.txt');f.write_text(o);r['commands'].append({'argv':argv,'limit':limit,'exit':x.returncode,'outputSHA256':sha(f)});save();assert x.returncode==0,o[-2000:];return o
try:
 cat=json.loads((H/'recipe/input-pins.json').read_text())
 for schema in ['motion','health']:
  pin=next(v for v in cat.values() if v['label']==schema);inp=Path(pin['inputPath']);out=a.output/(schema+'.js');run(['node','--expose-internals',H/'recipe/rewrite.cjs',inp,out],5,schema+'-derive');assert sha(out)==freeze[schema+'.js'];recipe=json.loads(Path(str(out)+'.recipe.json').read_text());assert recipe['stableFields']==['namespace','next','aux','capacity','depth','high','pending','mode','commands','pings'] and recipe['stores']==7
  run(['python3',ROOT/'experiments/s-prep/js-descending-cursor-transport/validate-full65.py','--cpu','9','--kind','js','--schema',schema.title(),'--program',out,'--output',a.output/(schema+'-full65')],20,schema+'-full65')
  run(['node','--expose-internals',H/'recipe/guard-controls.cjs',inp,out,a.output/(schema+'-guards')],90,schema+'-guards');r['schemas'].append({'schema':schema,'candidateSHA256':sha(out),'certificate':recipe['transport'],'full65':json.loads((a.output/(schema+'-full65/evidence.json')).read_text())['status']});save()
 run(['python3',H/'recipe/controls.py','--output',a.output/'controllers'],120,'controllers');assert json.loads((a.output/'controllers/evidence.json').read_text())['records']==576
 run(['python3',H/'recipe/witness-run.py','--output',a.output/'helper-witness'],90,'helper-witness');assert json.loads((a.output/'helper-witness/evidence.json').read_text())['status']=='BOTH_SCHEMAS_130_FOLD_FULLSHAPE_SNAPSHOT_TRUEOLD_FALLBACK_EXCEPTION_RECORDS_PASS'
 r['status']='INDEPENDENT_BOTH65_HELPER130_TX576_AND32_GUARD_REFUSALS_PASS'
except Exception as e:r.update(status='FAIL_OR_LIMIT',error=repr(e));raise
finally:save()
