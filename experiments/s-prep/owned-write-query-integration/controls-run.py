#!/usr/bin/env python3
"""Actual checked opening/rejoin/fallback and original Tx boundary controls."""
import argparse,hashlib,importlib.util,json,os,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('bounded',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def differences(lines):
 result=[]
 for block in range(36):
  start=block*4
  for phase in range(2):
   if lines[start+phase]!=lines[start+2+phase]:result.append({'block':block,'scenario':block//4,'schema':'Motion' if block%4<2 else 'Health','failure':bool(block%2),'phase':'pre' if phase==0 else 'post','expected':lines[start+phase],'actual':lines[start+2+phase]})
 return result
def independent(lines):
 for block in range(36):
  scenario=block//4;pre,post=lines[block*4:block*4+2];fail=bool(block%2)
  expected='L:100;M7/'+('1' if scenario==0 else '2')+':'+('10' if scenario==0 else '900')+';L:77;' if scenario in (0,8) else 'M7/1:10;L:77;' if scenario==5 else 'L:77;'
  assert pre['undo']==expected
  marks=[{'namespace':7,'id':2}]
  if scenario in (0,5):marks=[{'namespace':7,'id':1}]+marks
  if scenario==8:marks=[{'namespace':7,'id':2}]+marks
  assert pre['marks']==marks
  assert pre['commands']==[{'kind':'RemoveFlagView','id':1},{'kind':'DespawnView','id':2}]
  assert pre['pings']==[12,11] and post['pings']==([] if fail else [11,12])
  ledger=post['world']['ledger'];assert (ledger is None if scenario==5 else ledger['totals']['a']==(77 if fail else 101 if scenario in (0,8) else 100))
  assert post['world']['pending']==([] if fail else [{'kind':'DespawnView','id':2},{'kind':'RemoveFlagView','id':1}])
  first=post['world']['rows'][0];main=first['main'];field='coordinates' if block%4<2 else 'levels'
  assert (main is None if scenario==4 else main[field]['a']==(11 if not fail and scenario in (0,5) else 10))
  assert first['changed']==(9 if not fail and scenario in (0,5) else 4)
  if scenario==8:
   second=post['world']['rows'][1];assert second['main'][field]['a']==(900 if fail else 901);assert second['changed']==(6 if fail else 9)
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--output-dir',required=True,type=Path);p.add_argument('--cpu',type=int,default=9);p.add_argument('--only',choices=['baseline','wrong-restoration-slot','foreign-bypass','lost-write-mark','inverse-order']);a=p.parse_args();os.sched_setaffinity(0,{a.cpu});a.output_dir.mkdir(parents=True,exist_ok=False)
 result={'status':'INCOMPLETE','scope':'Finite checked binding/fallback/rejoin and actual Tx success/failure; no performance/API acceptance','limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'controlSourceSHA256':h(HERE/'controls.bend'),'cases':[],'mutants':[]}
 variants=[('baseline',None,None,None),('wrong-restoration-slot','held-adapter.bend','U32.sub(id,1),Some{main}','0,Some{main}'),('foreign-bypass','held-adapter.bend','U32.is_eq(namespace,foreign)','True{}'),('lost-write-mark','held.bend','handle <> marks','marks'),('inverse-order','held.bend','X.MainInverse{handle,old} <> undo','List.append(&2,X.Inverse<H>,undo,[X.MainInverse{handle,old}])')]
 try:
  for name,file,before,after in variants:
   if a.only and a.only!=name:continue
   folder=a.output_dir/name;folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);source=core/'held-integration-controls.bend';source.write_bytes((HERE/'controls.bend').read_bytes())
   if file:
    target=core/file;text=target.read_text();assert text.count(before)==(1 if file=='held.bend' else 2),(name,text.count(before));target.write_text(text.replace(before,after,1))
   outputs=[];artifacts=[]
   for program in B.build(source,folder):
    raw=B.execute(program);(folder/(program.name+'.observed.jsonl')).write_text(raw+'\n');lines=[json.loads(line) for line in raw.splitlines()];assert len(lines)==144,len(lines);outputs.append(lines);artifacts.append({'backend':'JS' if program.suffix=='.js' else 'Native','SHA256':h(program),'outputSHA256':hashlib.sha256((raw+'\n').encode()).hexdigest()})
   assert outputs[0]==outputs[1],name;d= differences(outputs[0]);entry={'name':name,'artifacts':artifacts,'differences':len(d)}
   if name=='baseline':
    assert not d,d[:1];independent(outputs[0])
    for block in range(36):
     scenario=block//4;pre,post=outputs[0][block*4:block*4+2];failure=bool(block%2);expectedvalue=46 if scenario==0 else 3606 if scenario==8 else 4294967295;assert pre['value']==expectedvalue,(block,pre['value']);assert post['pings']==([] if failure else [11,12])
     if scenario in (0,8):assert pre['undo']=='L:100;M7/'+('1' if scenario==0 else '2')+':'+('10' if scenario==0 else '900')+';L:77;',pre
     elif scenario==5:assert pre['undo']=='M7/1:10;L:77;',pre
     else:assert pre['undo']=='L:77;',pre
    result['cases']= [{'scenario':i,'schemas':['Motion','Health'],'boundaries':['success','failure'],'sameOriginalTxObservation':True} for i in range(9)]
    entry['status']='FINITE_ORIGINAL_TX_MATCH';result['baseline']=entry
   else:
    assert d,('mutant survived',name);entry.update(status='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE',witness=d[0]);result['mutants'].append(entry)
  result['status']='FINITE_CHECKED_HELD_TX_CONTROLS_PASS'
 except Exception as e:result.update(status='FAIL',error=str(e))
 (a.output_dir/'evidence.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));return int(result['status']=='FAIL')
if __name__=='__main__':raise SystemExit(main())
