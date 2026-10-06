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
for stage,d in m['recipePins'].items():assert sha(h/('rewrite.cjs' if stage=='read' else stage+'/rewrite.cjs'))==d
for stage,d in m['catalogPins'].items():assert sha(h/('input-pins.json' if stage=='read' else stage+'/input-pins.json'))==d
a.output.mkdir(exist_ok=False);r={'scope':m['scope'],'cpu':[8],'runtimeLimitSeconds':5,'pipelineSHA256':sha(h/'pipeline-pins.json'),'materializeSHA256':sha(Path(__file__)),'cases':[]}
def run(cmd):
 v=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr
for c in m['cases']:
 folder=a.output/c['label'];folder.mkdir();inp=Path(c['inputPath'])
 if c['label']=='baseline-health':
  hp=json.load(open(h/'health-store/input-pins.json'));d,v=next(iter(hp.items()));assert sha(v['inputPath'])==d;inp=folder/'store-prerequisite.js';run(['node','--expose-internals',h/'health-store/rewrite.cjs',v['inputPath'],inp])
 assert sha(inp)==c['inputSHA256'];read=folder/'read.js';run(['node','--expose-internals',h/'rewrite.cjs',inp,read]);assert sha(read)==c['readSHA256'];swap=folder/'swap.js';run(['node','--expose-internals',h/'swap-last/rewrite.cjs',read,swap]);assert sha(swap)==c['swapSHA256'];r['cases'].append({'label':c['label'],'schema':c['schema'],'inputSHA256':sha(inp),'readOutput':str(read),'readSHA256':sha(read),'readReceiptSHA256':sha(str(read)+'.recipe.json'),'swapOutput':str(swap),'swapSHA256':sha(swap),'swapReceiptSHA256':sha(str(swap)+'.recipe.json')})
r['status']='TEN_PINNED_READ_SWAP_OUTPUTS_REPRODUCED';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
