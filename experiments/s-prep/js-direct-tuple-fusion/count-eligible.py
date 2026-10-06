#!/usr/bin/env python3
import argparse,json,pathlib,os,sys,hashlib,importlib.util
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],default='Health');p.add_argument('--profile',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});r={'status':'INCOMPLETE','commands':[]}
def run(argv,cap=5):
 code,out=execute(list(map(str,argv)),cap);r['commands'].append({'argv':list(map(str,argv)),'exit':code,'capSeconds':cap});assert code==0,out[-2000:];return out
try:
 source=a.profile/'bend.js';report=a.output/'analysis.json';counted=a.output/'counted.js'
 run(['node','--expose-internals',HERE/'analyze.cjs',source,report]);run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',source,counted]);text=run(['node',counted]);(a.output/'counted.txt').write_text(text)
 ast=json.loads(report.read_text());sites=json.loads(pathlib.Path(str(counted)+'.sites.json').read_text())['sites'];counts=json.loads(next(x.split(':',1)[1] for x in text.splitlines() if x.startswith('ALLOCATION-COUNTS:')));assert len(counts)==len(sites)
 active=[]
 for x in ast['eligibleSites']:
  index=x['literalOrdinal'];site=sites[index];assert site['kind']=='object:Tuple' and site['line']==x['line'] and site['function']==x['caller'];active.append({**x,'executions':counts[index]})
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);ts=json.loads((a.profile/'TS.observed.txt').read_text());worlds=[x for x in text.splitlines() if x.startswith('{')];assert len(worlds)==9
 for line,world in zip(worlds,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
 r.update(status='ELIGIBLE_EXECUTED_HEALTH_NINE_FULL_FIELDS_PASS',ordinaryConstructors=sum(counts)-1,eligibleExecuted=sum(x['executions'] for x in active),activeEligibleSites=sum(x['executions']>0 for x in active),sites=active,sourceSHA256=hashlib.sha256(source.read_bytes()).hexdigest(),countsSHA256=hashlib.sha256((a.output/'counted.txt').read_bytes()).hexdigest())
except Exception as error:r.update(status='FAILED',error=repr(error))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r.get(k) for k in ['status','eligibleExecuted','activeEligibleSites','error']}));sys.exit(0 if r['status']=='ELIGIBLE_EXECUTED_HEALTH_NINE_FULL_FIELDS_PASS' else 1)
