#!/usr/bin/env python3
"""Compile actual reached Q defects; detect with unchanged finite field oracles."""
import argparse,hashlib,json,os,pathlib,re,shutil,signal,subprocess
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--baseline',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--cpu',type=int,default=6);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);base=json.loads((a.baseline/'evidence.json').read_text());assert base['status']=='GENERIC_AFFINE_HANDOFF_FINITE_FIELDS_AND_INTENDED_NEGATIVES_PASS';assert base['sourceClosureSHA256']=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55';sha=lambda b:hashlib.sha256(b).hexdigest();r={'status':'INCOMPLETE','sourceClosureSHA256':base['sourceClosureSHA256'],'sourceManifest':base['sourceManifest'],'scope':'Three actual compiling Q producer/recovery mutants only; no HA packed-consumer/Tx/production authority or proof acceptance','commands':[],'subjects':{}};save=lambda:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap,label):
 e={'argv':list(map(str,argv)),'limitSeconds':cap,'log':label+'.txt'};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with (a.output/e['log']).open('w') as f:
  child=subprocess.Popen(['taskset','-c',str(a.cpu),*map(str,argv)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True,env=env)
  try:e['exit']=child.wait(timeout=cap)
  except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait();e['status']='TIMEOUT';save();raise RuntimeError('Deadline '+label)
 text=(a.output/e['log']).read_text();e['sha256']=sha(text.encode());save();assert e['exit']==0,(e,text[-2000:]);return text
q=(a.baseline/'core/query.bend').read_text()
changes={'lost-owner':('Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner})','Array.set(Maybe<M>,columns,U32.sub(id,1),None{})'),'reversed-ids':('case HandoffNil{}: (columns,List.reverse(&2,U32,ids))','case HandoffNil{}: (columns,ids)')}
try:
 for mutant in ['lost-owner','reversed-ids','wrong-selection']:
  core=a.output/mutant/'core';shutil.copytree(a.baseline/'core',core)
  if mutant=='wrong-selection':
   start=q.index('def prototype_handoff_struct_idx_metadata(');end=q.index('\ndef ',start+4);old=q[start:end];assert old.count('selected(F,selection,flag)')==1;new=q[:start]+old.replace('selected(F,selection,flag)','Bool.not(selected(F,selection,flag))')+q[end:]
  else:
   old,new=changes[mutant];assert q.count(old)==1;new=q.replace(old,new)
  (core/'query.bend').write_text(new);entry={'mutatedQuerySHA256':sha(new.encode()),'roles':{}};r['subjects'][mutant]=entry;save()
  assert all(sha((core/P(n).name).read_bytes())==h for n,h in base['sourceManifest'].items()if P(n).name!='query.bend')
  for subject,b in base['subjects'].items():
   f=core/(subject+'.bend');assert sha(f.read_bytes())==b['fixtureSHA256'];expected=(a.baseline/(subject+'-oracle.txt')).read_text();assert sha(expected.encode())==b['oracleSHA256'];name=mutant+'-'+subject;run(['bend',f,'--check-only'],15,name+'-check');js=a.output/(name+'.js');c=a.output/(name+'.c');native=a.output/(name+'-native');run(['bend',f,'-o',js],30,name+'-emitJS');run(['bend',f,'-o',c],30,name+'-emitC');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',native,'-lm','-pthread'],120,name+'-clang')
   for backend,cmd in [('JS',['node',js]),('Native',[native,'--threads','1','--gpu','off'])]:
    actual=run(cmd,5,name+'-'+backend);assert len(actual.splitlines())==200;assert actual!=expected;difference=next({'line':i,'actual':x,'expected':y}for i,(x,y)in enumerate(zip(actual.splitlines(),expected.splitlines()))if x!=y);entry['roles'][subject+'-'+backend]={'status':'ACTUAL_COMPILING_DEFECT_DETECTED','fixtureSHA256':b['fixtureSHA256'],'oracleSHA256':b['oracleSHA256'],'firstDifference':difference};save()
 r['status']='THREE_REACHED_COMPILING_QUERY_DEFECTS_ALL_EIGHT_ROLES_DETECTED';save()
except BaseException as e:r.update(status='FAIL',error=repr(e));save();raise
