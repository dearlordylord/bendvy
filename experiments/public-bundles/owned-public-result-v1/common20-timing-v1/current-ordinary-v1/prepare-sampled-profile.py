"""Mechanically reuse existing observation-only sampled CLI on complete current scale1."""
from pathlib import Path
import json, hashlib, importlib.util, shutil
HERE=Path(__file__).resolve().parent; ROOT=Path('/workspace/formal-proofs/bendvy')
OLD=Path('/workspace/formal-proofs/bendvy-worktrees/native54-matching-tree-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/sampled-cli-v1')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
d=HERE/'sampled-cli-v1';d.mkdir(exist_ok=False);c=d/'compiler';c.mkdir()
for name in ['sample-helper.mjs','check-api.mjs','validate-profile.py.source','PATCHES.json']:
 shutil.copyfile(OLD/name,d/name)
for name in ['installed-cli-unmodified.mjs','installed-cli-sampled.mjs']:shutil.copyfile(OLD/'compiler'/name,c/name)
original=(c/'installed-cli-unmodified.mjs').read_bytes();assert len(original)==333165 and sha(c/'installed-cli-unmodified.mjs')=='015d68644efcd3ed53a5dbf17f5672c3f4fcb70c8c64cd2c895b4955e1f78e62'
text=(c/'installed-cli-sampled.mjs').read_text()
for patch in reversed(json.loads((d/'PATCHES.json').read_text())['patches']):
 assert text.count(patch['replacement'])==1;text=text.replace(patch['replacement'],patch['original'])
assert text.encode()==original
for name in ['base.bend','bendtt.lean','effs']:(c/name).symlink_to(Path('/home/node/.bend/bend2')/name,target_is_directory=name=='effs')
base=json.loads((HERE/'native-semantic02/plan.json').read_text());closure=json.loads((HERE/'IO-source05/CLOSURE.json').read_text());inventory=closure['sourceInventory'];entry=closure['entrypoint'];out=d/'actual01';out.mkdir()
collector=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/development-v2.py';spec=importlib.util.spec_from_file_location('existing_collector',collector);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
assert m.validate_imports(HERE,inventory,[entry])==sorted(inventory)
runner_spec=importlib.util.spec_from_file_location('existing_inputs',ROOT/'scripts/task_runner.py');runner=importlib.util.module_from_spec(runner_spec);runner_spec.loader.exec_module(runner)
resources=runner.Inputs(directories=[*base['resourceRoots'],str(c)]).expected
pins=dict(base['pins'])
for p in [Path(__file__),collector,*d.glob('*'),*c.glob('*.mjs')]:
 if p.is_file() and not p.is_symlink():pins[str(p.resolve())]=sha(p)
assert all(sha(p)==h for p,h in pins.items())
env=base['environment']|{'BUN_BE_BUN':'1','BENDVY_CPU_PROFILE_PATH':str(out/'compiler.cpuprofile')};env.pop('BUN_OPTIONS',None);prefix=[base['tools']['taskset'],'-c','5'];elf=base['tools']['bend']
commands=[{'label':'source-profile-api-control','argv':prefix+[elf,str(d/'check-api.mjs'),str(out/'api-control.cpuprofile')],'capSeconds':5,'expectedExit':0},{'label':'emit','argv':prefix+[elf,str(c/'installed-cli-sampled.mjs'),entry,'-o',str(out/'scenario.c')],'capSeconds':30},{'label':'source-profile-schema','argv':prefix+[base['tools']['python'],str(d/'validate-profile.py.source'),str(out/'compiler.cpuprofile')],'capSeconds':5,'expectedExit':0}]
plan=dict(scope='ONE observation-only copied installed CLI current complete scale1 compiler diagnostic; no Native semantic acceptance, compiler adoption or comparative credit; no build/consumer command',role='native',subject='normal',entrypoint=entry,stage=str(HERE),sourceEntries=[entry],sourceInventory=inventory,importClosure=sorted(inventory),pins=pins,resourceRoots=resources,environment=env,cwd=str(d),generated=str(out/'scenario.c'),native=str(out/'not-executed.native'),tools=base['tools'],commands=commands,oracle=str(HERE/'bend-scale1.stdout.gz'),oracleBytes=base['independentRawBytes'],oracleSHA256=base['independentRawSHA256'],postConsumer='No consumer; conditional profile schema validates completed copied observation only')
raw=(json.dumps(plan,indent=2)+'\n').encode();(out/'plan.json').write_bytes(raw)
(d/'PREPARED.json').write_text(json.dumps({'plan':str(out/'plan.json'),'sha256':hashlib.sha256(raw).hexdigest(),'collector':str(collector),'patchesUnchanged':True,'fullSourceCount':len(inventory),'pins':len(pins),'controlsExecuted':False,'compilerExecuted':False,'stockFailure':'native-semantic02 emit30 child deadline; retained unchanged'},indent=2)+'\n')
print(str(out/'plan.json'),hashlib.sha256(raw).hexdigest(),len(inventory),len(pins))
