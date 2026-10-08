"""No-child exact V3 tool snapshot reuse; fresh V4 source plan, not discovery."""
from pathlib import Path
import fcntl,hashlib,json,runpy
HERE=Path(__file__).resolve().parent
G=runpy.run_path(str(HERE/'runner.py'));sha=G['sha'];ROOT=G['ROOT']
old=HERE.parent/'core-consumer-v3';oldplan=old/'execution-plan.json';oldenv=old/'private-environment.json'
with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 assert not G['PLAN'].exists() and not G['ENV'].exists()
 proposal=G['preflight']();prior=json.loads(oldplan.read_text(),object_hook=G['decoded'])
 env=G['expected_environment']();assert env==json.loads(oldenv.read_text())
 snapshot=prior['toolSnapshot'];assert all(sha(p)==v for p,v in snapshot['pins'].items())
 resources={str(p.resolve()) for r in snapshot['resource_roots'] for p in Path(r).rglob('*') if p.is_file()}
 expectedResources={p for p in snapshot['pins'] if any(Path(p).is_relative_to(Path(r)) for r in snapshot['resource_roots'])}
 assert resources==expectedResources
 configuration=G['config'](env)
 for key in ['ldd','taskset']:assert str(configuration[key])==snapshot[key]
 assert configuration['cpu']==snapshot['cpu'] and configuration['capture_mode']==snapshot['capture_mode']
 assert {k:str(v) for k,v in configuration['tools'].items()}==snapshot['tools']
 assert list(map(str,configuration['resource_roots']))==snapshot['resource_roots']
 assert hashlib.sha256(json.dumps(env,sort_keys=True,separators=(',',':'),ensure_ascii=True).encode()).hexdigest()==snapshot['environment_sha256']
 configs=G['configs'](G['configuration_roots']());assert all(configs[k]==v for k,v in prior['rootConfigurations'].items() if k in configs)
 assert all(v is None for k,v in configs.items() if k not in prior['rootConfigurations'])
 assert G['loaders']()==prior['loaderConfigurations']
 files={str(ROOT/n):v for n,v in proposal['inputs'].items()};files.update(proposal['rootProductionPins'])
 for p in [HERE/'runner.py',Path(__file__),G['PROPOSAL'],HERE/'ERGONOMICS.md',HERE/'DELIVERY.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/owned-tool-pins.py',oldplan,old/'execution/receipt.json']:
  files[str(p)]=sha(p)
 for name in ['result.json','stdout','stderr']:files[str(HERE/'development-001'/name)]=sha(HERE/'development-001'/name)
 assert all(sha(p)==v for p,v in files.items())
 G['ENV'].write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');G['ENV'].chmod(0o600)
 plan=dict(status='UNEXECUTED',files=files,stageFiles=proposal['stageFiles'],environmentSHA256=sha(G['ENV']),toolSnapshot=snapshot,commands=proposal['commands'],rootConfigurations=configs,loaderConfigurations=G['loaders'](),preparationProbeResults=prior['preparationProbeResults'],scope=proposal['scope'],snapshotReuse=dict(sourcePlan=str(oldplan),sourcePlanSHA256=sha(oldplan),sourceReceiptSHA256=sha(old/'execution/receipt.json'),inheritedPreparationProbeCount=len(prior['preparationProbeResults']),freshPreparationProbeCount=0,reason='Current full resource membership/tool pins/resolver configuration/complete environment equal; fresh ordinary executable guards remain unchanged. No fresh discovery claimed.'))
 G['PLAN'].write_text(json.dumps(plan,indent=2,default=G['encoded'])+'\n');print(sha(G['PLAN']))
