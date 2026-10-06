#!/usr/bin/env python3
"""Frozen-source final mark join, exact unchanged recipe and fresh input pins."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});here=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
c=json.loads((here/'pipeline-pins.json').read_text())
for file,key in [('rewrite.cjs','recipeSHA256'),('template-pins.json','templateSHA256'),('input-pins.json','catalogSHA256'),('source-pins.json','sourcePinsSHA256')]:assert sha(here/file)==c[key],file
s=json.loads((here/'source-pins.json').read_text());root=Path(s['sourceRoot'])
for name,digest in s['manifestPins'].items():assert sha(root/name)==digest,name
for name,digest in s['sources'].items():assert sha(root/name)==digest,name
assert len(s['sources'])==29
m=json.loads((root/'overlay.json').read_text());cache=json.loads((root/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'];assert s['sources']==m['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert hashlib.sha256(json.dumps(m['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==cache['runtimeClosureSHA256']
for pins in s['buildPins'].values():
 for name,digest in pins.items():assert sha(name)==digest,name
for name,digest in c['upstreamChainPins'].items():assert sha(name)==digest,name
for case in c['cases']:assert sha(case['input'])==case['inputSHA256']
a.output.mkdir(exist_ok=False);records=[]
for case in c['cases']:
 out=a.output/(case['schema']+'.js');cmd=['node','--expose-internals',str(here/'rewrite.cjs'),case['input'],str(out)];code,text=supervisor.execute(cmd,5);assert code==0,text[-1000:];assert sha(out)==case['outputSHA256'];records.append(dict(case,output=str(out),argv=cmd,receiptSHA256=sha(str(out)+'.recipe.json')))
(a.output/'evidence.json').write_text(json.dumps({'status':'FROZEN_SOURCE_BOTH_MARK_JOIN_GUARDS_PASS','sourcePins':s,'cases':records,'newSourceTxAndMutations':'OPEN, no old-source gate transfer'},indent=2)+'\n');print('FROZEN_SOURCE_BOTH_MARK_JOIN_GUARDS_PASS')
