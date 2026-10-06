#!/usr/bin/env python3
"""Fail-closed pinned stage plus actual eight controller comparisons."""
import argparse,gzip,hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'cpu':9,'runtimeLimitSeconds':5,'commands':[],'cases':[]}
def run(cmd):
 code,text=supervisor.execute(list(map(str,cmd)),5);r['commands'].append({'argv':list(map(str,cmd)),'exit':code,'limitSeconds':5});assert code==0,text[-1000:];return text
for case in json.loads((here/'cases.json').read_text()):
 source=Path(case['input']);out=a.output/(case['label']+'.js');run(['node','--expose-internals',here/'rewrite.cjs',source,out]);receipt=json.loads(Path(str(out)+'.recipe.json').read_text());row=dict(case,inputSHA256=sha(source),outputSHA256=sha(out),recipe=receipt)
 if case['label'] not in ['baseline']:
  original=run(['node',source]);candidate=run(['node',out]);assert original==candidate,case['label'];assert len(candidate.splitlines())==72;protected=run(['node',case['originalJS']]);assert original==protected,case['label']+' actual original oracle'
  (a.output/(case['label']+'.jsonl.gz')).write_bytes(gzip.compress(candidate.encode(),mtime=0));row.update(status='ALL_72_CHECKPOINTS_BYTE_EQUAL',stdoutSHA256=hashlib.sha256(candidate.encode()).hexdigest())
 r['cases'].append(row)
r['status']='NINE_MATERIALIZATIONS_AND_EIGHT_ACTUAL_DIRECT_CONTROLLERS_576_CHECKPOINTS_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
