"""Focused log-isolation correction; no semantic/backend scope amendment."""
from pathlib import Path
import argparse,json,shutil,time,types
HERE=Path(__file__).resolve().parent
M=types.ModuleType('metadata_native_fixed');M.__file__=str(HERE/'native-runner.py')
exec((HERE/'native-runner.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],M.__dict__)
N=M.N
original=(HERE.parent/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
original=original.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL24_METADATA_NATIVE_IO_PASS'")
original=original.replace("    logs = LOGS.CommandLogs(out, [command['label'] for command in plan['commands']])","    command_logs = out / 'command-logs'\n    command_logs.mkdir()\n    logs = LOGS.CommandLogs(command_logs, [command['label'] for command in plan['commands']])")
original=original.replace("receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}","receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope'], 'logDirectory': str(command_logs)}")
exec(original,N.__dict__);N.configuration=M.configuration

def prepare(prior):
 prior=Path(prior).resolve();old=N.decode(json.loads(prior.read_text()));assert old['kind']=='metadata-native-io'
 assert N.task_runner.Inputs(files=old['files'],directories=[Path(old['stage']),*map(Path,old['directories'])]).expected==old['inputs']
 out=M.ROOT/'.artifacts'/('inspect54-metadata-native-log-fix-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
 source=Path(__file__).resolve();target=stage/source.relative_to(M.ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
 inv=json.loads(Path(old['sourceInventory']).read_text());inv['files'].append({'path':source.relative_to(M.ROOT).as_posix(),'origin':'selected-owned','sourceSHA256':N.sha(source),'stageSHA256':N.sha(target)})
 inventory=out/'source-inventory.json';inventory.write_text(json.dumps(inv,indent=2)+'\n');private=out/'private-environment.json';private.write_bytes(Path(old['privateEnvironment']).read_bytes());private.chmod(0o600)
 files=set(map(Path,old['files']));files.update([prior,prior.parent/'prepare-receipt.json',prior.parent/'observed-prechild-failure.json',source,inventory,private])
 p=dict(old);p.update(stage=str(stage),inventory=N.inventory(stage),sourceInventory=str(inventory),privateEnvironment=str(private),environmentSHA256=N.sha(private),files=sorted(map(str,files)),configurationStates=N.configurations(out,stage),reusedPreparation={'plan':str(prior),'planSHA256':N.sha(prior),'receipt':str(prior.parent/'prepare-receipt.json'),'receiptSHA256':N.sha(prior.parent/'prepare-receipt.json'),'scope':'Exact completed5 ordinary snapshot reused; no new snapshot/probe or backend replay'},scope=old['scope']+' Focused command-log directory isolation only; oldprechildfailure preserved.')
 c=out/'metadata.c';binary=out/'metadata.native';entry=stage/HERE.relative_to(M.ROOT)/'consumer-io.bend';p['commands']=[{'label':'metadata-emit-c','argv':[old['tools']['taskset'],'-c','5',old['tools']['tools']['bend'],str(entry),'-o',str(c)],'seconds':30,'generated':str(c),'oracle':None},{'label':'metadata-compile-native','argv':[old['tools']['taskset'],'-c','5',old['tools']['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'oracle':None},{'label':'metadata-run-native','argv':[old['tools']['taskset'],'-c','5',str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':'metadata'}]
 p['inputs']=N.task_runner.Inputs(files=files,directories=[stage,*map(Path,p['directories'])]).expected;path=out/'plan.json';path.write_text(json.dumps(p,indent=2,default=N.encode)+'\n');print(path);print(N.sha(path))
p=argparse.ArgumentParser();p.add_argument('--prepare');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare)
else:N.run(a.run)
