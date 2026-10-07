import pathlib,sys,json,shutil,hashlib
sys.path.insert(0,str(pathlib.Path.cwd()/'benchmarks/parity-features'))
from execute import Harness
from validate import validate
import importlib.util
spec=importlib.util.spec_from_file_location('timer',pathlib.Path('benchmarks/parity-features/timer-preflight.py'));timer=importlib.util.module_from_spec(spec);spec.loader.exec_module(timer)
output=pathlib.Path('.artifacts/parity-reader-after-integrated-profiles-v1').resolve()
paired=pathlib.Path('.artifacts/parity-integrated-readers-paired-v1').resolve()
receipt=paired/'receipt.json';program=paired/'readers-4.js'
sourcepins={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [receipt,program]}
assert json.loads(receipt.read_text())['status']=='COMPLETE_FEATURE_OBSERVATIONS'
h=Harness(pathlib.Path('/tmp/parity-integrated-readers-stage-v3'),output)
shutil.copy2(__file__,output/'profile-runner.py');h.pin(output/'profile-runner.py')
wrapper=output/'allocate.mjs';shutil.copy2('.artifacts/parity-reader-after-count-append-profiles-v1/allocate.mjs',wrapper);h.pin(wrapper)
h.receipt['consumedSourcePins']=sourcepins
try:
 for label,command,profile in [
  ('cpu',[h.tools['node'],'--cpu-prof','--cpu-prof-dir='+str(output),'--cpu-prof-name=cpu.cpuprofile',program],output/'cpu.cpuprofile'),
  ('allocation',[h.tools['node'],wrapper,program,output/'allocation.heapprofile'],output/'allocation.heapprofile')]:
  assert not profile.exists()
  assert all(hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()==v for p,v in sourcepins.items())
  result=h.run(label,[h.tools['taskset'],'-c','11',*command],5)
  validate('readers','JS',result.stdout.decode('utf8'),4)
  region=json.loads(result.stderr);assert region['bytes']==len(result.stdout) and region['digest']==timer.fnv(result.stdout)
  assert profile.is_file();h.pin(profile)
  assert all(hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()==v for p,v in sourcepins.items())
 h.guard();h.receipt.update(status='FULL_READER_INTEGRATED_PROFILES_VALIDATED',scope='Complete4lifecycle generatedJS CPU and sampled allocations including collected objects; finite descriptive diagnostics, not performance gate')
finally:h.save()
print(h.receipt['status'])
