#!/usr/bin/env python3
"""Verified source/build receipts, exact intermediates and unchanged swap recipe."""
import argparse,json,hashlib,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});h=Path(__file__).resolve().parent;m=json.load(open(h/'pipeline-pins.json'));sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for name,d in m['provenancePins'].items():
 assert sha(h/'provenance'/name)==d;v=json.load(open(h/'provenance'/name));root=Path(v['sourceRoot']);overlay=json.load(open(root/'overlay.json'));cache=json.load(open(root/'cache-specialization.json'));assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==v['sources'];assert hashlib.sha256(json.dumps(v['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==v['runtimeClosureSHA256']==cache['runtimeClosureSHA256'];assert len(v['sources'])==29
 for n,sourceDigest in v['sources'].items():assert sha(root/n)==sourceDigest
 for n,manifestDigest in v['manifestPins'].items():assert sha(root/n)==manifestDigest
 assert sha(v['buildReceiptPath'])==v['buildReceiptSHA256'];assert sha(v['entryPath'])==v['entrySHA256']
 for n,entryDigest in v.get('entryCompanionPins',{}).items():assert sha(n)==entryDigest
for stage,d in m['recipePins'].items():assert sha(h/stage/'rewrite.cjs')==d
for stage,d in m['catalogPins'].items():assert sha(h/stage/'input-pins.json')==d
a.output.mkdir(exist_ok=False);r={'scope':m['scope'],'cpu':[8],'runtimeLimitSeconds':5,'pipelineSHA256':sha(h/'pipeline-pins.json'),'materializeSHA256':sha(Path(__file__)),'cases':[]}
def run(cmd):
 v=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr
for c in m['cases']:
 inp=Path(c['input']);assert sha(inp)==c['inputSHA256'];dead=a.output/(c['label']+'-dead.js');run(['node','--expose-internals',h/'dead-provider/rewrite.cjs',inp,dead]);assert sha(dead)==c['deadSHA256'];final=a.output/(c['label']+'.js');run(['node','--expose-internals',h/'payload/rewrite.cjs',dead,final]);assert sha(final)==c['outputSHA256'];r['cases'].append({'label':c['label'],'schema':c['schema'],'inputSHA256':sha(inp),'deadSHA256':sha(dead),'deadReceiptSHA256':sha(str(dead)+'.recipe.json'),'output':str(final),'outputSHA256':sha(final),'payloadReceiptSHA256':sha(str(final)+'.recipe.json')})
r['status']='TEN_FINAL_PINNED_CHAIN_OUTPUTS_REPRODUCED';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
