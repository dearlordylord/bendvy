#!/usr/bin/env python3
import argparse,pathlib,json,hashlib,shutil,os,sys,importlib.util,subprocess,signal,time
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});HERE=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(BASE));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(name,path):s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
B=load('bounds',ROOT/'experiments/t05/run.py');S=load('slicer',BASE/'materialize-controls.py');E=load('independent_expected',BASE/'static-world-run.py');r={'status':'INCOMPLETE','scope':'Source generic Type owner and retained full Data snapshots across actual writes; finite only','CPU':10,'commands':[],'cases':[],'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'clientSHA256':sha(HERE/'retained-client.bend'),'fixtureSHA256':sha(BASE/'static-world-controls.bend'),'protectedExpectedSHA256':sha(BASE/'static-world-run.py')}
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
 generic=a.output/'generic';generic.mkdir();source=generic/'generic-owner.bend';source.write_text((HERE/'generic-owner.bend').read_text().replace('/tmp/bendvy-held-flat-both-reproduced-v5/',str(a.overlay.resolve())+'/'))
 for program in B.build(source,generic):assert B.execute(program)=='50';r['cases'].append({'kind':'generic Type owned arrays','programSHA256':sha(program),'expected':'50','status':'PASS'})
 mutant=generic/'generic-clone-negative.bend';mutant.write_text(source.read_text().replace('world,raw,+view','world,+raw,+view'));out=command(['bend',mutant,'--check-only'],expected=1);assert 'Data' in out and 'raw' in out;r['cases'].append({'kind':'generic Raw clone negative','status':'REJECTED_KIND_DATA','sourceSHA256':sha(mutant)})
 for observer in ('cached','raw'):
  for schema in ('motion','health'):
   folder=a.output/(observer+'-'+schema);folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);(core/'retained-client.bend').write_bytes((HERE/'retained-client.bend').read_bytes());text=(BASE/'static-world-controls.bend').read_text().replace('./prototype-static-client.bend','./retained-client.bend')
   if observer=='raw':
    for name in ('position','vitals','motion_ledger','health_ledger'):text=text.replace('P.'+name+'_get','P.'+name+'_uncached')
   other='health' if schema=='motion' else 'motion';text=text.replace('    '+other+'_start(True{})\n','').replace('    '+other+'_start(False{})\n','');text,retained,removed=S.reachable_fixture(text,'main');source=core/'retained-controls.bend';source.write_text(text)
   wanted=[]
   for foreign in (True,False):
    for ns in (1,2):
     record=E.expected(schema,ns,foreign)
     if not foreign:
      record['value']=1;record['world']['rows'][0]['main']['coordinates' if schema=='motion' else 'levels']['a']=30;record['world']['ledger']['totals']['a']=200
     wanted.extend([{'command':'MissingEntity'},record])
   for program in B.build(source,folder):
    out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');rows=[json.loads(x) for x in out.splitlines()];assert rows==wanted,(rows,wanted);r['cases'].append({'kind':'all-field retained Main/Ledger Data views','schema':schema,'observer':observer,'backend':'JS' if program.suffix=='.js' else 'Native','status':'PASS','records':len(rows),'sourceSHA256':sha(source),'clientSHA256':sha(core/'retained-client.bend'),'programSHA256':sha(program)})
 r['status']='GENERIC_TYPE_NEGATIVE_AND_FOUR_RETAINED_FULL_DATA_FIELDS_BOTH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
