#!/usr/bin/env python3
"""Finite source-current application controls, no timing or proof acceptance."""
import hashlib,json,os,pathlib,re,shutil,sys,time
ROOT=pathlib.Path(__file__).resolve().parents[2];HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
OUT=HERE/'evidence'/str(time.time_ns());OUT.mkdir(parents=True)
STAGE=None;EXPECTED=None;ARTIFACTS={}
r={'status':'INCOMPLETE','limits':{'checker':5,'emit':30,'clang':120,'runtime':5},'commands':[],'pins':{},'cases':[]}
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def save():(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
def stage_inventory(stage):
 return {str(p.relative_to(stage)):sha(p) for base in [stage/'src',stage/'experiments'] for p in sorted(base.rglob('*')) if p.is_file()}
def guard():
 assert all(sha(p)==h for p,h in r['pins'].items()),'root source drift'
 assert all(sha(p)==h for p,h in r.get('externalPins',{}).items()),'external source drift'
 assert all(sha(p)==h for p,h in ARTIFACTS.items()),'generated artifact drift'
 if STAGE is not None:assert stage_inventory(STAGE)==EXPECTED,'staged source drift'
def run(argv,limit,expected=0):
 guard()
 argv=list(map(str,argv));name='command-'+str(len(r['commands']))+'.txt'
 try:code,out=supervisor.execute(argv,limit,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'})
 except Exception as error:
  guard();r['commands'].append({'argv':argv,'limitSeconds':limit,'error':repr(error)});save();raise
 guard()
 (OUT/name).write_text(out);r['commands'].append({'argv':argv,'limitSeconds':limit,'exit':code,'log':name,'sha256':sha(OUT/name)});save()
 if expected is not None:assert code==expected,(code,out)
 return code,out
try:
 seen=set()
 def imports(p):
  p=p.resolve()
  if p in seen:return
  seen.add(p)
  for item in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if item!='Base':imports(p.parent/item)
 for p in HERE.glob('*.bend'):imports(p)
 for p in seen|{pathlib.Path(supervisor.__file__).resolve()}|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|set(HERE.glob('negative*.bend')):r['pins'][str(p)]=sha(p)
 r['externalPins']={str(p):sha(p) for p in sorted((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))}
 r['externalPins']['/home/node/.bend/bend2/base.bend']=sha('/home/node/.bend/bend2/base.bend')
 run(['bend','version'],5);run(['bend','guide'],5)
 manifest=json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'];r['references']={}
 for name,h in manifest.items():
  _,actual=run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5);assert actual.strip()==h;r['references'][name]=h
 _,merged=run(['node',HERE/'reference.mjs'],5)
 _,publicMerged=run(['node',HERE/'merge-reference.mjs'],5);assert publicMerged==merged;r['publicConstructedMergeTS']=publicMerged
 _,rawMerged=run(['node',HERE/'raw-merge-reference.mjs'],5);r['rawUnvalidatedMergeTSDiscovery']=rawMerged
 _,app=run(['node',HERE/'application-reference.mjs'],5)
 _,erased=run(['node',HERE/'erased-undeclared-reference.mjs'],5);r['erasedUndeclaredTSDiscovery']=erased
 _,foreignTS=run(['node',HERE/'foreign-reference.mjs'],5);r['foreignHandleTSDiscovery']=foreignTS
 for name,diagnostic in [('negative-schema','First'),('negative-affine','consumed more than once'),('negative-write-through-read','ValueWrite'),('negative-undeclared','H')]:
  _,out=run(['bend',HERE/(name+'.bend'),'--check-only'],5,1);assert diagnostic in out;r['cases'].append({'negative':name,'intendedDiagnostic':diagnostic})
 for case in ['merges','main','recursive','foreign','collision-omission','priority-omission','name-omission-effects','barrier-omission','invalid-initialization']:
  STAGE=None;EXPECTED=None;guard();stage=OUT/case
  expectedNormal={}
  for path,digest in r['pins'].items():
   rel=pathlib.Path(path).relative_to(ROOT);dst=stage/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,dst);assert sha(dst)==digest;expectedNormal[str(rel)]=digest
  assert stage_inventory(stage)==expectedNormal
  r.setdefault('stages',{})[case]={'normalInventory':expectedNormal}
  entry=stage/'experiments/public-schema-fragments'/('foreign.bend' if case=='foreign' else 'recursive.bend' if case=='recursive' else 'merges.bend' if case in ['merges','collision-omission','priority-omission'] else 'main.bend')
  if case=='collision-omission':
   path=stage/'src/ecs/schema-fragments.bend';text=path.read_text();old='case True{} _: Invalid{DuplicateKey{kind,key}}';assert text.count(old)==1;path.write_text(text.replace(old,'case True{} _: Valid{}'))
  if case=='priority-omission':
   path=stage/'src/ecs/schema-fragments.bend';text=path.read_text();old='first_failure(validate(~S,le),first_failure(validate(~S,re),validate(~S,List.append(&2,Entry<S>,le,re))))';assert text.count(old)==1;path.write_text(text.replace(old,'validate(~S,List.append(&2,Entry<S>,le,re))'))
  if case=='name-omission-effects':
   path=stage/'src/ecs/schema-fragments.bend';text=path.read_text();old='case False{} True{}: Invalid{DuplicateName{kind,name}}';assert text.count(old)==1;path.write_text(text.replace(old,'case False{} True{}: Valid{}'))
  if case=='barrier-omission':
   path=stage/'experiments/public-schema-fragments/application.bend';text=path.read_text();old='observe(~S,W.barrier(~S,~Store<S>,~U32,~U32,world))';assert text.count(old)==1;path.write_text(text.replace(old,'observe(~S,world)'))
  if case=='invalid-initialization':
   path=stage/'experiments/public-schema-fragments/application.bend';text=path.read_text();old='F.Entry{F.Component{},"other","Position"}';assert text.count(old)==1;path.write_text(text.replace(old,'F.Entry{F.Component{},"Position","Position"}'))
  EXPECTED=stage_inventory(stage);STAGE=stage
  changed={k:{'originalSHA256':expectedNormal[k],'derivedSHA256':v} for k,v in EXPECTED.items() if v!=expectedNormal[k]}
  assert len(changed)==(1 if case in ['collision-omission','priority-omission','name-omission-effects','barrier-omission','invalid-initialization'] else 0)
  r['stages'][case]['intentionalChanges']=changed;r['stages'][case]['derivedInventory']=EXPECTED;guard()
  run(['bend',entry,'--check-only'],5)
  for backend in ['js','native']:
   generated=stage/('main.js' if backend=='js' else 'main.c');run(['bend',entry,'-o',generated],30);ARTIFACTS[str(generated)]=sha(generated)
   if backend=='native':
    program=stage/'main-native';run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',generated,'-pthread','-lm','-o',program],120);ARTIFACTS[str(program)]=sha(program);argv=[program,'--threads','1','--gpu','off']
   else:argv=['node',generated]
   _,out=run(argv,5)
   if case=='merges':assert out==merged
   elif case=='foreign':assert out=='missing:10,11,:2,3,:0::0|20,21,:4,5,:0::0\n'*2
   elif case=='recursive':assert out=='10,99:20,99:7\n'*2
   elif case=='barrier-omission':
    lines=out.splitlines();assert lines[:2]==['12,11,:3,3,:1:9,:1:log=1,99|12,11,:3,3,:1:9,:1:log=1,99']*2;assert lines[2:]==['rejected:10,11,:2,3,:log=0,99']*4
   elif case=='name-omission-effects':
    lines=out.splitlines();assert lines[:4]==['12,11,:3,3,:1:9,:1:log=1,99|13,11,:3,3,:1:9,:0:log=1,99']*4;assert lines[4:]==['rejected:10,11,:2,3,:log=0,99']*2
   elif case=='priority-omission':assert out!=merged and out.count('key:k:10,99:20,99')==4
   elif case=='collision-omission':assert out!=merged and 'ok:10,99:20,99' in out
   else:
    lines=out.splitlines();assert '\n'.join(lines[:4])+'\n'==app
    assert lines[4:]==['rejected:10,11,:2,3,:log=0,99']*2
   r['cases'].append({'generatedSHA256':sha(generated),'nativeSHA256':sha(program) if backend=='native' else None,'case':case,'backend':backend,'status':'PASS','outputSHA256':hashlib.sha256(out.encode()).hexdigest()})
 for p,h in r['pins'].items():assert sha(p)==h
 r['artifactPins']=ARTIFACTS;guard();r['status']='FINITE_APPLICATION_MERGE_CONTROL_PASS'
except Exception as error:r['status']='FAIL';r['error']=repr(error)
finally:save()
print(OUT,r['status']);sys.exit(0 if r['status']=='FINITE_APPLICATION_MERGE_CONTROL_PASS' else 1)
