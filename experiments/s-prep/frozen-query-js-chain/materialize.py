#!/usr/bin/env python3
"""Exact frozen-source join; unchanged recipes, explicit catalogs, no dead pass."""
import argparse,json,hashlib,subprocess,os
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});h=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();m=json.load(open(h/'pipeline-pins.json'));assert sha(h/'source-pins.json')==m['sourcePinsSHA256'];s=json.load(open(h/'source-pins.json'));root=Path(s['sourceRoot']);overlay=json.load(open(root/'overlay.json'));cache=json.load(open(root/'cache-specialization.json'));assert cache==overlay['cacheSpecialization'];assert s['sources']==overlay['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert len(s['sources'])==29;assert hashlib.sha256(json.dumps(s['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==cache['runtimeClosureSHA256']
for n,d in s['sources'].items():assert sha(root/n)==d
for n,d in s['manifestPins'].items():assert sha(root/n)==d
for pins in s['buildPins'].values():
 for n,d in pins.items():assert sha(n)==d
for n,d in s['upstreamSourceControlPins'].items():assert sha(n)==d
for n,d in m['factsPins'].items():assert sha(h/n)==d
assert json.load(open(h/'pool/source-facts.json'))['runtimeSourcePins']==s['sources']
for st in m['stages']:
 assert sha(h/st['stage']/'rewrite.cjs')==st['recipeSHA256'];assert sha(h/st['stage']/'input-pins.json')==st['catalogSHA256']
a.output.mkdir(exist_ok=False);current={};receipts=[]
for st in m['stages']:
 for c in st['cases']:
  inp=current.get(c['schema'],Path(c['input']));assert sha(inp)==c['inputSHA256'];out=a.output/(c['schema']+'-'+st['stage']+'.js');args=['node','--expose-internals',h/st['stage']/'rewrite.cjs',inp,out];args+=[c['schema']] if st['stage'] in ['world','boxed'] else [];v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr;assert sha(out)==c['outputSHA256'];current[c['schema']]=out;receipts.append({'stage':st['stage'],'schema':c['schema'],'outputSHA256':sha(out)})
for schema,out in current.items():
 v=subprocess.run(['node','--expose-internals',str(h/'zero-provider-sites.cjs'),str(out),str(a.output/(schema+'-zero-provider.json'))],capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr
(a.output/'evidence.json').write_text(json.dumps({'status':'FROZEN_SOURCE_TWO_SCHEMA_EIGHT_STAGE_REPRODUCED','cpu':[8],'runtimeLimitSeconds':5,'receipts':receipts},indent=2)+'\n');print('FROZEN_SOURCE_TWO_SCHEMA_EIGHT_STAGE_REPRODUCED')
