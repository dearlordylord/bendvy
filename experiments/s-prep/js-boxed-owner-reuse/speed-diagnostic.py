#!/usr/bin/env python3
"""One raw full65 comparison, not a canonical cohort or qualified metric."""
import argparse,hashlib,importlib.util,json,os,subprocess
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();commands=[]
def run(args):
 q=subprocess.run(list(map(str,args)),text=True,capture_output=True,timeout=5);commands.append({'argv':list(map(str,args)),'limitSeconds':5,'exit':q.returncode});assert q.returncode==0,q.stderr;return q.stdout
ref=a.output/'reference.mjs';run(['python3',ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema','Motion','--batch','64']);raw=run(['node',ref]);(a.output/'TS.raw.json').write_text(raw);ts=json.loads(raw);assert len(ts['samples'])==64
spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
r={'status':'INCOMPLETE','scope':'Single raw diagnostic on full65 fields; CPU affinity is not exclusivity, noise qualification/metric/keep/performance acceptance remain open; no canonical cohort or cap reset','cpu':[8],'batch':64,'entities':256,'ticks':64,'commands':commands,'roles':{'TS':{'rawBatchMilliseconds':ts['batchMilliseconds'],'referenceSHA256':sha(ref)}},'validatorSHA256':sha(Path(v.__file__))}
for role,source in [('baseline',Path('/tmp/bendvy-cache-box-js-build/baseline.js')),('candidate',a.candidate)]:
 raw=run(['node',source]);f=a.output/(role+'.raw.txt');f.write_text(raw);lines=raw.splitlines();clock=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];records=[x for x in lines if x.startswith('{')];assert len(records)==65 and len(clock)==1
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,'Motion',False,256,world);assert v.normalized(json.loads(line),'Motion')==world['final']
 r['roles'][role]={'rawBatchMilliseconds':int(clock[0].split(':',1)[1]),'sourceSHA256':sha(source),'rawSHA256':sha(f),'fullWorldsEqual':65}
r['status']='BASELINE_CANDIDATE_65_FULL_FIELDS_PASS_NO_QUALIFIED_METRIC';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['roles']))
