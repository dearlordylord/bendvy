#!/usr/bin/env python3
"""Bounded exact affine lifecycle controls for the actual batched mark path."""
import argparse,atexit,hashlib,json,os,pathlib,signal,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-batched-marks-reproduced'));p.add_argument('--output',type=pathlib.Path,default=HERE/'controls-evidence');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
def sha(x):return hashlib.sha256(x).hexdigest()
receipt={'status':'INCOMPLETE','scope':'Finite actual batched marks, affine owners,52 original checkpoints plus batch fields; no proof, full22 or performance acceptance','limits':{'checker':15,'codegen':30,'clang':120,'runtime':5},'cpu':9,'commands':[],'backends':{}}
def save(): (a.output/'evidence.json').write_text(json.dumps(receipt,indent=2)+'\n')
atexit.register(save)
def run(args,limit):
 entry={'argv':list(map(str,args)),'limitSeconds':limit};receipt['commands'].append(entry);save()
 child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(child.pid,signal.SIGKILL);out,err=child.communicate();entry.update(status='TIMEOUT',stdout=out,stderr=err);save();raise
 entry.update(exit=child.returncode,outputSHA256=sha((out+err).encode()),status='PASS' if not child.returncode else 'FAIL');save()
 if child.returncode:entry.update(stdout=out,stderr=err);raise RuntimeError(entry)
 return out+err
assert 'bend 2.0.35' in run(['bend','version'],5);run(['bend','guide'],5)
base=ROOT/'experiments/s-prep/primitive-storage-integration'
original=(base/'lifecycle.bend').read_text();literal=(base/'expected.txt').read_text();assert len(literal.splitlines())==52
before='S.mark_main(Unit,A.Motion,A.Health,Unit,Unit,Unit,world,S.Handle{7,4},77)'
after='X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[S.Handle{7,4},S.Handle{7,4},S.Handle{8,1},S.Handle{7,0},S.Handle{7,3},S.Handle{7,65538},S.Handle{7,131073},S.Handle{7,4294967295}],world,77)'
assert original.count(before)==1
source=original.replace('import Base\n','import Base\nimport ./transaction.bend as X\n',1).replace(before,after)
extra=''
for label,ids,tick in [('nonmonotonic',[8,4,1,4],99),('empty',[],101)]:
 handles=','.join('S.Handle{7,'+str(i)+'}' for i in ids)
 extra+='    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}\n'
 extra+='    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,['+handles+'],world,'+str(tick)+')\n'
 extra+='    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)\n'
 for id in [1,4,8,65537]:extra+='    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-'+label+'-'+str(id)+':",S.rows_extract(A.Motion,A.Health,Unit,rows,'+str(id)+'))\n'
for label,id in [('hole',3),('above-high',65538)]:extra+='    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("batch-'+label+':",rows,'+str(id)+')\n'
extra+='    rows : S.Rows<A.Motion,A.Health,Unit> <- remove_print("batch-remove8:",S.rows_remove(A.Motion,A.Health,Unit,rows,8))\n'
extra+='    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}\n'
extra+='    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[S.Handle{7,8},S.Handle{7,3},S.Handle{7,65538}],world,103)\n'
extra+='    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)\n'
extra+='    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("batch-dead:",rows,8)\n'
assert source.endswith('    return Unit{}\n');source=source[:-len('    return Unit{}\n')]+extra+'    return Unit{}\n'
extra_expected=''
rows={1:'1|10:10,11,12,13|110:110,111,112,113|present|1:99',4:'4|400:400,401,402,403|410:410,411,412,413|present|81:99',8:'8|80:80,81,82,83|180:180,181,182,183|present|7:99',65537:'65537|90:90,91,92,93|190:190,191,192,193|present|9:10'}
for label in ['nonmonotonic','empty']:
 for id in [1,4,8,65537]:extra_expected+='batch-'+label+'-'+str(id)+':'+rows[id]+'\n'
extra_expected+='batch-hole:dead|absent|0:0\nbatch-above-high:dead|absent|0:0\nbatch-remove8:'+rows[8]+'\nbatch-dead:dead|absent|0:0\n'
expected=literal+extra_expected
receipt['adaptation']={'before':before,'after':after,'originalFixtureSHA256':sha(original.encode()),'originalLiteralSHA256':sha(literal.encode()),'derivedFixtureSHA256':sha(source.encode()),'expectedSHA256':sha(expected.encode()),'originalCheckpoints':52,'additionalCheckpoints':12}
(a.output/'fixture.bend').write_text(source);(a.output/'expected.txt').write_text(expected)
frozen={f.name:f.read_bytes() for f in (a.overlay/'experiments/s-integrate').glob('*.bend')};assert len(frozen)==29
manifest=json.loads((a.overlay/'overlay.json').read_text())
actual={str(f.relative_to(a.overlay)):sha(f.read_bytes()) for f in a.overlay.rglob('*.bend')}
assert actual==manifest['sources'], 'Overlay source manifest differs from actual source'
cache=json.loads((a.overlay/'cache-specialization.json').read_text())
assert cache==manifest['cacheSpecialization']
assert cache['runtimeClosure']==actual and cache['specializedClosure']==actual
receipt['sourceSHA256']={n:sha(v) for n,v in frozen.items()};receipt['overlayManifestSHA256']=sha((a.overlay/'overlay.json').read_bytes())
with tempfile.TemporaryDirectory(prefix='batched-mark-controls-') as directory:
 for backend in ['JS','Native']:
  stage=pathlib.Path(directory)/backend;stage.mkdir()
  for n,v in frozen.items():(stage/n).write_bytes(v)
  (stage/'owners.bend').write_bytes((base/'owners.bend').read_bytes());(stage/'lifecycle.bend').write_text(source)
  def command(args,limit):return run(['taskset','-c','9',*args],limit)
  def build(label):
   file=stage/'lifecycle.bend';assert 'ALL PROOFS CHECK' in command(['bend',file,'--check-only'],15)
   if backend=='JS':
    program=stage/(label+'.js');command(['bend',file,'-o',program],30);return command(['node',program],5)
   c=stage/(label+'.c');program=stage/label;command(['bend',file,'-o',c],30);command(['clang','-O3',c,'-o',program,'-lm','-pthread'],120);return command([program,'--threads','1','--gpu','off'],5)
  observed=build('original');(a.output/(backend+'-original.txt')).write_text(observed);assert observed==expected,(backend,observed,expected)
  tx=(stage/'transaction.bend').read_text();needle='case (live,True{}): (live,Array.set(U32,changed,index,tick))';assert tx.count(needle)==1
  mutant=tx.replace(needle,'case (live,True{}): (live,changed)');(stage/'transaction.bend').write_text(mutant)
  changed=build('mark-omission');(a.output/(backend+'-mutant.txt')).write_text(changed)
  assert len(changed.splitlines())==64
  assert [x.split(':',1)[0] for x in changed.splitlines()]==[x.split(':',1)[0] for x in expected.splitlines()]
  witness='marked:4|40:40,41,42,43|140:140,141,142,143|absent|5:6\n';assert witness in changed and witness not in expected
  receipt['backends'][backend]={'status':'PASS','checkpoints':64,'originalSHA256':sha(observed.encode()),'mutantSHA256':sha(changed.encode()),'mutantSourceSHA256':sha(mutant.encode()),'mutation':{'before':needle,'after':'case (live,True{}): (live,changed)'},'witness':witness.strip()};save()
assert all(f.read_bytes()==frozen[f.name] for f in (a.overlay/'experiments/s-integrate').glob('*.bend'))
receipt['status']='FINITE_BATCHED_MARK_FIELDS_AND_LIVE_OMISSION_MUTANT_PASS';save();print(receipt['status'])
