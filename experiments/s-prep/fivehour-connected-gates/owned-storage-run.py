#!/usr/bin/env python3
"""Actual indexed storage finite replay; independent expected values, no ECS proof."""
import hashlib,json,os,pathlib,signal,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
FIXTURES=ROOT/'experiments/s-perf/candidate'
OVERLAY=pathlib.Path(os.environ['BENDVY_FINAL_OVERLAY']).resolve()
MANIFEST=json.loads((OVERLAY/'overlay.json').read_text())
assert all(hashlib.sha256((OVERLAY/n).read_bytes()).hexdigest()==v for n,v in MANIFEST['sources'].items())
ART=pathlib.Path(os.environ['BENDVY_OWNED_ARTIFACT']);ART.mkdir(exist_ok=False)
CPU=os.environ.get('BENDVY_CPU','8')
# The implementation worktree had an untracked baseline types.bend. A clean
# checkout must obtain that exact dependency itself, before checking fixtures.
input_root=ART/'input';input_root.mkdir()
input_candidate=input_root/'candidate';input_candidate.mkdir()
# Final cached specialization adds imports even to generic storage. Preserve the
# entire actual supplied core closure; no module thinning or fixture Type erasure.
for source in (OVERLAY/'experiments/s-integrate').glob('*.bend'):
 (input_candidate/source.name).write_bytes(source.read_bytes())
for source in FIXTURES.glob('*.bend'):
 if source.name.startswith('owned-storage-') or source.name in ('storage.bend','identity.bend'):
  (input_candidate/source.name).write_bytes(((OVERLAY/'experiments/s-integrate'/source.name) if source.name in ('storage.bend','identity.bend') else source).read_bytes())
assert (input_candidate/'types.bend').read_bytes()==subprocess.check_output(['git','show','a976667:experiments/s-integrate/types.bend'],cwd=ROOT),'Actual Type fixture definitions changed'
(input_root/'owned-index-core.bend').write_bytes((FIXTURES.parent/'owned-index-core.bend').read_bytes())
HERE=input_candidate
def run(args,limit=5,ok=0):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.communicate();raise
 assert p.returncode==ok,(args,p.returncode,out,err)
 return out,err
assert 'bend 2.0.35' in ''.join(run(['bend','version']))
run(['bend','guide'])
base=pathlib.Path.home()/'.bend/bend2/base.bend'
assert hashlib.sha256(base.read_bytes()).hexdigest()=='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
for source in ['storage.bend','identity.bend','owned-storage-control.bend']:
 assert 'ALL PROOFS CHECK' in ''.join(run(['taskset','-c',CPU,'bend',HERE/source,'--check-only']))
for name,expected,observed in [('clone','Data','Type'),('duplicate','rows','rows (consumed more than once)'),('cross','S.Row<A.Health, A.Motion, Unit>','S.Row<A.Motion, A.Health, Unit>')]:
 out=''.join(run(['taskset','-c',CPU,'bend',HERE/f'owned-storage-negative-{name}.bend','--check-only'],ok=1))
 for line in ['SOME PROOFS FAIL','Location: bad',f'- expected : {expected}',f'- observed : {observed}']:assert line in out
 print('negative:'+name+':pass')
def fields(v):return f'{v}:{v},{v+1},{v+2},{v+3}'
def row(m,a,flag,added,changed):return (fields(m) if m else 'none')+'|'+fields(a)+'|'+flag+f'|{added}:{changed}'
expected=['insert1:placed','insert2:placed','insert4:placed','insert8:placed','insert65537:placed','shape:131072:17:65537',
 'first:'+row(10,110,'present',1,2),'no-main:'+row(0,120,'absent',3,4),'middle:'+row(40,140,'absent',5,6),'oldlast:'+row(80,180,'present',7,8),'last:'+row(90,190,'present',9,10),
 'zero:missing','hole:missing','out:missing','max:missing','roundtrip:'+fields(40),'mismatch:mismatch','foreign:missing','marked:'+row(40,140,'absent',5,77),
 'reject0:rejected:'+row(200,210,'present',11,12),'rejectmax:rejected:'+row(220,230,'absent',13,14),'rejectoccupied:rejected:'+row(240,250,'absent',15,16),
 'retained-first:'+row(10,110,'present',1,2),'retained-last:'+row(90,190,'present',9,10),'main-add:added','main-added:'+row(20,120,'absent',50,50),'main-change:changed','main-changed:'+row(21,120,'absent',50,51),'main-remove:removed','main-removed:'+row(0,120,'absent',0,0),'main-again:unchanged','main-unchanged:'+row(0,120,'absent',0,0),'main-stale:missing','removed:'+row(40,140,'absent',5,77),'tombstone:missing','repeat-remove:missing','reinstall:placed','reinstalled:'+row(400,410,'present',81,82),'shape:131072:17:65537']
if True:
 tmp=ART/'work';tmp.mkdir();candidate=tmp/'candidate';candidate.mkdir()
 for source in HERE.glob('*.bend'):(candidate/source.name).write_bytes(source.read_bytes())
 (tmp/'owned-index-core.bend').write_bytes((FIXTURES.parent/'owned-index-core.bend').read_bytes())
 def build(name):
  source=candidate/'owned-storage-control.bend';c=tmp/(name+'.c');js=tmp/(name+'.js');binary=tmp/name
  run(['taskset','-c',CPU,'bend',source,'-o',c],30);run(['taskset','-c',CPU,'bend',source,'-o',js],30)
  run(['taskset','-c',CPU,'clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
  native=run(['taskset','-c',CPU,binary,'--threads','1','--gpu','off'])[0]
  javascript=run(['taskset','-c',CPU,'node',js])[0]
  assert native==javascript,(name,native,javascript)
  return native
 original=build('original');assert original.splitlines()==expected,(original,expected)
 source=(HERE/'storage.bend').read_text()
 mutants={'wrong-slot':source.replace('Array.swap(Maybe<M>,main,U32.sub(id,1),None{})','Array.swap(Maybe<M>,main,id,None{})'),
 'wrong-growth':source.replace('ANode{m,slots_empty(M,d)}','ANode{slots_empty(M,d),m}'),
 'lost-growth-owner':source.replace('ANode{m,slots_empty(M,d)}','ANode{slots_empty(M,d),slots_empty(M,d)}')}
 for name,mutant in mutants.items():
  assert mutant!=source
  (candidate/'storage.bend').write_text(mutant)
  assert 'ALL PROOFS CHECK' in ''.join(run(['taskset','-c',CPU,'bend',candidate/'owned-storage-control.bend','--check-only']))
  changed=build(name);assert changed!=original
  print('semantic-mutant:'+name+':detected')
 print(original,end='')
 (ART/'original.txt').write_text(original)
 (ART/'evidence.json').write_text(json.dumps({'status':'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS','overlayManifestSHA256':hashlib.sha256((OVERLAY/'overlay.json').read_bytes()).hexdigest(),'storageSHA256':hashlib.sha256((OVERLAY/'experiments/s-integrate/storage.bend').read_bytes()).hexdigest(),'identitySHA256':hashlib.sha256((OVERLAY/'experiments/s-integrate/identity.bend').read_bytes()).hexdigest(),'scope':'Actual generic final storage with original affine Type fixtures; not complete cached World authority','mutants':['wrong-slot','wrong-growth','lost-growth-owner'],'backends':['Native','JS'],'versionSeam':'Original assertion 2.0.34 explicitly retargeted current approved 2.0.35, unchanged Base pin'},indent=2)+'\n')
