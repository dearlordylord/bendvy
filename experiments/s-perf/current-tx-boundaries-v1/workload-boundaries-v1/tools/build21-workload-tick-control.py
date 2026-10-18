from pathlib import Path
import shutil,json,hashlib
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');C=D/'controls/returned-tick-v1';assert not C.exists();C.mkdir(parents=True)
for name in ['meter.bend','private']:
 source=D/name;target=C/name
 if source.is_dir():shutil.copytree(source,target)
 else:shutil.copy2(source,target)
p=C/'private/src/ecs/commands.bend';old='Meter.Witness{namespace,tick,pending,List.length(&2,E,events)}';new='Meter.Witness{namespace,U32.add(tick,1),pending,List.length(&2,E,events)}';s=p.read_text();assert s.count(old)==1;before=hashlib.sha256(p.read_bytes()).hexdigest();p.write_text(s.replace(old,new));after=hashlib.sha256(p.read_bytes()).hexdigest()
gold=D/'oracle/failedtxn-motion64-v1/expected.boundaries.json';values=json.loads(gold.read_text());count=0
for world in values['worlds']:
 for sample in world['reports']:
  witness=sample['tx']['returnedWorld'];assert witness is not None;witness['tick']=(witness['tick']+1)%(2**32);count+=1
assert count==774
raw=(json.dumps(values,separators=(',',':'))+'\n').encode();(C/'expected.wrong.json').write_bytes(raw)
(C/'MUTATION.json').write_text(json.dumps({'scope':'Reached actual returnedWorld witness tick accounting only; original World/outcome/owners and complete canonical unchanged. Not arbitrary metadata or five-workload qualification.','source':'private/src/ecs/commands.bend','beforeSHA256':before,'afterSHA256':after,'old':old,'new':new,'normalOracleSHA256':hashlib.sha256(gold.read_bytes()).hexdigest(),'wrongOracleSHA256':hashlib.sha256(raw).hexdigest(),'wrongOracleBytes':len(raw),'changedWitnesses':count,'derivation':'Apply U32.add(tick,1) only to all774 actual returnedWorld.tick values in independently presealed normal gold; preserve every other field, append count, source site, begin/end tick, completion and ordering.'},indent=2)+'\n')
print('wrong',len(raw),hashlib.sha256(raw).hexdigest())
