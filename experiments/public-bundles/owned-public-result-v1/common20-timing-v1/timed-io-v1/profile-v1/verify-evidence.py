"""No-child complete archive/input/output/profile/public-join verification."""
import gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('profile_runner',HERE/'run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
spec=importlib.util.spec_from_file_location('profile_analysis',HERE/'analyze.py');A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
manifest=json.loads((HERE/'evidence-v1/MANIFEST.json').read_bytes());data={}
for member in manifest['members']:
 raw=gzip.decompress((HERE/'evidence-v1'/member['path']).read_bytes())
 if len(raw)!=member['bytes'] or hashlib.sha256(raw).hexdigest()!=member['sha256']:raise ValueError('Lossless member differs')
 if member['name'] in data:raise ValueError('Duplicate member')
 data[member['name']]=raw
if set(p.name for p in (HERE/'evidence-v1').iterdir())!={'MANIFEST.json'}|{m['path'] for m in manifest['members']}:raise ValueError('Archive membership differs')
plan=json.loads(data['plan.json']);receipt=json.loads(data['receipt.json'])
if hashlib.sha256(data['plan.json']).hexdigest()!='1a44abc715c36ed96f842be83272020d859d14de184b4d8c311a2d83d59aac40' or receipt['planSHA256']!=hashlib.sha256(data['plan.json']).hexdigest():raise ValueError('Admitted plan differs')
if receipt['status']!='COMPLETE_WHOLE_PROCESS_DIAGNOSTIC' or len(receipt['commands'])!=2 or len(receipt['guards'])!=7:raise ValueError('Incomplete cohort')
if {name:R.sha(name) for name in plan['pins']}!=plan['pins']:raise ValueError('Current input differs')
if R.resource_snapshot(plan['resourceRoots'])!=plan['resourceInventory']:raise ValueError('Current resources differ')
R.VERIFIED_SOURCES={name:Path(name).read_bytes() for name in plan['pins'] if name.endswith('.py')}
info=plan['roles']['JS'];T=R.load('transport',info['transport']);J=R.load('public_join',plan['join']);V=R.load('profile_shape',plan['profileValidator'])
expected=json.loads(Path(info['oracle']).read_bytes());pins=dict(plan['pins']);pins[str(Path(manifest['liveRoot'])/'plan.json')]=receipt['planSHA256']
for command,row,observation in zip(plan['commands'],receipt['commands'],receipt['observations']):
 if row['argv']!=command['argv'] or row['capSeconds']!=5 or row['exit']!=0 or row['failure']is not None:raise ValueError('Command differs')
 label=command['label'];stdout=data[label+'.stdout'];stderr=data[label+'.stderr']
 for key,raw in [('stdout',stdout),('stderr',stderr)]:
  if row[key]['bytes']!=len(raw) or row[key]['sha256']!=hashlib.sha256(raw).hexdigest():raise ValueError('Raw binding differs')
 result=dict(exit=0,failure=None,stdout=stdout,stderr=stderr)
 full=T.validate_result(result,expected,False);joined=J.compare(stdout.decode(),Path(plan['tsStdout']).read_text())
 profile=data[Path(command['profile']).name];V.validate_shape(command['role'],json.loads(profile))
 if observation['timer']!=full['timer'] or observation['publicJoin']!=joined or observation['profileSHA256']!=hashlib.sha256(profile).hexdigest():raise ValueError('Whole observation differs')
for guard in receipt['guards']:
 raw=data[Path(guard['path']).name];value=json.loads(raw)
 if guard['sha256']!=hashlib.sha256(raw).hexdigest() or not value['unchanged'] or value['actualResources']!=plan['resourceInventory']:raise ValueError('Guard differs')
 for key,sha in plan['pins'].items():
  if value['actualPins'].get(key)!=sha:raise ValueError('Guard input differs')
 for key,sha in value['actualPins'].items():
  if key not in plan['pins']:
   name=Path(key).name
   if name not in data or hashlib.sha256(data[name]).hexdigest()!=sha:raise ValueError('Progressive artifact differs')
analysis=A.analyze(json.loads(data['bundle.cpuprofile']),json.loads(data['bundle.heapprofile']),'file:///tmp/bendvy-bundle41-io-timed-js01/scenario.js')
if analysis!=json.loads((HERE/'PROFILE-ANALYSIS.json').read_bytes()):raise ValueError('Derived sample analysis differs')
print('All 15 lossless members, two whole outputs/20 joins, seven guards and raw-derived CPU/heap summaries PASS; no child replay')
