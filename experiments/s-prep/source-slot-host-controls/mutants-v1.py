#!/usr/bin/env python3
"""Twelve reached original Host mutations on frozen private Slot services; finite only."""
from pathlib import Path
import argparse,json,re,shutil,hashlib,gzip,subprocess,signal,os,importlib.util
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();p=argparse.ArgumentParser();p.add_argument('--motion',type=Path,required=True);p.add_argument('--health',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',action='append');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
parents={}
for schema,d in [('motion',a.motion),('health',a.health)]:
 e=json.loads((d/'evidence.json').read_text());assert e['status']=='FRESH_ORIGINAL_SLOT_HOST_SCHEMA_BOTH_CAPTURES_BOTH_BACKENDS_PASS';ad=json.loads((d/'adapted/adaptation.json').read_text());core=d/'adapted/core';assert all(sha(core/Path(n).name)==h for n,h in e['sourcePins'].items());assert all(sha(core/n)==h for n,h in ad['fixturePins'].items());parents[schema]=(d,e,ad)
assert parents['motion'][1]['sourcePins']==parents['health'][1]['sourcePins'];core0=a.motion/'adapted/core';rules=[
 ('query-order','query.bend','struct_idx_finish','List.reverse(&2,O,values)','values','snapshots'),
 ('suppressed-setter','cached-payload.bend','prototype_slot_position_swap_done','(PrototypeMotionMainSlot{Array.set(U32,coordinates,0,value),rawframe,value,b,c,d,cachedframe},old)','(PrototypeMotionMainSlot{coordinates,rawframe,old,b,c,d,cachedframe},old)','ownWrites'),
 ('inverse-order','transaction.bend','tx_finish_failure','unwind(W,H,restore_main,restore_ledger,undo,world)','unwind(W,H,restore_main,restore_ledger,List.reverse(&2,Inverse<H>,undo),world)','snapshots'),
 ('failed-cursor','readers.bend','complete','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)','reads'),
 ('other-reader-routing','readers.bend','replace_case','case False{}: head <> tail','case False{}: value <> tail','reads'),
 ('skip-change-cursor','readers.bend','skip_found','T.ReaderState{registered,last,now}','T.ReaderState{registered,now,now}','reads'),
 ('reset-capture','capture.bend','incremented','Array.set(U32,array,0,U32.add(count,1))','Array.set(U32,array,0,count)','dispatches'),
 ('reversed-command-FIFO','commands.bend','apply_world','batch(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,Running{rows,[]})','batch(Schema,M,A,F,pending,namespace,tick,Running{rows,[]})','snapshots'),
 ('implicit-flush','dispatcher.bend','tick_frame','run(W,H,presence,invoke,barrier,transition,nodes,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})','IO.bind(Runtime<W,H>,Dispatched<W,H>,deferred(W,H,barrier,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}),state => run(W,H,presence,invoke,barrier,transition,nodes,state))','snapshots'),
 ('failed-publication-leak','transaction.bend','tx_finish_failure','case Tx{world,_,undo,_,_,_}: Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}','case Tx{world,_,undo,commands,pings,marks}: Committed{unwind(W,H,restore_main,restore_ledger,undo,world),List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks}','reads'),
 ('failed-change-stamp','transaction.bend','tx_finish_failure','case Tx{world,_,undo,_,_,_}: Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}','case Tx{world,_,undo,_,_,marks}: Committed{unwind(W,H,restore_main,restore_ledger,undo,world),[],[],marks}','reads'),
 ('reissued-failed-reservation','transaction.bend','storage_commit','case Reverted{world}: (world,[])','case Reverted{world}: (storage_rewind(Schema,M,A,F,L,Mode,world),[])','rawReservations')]
# Bind exact callee bodies; no mutation may silently target a retained but unreachable definition.
def block(s,name):return re.search(r'^def '+re.escape(name)+r'\(.*?(?=\ndef |\ntype |\Z)',s,re.M|re.S)[0]
reach={}
for schema,d in [('motion',a.motion),('health',a.health)]:
 if not (d/'source-reachability.json').exists():subprocess.run(['python3',H/'reachable.py','--entry',d/'adapted/core'/('host-'+schema+'-fixture.bend'),'--output',d/'source-reachability.json'],check=True,timeout=15)
 reach[schema]=set(json.loads((d/'source-reachability.json').read_text())['definitions'])
# Current command helper name is checked from the exact unique live anchor.
for i,row in enumerate(rules):
 if row[0]=='reversed-command-FIFO':
  s=(core0/row[1]).read_text();heads=list(re.finditer(r'^def ([\w.]+)\(',s,re.M));found=[m[1] for m in heads if row[3] in block(s,m[1])];assert len(found)==1;rules[i]=(row[0],row[1],found[0],*row[3:])
ref=json.loads(gzip.decompress((H/'original-reference.json.gz').read_bytes()));expected={x['lane']:x for x in ref['results']}
def load(name):
 spec=importlib.util.spec_from_file_location(name,ROOT/'experiments/s-integrate'/(name+'.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
D=load('trace-decode');C=load('trace-compare');r={'status':'INCOMPLETE','scope':'Fresh actual original private Slot Host12 mutation coverage; no full22/adoption','sourcePins':parents['motion'][1]['sourcePins'],'originalReceiptPins':{s:sha(d/'evidence.json') for s,(d,e,ad) in parents.items()},'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for label,file,fn,before,after,channel in rules:
 if a.only and label not in a.only:continue
 folder=a.output/label;folder.mkdir();core=folder/'core';shutil.copytree(core0,core);shutil.copyfile(a.health/'adapted/core/host-health-body.bend',core/'host-health-body.bend');shutil.copyfile(a.health/'adapted/core/host-health-fixture.bend',core/'host-health-fixture.bend');case={'label':label,'target':file+':'+fn,'intendedChannel':channel,'status':'INCOMPLETE','commands':[]};r['cases'].append(case);save()
 def run(cmd,limit,log):
  cmd=list(map(str,cmd));proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);entry={'command':cmd,'limitSeconds':limit};case['commands'].append(entry)
  try:o,_=proc.communicate(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);o,_=proc.communicate();entry.update(status='TIMEOUT',exit=proc.returncode);(folder/(log+'.txt')).write_text(o);save();raise RuntimeError(log+' timeout')
  (folder/(log+'.txt')).write_text(o);entry.update(exit=proc.returncode,outputSHA256=hashlib.sha256(o.encode()).hexdigest());save();assert proc.returncode==0,o;return o
 try:
  assert file+':'+fn in reach['motion'] or file+':'+fn in reach['health'],'Mutation target not in original source closure';target=core/file;s=target.read_text();old=block(s,fn);assert old.count(before)==1;new=old.replace(before,after,1)
  if label=='skip-change-cursor':assert 'now: U32' in new;new=new.replace('now: U32','+now: U32',1)
  changed=s.replace(old,new,1)
  if label=='reissued-failed-reservation':
   helper='def storage_rewind(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,world:S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode>:\n  match world:\n    case S.World{ns,next,rows,pending,ledger,mode}: S.World{ns,U32.sub(next,1),rows,pending,ledger,mode}\n';assert 'def storage_rewind(' not in changed;changed=changed.replace('def storage_commit(',helper+'\ndef storage_commit(',1)
  target.write_text(changed);case.update(originalDefinitionSHA256=hashlib.sha256(old.encode()).hexdigest(),mutatedDefinitionSHA256=hashlib.sha256(new.encode()).hexdigest(),mutantSourcePins={n:sha(core/Path(n).name) for n in r['sourcePins']},fixturePins={n:sha(core/n) for n in parents['motion'][2]['fixturePins'] if (core/n).exists()});programs={}
  for schema in ['motion','health']:
   entry=core/('host-'+schema+'-fixture.bend');run(['bend',entry,'--check-only'],15,schema+'-check');run(['bend',entry,'-o',folder/(schema+'.js')],30,schema+'-js-emit');run(['bend',entry,'-o',folder/(schema+'.c')],30,schema+'-c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',folder/(schema+'.c'),'-pthread','-lm','-o',folder/(schema+'.native')],120,schema+'-clang');programs[schema]=True
  observations=[]
  for backend in ['js','native']:
   raws=[]
   for schema in ['motion','health']:
    cmd=['node',folder/(schema+'.js')] if backend=='js' else [folder/(schema+'.native'),'--threads','1','--gpu','off'];raws.append(run(cmd,5,schema+'-'+backend+'-run'))
   raw='\n'.join(raws)
   try:
    decoded=D.decode(raw);(folder/(backend+'-decoded.json')).write_text(json.dumps(decoded,indent=2)+'\n');actual={x['lane']:x for x in decoded['results']};assert len(actual)==4 and set(actual)==set(expected);diff=[]
    for lane in sorted(expected):
     for ch in C.CHANNELS:C.difference(expected[lane][ch],actual[lane][ch],lane+'.'+ch,diff)
    intended=[x for x in diff if '.'+channel in x['path']]
    if label=='failed-publication-leak':intended=[x for x in intended if '.messages' in x['path']]
    assert intended,(label,backend,diff[:3]);(folder/(backend+'-differences.json')).write_text(json.dumps(diff,indent=2)+'\n');observations.append({'backend':backend,'compiling':True,'differenceCount':len(diff),'intendedDifferenceCount':len(intended),'witness':intended[0]})
   except ValueError as error:
    assert label=='reissued-failed-reservation' and str(error)=='reserved handle reissued';seen={};repeat=[];lane=None
    for line in raw.splitlines():
     if not line.startswith(('{','[')):continue
     v=json.loads(line)
     if isinstance(v,dict) and v.get('kind')=='Lane':lane=v['schema']+'/'+v['style'];seen={}
     elif isinstance(v,list):
      for event in v:
       if event['kind']=='Reserved':
        key=(event['handle']['namespace'],event['handle']['id'])
        if key in seen:repeat.append({'lane':lane,'earlier':seen[key],'reissued':event})
        seen[key]=event
    assert len(repeat)==4;observations.append({'backend':backend,'compiling':True,'witness':repeat[0],'decoderError':str(error),'repeatedReservationLanes':4})
  case.update(status='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE',observations=observations,generatedPins={p.name:sha(p) for p in folder.glob('*') if p.suffix in ['.c','.js','.native']});print(label,'DETECTED',flush=True)
 except Exception as error:case.update(status='FAIL_OR_LIMIT',error=repr(error));print(label,'FAIL',repr(error),flush=True)
 save()
r['status']='FRESH_ACTUAL_SLOT_HOST12_MUTANTS_BOTH_BACKENDS_PASS' if len(r['cases'])==12 and all(c['status']=='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' for c in r['cases']) else 'PARTIAL_OR_FAILED';save()
