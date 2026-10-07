"""Read-only historical capsule verification; no compiler/runtime/probe execution."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'delivery-driver-native-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((OUT/'manifest.json').read_text());runs={}
assert not m['completeIssue49'] and not m['performanceQualified']
assert sha((OUT/'REPORT.md').read_bytes())==m['reportSHA256']
assert sha((HERE/'full-expected.json').read_bytes())==m['oracleSHA256']
for name,h in m['source'].items():assert sha((HERE/name).read_bytes())==h,name
for name,record in m['archives'].items():
 blob=(OUT/record['archive']).read_bytes();assert sha(blob)==record['sha256'];files={}
 with tarfile.open(fileobj=io.BytesIO(gzip.decompress(blob)),mode='r:') as archive:
  for member in archive:
   assert member.isfile() and not member.name.startswith('/') and '..' not in Path(member.name).parts
   assert member.name not in files and 'private-environment' not in member.name and not member.name.endswith('-native')
   data=archive.extractfile(member).read();files[member.name]=data
   assert record['members'][member.name]=={'sha256':sha(data),'bytes':len(data)}
 assert set(files)==set(record['members']);runs[name]=files
 receipt=json.loads(files['receipt.json']);assert receipt['planSHA256']==sha(files['plan.json'])
 for label,h in receipt.get('logs',{}).items():assert sha(files[label])==h,(name,label)
 for key in ('probePins',):
  for absolute,h in receipt.get(key,{}).items():
   relative=str(Path(absolute).relative_to(record['historicalDirectory']))
   assert sha(files[relative])==h,(name,relative)
expected=json.loads((HERE/'full-expected.json').read_text())['bend']
names=['A','B']
rows={s:[f'schema{s}_{p}{i}{suffix}|[{", ".join(expected[f"schema{s}_{p}{i}{suffix}"])}]' for p in ['exit','transition','enter'] for i in [0,1] for suffix in ['', '_missing']] for s in names}
wanted={s:('\n'.join(rows[s])+'\n').encode() for s in names}
js=json.loads(runs['driver-js']['consume.stdout']);assert js['observations']==rows['A']+rows['B']
native=runs['split-native'];a=native['schema-a-run.stdout'];b=native['schema-b-run.stdout']
assert a==wanted['A'] and b==wanted['B'];assert a+b==wanted['A']+wanted['B']
assert all(c['exit']==0 for c in json.loads(native['receipt.json'])['commands'])
assert len(json.loads(native['receipt.json'])['commands'])==6
assert len([n for n in native if n.startswith('execution-probes/') and n.endswith('.json')])==65
assert sha(runs['schema-a-c']['full.c'])=='958f44169f371f092e250ce8686e8f3d7a2e9287495e5d92ac6974c43b5420ba'
assert sha(native['schema-b.c'])=='abdca8acd84db0c02cf2717ccb43d182e9daaffd8fc99d65a7521cb20eb51105'
assert sha(runs['driver-js']['full-driver-v2.mjs'])=='84a06c711c85440cf7d9cdd0697c38cb2d5d7e35beb8ad5729af70d0c29e384c'
print(json.dumps({'status':'LOSSLESS_FULL96_JS_NATIVE_CAPSULE_PASS','nativeUnionSHA256':sha(a+b),'nativeUnionBytes':len(a+b),'archives':len(runs)}))
