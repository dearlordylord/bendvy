#!/usr/bin/env python3
"""Finite fused indexed query controls, not a performance evaluator or proof."""
import argparse, hashlib, importlib.util, json, os, shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('bounded',ROOT/'experiments/t05/run.py')
B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
EXPECTED='[100229, 400882]\n[100229, 400882]\n[100229]\n[400882]\n[]:143:2004'
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--build-dir',required=True,type=Path);p.add_argument('--cpu',type=int,default=6);a=p.parse_args()
 os.sched_setaffinity(0,{a.cpu});a.build_dir.mkdir(exist_ok=False,parents=True)
 fixture=(HERE/'fixture.bend').read_bytes()
 evidence={'fixtureSHA256':hashlib.sha256(fixture).hexdigest(),'status':'INCOMPLETE','controls':[],'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'candidateSHA256':hashlib.sha256((a.overlay/'experiments/s-integrate/query.bend').read_bytes()).hexdigest()}
 replacements=[
 ('reverse-order','(S.Rows{main,aux,metadata,capacity,depth,high},List.reverse(&2,O,values))','(S.Rows{main,aux,metadata,capacity,depth,high},values)'),
 ('wrong-slot','Array.swap(Maybe<M>,main,U32.sub(id,1),None{})','Array.swap(Maybe<M>,main,0,None{})'),
 ('early-membership','case (metadata,S.Metadata{False{},_,_,_}): StructIdxState{main,aux,metadata,values}','case (metadata,S.Metadata{False{},+flag,_,_}): struct_idx_selected(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selected(F,selection,flag),id,namespace,main,aux,metadata,values,flag)'),
 ('lost-main-owner','Array.set(Maybe<M>,main,index,Some{m})','Array.set(Maybe<M>,main,index,None{})'),
 ('drop-flag','S.Handle{namespace,id},flag,owner,a)','S.Handle{namespace,id},None{},owner,a)'),
 ]
 try:
  for name,old,new in [('baseline',None,None)]+replacements:
   folder=a.build_dir/name;folder.mkdir()
   core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core)
   q=core/'query.bend';text=q.read_text()
   if old:
    assert text.count(old)==1,(name,text.count(old));q.write_text(text.replace(old,new))
   source=core/'integrated-query.bend';source.write_bytes(fixture)
   outputs=[];artifacts=[]
   for program in B.build(source,folder):
    value=B.execute(program);outputs.append(value)
    artifacts.append({"backend":"javascript" if program.suffix==".js" else "native","SHA256":hashlib.sha256(program.read_bytes()).hexdigest(),"outputSHA256":hashlib.sha256((value+"\n").encode()).hexdigest()})
    (folder/(program.name+'.observed.txt')).write_text(value+'\n')
   assert outputs[0]==outputs[1],name
   if name=='baseline': assert outputs[0]==EXPECTED,outputs
   else: assert outputs[0]!=EXPECTED,('mutant survived',name)
   evidence['controls'].append({'name':name,'status':'PASS' if name=='baseline' else 'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','output':outputs[0],'artifacts':artifacts,'mutatedQuerySHA256':hashlib.sha256(q.read_bytes()).hexdigest()})
  evidence['status']='FINITE_CONNECTED_QUERY_CONTROLS_PASS'
 except Exception as e:evidence.update(status='FAIL',error=str(e))
 (a.build_dir/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(json.dumps(evidence,indent=2));return int(evidence['status']=='FAIL')
if __name__=='__main__':raise SystemExit(main())
