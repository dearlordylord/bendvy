"""Portable actual TS42 raw/source/common-model joins; no runtime or compiler children."""
import hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-ts-v1';sha=lambda b:hashlib.sha256(b).hexdigest();sys.dont_write_bytecode=True
m=json.loads((D/'manifest.json').read_text())
assert sha((H/'delivery-v1/manifest.json').read_bytes())==m['baselineManifestSHA256'];assert sha((H/'delivery-native-v1/manifest.json').read_bytes())==m['nativeManifestSHA256']
for n,d in m['source'].items():assert sha((H/n).read_bytes())==d,n
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256'] and sha((D/m['archive']['name']).read_bytes())==m['archive']['sha256']
with tarfile.open(D/m['archive']['name'],'r:gz') as t:
 members=t.getmembers();assert all(f.isfile() for f in members);assert len(members)==len({f.name for f in members});data={f.name:t.extractfile(f).read() for f in members}
assert set(data)==set(m['archive']['members'])
for n,v in m['archive']['members'].items():assert sha(data[n])==v['sha256'] and len(data[n])==v['bytes']
j=lambda n:json.loads(data[n]);equal=lambda a,b:json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
actual='bundle-TS-1791437636585546165';failed='bundle-TS-1791437104734996072'
for run,admitted,status in [(actual,'0b0a5de0ae6071123d8eb863a1c5a221b36241c748f3e0163dc7a95e6afa16b5','ACTUAL_PINNED_TS_FORTY_TWO_COMMON_WITH_COMPLETE_RAW_PASS'),(failed,'1438b839174991ea4b3f36fdc11844040df886bc2c5ccdf70b1993ed938656da','INCOMPLETE')]:
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==admitted==r['planSHA256'];assert r['status']==status
 assert len(p['commands'])==1 and p['commands'][0]['seconds']==5
 assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])==15
 stage={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stage==p['inventory']
 assert set(r['logs'])=={'bundle-TS-consume.stdout','bundle-TS-consume.stderr'}
 for n,d in r['logs'].items():assert sha(data[run+'/'+n])==d
 rawRoot=Path(p['stage']).parent;probe=rawRoot/'execution-probes';expected={str(probe/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']};assert set(r['probePins'])==expected
 for absolute,d in r['probePins'].items():assert sha(data[run+'/'+str(Path(absolute).relative_to(rawRoot))])==d
 assert {n[len(run+'/execution-probes/'):] for n in data if n.startswith(run+'/execution-probes/')}=={Path(n).name for n in expected}
 assert {n[len('reference-core/'):]:sha(raw) for n,raw in data.items() if n.startswith('reference-core/')}==p['tsCoreInventory']
 if run==actual:
  assert len(r['commands'])==1 and r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
  assert not data[run+'/bundle-TS-consume.stderr']
  fixture='experiments/public-machine-handlers/candidate-v1/bundle-v1/'
  for n,d in json.loads((H/'ts-source-review-manifest.json').read_text())['source'].items():assert stage[fixture+n]==d==sha((H/n).read_bytes())
 else:
  assert r['failedCommand']['exit']==1 and r['failedCommand']['failure'] is None
  assert not data[run+'/bundle-TS-consume.stdout'];assert b'A:later_enterPlay1' in data[run+'/bundle-TS-consume.stderr']
manifest=json.loads((H/'ts-source-review-manifest.json').read_text());assert sha(data['references-sources.json'])==manifest['pinnedTSSource']['sourceManifestSHA256']
assert j('references-sources.json')['sources']['bevy-ts']['commit']==manifest['pinnedTSSource']['commit']=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
raw=j(actual+'/bundle-TS-consume.stdout');assert raw['status']=='ACTUAL_PINNED_TS_BUNDLE_COMMON_WITH_COMPLETE_RAW';expected=json.loads((H/'ts-common-expected.json').read_text())
full=json.loads((H/'expected.json').read_text())['rows'];spec=importlib.util.spec_from_file_location('bundle_ts_independent_projection',H/'ts-common-oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
projected={s:{name:model.project(row) for name,row in rows.items() if name not in model.EXCLUDED} for s,rows in full.items()};assert equal(projected,expected['comparable'])
assert list(raw['schemas'])==['A','B']
for s in ['A','B']:
 rows=raw['schemas'][s];assert list(rows)==list(projected[s]) and len(rows)==21
 assert len(expected['bendOnly'][s])==3 and set(expected['bendOnly'][s])==model.EXCLUDED and len(full[s])==24
 for name,row in rows.items():
  assert set(row)=={'common','raw'} and equal(row['common'],projected[s][name]);assert row['raw']['world'] and isinstance(row['raw']['history'],list)
print('PORTABLE_ACTUAL_TS_BUNDLE42_WITH_RAW_PASS')
