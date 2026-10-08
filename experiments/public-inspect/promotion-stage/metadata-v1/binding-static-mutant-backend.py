"""Reuse ordinary baseline snapshot; freeze emitted reached controls for review."""
from pathlib import Path
import argparse,json,shutil,time,types
HERE=Path(__file__).resolve().parent
M=types.ModuleType('static_native');M.__file__=str(HERE/'binding-static-native-fresh.py')
exec((HERE/'binding-static-native-fresh.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],M.__dict__)
N=M.N
# Full expected outputs already include IO.print LF; reject baseline semantically.
original=(HERE.parent/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
original=original.replace("    logs = LOGS.CommandLogs(out, [command['label'] for command in plan['commands']])","    command_logs=out/'command-logs'\n    command_logs.mkdir()\n    logs=LOGS.CommandLogs(command_logs,[command['label'] for command in plan['commands']])")
original=original.replace("receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}","receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope'], 'logDirectory':str(command_logs)}")
original=original.replace("assert result['stdout'] == (oracle[command['oracle']] + '\\n').encode(), 'complete raw Native oracle mismatch: ' + command['label']", "assert result['stdout']==oracle[command['oracle']].encode(),'full8 defect oracle mismatch'\n                baseline=Path(plan['baselineOracle']);base=json.loads(baseline.read_text())['IOString'];actual=result['stdout'].decode();assert actual!=base\n                differences=[i for i,(a,b) in enumerate(zip(actual.splitlines(),base.splitlines())) if a!=b];assert len(differences)==plan['semanticRows'][command['oracle']]\n                receipt.setdefault('reached',{})[command['oracle']]={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'differentSemanticRows':differences,'completeRows':8,'exactIOFinalLF':True}")
original=original.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL8_STATIC_MUTANT_EMITTED_REACHED_PASS'")
start=original.index("            try:\n                result = runner.run(command['label']")
end=original.index("        assert ledger.index",start)
original=original[:start]+"""            result=None
            try:
                try:
                    result=runner.run(command['label'],command['argv'],command['seconds'])
                except BaseException as error:
                    r=getattr(error,'result',None)
                    receipt['commands'].append({'label':command['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error),'error':str(error)})
                    raise
                receipt['commands'].append({'label':command['label'],'exit':result['exit'],'failure':result['failure']})
            finally:
                try:
                    if result is not None and 'generated' in command:
                        file=command['generated'];generated[file]=sha(file)
                        runner.inputs=task_runner.Inputs(files=[path,*plan['files'],*generated],directories=[stage,*map(Path,plan['directories'])])
                finally:
                    primary=sys.exc_info()[1]
                    try:
                        logs.guard()
                        guard()
                    except BaseException as error:
                        receipt.setdefault('postChildGuardErrors',[]).append(str(error))
                        if primary is None:raise
            if command['oracle']:
                assert result['stdout']==oracle[command['oracle']].encode(),'full8 defect oracle mismatch'
                base=json.loads(Path(plan['baselineOracle']).read_text())['IOString'];actual=result['stdout'].decode();assert actual!=base
                differences=[i for i,(a,b) in enumerate(zip(actual.splitlines(),base.splitlines())) if a!=b];assert len(differences)==plan['semanticRows'][command['oracle']]
                receipt.setdefault('reached',{})[command['oracle']]={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'differentSemanticRows':differences,'completeRows':8,'exactIOFinalLF':True}
"""+original[end:]
original="import sys\n"+original
exec(original,N.__dict__);N.configuration=M.configuration

def prepare(backend):
 cli=M.ROOT/'.artifacts/inspect54-static-mutant-cli-1791424729771627281/plan.json';cp=json.loads(cli.read_text());receipt=cli.parent/'receipt.json';cr=json.loads(receipt.read_text());assert cr['planSHA256']==N.sha(cli) and cr['status']=='FULL8_STATIC_MUTANT_CLI_IO_REACHED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in cr['commands'])
 assert N.task_runner.Inputs(files=cp['files'],directories=map(Path,cp['directories'])).expected==cp['inputs'];assert N.sha(cp['privateEnvironment'])==cp['environmentSHA256']
 for name,digest in cr['logs'].items():assert N.sha(cli.parent/name)==digest
 source=Path(cp['sourceJoin']['plan']);assert N.sha(source)==cp['sourceJoin']['planSHA256'];sp=json.loads(source.read_text());sr=Path(cp['sourceJoin']['receipt']);assert N.sha(sr)==cp['sourceJoin']['receiptSHA256']
 authority=M.ROOT/'.artifacts/inspect54-static-backend-1791424102532925260/plan.json';ap=N.decode(json.loads(authority.read_text()));ar=authority.parent/'receipt.json';rr=json.loads(ar.read_text());assert rr['planSHA256']==N.sha(authority) and rr['status']=='FULL8_STATIC_DESCRIPTOR_EMITTED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in rr['commands']);assert ap['preparationConfigurationBefore']==ap['preparationConfigurationAfter']
 assert N.task_runner.Inputs(files=ap['files'],directories=[Path(ap['stage']),*map(Path,ap['directories'])]).expected==ap['inputs'],'historical snapshot input drift'
 prep=authority.parent/'prepare-receipt.json';pr=json.loads(prep.read_text());assert pr['status']=='OWNED_TOOL_SNAPSHOT_COMPLETE' and pr['probeCount']==5 and pr['configurationStable'] is True;assert pr['configurationBefore']==pr['configurationAfter']==ap['preparationConfigurationBefore']==ap['preparationConfigurationAfter']
 for file,digest in pr['probePins'].items():assert N.sha(file)==digest
 for file,digest in ap['tools']['pins'].items():assert N.sha(file)==digest
 out=M.ROOT/'.artifacts'/('inspect54-static-mutant-'+backend+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,cp['files']));files.update([prep,*map(Path,pr['probePins']),cli,receipt,source,sr,authority,ar,Path(__file__).resolve(),HERE/'binding-static-native-fresh.py',*map(Path,ap['tools']['pins']),*[cli.parent/name for name in cr['logs']]])
 private=out/'private-environment.json';private.write_bytes(Path(cp['privateEnvironment']).read_bytes());private.chmod(0o600);assert N.sha(private)==cp['environmentSHA256']==ap['environmentSHA256'];files.add(private)
 commands=[];oracles={};semantic={};inventory=[];prefix=[ap['tools']['taskset'],'-c','5']
 for mutation in sp['mutations']:
  name=mutation['name'];old=Path(mutation['stage']);target=stage/name;shutil.copytree(old,target);assert N.sha(mutation['inventory'])==mutation['inventorySHA256']
  for record in json.loads(Path(mutation['inventory']).read_text()):assert N.sha(target/record['path'])==record['stageSHA256'];inventory.append({'path':name+'/'+record['path'],'originalSHA256':record['originalSHA256'],'stageSHA256':record['stageSHA256']})
  entry=target/HERE.relative_to(M.ROOT)/'binding-static-driver-io.bend';oracles[name]=mutation['oracleIOString'];semantic[name]=mutation['differentSemanticRows']
  if backend=='js':
   output=out/(name+'.js');commands.extend([{'label':name+'-emit-js','argv':prefix+[ap['tools']['tools']['bend'],str(entry),'-o',str(output)],'seconds':30,'generated':str(output),'oracle':None},{'label':name+'-run-js','argv':prefix+[ap['tools']['tools']['node'],str(output)],'seconds':5,'oracle':name}])
  else:
   c=out/(name+'.c');binary=out/(name+'.native');commands.extend([{'label':name+'-emit-c','argv':prefix+[ap['tools']['tools']['bend'],str(entry),'-o',str(c)],'seconds':30,'generated':str(c),'oracle':None},{'label':name+'-compile-native','argv':prefix+[ap['tools']['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'oracle':None},{'label':name+'-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':name}])
 inv=out/'source-inventory.json';inv.write_text(json.dumps(inventory,indent=2)+'\n');files.add(inv);oracle=out/'oracle.json';oracle.write_text(json.dumps(oracles,indent=2)+'\n');files.add(oracle);files.add(HERE/'BINDING-ALLFIELD-ORACLE.json');guards=2*len(commands)+1
 p={'status':'PREPARED_UNADMITTED_MUTANT_EMITTED','backend':backend,'stage':str(stage),'inventory':N.inventory(stage),'sourceInventory':str(inv),'files':sorted(map(str,files)),'directories':ap['directories'],'inputs':N.task_runner.Inputs(files=files,directories=[stage,*map(Path,ap['directories'])]).expected,'privateEnvironment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.configurations(out,stage),'tools':ap['tools'],'toolConfigurationAuthority':ap['toolConfigurationAuthority'],'oracle':str(oracle),'baselineOracle':str(HERE/'BINDING-ALLFIELD-ORACLE.json'),'semanticRows':semantic,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(guards) for name in N.NAMES],'snapshotReuse':{'plan':str(authority),'planSHA256':N.sha(authority),'receipt':str(ar),'receiptSHA256':N.sha(ar),'prepareReceipt':str(prep),'prepareReceiptSHA256':N.sha(prep),'prepareProbePins':pr['probePins'],'historicalInputs':ap['inputs'],'noFreshPreparationProbes':True},'joins':{'source':cp['sourceJoin'],'CLI':{'plan':str(cli),'planSHA256':N.sha(cli),'receipt':str(receipt),'receiptSHA256':N.sha(receipt)}},'scope':'Two compiling/reached static canonical descriptor routing/order defects. Full8 independently authored outputs and exact4/8 semantic differences; all other owners/fields unchanged. Ordinary approved baseline snapshot reused, full execution guards; no framingkill/proof/universalcanonicaltruth/full54.'};path=out/'plan.json';path.write_text(json.dumps(p,indent=2,default=N.encode)+'\n');print(path);print(N.sha(path))
p=argparse.ArgumentParser();p.add_argument('--prepare',choices=['js','native']);p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare)
else:N.run(a.run)
