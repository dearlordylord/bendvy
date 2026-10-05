#!/usr/bin/env python3
"""Actual original Tx/cache getter coherence, finite controls, not timing."""
import argparse,hashlib,importlib.util,json,os,re,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent;GATE=HERE.parent/'fivehour-connected-gates'
sp=importlib.util.spec_from_file_location('build',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
sp=importlib.util.spec_from_file_location('independent',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');I=importlib.util.module_from_spec(sp);sp.loader.exec_module(I)
def h_bytes(data):return hashlib.sha256(data).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--mutation',choices=['stale-head','torn-tail','lost-mark','inverse-order']);p.add_argument('--cpu',type=int,default=9);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu});h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();result={'status':'INCOMPLETE','scope':'Actual cached World point-Tx original callback success/failure; finite held/cache fields, no general API/performance acceptance','cases':[]}
 try:
  manifest=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert all(h(a.overlay/n)==v for n,v in manifest.items());result['overlaySHA256']=h(a.overlay/'overlay.json');result['fixtureSHA256']=h(GATE/'tx-controls.bend')
  records=[]
  for mode in ('cached','raw'):
   folder=a.output/mode;folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);source=core/'cache-tx-controls.bend'
   if a.mutation:
    mutations={'stale-head':('cached-payload.bend','T.Four{value,b,c,d},frame','T.Four{U32.add(value,1),b,c,d},frame'),'torn-tail':('cached-payload.bend','T.Four{value,b,c,d},frame','T.Four{value,b,c,U32.add(d,1)},frame'),'lost-mark':('held.bend','handle <> marks','marks'),'inverse-order':('held.bend','X.MainInverse{handle,old} <> undo','List.append(&2,X.Inverse<H>,undo,[X.MainInverse{handle,old}])')}
    file,before,after=mutations[a.mutation];target=core/file;original=target.read_text();assert original.count(before)==1,(a.mutation,original.count(before));target.write_text(original.replace(before,after))
   text=(GATE/'tx-controls.bend').read_text()
   callbacks=(core/'measurement-bend.bend').read_text();chunks=[];callbackPins={}
   for name in ('first','sum','motion_body_ledger','motion_body_read','motion_body','health_body_ledger','health_body_read','health_body'):
    match=re.search('^def '+name+r'\(',callbacks,re.M);end=min(x for x in [callbacks.find('\ndef ',match.start()+1),callbacks.find('\ntype ',match.start()+1),len(callbacks)] if x>=0);chunk=callbacks[match.start():end].rstrip()+'\n';chunks.append(chunk);callbackPins[name]=h_bytes(chunk.encode())
   expected=json.loads((a.overlay/'cache-specialization.json').read_text())['callbackPins']
   assert all(callbackPins[name]==digest for name,digest in expected.items()),'Original callback bytes changed'
   (core/'control-callbacks.bend').write_text('import Base\nimport ./types.bend as T\n\n'+'\n'.join(chunks))
   text=text.replace('import ./measurement-bend.bend as M','import ./control-callbacks.bend as M');result['controlCallbackPins']=callbackPins
   if mode=='raw':
    # Only observation getters change; authored callback providers remain untouched.
    provider=core/'cached-payload.bend';provider_text=provider.read_text()
    provider_text=provider_text.replace('import Base\n','import Base\nimport ./payload.bend as ORIGINAL\n',1)
    original_bindings={}
    for name in ('position','vitals','motion_ledger','health_ledger'):
     match=re.search(r'^def '+name+r'_uncached\(',provider_text,re.M);end=provider_text.find('\ndef ',match.start()+1);end=end if end>=0 else len(provider_text);chunk=provider_text[match.start():end]
     assert chunk.count('P.'+name+'_get')==1
     changed=chunk.replace('P.'+name+'_get','ORIGINAL.'+name+'_get');provider_text=provider_text[:match.start()]+changed+provider_text[end:];original_bindings[name]=h_bytes(changed.encode())
    provider.write_text(provider_text);result['originalRawObservation']={'payloadSHA256':h(core/'payload.bend'),'bindings':original_bindings,'scope':'Control-only observers preserve cached view and return affine raw owner; Native optimized getter is not the oracle'}
    for name in ('position','vitals','motion_ledger','health_ledger'):text=text.replace('P.'+name+'_get','P.'+name+'_uncached')
   source.write_text(text);outputs=[]
   for program in B.build(source,folder):
    raw=B.execute(program);out=folder/(program.name+'.jsonl');out.write_text(raw+'\n');lines=[json.loads(line) for line in raw.splitlines()];assert len(lines)==144,len(lines);outputs.append(lines)
    if not a.mutation:
     I.independent(lines)
     assert not I.differences(lines),'Original point Tx versus held Tx mismatch'
     for block in range(36):assert lines[block*4]['value']==(46 if block//4==0 else 3606 if block//4==8 else 4294967295)
    result['cases'].append({'getter':mode,'backend':'JS' if program.suffix=='.js' else 'Native','status':'COMPILED_RUNTIME_OBSERVED' if a.mutation else 'FULL_TX_FIELDS_PASS','programSHA256':h(program),'rawSHA256':h(out),'records':144})
   assert outputs[0]==outputs[1];records.append(outputs[0])
  if a.mutation:
   detected=records[0]!=records[1] or bool(I.differences(records[0]))
   try:I.independent(records[0])
   except AssertionError:detected=True
   assert detected,'Compiling runtime mutant survived'
   witness=next(({'record':i,'cached':x,'raw':y} for i,(x,y) in enumerate(zip(records[0],records[1])) if x!=y),None)
   if witness is None:witness=I.differences(records[0])[:1]
   result.update(status='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE',mutation=a.mutation,witness=witness)
   return
  assert records[0]==records[1],'Raw owner differs from cached observation after actual Tx boundary'
  assert all(h(a.overlay/n)==v for n,v in manifest.items())
  result['status']='FINITE_ACTUAL_TX_CACHE_FIELDS_PASS'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
