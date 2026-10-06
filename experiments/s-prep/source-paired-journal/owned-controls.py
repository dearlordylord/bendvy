#!/usr/bin/env python3
"""Independent literals for affine private owner transport; no performance acceptance."""
import argparse,pathlib,json,hashlib,os,subprocess,signal,time,importlib.util
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});here=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('bounded','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':8,'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'commands':[],'cases':[]}
r['recipeSHA256']=sha(pathlib.Path(__file__))
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'output':out};r['commands'].append(rec);save();assert c.returncode==expected and not timed,rec;return out
B.command=command
try:
 success='8/3|M7/1:7;L:9;L:77;=30,7,7,7|40,8,8,8|50,9,9,9|[11,11,11,11][66,66,66,66]|11,12,9,|8/2,7/1,7/2,'
 failure='8/3|M7/1:7;L:9;L:77;=7,7,7,7|40,8,8,8|77,9,9,9|reverted'
 for name,wanted,anchor,mutant in [('generic-paired-owner','50','raw,+view','+raw,+view')]:
  folder=a.output/name;folder.mkdir();src=folder/(name+'.bend');text=(here/(name+'.bend')).read_text().replace('OVERLAY',str(a.overlay.resolve()));src.write_text(text)
  for program in B.build(src,folder):
   observed=B.execute(program);assert observed==wanted,(observed,wanted);r['cases'].append({'kind':name,'backend':'JS' if program.suffix=='.js' else 'Native','expected':wanted,'observed':observed,'programSHA256':sha(program),'status':'PASS'})
  if anchor is None:continue
  assert text.count(anchor)==1;neg=folder/'clone-negative.bend';neg.write_text(text.replace(anchor,mutant));out=command(['bend',neg,'--check-only'],expected=1);assert 'Data' in out and ('raw' if name=='generic-paired-owner' else 'owner' if name=='generic-returned-owner' else 'scope') in out;r['cases'].append({'kind':name+' clone','status':'REJECTED_KIND_DATA','sourceSHA256':sha(neg)})
 r['status']='AFFINE_PRIVATE_OWNER_TYPE_POSITIVES_AND_CLONE_NEGATIVES_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
