#!/usr/bin/env python3
"""Frozen wrapper correctness: original buffered readers and historical-stale lifecycle; no timing cohorts."""
import argparse,hashlib,importlib.util,json,os,pathlib,signal,subprocess
P=pathlib.Path;ROOT=P('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-integrate'
p=argparse.ArgumentParser();p.add_argument('--prepared',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--sizes',type=int,nargs='+',default=[64]);p.add_argument('--cpu',type=int,default=6);a=p.parse_args();assert all(n in [64,256,1024] for n in a.sizes);a.output.mkdir(parents=True,exist_ok=False);core=a.prepared/'core';adapt=json.loads((a.prepared/'adaptation.json').read_text());assert adapt['status']=='PREPARED_TRANSPORT_ONLY'
sha=lambda b:hashlib.sha256(b).hexdigest();r={'status':'INCOMPLETE','scope':'Four available frozen algorithms: complete fields; buffered readers and historical-stale lifecycle retain original bodies. Dense/sparse original sample inner body called twice. Quiet FailedTxn not admitted. Same-process fresh warmup; no timing/qualification/full22 acceptance','sourceClosureSHA256':adapt['sourceClosureSHA256'],'adaptationSHA256':sha((a.prepared/'adaptation.json').read_bytes()),'commands':[],'families':{}}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 out=a.output/(label+'.txt');entry={'argv':list(map(str,argv)),'limitSeconds':limit,'log':out.name};r['commands'].append(entry);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with out.open('w') as f:
  proc=subprocess.Popen(['taskset','-c',str(a.cpu),*map(str,argv)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True,env=env)
  try:entry['exit']=proc.wait(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait();entry['status']='TIMEOUT';save();raise RuntimeError('Deadline: '+label)
 entry['sha256']=sha(out.read_bytes());save();assert entry['exit']==0,(entry,out.read_text()[-3000:]);return out.read_text()
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
# Invoke unchanged independent validators, never their original execution/timing main.
B=module('ready_dense',BASE/'measurement-bend-run.py');L=module('ready_lifecycle',BASE/'measurement-lifecycle-run.py');R=module('ready_readers',BASE/'measurement-readers-run.py');F=module('ready_failure',BASE/'measurement-failure-oracle.py');LT=module('ready_frozen_lifecycle',BASE/'measurement-lifecycle-timed-run.py')
validators={'dense':B,'sparse':B,'lifecycle':L,'readers':R,'failed-transaction':F};r['validatorPins']={n:sha((BASE/n).read_bytes()) for n in ['measurement-bend-run.py','measurement-lifecycle-run.py','measurement-readers-run.py','measurement-failure-oracle.py','measurement-lifecycle-timed-run.py']};r['referenceAdapterSHA256']=sha((BASE/'measurement-reference.mjs').read_bytes());r['recipes']={P(__file__).name:sha(P(__file__).read_bytes())};save()
reference=a.output/'reference-warmup.mjs';reference.write_text("import {pathToFileURL} from 'node:url';\nconst reference="+json.dumps(str(BASE/'measurement-reference.mjs'))+";\nprocess.argv=[process.execPath,reference,...process.argv.slice(2)];\nawait import(pathToFileURL(reference).href+'?slot_readiness_warmup');\nawait import(pathToFileURL(reference).href+'?slot_readiness_fresh');\n")
frozen_reference=a.output/'frozen-lifecycle-reference.mjs';frozen_reference.write_text("import {pathToFileURL} from 'node:url';\nconst reference="+json.dumps(str(BASE/'measurement-lifecycle-timing-reference.mjs'))+";\nprocess.argv=[process.execPath,reference,...process.argv.slice(2),'1'];\nconsole.log('READINESS-WARMUP-BEGIN');\nawait import(pathToFileURL(reference).href+'?slot_readiness_warmup');\nconsole.log('READINESS-WARMUP-END');\nawait import(pathToFileURL(reference).href+'?slot_readiness_fresh');\nconsole.log('READINESS-FRESH-END');\n")
r['frozenReferenceSHA256']=sha((BASE/'measurement-lifecycle-timing-reference.mjs').read_bytes())
def verify():
 assert all(sha((core/P(n).name).read_bytes())==v for n,v in adapt['sourcePins'].items())
 assert all(sha((core/n).read_bytes())==v for n,v in adapt['extraPins'].items())
try:
 verify();run(['bend','version'],5,'version');run(['bend','guide'],5,'guide')
 for family,entry in [('dense','measurement-samples-bend.bend'),('sparse','measurement-samples-bend.bend'),('lifecycle','measurement-lifecycle-timed.bend'),('readers','measurement-samples-readers.bend')]:
  item={'status':'PREPARING','route':adapt['route'],'cases':[]};r['families'][family]=item;save()
  name='frozen-readiness-'+family;driver=core/(name+'.bend');argc='schema:Maybe<&2,U32>,count:Maybe<&2,U32>'
  call='M.choose(schema,'+('1' if family=='sparse' else '0')+',count)' if family in ['dense','sparse'] else ('W.once(schema,count,True{})' if family=='lifecycle' else 'W.choose(schema,count)')
  driver.write_text('import Base\nimport ./'+adapt['entries'][entry]+' as W\nimport ./'+adapt['entries']['measurement-bend.bend']+' as M\n'+f'''def choose(+schema:U32,+count:U32) -> IO(Unit):
  do IO<Unit>:
    IO.print("READINESS-WARMUP-BEGIN")
    {call}
    IO.print("READINESS-WARMUP-END")
    {call}
    IO.print("READINESS-FRESH-END")
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{{schema}} Some{{count}}: choose(schema,count)
    case _ _: IO.die(Unit,2,"schema count required")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{{_,Con{{schema,Con{{count,_}}}}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
''');item['driverSHA256']=sha(driver.read_bytes())
  try:
   check=run(['bend',driver,'--check-only'],15,name+'-check');assert 'ALL PROOFS CHECK' in check
   js=a.output/(name+'.js');c=a.output/(name+'.c');native=a.output/(name+'-native');run(['bend',driver,'-o',js],30,name+'-emitJS');run(['bend',driver,'-o',c],30,name+'-emitC');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',native,'-lm','-pthread'],120,name+'-clang');item['buildStatus']='PASS'
  except BaseException as e:item.update(status='BUILD_BLOCKED',error=repr(e));save();continue
  for n in a.sizes:
   for sn,schema in enumerate(['Motion','Health']):
    case={'schema':schema,'size':n,'backends':{}};item['cases'].append(case);save()
    try:
     text=run(['node',reference,schema,family,n],5,f'{family}-{schema}-{n}-reference');refs=[json.loads(line) for line in text.splitlines()];assert len(refs)==2 and all(x['status']=='PASS' for x in refs);case['reference']='TWO_FRESH_WORLDS_SAME_PROCESS_PASS'
     if family=='lifecycle':
      frozen=run(['node',frozen_reference,schema,n],5,f'{family}-{schema}-{n}-frozen-reference');warm,fresh=frozen[len('READINESS-WARMUP-BEGIN\n'):].split('READINESS-WARMUP-END\n');fresh=fresh[:-len('READINESS-FRESH-END\n')];values=[LT.validate(body,schema,n,'TS',True,ref) for body,ref in zip([warm,fresh],refs)];[v.pop('milliseconds') for v in values];case['actualFrozenReferenceFullFields']=values
    except BaseException as e:case['reference']='BLOCKED';case['error']=repr(e);save();continue
    for backend,argv in [('JS',['node',js,sn,n]),('Native',[native,sn,n,'--threads','1','--gpu','off'])]:
     try:
      text=run(argv,5,f'{family}-{schema}-{n}-{backend}');assert text.startswith('READINESS-WARMUP-BEGIN\n') and text.endswith('READINESS-FRESH-END\n');warm,fresh=text[len('READINESS-WARMUP-BEGIN\n'):].split('READINESS-WARMUP-END\n');fresh=fresh[:-len('READINESS-FRESH-END\n')];results=[]
      for body,ref in zip([warm,fresh],refs):
       if family in ['dense','sparse']:v=B.validate(body,schema,family=='sparse',n,ref);v.pop('milliseconds')
       elif family=='lifecycle':v=LT.validate(body,schema,n,backend,True,ref);v.pop('milliseconds')
       elif family=='readers':
        lines=body.splitlines();clock=json.loads(lines[-1]);assert set(clock)=={'timingMilliseconds'} and isinstance(clock['timingMilliseconds'],int);v=R.validate('\n'.join(lines[:-1])+'\n',schema,n,ref)
       else:v=F.validate(body,ref)
       results.append(v)
      case['backends'][backend]={'status':'FULL_FIELDS_TWO_FRESH_WORLDS_SAME_PROCESS_PASS','warmup':results[0],'fresh':results[1],'wholeOutputSHA256':sha(text.encode())};save()
     except BaseException as e:case['backends'][backend]={'status':'BLOCKED_OR_MISMATCH','error':repr(e)};save()
  item['status']='FULL_FIELDS_READY_LISTED_SIZES' if len(item['cases'])==2*len(a.sizes) and all(c.get('reference')=='TWO_FRESH_WORLDS_SAME_PROCESS_PASS' and len(c['backends'])==2 and all(v['status']=='FULL_FIELDS_TWO_FRESH_WORLDS_SAME_PROCESS_PASS' for v in c['backends'].values()) for c in item['cases']) else 'PARTIAL_OR_BLOCKED';save()
 verify();r['status']='LISTED_FOUR_AVAILABLE_FROZEN_FAMILIES_FULL_FIELDS_PASS' if len(r['families'])==4 and all(x['status']=='FULL_FIELDS_READY_LISTED_SIZES' for x in r['families'].values()) else 'PARTIAL_OR_BLOCKED';save()
except BaseException as e:r['error']=repr(e);save();raise
