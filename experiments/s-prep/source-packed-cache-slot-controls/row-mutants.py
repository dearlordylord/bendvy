#!/usr/bin/env python3
import pathlib,json,hashlib,subprocess,signal,os,argparse
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--kinds',nargs='+');a=p.parse_args();a.output.mkdir(exist_ok=False);H=pathlib.Path(__file__).resolve().parent;files,pins,closure=verify(a.overlay);q=files['held-adapter.bend'].decode();at=q.index('def prototype_packed_row_set_done');end=q.index('def prototype_packed_row_setledger_done',at);prefix,tail,suffix=q[:at],q[at:end],q[end:];r={'status':'INCOMPLETE','source29Original':pins,'closure':closure,'scope':'Actual private packed row providers: full raw/cache fields and true-old semantic mutants','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 cmd=['taskset','-c','10',*map(str,argv)];e={'argv':cmd,'limitSeconds':limit};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.communicate();e['status']='TIMEOUT';save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();assert ch.returncode==0,(cmd,o,err);return o
changed={}
needle='Array.set(U32,coordinates,0,value)';assert tail.count(needle)==1
changed['lost-raw']=tail.replace(needle,'coordinates')
changed['other-cell']=tail.replace(needle,'Array.set(U32,Array.set(U32,coordinates,0,value),1,9999)')
# Retain the incoming cached a instead of patching it after writes.
changed['stale-cached']=tail.replace('rawframe:U32,b:U32','rawframe:U32,a:U32,b:U32').replace('rawframe,value,b,c,d,cachedframe','rawframe,a,b,c,d,cachedframe').replace('coordinates,rawframe,_,b,c,d','coordinates,rawframe,a,b,c,d').replace('prototype_packed_row_set_done(rawframe,b,c,d','prototype_packed_row_set_done(rawframe,a,b,c,d')
changed['wrong-true-old']=tail.replace('X.PrototypeFlatMain{space,id,old,undo}','X.PrototypeFlatMain{space,id,cachedframe,undo}').replace('cachedframe:U32,ledger_raw:', '+cachedframe:U32,ledger_raw:')
try:
 for kind,mutation in changed.items():
  if a.kinds and kind not in a.kinds:continue
  for backend in ['JS','Native']:
   name=kind+'-'+backend;stage=a.output/name;stage.mkdir();[(stage/n).write_bytes(b) for n,b in files.items()];(stage/'held-adapter.bend').write_text(prefix+mutation+suffix);f=stage/'fixture.bend';f.write_bytes((H/'row.bend').read_bytes());assert 'ALL PROOFS CHECK' in run(['bend',f,'--check-only'],15,name+'-check');dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,name+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,name+'-clang')
   out=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,name+'-run');expected=(H/'row-expected.txt').read_text();actual=out.splitlines();old=expected.splitlines();assert len(actual)==len(old)==4;assert [x.split(':',1)[0] for x in actual]==[x.split(':',1)[0] for x in old];at=next(i for i,(x,y) in enumerate(zip(actual,old)) if x!=y)
   witness='length2';at=1;assert actual[at]!=old[at]
   import json
   obj=json.loads(actual[at])
   if kind=='lost-raw':assert obj['array']==[100,101] and obj['inverse'][0][2]==100
   if kind=='other-cell':assert obj['array']==[700,9999]
   if kind=='stale-cached':assert obj['array']==[700,101] and obj['cached']['coordinates']['a']==999
   if kind=='wrong-true-old':assert [x[2] for x in obj['inverse']]==[77,77]
   r['cases'].append({'name':name,'status':'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','mutantQuerySHA256':hashlib.sha256((prefix+mutation+suffix).encode()).hexdigest(),'witness':{'label':witness,'expected':old[at],'actual':actual[at]},'fullCheckpoints':4});save()
 r['status']='ALL_REQUESTED_ACTUAL_PACKED_ROW_COMPILING_MUTANTS_DETECTED';save()
except BaseException as e:r['failure']=repr(e);save();raise
