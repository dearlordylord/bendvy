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
p = read('current/plan.json')
r = read('current/receipt.json')
assert r['status'] == 'INCOMPLETE' and r['error'] == 'child deadline'
assert r['planSHA256'] == sha(raw('current/plan.json'))
assert r['probeCommandsExecuted'] == 12
c = p['command']
assert c['seconds'] == 5 and c['argv'][-4:] == ['population', '1024', '0', '0']
assert raw('current/' + c['label'] + '.stdout') == b''
expected = read('oracle/' + Path(c['oracle']).name)
assert sum(len(x['records']) for x in expected['roots']) == 30
manifest = read('oracle/remainder-manifest.json')
case = next(x for x in manifest['cases'] if Path(x['expected']).name == Path(c['oracle']).name)
assert case['sha256'] == sha(raw('oracle/' + Path(c['oracle']).name))
assert [json.loads(x) for x in raw('current/' + c['label'] + '.stderr').splitlines()] == force(expected)
for name, digest in r['logs'].items():
    assert sha(raw('current/' + name)) == digest
for path, digest in r['probePins'].items():
    assert sha(by_path(path)) == digest
for path, digest in p['pins'].items():
    if path in i['pathKeys']:
        assert sha(by_path(path)) == digest
historical = next(k for k in i['files'] if k.endswith('relations-normal-first-1791416550923842697/receipt.json'))
hr = read(historical)
assert hr['status'] == 'INCOMPLETE'
base = historical.rsplit('/', 1)[0]
assert read(base + '/0-ts.stdout') == expected
assert raw(base + '/0-js.stdout') == b''
assert [json.loads(x) for x in raw(base + '/0-js.stderr').splitlines()] == [{'boundary': 'begin'}]
for key in i['files']:
    if not key.endswith('/receipt.json'):
        continue
    receipt = read(key)
    for path, digest in receipt.get('probePins', {}).items():
        assert sha(by_path(path)) == digest
    for name, digest in receipt.get('logs', {}).items():
        candidate = key.rsplit('/', 1)[0] + '/' + name
        if candidate in i['files']:
            assert sha(raw(candidate)) == digest
print('PASS: archived INCOMPLETE N1024 complete-force timeout and historical Begin-only timeout; no full30 runtime qualification, backend rerun or timing claim.')
