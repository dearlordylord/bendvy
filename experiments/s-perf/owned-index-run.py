#!/usr/bin/env python3
"""Finite owned-index gate; no dependencies, ECS proofs or timing acceptance."""
import hashlib,json,pathlib,subprocess,tempfile,os,signal
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[1]
REF=pathlib.Path('/workspace/formal-proofs/bendvy/.references')
def run(args,limit=5,ok=0):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try: stdout,stderr=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);p.communicate();raise
 assert p.returncode==ok,(args,p.returncode,stdout,stderr)
 return stdout+stderr
assert 'bend 2.0.34' in run(['bend','version']);run(['bend','guide'])
assert hashlib.sha256(pathlib.Path.home().joinpath('.bend/bend2/base.bend').read_bytes()).hexdigest()=='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
pins=json.loads((ROOT/'.references/sources.json').read_text())['sources']
for name in ['bevy-ts','bevy','bend2']:
 expected=next(x['commit'] for x in pins if x['name']==name) if isinstance(pins,list) else pins[name]['commit']
 assert run(['git','-C',REF/name,'rev-parse','HEAD']).strip()==expected
checks={'clone':('Data','Type'),'cross-schema':('A.Motion','A.Health'),'duplicate':('p','p (consumed more than once)'),'read-write':('A.Motion','bad~P'),'reconstruct':('bad~P','A.Motion')}
for name,(expected,observed) in checks.items():
 positive=run(['bend',HERE/'owned-index-positive.bend','--check-only']);assert 'ALL PROOFS CHECK' in positive
 negative=run(['bend',HERE/f'owned-index-negative-{name}.bend','--check-only'],ok=1)
 for text in ['SOME PROOFS FAIL','Location: bad',f'- expected : {expected}',f'- observed : {observed}']:assert text in negative
 print('control:'+name+':pass')
assert 'ALL PROOFS CHECK' in run(['bend',HERE/'owned-index-main.bend','--check-only'])
with tempfile.TemporaryDirectory(prefix='owned-index-') as tmp:
 tmp=pathlib.Path(tmp)
 def build(source,name):
  c=tmp/(name+'.c');js=tmp/(name+'.js');binary=tmp/name
  run(['bend',source,'-o',c],30);run(['bend',source,'-o',js],30)
  run(['clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
  native=run(['taskset','-c','8',binary,'--threads','1','--gpu','off'])
  javascript=run(['taskset','-c','8','node',js]);assert native==javascript
  return native
 original=build(HERE/'owned-index-main.bend','probe')
 expected=[]
 for schema in ['motion','health']:
  for ns,slot in [(7,0),(7,2),(7,3),(8,0),(7,4),(7,4294967295),(7,1)]:
   value='rejected' if ns!=7 or slot>=4 else 'missing' if slot==1 else f'{(slot+1)*10}:{(slot+1)*10},{(slot+1)*10+1},{(slot+1)*10+2},{(slot+1)*10+3}'
   expected.append(f'{schema}:{ns}:{slot}:{value}')
  expected.append(f'{schema}:mismatch:rejected')
  for slot in [0,2,3,4,7]:expected.append(f'{schema}:grown:{slot}:'+('missing' if slot==4 else f'{(slot+1)*10}:{(slot+1)*10},{(slot+1)*10+1},{(slot+1)*10+2},{(slot+1)*10+3}'))
 assert original.splitlines()==expected
 core=(HERE/'owned-index-core.bend').read_text().replace('Bool.and(U32.is_eq(namespace, 7), (slot < capacity : U32))','U32.is_eq(namespace, 7)')
 (tmp/'owned-index-core.bend').write_text(core)
 mutant=tmp/'mutant.bend';mutant.write_text((HERE/'owned-index-main.bend').read_text())
 assert 'ALL PROOFS CHECK' in run(['bend',mutant,'--check-only'])
 changed=build(mutant,'mutant');assert changed!=original
 assert 'motion:7:4:10:10,11,12,13' in changed
 print('bounds-bypass-mutant:detected')
 (tmp/'owned-index-core.bend').write_text((HERE/'owned-index-core.bend').read_text())
 extended=build(HERE/'owned-index-extended.bend','extended')
 lines=extended.splitlines();assert len(lines)==13
 for n,capacity in enumerate([2,4,8,16]):assert lines[n]==';'.join(['10:10,11,12,13','20:20,21,22,23']+['none']*(capacity-2))
 before=lines[4].removeprefix('before:');assert lines[4].startswith('before:')
 def fields(base):return f'{base}:{base},{base+1},{base+2},{base+3}'
 exact='|'.join([';'.join([fields(10)]+['none']*15),';'.join([fields(50),fields(60)]+['none']*14),fields(70),fields(80),fields(90)+';'+fields(100)+';end'])+'|meta='+','.join(['2','1']+['0']*14)
 assert before==exact
 for i,(ns,id) in enumerate([(7,0),(8,1),(7,17),(7,65537),(7,4294967295)]):assert lines[5+i]==f'reject:{ns}:{id}:unsupported:'+before
 assert lines[-3:]==['MissingEntity','MissingComponent','Matched']
 wrong=(HERE/'owned-index-core.bend').read_text().replace('col, slot, None{}','col, U32.add(slot, 1), None{}')
 (tmp/'owned-index-core.bend').write_text(wrong)
 assert 'ALL PROOFS CHECK' in run(['bend',mutant,'--check-only'])
 assert build(mutant,'wrong-slot')!=original
 print('wrong-slot-mutant:detected')
 (tmp/'owned-index-core.bend').write_text((HERE/'owned-index-core.bend').read_text())
 growth=tmp/'wrong-growth.bend';growth.write_text((HERE/'owned-index-extended.bend').read_text().replace('ANode{c, A.empty(~A.Motion, 1n)}','ANode{A.empty(~A.Motion, 1n), c}'))
 assert 'ALL PROOFS CHECK' in run(['bend',growth,'--check-only'])
 assert build(growth,'wrong-growth')!=extended
 print('wrong-growth-mutant:detected')
 print(original,end='');print(extended,end='')
 print('base-sha256:'+hashlib.sha256(pathlib.Path.home().joinpath('.bend/bend2/base.bend').read_bytes()).hexdigest())
