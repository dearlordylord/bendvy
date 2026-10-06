#!/usr/bin/env python3
import argparse,pathlib,json,hashlib,shutil,os,sys,importlib.util,subprocess,signal,time,copy
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});HERE=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(BASE));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(name,path):s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
B=load('bounds',ROOT/'experiments/t05/run.py');S=load('slicer',BASE/'materialize-controls.py');E=load('independent_expected',BASE/'static-world-run.py');r={'status':'INCOMPLETE','scope':'Compiling returned-owner omission witness using exact retained client and independent full-field expectation; finite only','CPU':8,'commands':[],'cases':[],'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'clientSHA256':sha(HERE/'retained-client.bend'),'fixtureSHA256':sha(BASE/'static-world-controls.bend'),'protectedExpectedSHA256':sha(BASE/'static-world-run.py')}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 st=time.monotonic();c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'seconds':time.monotonic()-st,'output':out};r['commands'].append(rec);save();assert c.returncode==expected,rec;return out
B.command=command
try:
 for observer in ('raw',):
  for schema in ('motion','health'):
   folder=a.output/(observer+'-'+schema);folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);(core/'retained-client.bend').write_bytes((HERE/'retained-client.bend').read_bytes());text=(BASE/'static-world-controls.bend').read_text().replace('./prototype-static-client.bend','./retained-client.bend')
   for lane in ('motion','health'):text=text.replace('HA.'+lane+'_row(', 'HA.prototype_flatjournal_'+lane+'_row(')
   if observer=='raw':
    for name in ('position','vitals','motion_ledger','health_ledger'):text=text.replace('P.'+name+'_get','P.'+name+'_uncached')
   other='health' if schema=='motion' else 'motion';text=text.replace('    '+other+'_start(True{})\n','').replace('    '+other+'_start(False{})\n','');text,retained,removed=S.reachable_fixture(text,'main');source=core/'retained-controls.bend';source.write_text(text)
   adapter=core/'held-adapter.bend';body=adapter.read_text();begin=body.index('def '+('prototype_flatfold_motion' if schema=='motion' else 'prototype_journalledger_health')+'_returned(');end=body.index('\ndef ',begin+1);chunk=body[begin:end];anchor='Some{CC.Cache{main_raw,main_cached}}';assert chunk.count(anchor)==1
   replacement='T.Position{[0:U32^2n],0}' if schema=='motion' else 'T.Vitals{[0:U32^2n],0,0}'
   chunk=chunk.replace(anchor,'Some{CC.Cache{'+replacement+',main_cached}}');adapter.write_text(body[:begin]+chunk+body[end:]);r.setdefault('mutations',[]).append({'schema':schema,'family':('prototype_flatfold_motion' if schema=='motion' else 'prototype_journalledger_health')+'_returned','kind':'discard returned affine Main Raw at final reconstruction','sourceSHA256':sha(adapter),'anchorCount':1})
   wanted=[]
   for foreign in (True,False):
    for ns in (1,2):
     record=E.expected(schema,ns,foreign)
     if not foreign:
      record['value']=1;record['world']['rows'][0]['main']['coordinates' if schema=='motion' else 'levels']['a']=30;record['world']['ledger']['totals']['a']=200
     wanted.extend([{'command':'MissingEntity'},record])
   for program in B.build(source,folder):
    out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');rows=[json.loads(x) for x in out.splitlines()];mutated=copy.deepcopy(wanted)
    for index in (5,7):
     main=mutated[index]['world']['rows'][0]['main'];main['coordinates' if schema=='motion' else 'levels']={k:0 for k in ('a','b','c','d')}
     if schema=='motion':main['frame']=0
     else:main['reserve']=0;main['class']=0
    assert rows==mutated and rows!=wanted,(rows,mutated,wanted);r['cases'].append({'kind':'all-field retained Main/Ledger Data views','schema':schema,'observer':observer,'backend':'JS' if program.suffix=='.js' else 'Native','status':'COMPILED_MUTANT_DETECTED_EXACT_RETURNED_RAW','records':len(rows),'sourceSHA256':sha(source),'clientSHA256':sha(core/'retained-client.bend'),'programSHA256':sha(program)})
 r['status']='ACTUAL_RETURNED_OWNER_DISCARD_MUTANT_BOTH_SCHEMAS_BACKENDS_DETECTED'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
