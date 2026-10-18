from pathlib import Path
import shutil,json,hashlib
D=Path('/tmp/bendvy-current-tx-mixed-reset/experiments/s-perf/current-tx-boundaries-v1/mixed-reset-v1')
normal=json.loads((D/'oracle/expected.boundaries.json').read_text())
changes={
 'omitted-reset':('meter.bend','Counts{u,0n,e},peak,rows','Counts{u,c,e},peak,rows'),
 'wrong-category':('private/src/ecs/transaction.bend','Meter.append(meter,"transaction.emit",0n,0n,1n)','Meter.append(meter,"transaction.emit",0n,1n,0n)'),
 'corrupt-counter':('meter.bend','Counts{Nat.add(u,du),Nat.add(c,dc),Nat.add(e,de)}','Counts{Nat.add(Nat.add(u,du),1n),Nat.add(c,dc),Nat.add(e,de)}')}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name,(rel,old,new) in changes.items():
 C=D/'controls'/name; assert not C.exists();C.mkdir()
 for relcopy in ['meter.bend','private','subject']:
  source=D/relcopy; dest=C/relcopy
  if source.is_dir():shutil.copytree(source,dest)
  else:shutil.copy2(source,dest)
 f=C/rel;s=f.read_text();assert s.count(old)==1;before=sha(f);f.write_text(s.replace(old,new));after=sha(f)
 gold=json.loads(json.dumps(normal))
 for case in gold['cases']:
  for sample in case['reports']:
   tx=sample['tx'];current=[0,0,0];peak=[0,0,0]
   for row in tx['boundaries']:
    delta=row['delta'][:]
    if name=='wrong-category' and row['site']=='transaction.emit':delta=[0,1,0];row['delta']=delta
    if row['site']=='bundle-batch.stage':
     if name!='omitted-reset':current[1]=0
    else:
     current=[a+b for a,b in zip(current,delta)]
     if name=='corrupt-counter':current[0]+=1
    peak=[max(a,b) for a,b in zip(peak,current)];row['current']=current[:];row['peak']=peak[:]
   tx['consistent']=current==tx['terminal']
 (C/'expected.wrong.json').write_text(json.dumps(gold,separators=(',',':')))
 (C/'MUTATION.json').write_text(json.dumps({'scope':'Source accounting only; independent wrong model sealed before subject, actual canonical and traversed terminal counts unchanged. Zero-selector discard is bounded, nonempty raw discard remains outside slice.','name':name,'source':rel,'beforeSHA256':before,'afterSHA256':after,'old':old,'new':new,'normalModelSHA256':sha(D/'oracle/expected.boundaries.json'),'wrongModelSHA256':sha(C/'expected.wrong.json'),'model':'Replay source-declared deltas from independent normal model with the exact accounting mutation; retain actual terminal traversal and compare cached current to it.'},indent=2)+'\n')
 print(name,sha(C/'expected.wrong.json'))
