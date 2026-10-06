#!/usr/bin/env python3
"""Actual compiling finite Slot/Rows mutations, exact intended full-field witnesses."""
import argparse,json,pathlib,hashlib,shutil,subprocess,signal,os,time
from pins import verify
H=pathlib.Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();files,pins,closure=verify(a.overlay);a.output.mkdir(exist_ok=False);allrows=[]
def sha(b):return hashlib.sha256(b).hexdigest()
def run(cmd,cap,stage,label,row):
 cmd=['taskset','-c','10',*map(str,cmd)];env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';st=time.monotonic();ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env);e={'argv':cmd,'limitSeconds':cap};row['commands'].append(e)
 try:o,err=ch.communicate(timeout=cap)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);o,err=ch.communicate();e['status']='TIMEOUT';(stage/(label+'.stdout')).write_text(o);(stage/(label+'.stderr')).write_text(err);raise
 (stage/(label+'.stdout')).write_text(o);(stage/(label+'.stderr')).write_text(err);e.update(returncode=ch.returncode,elapsedSeconds=time.monotonic()-st);assert ch.returncode==0,(label,ch.returncode,o,err);return o,err
for schema,stem,raw in [('motion','position','coordinates'),('health','vitals','levels')]:
 fixture=H/(schema+'-slot-lifecycle.bend');expected=(H/(schema+'-slot-lifecycle-expected.txt')).read_text();expected_json=[json.loads(x) for x in expected.splitlines() if x.startswith('{')]
 cp=files['cached-payload.bend'].decode();start=cp.index('def prototype_slot_'+stem+'_swap_done(');end=cp.index('\ndef prototype_slot_'+stem+'_swap(',start);body=cp[start:end];write='Array.set(U32,'+raw+',0,value)';assert body.count(write)==1
 for name in ['lost-raw','other-cell','stale-cached','true-old','removed-membership']:
  mutation=dict(files);modified=body
  if name=='lost-raw':modified=body.replace(write,raw)
  elif name=='other-cell':modified=body.replace(write,'Array.set(U32,Array.set(U32,'+raw+',1,0),0,value)')
  elif name=='stale-cached':
   old=',rawframe,value,b,c,d,cachedframe}' if schema=='motion' else ',rawreserve,rawclass,value,b,c,d,cachedreserve,cachedclass}'
   assert body.count(old)==1;modified=body.replace(old,old.replace(',value,',',999,'))
  elif name=='true-old':assert body.count('},old)')==1;modified=body.replace('},old)','},value)')
  if name=='removed-membership':
   storage=files['storage.bend'].decode();old='metadata_set(F,f,U32.sub(id,1),Metadata{False{},None{},0,0})';assert storage.count(old)==1;mutation['storage.bend']=storage.replace(old,old.replace('False{}','True{}')).encode()
  else:assert modified!=body;mutation['cached-payload.bend']=(cp[:start]+modified+cp[end:]).encode()
  stage=a.output/(schema+'-'+name);stage.mkdir();[ (stage/n).write_bytes(b) for n,b in mutation.items() ];f=stage/'fixture.bend';shutil.copyfile(fixture,f)
  row={'schema':schema,'mutation':name,'status':'INCOMPLETE','parentClosure':closure,'actualMutated29':{'experiments/s-integrate/'+n:sha(b) for n,b in mutation.items()},'fixtureSHA256':sha(f.read_bytes()),'expectedSHA256':sha(expected.encode()),'commands':[],'subjects':{}}
  try:
   o,err=run(['bend',f,'--check-only'],15,stage,'check',row);assert 'ALL PROOFS CHECK' in o+err
   for backend in ['JS','Native']:
    dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,stage,backend+'-emit',row)
    if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,stage,'clang',row)
    out,err=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,stage,backend+'-run',row);assert out!=expected,'mutant did not change any literal observation'
    if name=='removed-membership':assert 'missing:1:2\nunexpected-present\n' in out;witness={'expectedNext':'missing:1:3','observedNext':'unexpected-present'}
    else:
     values=[json.loads(x) for x in out.splitlines() if x.startswith('{')];assert len(values)==5
     if name=='lost-raw':assert values[0]['array'][0]==100 and expected_json[0]['array'][0]==700;witness={'length':1,'path':'array[0]','expected':700,'observed':100}
     elif name=='other-cell':assert values[1]['array'][1]==0 and expected_json[1]['array'][1]==101;witness={'length':2,'path':'array[1]','expected':101,'observed':0}
     elif name=='stale-cached':key='coordinates' if schema=='motion' else 'levels';assert values[0]['cached'][key]['a']==999;witness={'length':1,'path':'cached.'+key+'.a','expected':700,'observed':999}
     else:assert values[0]['old']==[500,700] and expected_json[0]['old']==[100,500];witness={'length':1,'path':'old','expected':[100,500],'observed':[500,700]}
    row['subjects'][backend]={'status':'INTENDED_RUNTIME_COUNTEREXAMPLE','witness':witness,'outputSHA256':sha(out.encode())}
   row['status']='COMPILING_MUTATION_DETECTED_BOTH_BACKENDS'
  except BaseException as e:row['status']='FAIL_OR_BLOCKED';row['failure']=repr(e)
  (stage/'evidence.json').write_text(json.dumps(row,indent=2)+'\n');allrows.append(row);print(schema,name,row['status'],flush=True)
(a.output/'evidence.json').write_text(json.dumps({'status':'PASS' if all(x['status']=='COMPILING_MUTATION_DETECTED_BOTH_BACKENDS' for x in allrows) else 'INCOMPLETE','parentClosure':closure,'source29':pins,'variants':allrows,'noUniversalProofOrHostDispatchClaim':True},indent=2)+'\n');assert all(x['status']=='COMPILING_MUTATION_DETECTED_BOTH_BACKENDS' for x in allrows)
