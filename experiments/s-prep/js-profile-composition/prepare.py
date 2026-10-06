#!/usr/bin/env python3
"""Materialize an explicitly pinned finite generated-JS composition; source unchanged."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});here=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
s=json.load(open(here/'source-build-pins.json'));root=Path(s['sourceRoot'])
for name,digest in s['manifestPins'].items():assert sha(root/name)==digest,name
m=json.load(open(root/'overlay.json'));c=json.load(open(root/'cache-specialization.json'));assert c==m['cacheSpecialization'];assert m['sources']==s['sources']==c['runtimeClosure']==c['specializedClosure'];assert hashlib.sha256(json.dumps(m['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==s['runtimeClosureSHA256']==c['runtimeClosureSHA256'];assert len(s['sources'])==29
for name,digest in s['sources'].items():assert sha(root/name)==digest,name
assert sha(s['buildReceiptPath'])==s['buildReceiptSHA256'];assert sha(s['entryPath'])==s['entrySHA256']
config=json.load(open(here/'pipeline-pins.json'));stages=list(config['recipePins'])
for stage,digest in config['recipePins'].items():assert sha(here/stage/'rewrite.cjs')==digest,stage
for stage,digest in config['catalogPins'].items():assert sha(here/stage/'input-pins.json')==digest,stage
for name,digest in config.get('poolFactsPins',{}).items():assert sha(here/'pool'/name)==digest,name
if 'pool' in stages:assert json.load(open(here/'pool/source-facts.json'))['runtimeSourcePins']==s['sources']
# All provenance checks precede creating outputs. Each stage independently verifies its AST guards.
a.output.mkdir(exist_ok=False);receipt={'scope':'Pinned emitted backend diagnostic only; no source/API/compiler change or universal proof','cpu':[8],'runtimeLimitSeconds':5,'sourcePins':s,'prepareRecipeSHA256':sha(Path(__file__)),'pipelinePinsSHA256':sha(here/'pipeline-pins.json'),'cases':[]}
for case in config['cases']:
 inp=Path(case['input']);assert sha(inp)==case['inputSHA256'];folder=a.output/case['label'];folder.mkdir();records=[]
 for stage in stages:
  out=folder/(stage+'.js');cmd=['node','--expose-internals',str(here/stage/'rewrite.cjs'),str(inp),str(out)]
  if stage in ['world','boxed']:cmd.append(case['schema'])
  if stage=='boxed' and case['mode']=='suppressed':cmd.append('--suppressed-main')
  run=subprocess.run(cmd,capture_output=True,text=True,timeout=5);assert run.returncode==0,run.stderr;assert sha(out)==case[stage+'SHA256'],stage
  records.append({'stage':stage,'argv':cmd,'exit':run.returncode,'inputSHA256':sha(inp),'outputSHA256':sha(out),'recipeSHA256':config['recipePins'][stage],'catalogSHA256':config['catalogPins'][stage],'receiptSHA256':sha(str(out)+'.recipe.json')});inp=out
 receipt['cases'].append({'label':case['label'],'schema':case['schema'],'inputSHA256':case['inputSHA256'],'output':str(inp),'outputSHA256':sha(inp),'stages':records})
receipt['status']='ALL_NINE_COMPOSED_INPUTS_GUARDS_PASS';(a.output/'evidence.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
