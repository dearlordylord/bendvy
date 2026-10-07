"""Source-bound public nested provisioning observations; no timings/profiles."""
import argparse,pathlib,hashlib,json,subprocess,os,shutil,tempfile,gzip,re
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();OUT=a.output.resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inputs():
 found=set();pending=list(HERE.glob('*.bend'))
 while pending:
  p=pending.pop().resolve()
  if p in found:continue
  found.add(p)
  for token in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if token=='Base':continue
   assert token.endswith('.bend'),token;pending.append((p.parent/token).resolve())
 found.update([HERE/'reference.mjs',HERE/'run.py'])
 return {str(p.relative_to(ROOT)):sha(p) for p in sorted(found)}
SNAP=inputs();refs=ROOT/'.references';manifest=json.loads((refs/'sources.json').read_text())['sources'];r={'status':'INCOMPLETE','sources':SNAP,'commands':[],'mutants':{},'limits':'Finite two nominal schema traces, actual public owners, no timing/profiling/production refinement claim'}
EXTERNAL={str(p):sha(p) for p in sorted((refs/'bevy-ts/packages/core/src').rglob('*.ts'))};EXTERNAL[str(pathlib.Path('/home/node/.bend/bend2/base.bend'))]=sha(pathlib.Path('/home/node/.bend/bend2/base.bend'))
r['external_hashes']=EXTERNAL

def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}
def guard(stage,expected):
 assert inputs()==SNAP,'root source drift';assert inventory(stage)==expected,'staged input drift';assert all(sha(pathlib.Path(p))==v for p,v in EXTERNAL.items()),'external source drift'
def run(stage,expected,label,cmd,cap,good=True):
 guard(stage,expected);q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
 gzip.open(OUT/(label+'.stdout.gz'),'wb').write(q.stdout.encode());(OUT/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap_seconds':cap,'exit':q.returncode});assert (q.returncode==0)==good,(label,q.stdout,q.stderr);guard(stage,expected);return q.stdout if good else q.stdout+q.stderr

def parse(text):
 blocks=text.strip().split('schema-B\n');assert len(blocks)==2;assert blocks[0].startswith('schema-A\n');blocks[0]=blocks[0][len('schema-A\n'):];parts=[b.strip().splitlines() for b in blocks];assert parts[0]==parts[1],'nominal schema observations differ'
 cases={};last=None
 for line in parts[0]:
  label,body=line.split('|',1)
  if label=='retry':assert last is not None;cases[last]['retry']=body
  else:last=int(label[4:]);assert last not in cases;cases[last]={'body':body}
 assert set(cases)==set(range(12));return cases

def fields(body):return dict(item.split('=',1) for item in body.split('|')[-1].split(';'))
def check(text):
 cases=parse(text)
 for mode,v in cases.items():
  b=v['body'];f=fields(b)
  for key in ['cell','retired','resource','service','cw','rw','host','conditions','clock','events','queue','trace','family']:assert key in f,(mode,key,b)
  assert 'component.write,resource.write,service.call,event.write,commands,' in b
  if mode==0 or 'retry' in v:
   retry=mode!=0;target=fields(v['retry'] if retry else b)
   if mode==8:
    assert 'skip:2;' in v['retry'];expected={'cw':'0','rw':'0','host':'0','conditions':'1','clock':'0','events':'[]','queue':'0','trace':'[]','cell':'[10, 99]','retired':'[]'}
   else:
    expected={'cw':'2','rw':'2','host':'2','conditions':'2','clock':'2','events':'[1, 2]','queue':'2','trace':'[1, 2]','cell':'[2, 99]','retired':'[[1, 99], [10, 99]]','resource':'[2, 120]','service':'[30, 130]'}
    assert 'phase:before;run:1;phase:inner;run:2;' in (v['retry'] if retry else b)
   for k,val in expected.items():assert target[k]==val,(mode,k,target[k],val)
  if mode in [1,2,3,4,5,6,8,11]:
   missing={1:'R1,',2:'R1,',3:'S1,',4:'S1,',5:'C1,',6:'C1,',8:'S1,',11:'S1,R1,'}[mode];assert b.startswith('missing:'+missing+':'),(mode,b)
   for k,val in {'cw':'0','rw':'0','host':'0','conditions':'0','clock':'0','events':'[]','queue':'0','trace':'[]','cell':'[10, 99]','retired':'[]'}.items():assert f[k]==val,(mode,k,f[k])
   assert 'retry' in v
   ownertext='nested:1:1:1:A:component.write,resource.write,service.call,event.write,commands,:0/1:2:B:component.write,resource.write,service.call,event.write,commands,:0'
   assert b.split('|owners=',1)[1].split('|',1)[0]==ownertext,(mode,'registry metadata',b)
   expectedSlots={1:('missing','[30, 130]'),2:('incompatible:[20, 120]','[30, 130]'),3:('[20, 120]','missing'),4:('[20, 120]','incompatible:[30, 130]'),5:('[20, 120]','[30, 130]'),6:('[20, 120]','[30, 130]'),8:('[20, 120]','missing'),11:('missing','missing')}
   resource,service=expectedSlots[mode]
   assert (f['resource'],f['service'])==(resource,service),(mode,'returned slots',f)
   assert f['family']=={5:'0',6:'2'}.get(mode,'1'),(mode,'family',f)
  elif mode==7:
   assert b.startswith('invalid|');assert all(f[k]=='0' for k in ['cw','rw','host','conditions','clock','queue']);assert f['events']=='[]'
  elif mode in [9,10]:
   assert b.startswith('ok:phase:'+('empty' if mode==9 else 'family-only')+';')
   assert all(f[k]=='0' for k in ['cw','rw','host','conditions','clock','queue']);assert f['events']=='[]'
   assert f['cell']==('absent' if mode==10 else '[10, 99]')
  if mode not in [7,9,10]:assert ':needs=S1,R1,C1,' in b,(mode,b)
  if mode==10:assert ':needs=C1,' in b and f['family']=='1'
  if mode==2:assert f['resource']=='incompatible:[20, 120]'
  if mode==4:assert f['service']=='incompatible:[30, 130]'
 if 'observed_TS' in r:
  bymode={x['mode']:x for x in r['observed_TS']}
  for mode,tsmode in [(0,'positive'),(1,'resource-missing'),(3,'service-missing'),(7,'duplicate'),(8,'condition-missing'),(9,'empty'),(11,'both-missing')]:
   f=fields(cases[mode]['body']);v=bymode[tsmode]
   for key in ['cw','rw','host','conditions','queue']:assert int(f[key])==v[key],(mode,key,f[key],v[key])
   for key,field in [('events','events'),('trace','trace'),('component','cell')]:assert json.loads(f[field])==v[key],(mode,key,f[field],v[key])
   actualResource=None if f['resource']=='missing' else json.loads(f['resource']);assert actualResource==v['resource'],(mode,actualResource,v['resource'])
   if 'requirements' in v:
    needsText=cases[mode]['body'].split(':needs=',1)[1].split('|',1)[0]
    actualRequirements=[{'S1':'service:Host','R1':'resource:Resource'}[x] for x in needsText.split(',') if x in ['S1','R1']];assert actualRequirements==v['requirements'],(mode,actualRequirements,v['requirements'])
   if 'missing' in v:
    items=cases[mode]['body'].split(':needs=',1)[0][len('missing:'):].split(',');actualMissing=[{'S1':{'kind':'service','name':'Host'},'R1':{'kind':'resource','name':'Resource'}}[x] for x in items if x];assert actualMissing==v['missing'],(mode,actualMissing,v['missing'])
 return cases
try:
 with tempfile.TemporaryDirectory(prefix='nested-provision-source-') as tmp:
  stage=pathlib.Path(tmp)
  for name,digest in SNAP.items():
   dst=stage/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,dst);assert sha(dst)==digest
  expected=inventory(stage);assert expected==SNAP;fixture=stage/HERE.relative_to(ROOT)/'main.bend'
  run(stage,expected,'version',['bend','version'],5);run(stage,expected,'guide',['bend','guide'],5)
  for name,known in manifest.items():
   actual=run(stage,expected,'reference-commit-'+name,['git','-C',refs/name,'rev-parse','HEAD'],5).strip();assert actual==known['commit'];r.setdefault('reference_commits',{})[name]=actual
  node=run(stage,expected,'node-version',['node','--version'],5);r['node']=node.strip()
  ts=json.loads(run(stage,expected,'reference',['node',stage/HERE.relative_to(ROOT)/'reference.mjs'],5));r['observed_TS']=ts
  run(stage,expected,'normal-check',['bend',fixture,'--check-only'],5);run(stage,expected,'access-positive',['bend',fixture.parent/'access.bend','--check-only'],5)
  negatives={'schema':['P.Plan<A.Schema>','P.Plan<B.Schema>'],'owner':['owner (consumed more than once)'],'undeclared':['Array<U32>','gameplay~H'],'write-read':['Cap.Write<gameplay~H','Cap.Read<gameplay~H'],'incompatible':['Array<U32>','observed : Unit']}
  for name,needles in negatives.items():
   error=run(stage,expected,'negative-'+name,['bend',fixture.parent/('negative-'+name+'.bend'),'--check-only'],5,False);assert all(s in error for s in needles),(name,error)
  def backend(label,expected,validate):
   observations=[]
   for role in ['JS','Native']:
    target=OUT/(label+('.js' if role=='JS' else '.c'));run(stage,expected,label+'-emit-'+role,['bend',fixture,'-o',target],30)
    if role=='Native':run(stage,expected,label+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',OUT/label,'-pthread','-lm'],120)
    observed=run(stage,expected,label+'-run-'+role,['node',target] if role=='JS' else [OUT/label],5);validate(observed,role);observations.append(observed)
   assert observations[0]==observations[1],label+' JS/Native differ'
  backend('normal',expected,lambda text,role:check(text))
  # Reached validator controls corrupt BOTH nominal schemas identically, so
  # schema equality and subsequent repair cannot mask refusal owner corruption.
  normal=gzip.open(OUT/'normal-run-JS.stdout.gz','rt').read()
  r['refusal_observation_controls']=[]
  for mode in [1,2,3,4,5,6,8,11]:
   for field in ['resource','service','registry']:
    def corrupt(line):
     if not line.startswith('case'+str(mode)+'|'):return line
     if field=='registry':return line.replace('commands,:0/1:2:B:','commands,:7/1:2:B:',1)
     return re.sub(r'(?<=;)'+field+r'=[^;]+',field+'=CORRUPTED_OWNER',line,count=1)
    altered='\n'.join(corrupt(line) for line in normal.split('\n'))
    assert altered!=normal
    try:check(altered)
    except (AssertionError,ValueError):r['refusal_observation_controls'].append({'mode':mode,'field':field,'both_schemas':'DETECTED'})
    else:raise AssertionError(('refusal observation corruption survived',mode,field))
  core=stage/'src/ecs/schedule-provision.bend';original=core.read_text();mutations={
   'omitted-requirement':original.replace('case Entry{_,needs}: needs','case Entry{_,needs}: []'),
   'precheck-bypass':original.replace('missing_requirements(~S,needs,available),schedule,world,needs','[],schedule,world,needs')}
  for name,text in mutations.items():
   assert text!=original;guard(stage,expected);core.write_text(text);mutated=dict(expected);mutated[str(core.relative_to(stage))]=sha(core);r['mutants'][name]={'changed_source':str(core.relative_to(stage)),'original_sha256':hashlib.sha256(original.encode()).hexdigest(),'mutant_sha256':sha(core),'backends':{}}
   run(stage,mutated,name+'-check',['bend',fixture,'--check-only'],5)
   def detected(text,role):
    try:check(text)
    except (AssertionError,ValueError):r['mutants'][name]['backends'][role]='DETECTED'
    else:raise AssertionError(name+' survived '+role)
   backend(name,mutated,detected);guard(stage,mutated);core.write_text(original);guard(stage,expected)
  guard(stage,expected)
 assert inputs()==SNAP;r['status']='PASS';r['nominal_schemas']=2;r['scenarios_per_schema']=12
except subprocess.TimeoutExpired as error:
 r['status']='INCONCLUSIVE_TIMEOUT';r['timeout']={'command':list(map(str,error.cmd)),'seconds':error.timeout};raise
finally:
 r['artifacts']={p.name:sha(p) for p in sorted(OUT.iterdir()) if p.is_file() and p.name!='receipt.json'};(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
