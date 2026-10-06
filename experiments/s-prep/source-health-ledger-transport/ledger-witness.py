#!/usr/bin/env python3
"""Independent literal true-old/raw/view/epoch preservation, including compiling mutants."""
import argparse,pathlib,json,hashlib,shutil,os,sys,importlib.util,subprocess,signal,time,copy
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});HERE=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sp=importlib.util.spec_from_file_location('B',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B);r={'status':'INCOMPLETE','scope':'Finite private-array witness; cached first intentionally differs from true raw old; all snapshot fields, epoch and array depths0-3; no universal authority/refinement','sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'fixtureSHA256':sha(HERE/'ledger-old-witness.bend'),'CPU':10,'commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 t=time.monotonic();c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'seconds':time.monotonic()-t,'output':out};r['commands'].append(rec);save();assert c.returncode==expected and not timed,rec;return out
B.command=command
four=lambda a,b,c,d:{'a':a,'b':b,'c':c,'d':d}
main={'levels':four(10,10,10,10),'reserve':9,'class':2};cached={'totals':four(500,200,300,400),'epoch':77};retained={'totals':four(999,200,300,400),'epoch':77};handle={'namespace':8,'id':4}
wanted=[]
for n in [1,2,4,8]:
 raw=[100+i for i in range(n)];raw[0]=500
 wanted.append({'label':n,'main':main,'mainCached':main,'totals':four(*[raw[i%n] for i in range(4)]),'rawArray':raw,'epoch':4,'cached':cached,'retained':retained,'handle':handle,'mark':handle,'old':100,'prior':55})
try:
 for kind in ('original','wrong-old','omitted-write','omitted-epoch'):
  folder=a.output/kind;folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);adapter=core/'held-adapter.bend';text=adapter.read_text();start=text.index('def prototype_flatledger_health_setledger_done(');end=text.index('\ndef ',start+1);before=text[start:end];after=before
  if kind=='wrong-old':assert before.count('X.LedgerInverse{old} <> undo')==1;after=before.replace('X.LedgerInverse{old} <> undo','X.LedgerInverse{value} <> undo')
  if kind=='omitted-write':assert before.count('Array.set(U32,totals,0,value)')==1;after=before.replace('Array.set(U32,totals,0,value)','totals')
  if kind=='omitted-epoch':assert before.count('),epoch,P.health_ledger_patch')==1;after=before.replace('),epoch,P.health_ledger_patch','),0,P.health_ledger_patch')
  if kind!='original':assert after!=before;adapter.write_text(text[:start]+after+text[end:])
  source=folder/'ledger-old-witness.bend';source.write_text((HERE/'ledger-old-witness.bend').read_text().replace('/tmp/bendvy-health-ledger-flat-v3/experiments/s-integrate/',str(core.resolve())+'/'))
  programs=B.build(source,folder)
  for program in programs:
   output=B.execute(program);(folder/(program.name+'.jsonl')).write_text(output+'\n');rows=[json.loads(x) for x in output.splitlines()];expected=copy.deepcopy(wanted)
   if kind=='wrong-old':
    for row in expected:row['old']=500
   if kind=='omitted-write':
    for row in expected:
     raw=[100+i for i in range(row['label'])];row['totals']=four(*[raw[i%len(raw)] for i in range(4)]);row['rawArray']=raw
   if kind=='omitted-epoch':
    for row in expected:row['epoch']=0
   assert rows==expected,(kind,rows,expected)
   assert (rows==wanted)==(kind=='original')
   r['cases'].append({'kind':kind,'backend':'JS' if program.suffix=='.js' else 'Native','status':'PASS' if kind=='original' else 'DETECTED_EXACT_COMPILING_COUNTEREXAMPLE','records':len(rows),'sourceSHA256':sha(source),'adapterSHA256':sha(adapter),'programSHA256':sha(program)});save()
 r['status']='TRUE_OLD_OWNED_ARRAY_ALL_FIELDS_AND_THREE_COMPILING_MUTANTS_BOTH_BACKENDS_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
