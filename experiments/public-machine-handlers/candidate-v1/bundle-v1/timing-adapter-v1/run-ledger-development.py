"""One affected ledger source5 development check; no runtime or timing."""
import hashlib,importlib.util,json,time,fcntl,types,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
N=types.ModuleType('native_inspection');N.__file__=str(HERE/'run-native-inspection.py')
wrapper=Path(N.__file__).read_text();prefix=wrapper.split('\nparser=argparse.ArgumentParser();')[0]
assert len(prefix)<len(wrapper)
exec(compile(prefix,N.__file__,'exec'),N.__dict__)
def main():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  olddir=HERE/'native-clock-inspection-1791444817897881996'
  old=json.loads((olddir/'plan.json').read_text())
  envpath=Path(old['privateEnvironment']);assert N.sha(envpath)==old['environmentSHA256']
  env=json.loads(envpath.read_text())
  name=sys.argv[1] if len(sys.argv)>1 else 'ledger-driver.bend'
  assert name in ['ledger-driver.bend','correctness-main.bend']
  source=HERE/'ledger-driver-source-v1'/name
  files=set();N.closure(source,files)
  files.update(map(Path,old['tools']['pins']))
  files.update([Path(__file__),HERE/'run-native-inspection.py',N.T.IMPLEMENTATION,N.BOUNDARY,N.ROOT/'scripts/receipt-logs.py',envpath])
  inputs=N.T.Inputs(files=files)
  out=HERE/('development-ledger-source-'+str(time.time_ns()));out.mkdir()
  # Archive every actual source before the affected check; no repaired-byte rebase.
  archived=out/'source';archived.mkdir()
  sources={str(p):N.sha(p) for p in files if p.suffix=='.bend'}
  for index,p in enumerate(sorted(p for p in files if p.suffix=='.bend')):
   (archived/(str(index)+'.bend')).write_bytes(p.read_bytes())
  (out/'source-inventory.json').write_text(json.dumps(sources,indent=2)+'\n')
  command=['/usr/bin/taskset','-c','8','/home/node/.bend/bin/bend',str(source),'--check-only']
  configs=N.current_configs(out,HERE/'stage',old['tools'],env)
  def guard():
   inputs.guard();assert N.current_configs(out,HERE/'stage',old['tools'],env)==configs
  logs=N.L.CommandLogs(out,['ledger']);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=N.ROOT,capture='split')
  receipt={'scope':'Affected source5 development typing only; no runtime/timing/proof/resolver acceptance.','commands':[],'argv':command,'seconds':5,'source':sources,'configurationStates':configs}
  with N.E.ReceiptBoundary(receipt,out/'receipt.json',[('inputs/configurations',guard),('raw logs',logs.guard)]):
   guard()
   with N.E.GuardBoundary([('inputs/configurations',guard),('raw logs',logs.guard)]):
    result=runner.run('ledger',command,5,expected=None)
   receipt['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']});receipt['logs']=dict(logs.hashes)
   assert result['exit']==0 and result['failure'] is None
   assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
   assert result['stderr']==b''
   receipt['status']='DEVELOPMENT_LEDGER_TYPING_PASS_NO_RUNTIME_TIMING_CREDIT'
  print(out)
if __name__=='__main__':main()
