#!/usr/bin/env python3
"""Exact Health emitted-JS composition; unchanged stage guards, fresh outputs."""
import argparse, hashlib, json, os, subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args()
os.sched_setaffinity(0,{9});here=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
s=json.loads((here/'source-build-pins.json').read_text());root=Path(s['sourceRoot'])
for name,digest in s['manifestPins'].items():assert sha(root/name)==digest,name
m=json.loads((root/'overlay.json').read_text());c=json.loads((root/'cache-specialization.json').read_text())
assert c==m['cacheSpecialization'];assert m['sources']==s['sources']==c['runtimeClosure']==c['specializedClosure'];assert len(s['sources'])==29
assert hashlib.sha256(json.dumps(m['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==s['runtimeClosureSHA256']==c['runtimeClosureSHA256']
for name,digest in s['sources'].items():assert sha(root/name)==digest,name
for k in ['buildReceipt','entry']:assert sha(s[k+'Path'])==s[k+'SHA256'],k
for name,digest in s['entryCompanionPins'].items():assert sha(name)==digest,name
build=json.loads(Path(s['buildReceiptPath']).read_text())['commands'][0]
config=json.loads((here/'pipeline-pins.json').read_text());assert build['exit']==0 and build['sourceSHA256']==s['entrySHA256'] and build['outputSHA256']==config['inputSHA256']
for stage,digest in config['recipePins'].items():assert sha(here/stage/'rewrite.cjs')==digest,stage
for stage,digest in config['catalogPins'].items():assert sha(here/stage/'input-pins.json')==digest,stage
for name,digest in config['poolFactsPins'].items():assert sha(here/'pool'/name)==digest,name
assert json.loads((here/'pool/source-facts.json').read_text())['runtimeSourcePins']==s['sources']
inp=Path(config['input']);assert sha(inp)==config['inputSHA256']
a.output.mkdir(exist_ok=False);records=[]
for stage in config['recipePins']:
 out=a.output/(stage+'.js');cmd=['node','--expose-internals',str(here/stage/'rewrite.cjs'),str(inp),str(out)]
 if stage in ['world','boxed']:cmd.append('health')
 run=subprocess.run(cmd,capture_output=True,text=True,timeout=5);assert run.returncode==0,run.stderr
 assert sha(out)==config['outputPins'][stage],stage
 records.append({'stage':stage,'argv':cmd,'exit':run.returncode,'inputSHA256':sha(inp),'outputSHA256':sha(out),'receiptSHA256':sha(str(out)+'.recipe.json')});inp=out
(a.output/'evidence.json').write_text(json.dumps({'status':'HEALTH_FOUR_STAGES_GUARDS_PASS','sourcePins':s,'pipelineSHA256':sha(here/'pipeline-pins.json'),'stages':records},indent=2)+'\n')
print(inp)
