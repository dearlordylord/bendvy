#!/usr/bin/env python3
"""Finite compiling source mutations at reached private packed setter/helper anchors."""
from pathlib import Path
import json,hashlib,shutil,subprocess,argparse
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);base=Path('/tmp/bendvy-packed-paired-journal-both-v3');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();report={'scope':'Finite compiling mutants against unchanged literal pair-row oracle; not full22/source proof','subjects':{}}
for lane,cap,prefix in [('motion','Motion','prototype_packed_row_set_done'),('health','Health','prototype_packed_prototype_journalledger_health_set_fused_done')]:
 for mutant in ['lost-mark','pair-wrong-ledger-old']:
  stage=a.output/(lane+'-'+mutant);stage.mkdir();core=stage/'overlay';shutil.copytree(base,core);file=core/'experiments/s-integrate/held-adapter.bend';s=file.read_text()
  if mutant=='lost-mark':
   import re
   match=re.search(r'^def '+prefix+r'\(.*?(?=\ndef |\Z)',s,re.M|re.S);b=match[0];old='X.PrototypeFlatMark{space,id,marks}';assert b.count(old)==1;new=b.replace(old,'marks');s=s.replace(b,new,1)
  else:
   old='case PrototypePendingUndo{True{},space,id,main_old,tail}: PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatPair{space,id,main_old,old,tail}}';new='case PrototypePendingUndo{True{},space,id,+main_old,tail}: PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatPair{space,id,main_old,main_old,tail}}';assert s.count(old)==1;s=s.replace(old,new,1)
  file.write_text(s);m=json.loads((core/'overlay.json').read_text());c=json.loads((core/'cache-specialization.json').read_text());pins={n:sha(core/n) for n in m['sources']};digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();c.update(runtimeClosure=pins,specializedClosure=pins,runtimeClosureSHA256=digest,specializedClosureSHA256=digest);m.update(sources=pins,cacheSpecialization=c)
  for n,d in [('overlay.json',m),('cache-specialization.json',c)]:(core/n).write_text(json.dumps(d,indent=2)+'\n')
  # Exact new closed catalog for this deliberately mutated subject; positive recipe remains fixed.
  runner=stage/'runner.py';runner.write_text((H/'paired-fixture-run.py').read_text().replace("d437d8f7e97ae66764e470c58cada7182715b8724d9dd065d20e55417e01e744",digest));output=stage/'actual';cmd=['python3',str(runner),'--overlay',str(core),'--output',str(output),'--fixture',str(H/('paired-'+lane+'-pairs.bend')),'--expected',str(H/('paired-'+lane+'-pairs-expected.txt'))];x=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True);(stage/'command.stdout').write_text(x.stdout);e=json.loads((output/'evidence.json').read_text());commands=e['commands'];compiled=any(c['argv'][-2:] if False else ('--check-only' in c['argv'] and c['returncode']==0) for c in commands);runtime=[c for c in commands if c['argv'][3:4]==['node']];assert x.returncode!=0 and compiled and runtime and runtime[0]['returncode']==0
  observed=(output/'JS-run.stdout').read_text();expected=(H/('paired-'+lane+'-pairs-expected.txt')).read_text();assert observed!=expected
  report['subjects'][lane+'-'+mutant]={'status':'DETECTED_COMPILING_JS_RUNTIME_COUNTEREXAMPLE','sourceClosure':digest,'commands':cmd,'runnerSHA256':sha(runner),'baseSHA256':sha(base/'experiments/s-integrate/held-adapter.bend'),'mutantSHA256':sha(file),'actualSHA256':sha(output/'JS-run.stdout'),'expectedSHA256':sha(H/('paired-'+lane+'-pairs-expected.txt'))}
  (a.output/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
report['status']='FOUR_COMPILING_SOURCE_MUTATIONS_DETECTED_JS';(a.output/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
