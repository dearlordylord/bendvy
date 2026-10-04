#!/usr/bin/env python3
"""Renderer-only finite controls, not an integrated runtime or universal proof."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tempfile
import shutil

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('t05', HERE.parent / 't05/run.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)

def four(a,b,c,d): return dict(a=a,b=b,c=c,d=d)
def handle(ns,id): return dict(namespace=ns,id=id)
def tagged(kind, **fields): return dict(kind=kind, **fields)
pos = dict(coordinates=four(1,2,3,4),frame=5)
aux = dict(rates=four(6,7,8,9),moving=True)
row = dict(handle=handle(41,17),main=pos,aux=aux,flag=dict(group=10))
bundle = dict(main=pos,aux=aux,flag=dict(group=16))
world = dict(namespace=41,next=18,rows=[dict(id=17,main=pos,aux=aux,flag=None,added=11,changed=12),dict(id=18,main=None,aux=None,flag=dict(group=13),added=14,changed=15)],pending=[tagged('SpawnView',id=19,bundle=bundle),tagged('MainView',id=17,main=pos),tagged('FlagView',id=17,flag=dict(group=20)),tagged('RemoveMainView',id=18),tagged('RemoveFlagView',id=17),tagged('DespawnView',id=18)],ledger=dict(totals=four(21,22,23,24),epoch=25),mode='MotionOn')
expected = [
 ''.join(chr(i) for i in range(32))+'"\\λ😀',
 tagged('Reserved',step='reserve',worldName='motion',label='raw',handle=handle(41,17),components=dict(main=pos,aux=aux,flag=dict(group=10))),
 tagged('Snapshot',step='snapshot',worldName='world',prior=tagged('Complete'),world=world,query=[row],plus=[row],minus=[],optional=[row],lookups=[dict(label='found',handle=handle(41,17),result=tagged('Found',value=row)),dict(label='foreign',handle=handle(42,17),result=tagged('Mismatch')),dict(label='stale',handle=handle(41,99),result=tagged('Missing'))]),
 tagged('Read',step='read',system='Fast',count=26,boundary=dict(since=27,streamSince=28,thisRun=29),query=[row],added=[row],changed=[row],removed=[handle(41,17)],despawned=[handle(41,18)],messages=[dict(code=30),dict(code=31)],messageLag=True,removedLag=False,despawnedLag=True),
 tagged('ReadDone',step='readDone',system='Fast',frame=32,tick=33,outcome=tagged('Failure',code=34),messageLag=False,removedLag=True,despawnedLag=False),
 tagged('Dispatch',step='dispatch',worldName='motion',tracked=True,outcome=tagged('SystemFailure',system='B',code=35),clockTick=36,frame=37,counts=[dict(system='A',value=four(38,39,40,41))]),
 tagged('OwnWrites',step='writes',system='B',views=[tagged('Main',value=tagged('Found',value=tagged('MotionMain',position=pos))),tagged('Main',value=tagged('Missing')),tagged('Main',value=tagged('Mismatch')),tagged('ReservedLookup',value=tagged('Missing')),tagged('Ledger',value=dict(totals=four(42,43,44,45),epoch=46)),tagged('Ledger',value=None)]),
 tagged('Snapshot',step='health',worldName='health-world',prior=tagged('SetupRejected',reason='reason'),world=dict(namespace=47,next=48,rows=[dict(id=49,main=dict(levels=four(50,51,52,53),reserve=54,**{'class':55}),aux=dict(layers=four(56,57,58,59),grade=60),flag=dict(group=61),added=62,changed=63)],pending=[],ledger=None,mode='HealthOff'),query=[],plus=[],minus=[],optional=[],lookups=[]),
 tagged('Read',step='health-read',system='Slow',count=64,boundary=dict(since=65,streamSince=66,thisRun=67),query=[],added=[],changed=[],removed=[],despawned=[],messages=[dict(code=68)],messageLag=False,removedLag=False,despawnedLag=False),
 tagged('MissingRuntimeRequirements',requirements=[tagged('ResourceRequired',name='resource'),tagged('ServiceRequired',name='service'),tagged('StateRequired',name='state')]),
 tagged('Success'),'MotionOff','HealthOn',tagged('HealthMain',vitals=dict(levels=four(69,70,71,72),reserve=73,**{'class':74}))]

# Only renderer changes; actual fixture source is retained byte-for-byte except
# import routing to the isolated modified implementation. Every mutant checks
# and compiles on both backends before differing at its intended JSON field.
mutations = {
 'four-slot': ('U32.show(c), ",\\\"d\\\":", U32.show(d)', 'U32.show(d), ",\\\"d\\\":", U32.show(c)'),
 'namespace': ('U32.show(namespace), ",\\\"id\\\":",', 'U32.show(id), ",\\\"id\\\":",'),
 'fifo': ('case Nil{}: List.reverse(&2,String,acc)', 'case Nil{}: acc'),
 'control-escape': ('render_hex((code % 16 : U32))', 'render_hex(0)'),
}

def imports(text, original, renderer=None):
 def rewrite(m):
  target=(original.parent/m.group(1)).resolve()
  if renderer is not None and target.name=='host-render.bend':target=renderer
  return 'import '+str(target)
 return re.sub(r'import (\./[^\s]+)',rewrite,text)

def source_closure():
 inventory={}
 def visit(path):
  path=path.resolve()
  key=str(path.relative_to(HERE.parent.parent))
  if key in inventory:return
  inventory[key]=hashlib.sha256(path.read_bytes()).hexdigest()
  for target in re.findall(r'^import (\./[^\s]+)',path.read_text(),re.M):
   visit(path.parent/target)
 visit(HERE/'renderer-controls.bend')
 return inventory

def main():
 evidence={'import_closure_sha256':source_closure(),'compiler_version':runner.command(['bend','version']).strip(),'compiler_sha256':hashlib.sha256(Path(shutil.which('bend')).resolve().read_bytes()).hexdigest(),'base_sha256':hashlib.sha256((Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest(),'build_helper_sha256':hashlib.sha256((HERE.parent/'t05/run.py').read_bytes()).hexdigest(),'checker_wrapper_sha256':hashlib.sha256((HERE.parent/'t01/bend-check').read_bytes()).hexdigest(),'scope':'finite renderer-only full-field/ordered JSON controls','limits':{'checker_seconds':5,'runtime_seconds':5,'codegen_seconds':30,'clang_seconds':120},'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'host-render.bend',HERE/'host-observations.bend',HERE/'renderer-controls.bend',Path(__file__)]},'expected':expected,'outcomes':{}}
 with tempfile.TemporaryDirectory(prefix='bendvy-renderer-') as tmp:
  root=Path(tmp)
  for name,change in [('original',None),*mutations.items()]:
   folder=root/name;folder.mkdir()
   source=(HERE/'host-render.bend').read_text()
   if change:
    old,new=change
    assert old in source,(name,old)
    source=source.replace(old,new)
    if name=='namespace': source=source.replace('case S.Handle{namespace,id}:','case S.Handle{namespace,+id}:')
   renderer=folder/'host-render.bend';renderer.write_text(imports(source,HERE/'host-render.bend'))
   fixture=folder/'renderer-controls.bend';fixture.write_text(imports((HERE/'renderer-controls.bend').read_text(),HERE/'renderer-controls.bend',renderer))
   binaries=runner.build(fixture,folder)
   rows=[]
   for binary in binaries:
    raw=runner.execute(binary)
    actual=[json.loads(line) for line in raw.splitlines()]
    if change:
     assert actual!=expected,name
     checkpoint={'four-slot':2,'namespace':1,'fifo':2,'control-escape':0}[name]
     assert actual[checkpoint]!=expected[checkpoint],name
    else:assert actual==expected,(name,actual)
    rows.append({'backend':'JS' if binary.suffix=='.js' else 'Native','raw':raw,'parsed':actual,'status':'detected' if change else 'PASS'})
   evidence['outcomes'][name]=rows
 (HERE/'renderer-evidence.json').write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+'\n')
 print('PASS: 14 complete JSON values x Native/JS; four compiling perturbations x Native/JS')
if __name__=='__main__':main()
