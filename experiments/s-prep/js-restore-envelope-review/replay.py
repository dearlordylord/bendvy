#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,subprocess,os,signal
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');F=Path('/tmp/bendvy-restore-envelope-frozen-v1');p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();freeze=json.loads((F/'freeze.json').read_text());assert all(sha(F/n)==h for n,h in freeze.items());assert all(sha(H/'recipe'/Path(n).name)==h for n,h in freeze.items() if n.startswith('recipe/'));r={'status':'INCOMPLETE','scope':'Independent four-envelope emitted-JS finite review on exactb0; no timing/adoption/4baa/universal alias claim','freeze':freeze,'freezeSHA256':sha(F/'freeze.json'),'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 argv=list(map(str,argv));x=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:o=x.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);o=x.communicate()[0];(a.output/(label+'.txt')).write_text(o);r['commands'].append({'argv':argv,'limit':limit,'status':'TIMEOUT'});save();raise
 f=a.output/(label+'.txt');f.write_text(o);r['commands'].append({'argv':argv,'limit':limit,'exit':x.returncode,'outputSHA256':sha(f)});save();assert x.returncode==0,o[-2000:];return o
try:
 cat=json.loads((H/'recipe/input-pins.json').read_text())
 for schema in ['motion','health']:
  pin=next(v for v in cat.values() if v['label']==schema);inp=Path(pin['inputPath']);out=a.output/(schema+'.js');run(['node','--expose-internals',H/'recipe/rewrite.cjs',inp,out],5,schema+'-derive');assert sha(out)==freeze[schema+'.js'];run(['python3',ROOT/'experiments/s-prep/js-descending-cursor-transport/validate-full65.py','--cpu','9','--kind','js','--schema',schema.title(),'--program',out,'--output',a.output/(schema+'-full65')],20,schema+'-full65');run(['node','--expose-internals',H/'recipe/guard-controls.cjs',inp,out,a.output/(schema+'-guards')],120,schema+'-guards');assert len(json.loads((a.output/(schema+'-guards/evidence.json')).read_text())['refusals'])==16
 for script,folder,cap in [('controls.py','controllers',150),('witness-run.py','helper-witness',90),('exception-run.py','exceptions',90),('mutants.py','mutants',120)]:run(['python3',H/'recipe'/script,'--output',a.output/folder],cap,folder)
 controllers=json.loads((a.output/'controllers/evidence.json').read_text());assert controllers['records']==576 and len(controllers['controllers'])==8;assert all(c['actualRouteCounts']=={'ingress':18,'terminal':4} for c in controllers['controllers']);w=json.loads((a.output/'helper-witness/evidence.json').read_text());assert w['actualRouteCounts']=={'motion':{'ingress':64,'terminal':9},'health':{'ingress':64,'terminal':9}}
 exceptions=json.loads((a.output/'exceptions/evidence.json').read_text());assert exceptions['status']=='BOTH_SCHEMAS_CONSTRUCTOR_PUBLICATION_FLUSH_BOUNDARY_RECORDS_PASS';assert sum(c['records'] for c in exceptions['cases'] if c['role']=='candidate')==31
 for schema in ['motion','health']:
  route=json.loads((a.output/('exceptions/'+schema+'-candidate.js.route.json')).read_text());assert route['candidate'] and route['inputCandidate'] and route['selectedReturned']=='__restore_envelope_4' and route['requiredRuntimeInvocationsPerStage']==1 and 'flush-inside' in route['stages']
 mutants=json.loads((a.output/'mutants/evidence.json').read_text());assert mutants['status']=='SIX_COMPILING_OMISSION_AND_EARLY_LEDGER_COUNTEREXAMPLES_DETECTED';assert len([x for x in mutants['mutants'] if x['label']=='early-ledger' and x['observedExit']==1])==2
 r['status']='INDEPENDENT_BOTH65_HELPER130_TX576_EXCEPTION31_GUARDS32_AND_SIX_MUTANTS_PASS'
except Exception as e:r.update(status='FAIL_OR_LIMIT',error=repr(e));raise
finally:save()
