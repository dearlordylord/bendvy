"""No-child complete archive, progressive guards and literal model verification."""
import gzip, hashlib, json
from pathlib import Path
HERE = Path(__file__).resolve().parent
scope = {'__file__': str(HERE/'transport-v1/transport.py')}
exec(compile((HERE/'transport-v1/transport.py').read_bytes(), str(HERE/'transport-v1/transport.py'), 'exec'), scope)
Transport = scope['Transport']
sha = lambda data: hashlib.sha256(data).hexdigest()
for label, selected in json.loads((HERE/'NATIVE-PREPARED-v3.json').read_text())['plans'].items():
 directory = HERE/'evidence-v3'/label
 manifest = json.loads((directory/'MANIFEST.json').read_text())
 members = {item['original']: item for item in manifest['members']}
 assert len(members) == len(manifest['members'])
 assert {p.name for p in directory.iterdir()} == {'MANIFEST.json'} | {m['archive'] for m in members.values()}
 def read(name):
  item = members[name]; compressed = (directory/item['archive']).read_bytes()
  assert sha(compressed) == item['gzipSHA256']
  data = gzip.decompress(compressed)
  assert len(data) == item['bytes'] and sha(data) == item['sha256']
  return data
 for name in members: read(name)
 plan = json.loads(read('plan.json')); receipt = json.loads(read('receipt.json'))
 assert sha(read('plan.json')) == selected['sha256'] == manifest['executedPlanSHA256'] == receipt['planSHA256']
 assert receipt['status'] == 'DEVELOPMENT_PASS' and len(receipt['commands']) == 3
 expected_pins = dict(plan['pins']); expected_pins[selected['path']] = selected['sha256']
 guards = iter(receipt['guards'])
 def guard():
  row = next(guards); name = Path(row['path']).name
  assert sha(read(name)) == row['sha256']
  value = json.loads(read(name))
  assert value['unchanged'] and value['actualPins'] == expected_pins
  assert value['actualResources'] == plan['resourceInventory']
 for command, declared in zip(receipt['commands'], plan['commands']):
  assert all(command[key] == value for key, value in declared.items())
  assert command['exit'] == 0 and command['failure'] is None
  guard(); guard()
  for channel in ['stdout', 'stderr']:
   raw = command[channel]; data = read(Path(raw['path']).name)
   assert sha(data) == raw['sha256'] and len(data) == raw['bytes']
   expected_pins[raw['path']] = raw['sha256']
  if command['label'] == 'emit': expected_pins[plan['generated']] = sha(read(Path(plan['generated']).name))
  if command['label'] == 'build': expected_pins[plan['native']] = sha(read(Path(plan['native']).name))
  guard()
 guard(); assert next(guards, None) is None
 assert receipt['generatedSHA256'] == expected_pins[plan['generated']]
 assert receipt['buildArtifactSHA256'] == expected_pins[plan['native']]
 assert receipt['wholeOracleSHA256'] == plan['expectedSHA256'] == sha(read('independent-expected.json'))
 assert read('consumer.stderr') == b''
 actual = Transport(plan['entrypoint']).normalize(read('consumer.stdout').decode())
 assert actual == json.loads(read('independent-expected.json'))
 for path, digest in plan['pins'].items():
  if 'source:'+path in members: assert sha(read('source:'+path)) == digest
 print(label, 'complete model and archive/guard bindings PASS')
