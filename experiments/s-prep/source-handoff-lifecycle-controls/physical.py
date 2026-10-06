#!/usr/bin/env python3
"""Additional consuming exact-Slot physical Main snapshots; no timing."""
import argparse,hashlib,importlib.util,json,os,re,shutil,signal,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--fixture',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
e=json.loads((a.fixture/'evidence.json').read_text());assert e['candidateClosureSHA256']=='a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b'
shutil.copy2(Path(__file__),a.output/'executed-recipe.py')
r={'recipeSHA256':sha(Path(__file__)),'status':'INCOMPLETE','scope':'Consuming actual Slot physical Main leaf/raw/cache snapshots plus original logical pre/post; not full physical Aux/metadata','inputReceiptSHA256':sha(a.fixture/'evidence.json'),'sourcePins':e['sourcePins'],'commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 pins={x:sha(x) for x in argv if Path(x).is_file()};exe=shutil.which(argv[0]) or argv[0];pins[exe]=sha(exe)
 c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'inputFileSHA256':pins,'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'output':out,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()};r['commands'].append(rec);save();assert c.returncode==expected and not timed,rec;return out
sp=importlib.util.spec_from_file_location('bounded','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B);B.command=command
try:
 bound=Path('/tmp/bendvy-slot-host-handoff-v7');m=json.loads((bound/'overlay.json').read_text());cache=json.loads((bound/'cache-specialization.json').read_text());assert m['sources']==e['sourcePins'] and len(e['sourcePins'])==29
 digest=hashlib.sha256(json.dumps(e['sourcePins'],sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest==e['candidateClosureSHA256']
 assert m['cacheSpecialization']==cache and cache['runtimeClosure']==cache['specializedClosure']==e['sourcePins'] and cache['specializedClosureSHA256']==cache['runtimeClosureSHA256']==digest
 for name,h in e['sourcePins'].items():assert sha(bound/name)==h
 r['sourceRoot']=str(bound);r['candidateClosureSHA256']=digest
 for lane,cap,aux,flag,mode in [('motion','Motion','Velocity','Selected','MotionMode'),('health','Health','Armor','Tracked','HealthMode')]:
  src=a.fixture/lane/'fallback.bend';s=src.read_text()
  if lane=='health':assert 'T.Vitals{quad(10),9,2}' in s and 'T.Vitals{quad(900),9,2}' in s,'Physical metadata oracle must bind seeded reserve9/class2'
  else:assert 'T.Position{quad(10),7}' in s and 'T.Position{quad(900),7}' in s
  assert any(x.get('sourceSHA256')==sha(src) and x.get('schema')==lane for x in e['cases'])
  slot=f'P.Prototype{cap}MainSlot';world=f'S.World<T.{cap}Schema,{slot},T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode}>';cmd=f'S.Command<{slot},T.{aux},T.{flag}>';handle=f'S.Handle<T.{cap}Schema>';tx=f'X.Tx<{world},{handle},{cmd}>';vl='List<&2,Maybe<&2,Physical>>'
  fields=['frame','a','b','c','d','cachedframe'] if lane=='motion' else ['reserve','class','a','b','c','d','cachedreserve','cachedclass'];fs=','.join(fields);decl=','.join('+'+x+':U32' for x in fields);shape=','.join('+'+x for x in fields)
  common=f'ns:U32,next:U32,aux:Array<Maybe<T.{aux}>>,metadata:S.MetadataColumns<T.{flag}>,capacity:U32,depth:Nat,high:U32,pending:List<{cmd}>,ledger:Maybe<CC.Cache<T.{cap}Ledger,T.LedgerView>>,mode:T.{mode}'
  extra=f'''type Physical is Data:
  Physical{{raw:List<&2,U32>,meta:List<&2,U32>}}
def physical_render(value:Maybe<&2,Physical>) -> String:
  match value:
    case None{{}}: "null"
    case Some{{Physical{{raw,meta}}}}: "{{\\\"raw\\\":" ++ R.render_list(U32,U32.show,raw) ++ ",\\\"meta\\\":" ++ R.render_list(U32,U32.show,meta) ++ "}}"
def values_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case Tuple{{xs,vs}} Tuple{{ys,ws}}: (ANode{{xs,ys}},List.append(&2,U32,vs,ws))
def values(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{{+v}}: (ALeaf{{v}},v <> [])
    case ANode{{xs,ys}}: values_join(values(xs),values(ys))
def slot_done({decl},result:Array<U32> & List<&2,U32>) -> {slot} & Physical:
  match result:
    case (array,raw): ({slot}{{array,{fs}}},Physical{{raw,[{fs}]}})
def slot_view(owner:{slot}) -> {slot} & Physical:
  match owner:
    case {slot}{{array,{fs}}}: slot_done({fs},values(array))
def leaf_done(result:{slot} & Physical) -> Maybe<{slot}> & Maybe<&2,Physical>:
  match result:
    case (owner,view): (Some{{owner}},Some{{view}})
def leaf(value:Maybe<{slot}>) -> Maybe<{slot}> & Maybe<&2,Physical>:
  match value:
    case None{{}}: (None{{}},None{{}})
    case Some{{owner}}: leaf_done(slot_view(owner))
def column_leaf(result:Maybe<{slot}> & Maybe<&2,Physical>) -> Array<Maybe<{slot}>> & {vl}:
  match result:
    case (owner,view): (ALeaf{{owner}},view <> [])
def column_join(left:Array<Maybe<{slot}>> & {vl},right:Array<Maybe<{slot}>> & {vl}) -> Array<Maybe<{slot}>> & {vl}:
  match left right:
    case Tuple{{xs,vs}} Tuple{{ys,ws}}: (ANode{{xs,ys}},List.append(&2,Maybe<&2,Physical>,vs,ws))
def column(array:Array<Maybe<{slot}>>) -> Array<Maybe<{slot}>> & {vl}:
  match array:
    case ALeaf{{value}}: column_leaf(leaf(value))
    case ANode{{xs,ys}}: column_join(column(xs),column(ys))
def world_done({common},result:Array<Maybe<{slot}>> & {vl}) -> {world} & {vl}:
  match result:
    case (main,views): (S.World{{ns,next,S.Rows{{main,aux,metadata,capacity,depth,high}},pending,ledger,mode}},views)
def world_view(world:{world}) -> {world} & {vl}:
  match world:
    case S.World{{ns,next,S.Rows{{main,aux,metadata,capacity,depth,high}},pending,ledger,mode}}: world_done(ns,next,aux,metadata,capacity,depth,high,pending,ledger,mode,column(main))
'''
  wrappers=f'''def physical_pre_done(selected:{handle},undo:List<&2,X.Inverse<{handle}>>,commands:List<{cmd}>,pings:List<&2,U32>,marks:List<&2,{handle}>,value:U32,result:{world} & {vl}) -> IO({tx}):
  match result:
    case (world,views):
      do IO<{tx}>:
        IO.print("{{\\\"phase\\\":\\\"physical\\\",\\\"main\\\":" ++ R.render_list(Maybe<&2,Physical>,physical_render,views) ++ "}}")
        owner : {tx} <- {lane}_logical_pre((X.Tx{{world,selected,undo,commands,pings,marks}},value))
        return owner
def {lane}_pre(result:{tx} & U32) -> IO({tx}):
  match result:
    case (X.Tx{{world,selected,undo,commands,pings,marks}},value): physical_pre_done(selected,undo,commands,pings,marks,value,world_view(world))
'''
  post=f'''def physical_post_done(pings:List<&2,U32>,result:{world} & {vl}) -> IO(Unit):
  match result:
    case (world,views):
      do IO<Unit>:
        IO.print("{{\\\"phase\\\":\\\"physical\\\",\\\"main\\\":" ++ R.render_list(Maybe<&2,Physical>,physical_render,views) ++ "}}")
        {lane}_logical_post((world,pings))
def {lane}_post(result:{world} & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings): physical_post_done(pings,world_view(world))
'''
  seed=f'''def seed_done(selected:{handle},undo:List<&2,X.Inverse<{handle}>>,commands:List<{cmd}>,pings:List<&2,U32>,marks:List<&2,{handle}>,result:{world} & {vl}) -> IO({tx}):
  match result:
    case (world,views):
      do IO<{tx}>:
        IO.print("{{\\\"phase\\\":\\\"initial\\\",\\\"main\\\":" ++ R.render_list(Maybe<&2,Physical>,physical_render,views) ++ "}}")
        return X.Tx{{world,selected,undo,commands,pings,marks}}
def physical_seed(owner:{tx}) -> IO({tx}):
  match owner:
    case X.Tx{{world,selected,undo,commands,pings,marks}}: seed_done(selected,undo,commands,pings,marks,world_view(world))
'''
  extra+=seed
  s=s.replace(f'def {lane}_pre(',extra+f'def {lane}_logical_pre(',1)
  s=s.replace(f'def {lane}_post_view(',wrappers+f'def {lane}_post_view(',1)
  s=s.replace(f'def {lane}_post(',f'def {lane}_logical_post(',1)
  s=s.replace('def fixture_body(',post+'def fixture_body(',1)
  original=re.search(r'^( +)original : .*? <- '+lane+r'_pre\(reference\('+lane+r'_owner\((\d+)\)\)\)\s*$',s,re.M)
  assert original
  n=original[2];indent=original[1];replacement=f'{indent}original_seed : {tx} <- physical_seed({lane}_owner({n}))\n'+original[0].replace(f'{lane}_owner({n})','original_seed');s=s.replace(original[0],replacement,1)
  candidate=re.search(r'^( +)candidate : .*? <- candidate_pre\(.*$',s,re.M);assert candidate
  n=re.search(lane+r'_owner\((\d+)\)',candidate[0])[1];replacement=f'{candidate[1]}candidate_seed : {tx} <- physical_seed({lane}_owner({n}))\n'+candidate[0].replace(f'{lane}_owner({n})','candidate_seed');s=s.replace(candidate[0],replacement,1)
  folder=a.output/lane;folder.mkdir();entry=folder/'physical.bend';entry.write_text(s);r['cases'].append({'schema':lane,'inputEntrySHA256':sha(src),'entrySHA256':sha(entry)})
  for program in B.build(entry,folder):
   out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');records=[json.loads(x) for x in out.splitlines()];assert len(records)==20
   for failure in range(2):
    ois,opre,olpre,opost,olpost,cis,cpre,clpre,cpost,clpost=records[10*failure:10*failure+10];assert ois==cis;assert opre==cpre and opost==cpost and olpre==clpre and olpost==clpost
    expected_first=[30,11,12,13];expected_second=[900,901,902,903]
    if e['scenario']=='two':expected_second[0]=30
    def cell(raw):return {'raw':raw,'meta':([7,*raw,7] if lane=='motion' else [9,2,*raw,9,2])}
    assert ois['main']==[cell([10,11,12,13]),cell([900,901,902,903])],ois
    assert opre['main']==[cell(expected_first),cell(expected_second)],opre
    if failure:expected_first[0]=10;expected_second[0]=900
    assert opost['main']==[cell(expected_first),cell(expected_second)],opost
   r['cases'].append({'schema':lane,'backend':'JS' if program.suffix=='.js' else 'Native','status':'PASS','records':20,'programSHA256':sha(program)})
 for name,h in e['sourcePins'].items():assert sha(bound/name)==h,'Post-run source drift'
 assert sha(Path(__file__))==r['recipeSHA256'],'Post-run physical recipe drift'
 r['status']='ACTUAL_SLOT_PHYSICAL_MAIN_BEFORE_AFTER_BOTH_PASS'
except Exception as x:r.update(status='FAIL',error=repr(x));raise
finally:save()
