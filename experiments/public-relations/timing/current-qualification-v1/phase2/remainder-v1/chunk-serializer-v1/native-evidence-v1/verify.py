"""Verify archived Native evidence without live files or child execution."""
from pathlib import Path
import hashlib, json, tarfile
H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
i = json.loads((H / 'index.json').read_text())
assert sha((H / 'objects.tar.gz').read_bytes()) == i['archiveSHA256']
with tarfile.open(H / 'objects.tar.gz') as archive:
    o = {m.name: archive.extractfile(m).read() for m in archive.getmembers()}
assert set(o) == set(i['objects'])
for digest, data in o.items():
    assert sha(data) == digest and len(data) == i['objects'][digest]
raw = lambda key: o[i['files'][key]]
read = lambda key: json.loads(raw(key))
by_path = lambda path: raw(i['pathKeys'][path])
def force(v):
 pending=[v];nodes=chars=total=0
 while pending:
  v=pending.pop();nodes=(nodes+1)&0xffffffff
  if v is None:total+=1
  elif isinstance(v,bool):total+=5 if v else 4
  elif isinstance(v,int):total+=2+v
  elif isinstance(v,str):total+=3;chars+=len(v);total+=sum(map(ord,v))
  elif isinstance(v,list):total+=6;pending.extend(reversed(v))
  else:
   total+=7
   for k,x in reversed(list(v.items())):pending.extend([x,k])
  total&=0xffffffff;chars&=0xffffffff
 return [{'boundary':'begin'},{'boundary':'complete-trace-forced','nodes':nodes,'characters':chars,'sum':total}]
p = read('native/plan.json')
r = read('native/receipt.json')
assert r['status'] == 'CHUNK_AFFECTED_NATIVE_FULL30_REFUSALS_PASS_NO_TIMING'
assert r['planSHA256'] == sha(raw('native/plan.json'))
assert len(p['commands']) == len(r['commands']) == 10
assert r['probeCommandsExecuted'] == 105
assert all(c['exit'] == 0 and c['failure'] is None for c in r['commands'])
assert [c['seconds'] for c in p['commands']] == [30, 120, 5, 5, 5, 5, 5, 30, 120, 5]
for name, digest in r['logs'].items():
    assert sha(raw('native/' + name)) == digest
prep = read('native/prepare-receipt.json')
assert prep['status'] == 'OWNED_TOOL_PREPARATION_PASS' and prep['probeCommandsExecuted'] == 5
for receipt in (prep, r):
    for path, digest in receipt['probePins'].items():
        assert sha(by_path(path)) == digest
for path, digest in p['pins'].items():
    if path in i['pathKeys']:
        assert sha(by_path(path)) == digest
manifests = [read('oracle/remainder-manifest.json'), read('oracle/initial-manifest.json')]
normal = 0
for c in p['commands']:
    if 'oracle' in c or 'forcedOracle' in c:
        name = Path(c.get('oracle', c.get('forcedOracle'))).name
        expected = read('oracle/' + name)
        case = next(x for m in manifests for x in m['cases'] if Path(x['expected']).name == name)
        assert sha(raw('oracle/' + name)) == case['sha256']
        assert sum(len(x['records']) for x in expected['roots']) == 30
        assert [json.loads(x) for x in raw('native/' + c['label'] + '.stderr').splitlines()] == force(expected)
        if 'oracle' in c:
            normal += 1
            assert read('native/' + c['label'] + '.stdout') == expected
            assert r[c['label'] + 'Records'] == 30
    if 'refusal' in c:
        assert raw('native/' + c['label'] + '.stdout') == c['refusal'].encode()
        if 'forcedOracle' not in c:
            assert raw('native/' + c['label'] + '.stderr') == b''
assert normal == 4
# Archived historical receipts keep their original verdicts. Every retained raw
# log and owned probe is joined by the path mapping, without opening that path.
for key in i['files']:
    if not key.endswith('/receipt.json') or key == 'native/receipt.json':
        continue
    historical = read(key)
    for path, digest in historical.get('probePins', {}).items():
        assert sha(by_path(path)) == digest
    for name, digest in historical.get('logs', {}).items():
        candidate = key.rsplit('/', 1)[0] + '/' + name
        if candidate in i['files']:
            assert sha(raw(candidate)) == digest
print('PASS: archived Native four full30 cases/refusals, source/oracle/raw/probe joins; no backend rerun, C reconstruction, timing, N1024 or universal proof.')
