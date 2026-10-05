#!/usr/bin/env python3
"""Actual original Tx/cache getter coherence, finite controls, not timing."""
import argparse,hashlib,importlib.util,json,os,re,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('build',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
sp=importlib.util.spec_from_file_location('independent',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');I=importlib.util.module_from_spec(sp);sp.loader.exec_module(I)
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--mutation',choices=['stale-head','torn-tail','lost-mark','inverse-order']);p.add_argument('--cpu',type=int,default=9);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu});h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();result={'status':'INCOMPLETE','scope':'Actual cached World point-Tx original callback success/failure; finite held/cache fields, no general API/performance acceptance','cases':[]}
 try:
  manifest=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert all(h(a.overlay/n)==v for n,v in manifest.items());result['overlaySHA256']=h(a.overlay/'overlay.json');result['fixtureSHA256']=h(HERE/'tx-controls.bend')
  records=[]
  for mode in ('cached','raw'):
   folder=a.output/mode;folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);source=core/'cache-tx-controls.bend'
   full=(core/'measurement-bend.bend').read_text();definitions={match.group(1):match.group(0) for match in re.finditer(r'^def ([\w.]+)\([^\n]*\n(?:(?!^(?:def |type |import |#)).*\n)*',full,re.M)};pins=json.loads((ROOT/'experiments/s-prep/owned-write-query-integration/prepare-evidence.json').read_text())['callbackFunctionSHA256'];assert all(hashlib.sha256(definitions[n].encode()).hexdigest()==v for n,v in pins.items()),'Original callback bytes changed';(core/'gate-callbacks.bend').write_text('import Base\nimport ./types.bend as T\n'+''.join(definitions[n] for n in ['first','sum','motion_body_ledger','motion_body_read','motion_body','health_body_ledger','health_body_read','health_body']));result['callbackDefinitionPins']=pins
   if a.mutation:
    mutations={'stale-head':('cached-payload.bend','T.Four{value,b,c,d},frame','T.Four{U32.add(value,1),b,c,d},frame'),'torn-tail':('cached-payload.bend','T.Four{value,b,c,d},frame','T.Four{value,b,c,U32.add(d,1)},frame'),'lost-mark':('held.bend','handle <> marks','marks'),'inverse-order':('held.bend','X.MainInverse{handle,old} <> undo','List.append(&2,X.Inverse<H>,undo,[X.MainInverse{handle,old}])')}
    file,before,after=mutations[a.mutation];target=core/file;original=target.read_text();assert original.count(before)==1,(a.mutation,original.count(before));target.write_text(original.replace(before,after))
   text=(HERE/'tx-controls.bend').read_text().replace('import ./measurement-bend.bend as M','import ./gate-callbacks.bend as M')
   if mode=='raw':
    # Only observation getters change; authored callback providers remain untouched.
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
