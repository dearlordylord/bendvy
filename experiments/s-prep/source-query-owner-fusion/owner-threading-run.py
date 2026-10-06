#!/usr/bin/env python3
"""Finite nonidentity general-getter threading, public vs flat source protocols."""
import argparse,hashlib,json,os,pathlib,subprocess,shutil
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Finite trusted getters return changed affine scalar owners while retaining complete old String observations; no read-write API approval','commands':[],'cases':[]}
def run(args,limit):
 v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=limit);r['commands'].append({'argv':list(map(str,args)),'limitSeconds':limit,'exit':v.returncode});assert v.returncode==0,v.stdout+v.stderr;return v.stdout
helpers='''
def thread_motion_return(result:A.Motion & String) -> A.Motion & String:
  match result:
    case (A.Motion{items,+scalar},text): (A.Motion{items,U32.add(scalar,1)},text)
def thread_motion(owner:A.Motion) -> A.Motion & String:
  thread_motion_return(A.motion_observe(owner))
def thread_health_return(result:A.Health & String) -> A.Health & String:
  match result:
    case (A.Health{items,+scalar},text): (A.Health{items,U32.add(scalar,2)},text)
def thread_health(owner:A.Health) -> A.Health & String:
  thread_health_return(A.health_observe(owner))
'''
try:
 pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items());r['sourcePins']=pins
 for schema in ('one','two'):
  fixture=(HERE/'getter-control-flat.bend').read_text();needle='Unit,Unit,A.motion_observe,A.health_observe,prototype_owner_callback,selection,world)';assert fixture.count(needle)==1;fixture=fixture.replace(needle,'Unit,Unit,thread_motion,thread_health,prototype_owner_callback,selection,world)');fixture=fixture.replace('def make_motion(',helpers+'\ndef make_motion(',1)
  if schema=='two':
   fixture=fixture.replace('QuerySchemaOne','QuerySchemaTwo').replace('A.Motion','A.TEMP').replace('A.Health','A.Motion').replace('A.TEMP','A.Health').replace('motion_','TEMP_').replace('health_','motion_').replace('TEMP_','health_').replace('make_motion','make_TEMP').replace('make_health','make_motion').replace('make_TEMP','make_health').replace('S.World{7,','S.World{9,').replace('S.Handle{7,','S.Handle{9,').replace('S.Handle{8,','S.Handle{10,')
  observed={}
  for protocol in ('flat','public'):
   folder=a.output/(schema+'-'+protocol);folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);shutil.copyfile(ROOT/'experiments/s-prep/primitive-storage-integration/owners.bend',core/'owners.bend')
   text=fixture if protocol=='flat' else fixture.replace('Q.prototype_owner_each(','Q.each(').replace(',prototype_owner_callback,selection,world)',',callback,selection,world)');source=core/'owner-threading.bend';source.write_text(text);assert 'ALL PROOFS CHECK' in run(['bend',source,'--check-only'],15)
   c=folder/'subject.c';js=folder/'subject.js';native=folder/'subject.native';run(['bend',source,'-o',c],30);run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',native,'-lm','-pthread'],120);run(['bend',source,'-o',js],30)
   outputs=[]
   for backend,args in [('JS',['node',js]),('Native',[native,'--threads','1','--gpu','off'])]:
    output=run(args,5);assert len(output.splitlines())==40;(folder/(backend+'.txt')).write_text(output);outputs.append(output);r['cases'].append({'schema':schema,'protocol':protocol,'backend':backend,'records':40,'sourceSHA256':sha(source),'outputSHA256':hashlib.sha256(output.encode()).hexdigest()})
   assert outputs[0]==outputs[1];observed[protocol]=outputs[0]
  assert observed['flat']==observed['public'];literal=(HERE/'getter-expected.txt').read_text();literal=literal if schema=='one' else literal.replace('7:','9:');assert observed['flat']!=literal,'Nonidentity getters did not affect owners'
  prefix='initial-present:'+('7' if schema=='one' else '9')+':1|';line=next(x for x in observed['flat'].splitlines() if x.startswith(prefix));assert '|11:10,11,12,13|' in line,line
 r['status']='BOTH_SCHEMA_NONIDENTITY_AFFINE_GETTER_FULL40_PROTOCOL_FIELDS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e));raise
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
