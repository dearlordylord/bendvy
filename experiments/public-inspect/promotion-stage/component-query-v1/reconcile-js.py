"""No-child derived reconciliation; original backend receipt stays immutable."""
import hashlib, importlib.util, json, pathlib, sys
sys.dont_write_bytecode = True
HERE = pathlib.Path(__file__).resolve().parent
EXPECTED_PLAN = '5b6ef2f9444f1fac86fa28767b9d1d37e8699188eb56b78461a2e5c8e5cbe1f1'
def sha(p): return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def load_module(name, path):
 spec = importlib.util.spec_from_file_location(name, path)
 module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module); return module
B = load_module('reconcile_backend', HERE/'js-backend.py')
def run(path):
 frozen = json.loads(path.read_text()); plan_sha = sha(path)
 p = json.loads(pathlib.Path(frozen['originalPlan']).read_text())
 original = json.loads(pathlib.Path(frozen['originalReceipt']).read_text())
 result = {'status':'INCOMPLETE', 'planSHA256':plan_sha, 'scope':frozen['scope']}
 def guard():
  assert sha(path) == plan_sha
  for name, digest in frozen['files'].items(): assert sha(name) == digest, name
  assert sha(frozen['originalPlan']) == EXPECTED_PLAN
  B.stage_guard(p)
  for item in p['rootDependencies'].values(): assert sha(item['root']) == item['sha256']
  assert original['status'] == 'INCOMPLETE' and original['planSHA256'] == EXPECTED_PLAN
  assert original['probeCount'] == 25 and not original.get('guardFailures', [])
  assert len(original['commands']) == 2
  assert all(c['exit'] == 0 and c['failure'] is None for c in original['commands'])
  out = pathlib.Path(frozen['originalPlan']).parent
  labels = ['verify-'+str(i)+'-ldd-'+name for i in range(5) for name in ['bend','node','python','taskset','clang']]
  assert p['executionProbeLabels'] == labels
  probe_names = {str(out/'execution-probes'/(label+suffix)) for label in labels for suffix in ['.json','.stdout.raw','.stderr.raw']}
  assert set(original['probePins']) == probe_names
  assert {str(q) for q in (out/'execution-probes').iterdir() if q.is_file()} == probe_names
  subject_names = ['complete-emit-js','complete-run-js']
  assert [c['label'] for c in original['commands']] == subject_names
  assert [c['seconds'] for c in original['commands']] == [30,5]
  raw_names = {label+'.'+stream+'.raw' for label in subject_names for stream in ['stdout','stderr']}
  assert set(original['logs']) == raw_names
  prepare = json.loads((out/'prepare-receipt.json').read_text())
  assert {q.name for q in out.glob('*.raw')} == raw_names | set(prepare['logs'])
  assert frozen['subjectRawDigests'] == original['logs']
  for n, digest in prepare['logs'].items(): assert sha(out/n) == digest
  for label in labels:
   metadata = json.loads((out/'execution-probes'/(label+'.json')).read_text())
   assert metadata['exit'] == 0 and metadata['failure'] is None and metadata['seconds'] == 5
   assert metadata['runnerSHA256'] == sha(B.ROOT/'scripts/task_runner.py')
  for name, digest in original['probePins'].items(): assert sha(name) == digest
  for name, digest in original['logs'].items(): assert sha(out/name) == digest
  for name, digest in original['generated'].items(): assert sha(name) == digest
  archive = HERE/'js-execution-history-v1/5b6ef2f9-oracle-mismatch'
  index = json.loads((archive/'archive-index.json').read_text())
  assert {str(q.relative_to(archive)) for q in archive.rglob('*') if q.is_file()} == set(index)|{'archive-index.json'}
  for name, digest in index.items(): assert sha(archive/name) == digest
 checks = [('literal original plan/full source/root/config/environment/raw/generated/25-ledger/model histories', guard)]
 with B.E.ReceiptBoundary(result, pathlib.Path(frozen['result']), checks):
  guard()
  model = load_module('source_corrected_physical_model', HERE/'physical-oracle-v2.py')
  expected = (model.build('Workshop')+model.build('Garden')+'\n').encode()
  assert expected == pathlib.Path(frozen['correctedOracle']).read_bytes()
  actual = pathlib.Path(frozen['actual']).read_bytes()
  assert actual == expected, 'complete public/physical oracle mismatch'
  assert pathlib.Path(frozen['stderr']).read_bytes() == b''
  result.update(status='COMPLETE_DERIVED_SOURCE_BACKED_JS_RECONCILIATION', originalReceiptSHA256=frozen['files'][frozen['originalReceipt']], originalStatus='INCOMPLETE', bytes=len(actual), fullOracleSHA256=hashlib.sha256(actual).hexdigest(), originalPlanSHA256=EXPECTED_PLAN, backendReexecuted=False)
if __name__ == '__main__': run(pathlib.Path(sys.argv[1]).resolve())
