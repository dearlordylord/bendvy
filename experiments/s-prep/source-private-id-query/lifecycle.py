#!/usr/bin/env python3
"""Independent finite existing40 oracle on actual identity entry plus generic rendering."""
import argparse,hashlib,json,pathlib,subprocess,os,signal,shutil
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-private-id-query-v4'));a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
from pins import verify
R=pathlib.Path('/workspace/formal-proofs/bendvy');P=R/'experiments/s-prep/primitive-storage-integration';clang=pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19')
def sha(b):return hashlib.sha256(b).hexdigest()
files={x.name:x.read_bytes() for x in (a.overlay/'experiments/s-integrate').glob('*.bend')};pins={k:sha(v) for k,v in sorted(files.items())};assert len(pins)==29
# Same canonical source29 closure representation used by overlay manifest.
manifest=json.loads((a.overlay/'overlay.json').read_text());files,verified_pins,closure=verify(a.overlay)
r={'status':'INCOMPLETE','scope':'Finite actual typed-cursor40 and unchanged generic40; no proof/full22/performance','source29':pins,'closure':closure,'commands':[],'subjects':{}}
def save(): (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 argv=list(map(str,argv));out=a.output/(label+'.stdout');err=a.output/(label+'.stderr');entry={'argv':argv,'limitSeconds':limit,'stdout':str(out),'stderr':str(err)};r['commands'].append(entry);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with out.open('w') as o,err.open('w') as e:
  ch=subprocess.Popen(['taskset','-c','10',*argv],stdout=o,stderr=e,start_new_session=True,env=env)
  try:entry['returncode']=ch.wait(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.wait();entry['status']='TIMEOUT';save();raise
 assert entry['returncode']==0,entry;save();return out.read_text()+err.read_text()
run(['bend','version'],5,'version');run(['bend','guide'],5,'guide')
fixture=(P/'query-lifecycle.bend').read_text().replace('get_main: P ->','~get_main: P ->').replace('get_aux: U ->','~get_aux: U ->').replace('callback(-P: Type,-U: Type','callback(~P: Type,~U: Type').replace('callback_main(-P: Type,-U: Type','callback_main(~P: Type,~U: Type');expected=(P/'query-expected.txt').read_text();owners=(P/'owners.bend').read_text();owners='import Base\n\n'+owners[owners.index('type Motion is Type:'):owners.index('def snap_leaf(')]
needle='each_print(prefix,Q.each(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,callback,selection,world))';assert fixture.count(needle)==1
# Observe identity result using unchanged Q.lookup, not an invented owner decoder.
# Safe defs are DAG; recursion lives in one helper, so use a threaded pending accumulator instead of mutual recursion.
extra='''def identity_lookup_value(-Schema:Data,result: S.World<Schema,A.Motion,A.Health,Unit,Unit,Unit> & T.Access<String>) -> S.World<Schema,A.Motion,A.Health,Unit,Unit,Unit> & Maybe<&2,String>:
  match result:
    case (world,value): (world,Some{access_text(value)})
def identity_values(values: List<&2,S.Handle<QuerySchemaOne>>,acc: List<&2,String>,result: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & Maybe<&2,String>) -> S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & List<&2,String>:
  match values result:
    case Nil{} Tuple{world,None{}}: (world,List.reverse(&2,String,acc))
    case Nil{} Tuple{world,Some{text}}: (world,List.reverse(&2,String,text <> acc))
    case Con{handle,tail} Tuple{world,None{}}: identity_values(tail,acc,identity_lookup_value(QuerySchemaOne,Q.lookup(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,callback,Q.Optional{},world,handle)))
    case Con{handle,tail} Tuple{world,Some{text}}: identity_values(tail,text <> acc,identity_lookup_value(QuerySchemaOne,Q.lookup(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,callback,Q.Optional{},world,handle)))
def cursor_decode(+ns:U32,ids:List<&2,U32>) -> List<&2,S.Handle<QuerySchemaOne>>:
  match ids:
    case Nil{}: []
    case Con{id,rest}: S.Handle{ns,id} <> cursor_decode(ns,rest)
def identity_render(result: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & Q.PrototypeIdCursor<QuerySchemaOne>) -> S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & List<&2,String>:
  match result:
    case (world,Q.PrototypeIdCursor{ns,ids}): identity_values(cursor_decode(ns,ids),[],(world,None{}))
'''

identity=fixture.replace('def each(prefix:',extra+'def each(prefix:').replace(needle,'each_print(prefix,identity_render(Q.prototype_cursor_each(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,selection,world)))')
try:
 for schema in ['one','two']:
  for route in ['generic','identity']:
   src=fixture if route=='generic' else identity;exp=expected
   if schema=='two':
    src=src.replace('QuerySchemaOne','QuerySchemaTwo').replace('A.Motion','A.TEMP').replace('A.Health','A.Motion').replace('A.TEMP','A.Health').replace('motion_','TEMP_').replace('health_','motion_').replace('TEMP_','health_').replace('make_motion','make_TEMP').replace('make_health','make_motion').replace('make_TEMP','make_health').replace('S.World{7,','S.World{9,').replace('S.Handle{7,','S.Handle{9,').replace('S.Handle{8,','S.Handle{10,');exp=exp.replace('7:','9:')
   for backend in ['JS','Native']:
    name=f'{route}-{schema}-{backend}';stage=a.output/name;stage.mkdir();[(stage/n).write_bytes(v) for n,v in files.items()];(stage/'owners.bend').write_text(owners);f=stage/'query-lifecycle.bend';f.write_text(src);r['subjects'][name]={'status':'INCOMPLETE','fixture':sha(src.encode()),'expected':sha(exp.encode())};save()
    text=run(['bend',f,'--check-only'],15,name+'-check');assert 'ALL PROOFS CHECK' in text
    dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,name+'-emit')
    if backend=='Native':run([clang,'-O3',dest,'-o',stage/'native','-lm','-pthread'],120,name+'-clang')
    argv=['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'];observed=run(argv,5,name+'-run');assert observed==exp,(name,observed,exp);r['subjects'][name].update(status='PASS',checkpoints=40,outputSHA256=sha(observed.encode()));save()
 r['status']='ACTUAL_IDENTITY_AND_UNCHANGED_GENERIC_40_ALL_FOUR_ROLES_PASS';save()
except BaseException as e:r['failure']=repr(e);save();raise
