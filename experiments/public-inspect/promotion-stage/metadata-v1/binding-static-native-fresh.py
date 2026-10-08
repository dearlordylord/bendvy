"""Fresh ordinary Native preparation; execute only separately admitted plan."""
from pathlib import Path
import argparse,json,os,shutil,time,types
HERE=Path(__file__).resolve().parent
P=HERE.parent
ROOT=P.parents[2]
N=types.ModuleType('metadata_native');N.__file__=str(P/'native-backends.py')
code=(P/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
exec(code.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL8_STATIC_DESCRIPTOR_EMITTED_PASS'"),N.__dict__)
original=(P/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
original=original.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL8_STATIC_DESCRIPTOR_EMITTED_PASS'")
original=original.replace("    logs = LOGS.CommandLogs(out, [command['label'] for command in plan['commands']])","    command_logs=out/'command-logs'\n    command_logs.mkdir()\n    logs=LOGS.CommandLogs(command_logs, [command['label'] for command in plan['commands']])")
original=original.replace("receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}","receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope'], 'logDirectory':str(command_logs)}")
exec(original,N.__dict__)
def configuration(ledger):
 value=N.TOOLS.configuration();value.update(cpu=5,env=ledger.env,execute=ledger.execute);return value
N.configuration=configuration
def prepare(proposal):
 proposal=Path(proposal).resolve();d=json.loads(proposal.read_text());assert d['status']=='SOURCE_ONLY_BACKEND_PROPOSAL_NEEDS_RESOLVER_REVIEW' and d['backend']=='native'
 assert N.task_runner.Inputs(files=d['files'],directories=map(Path,d['directories'])).expected==d['inputs']
 out=ROOT/'.artifacts'/('inspect54-static-backend-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,d['files']));files.add(proposal)
 jsPlan=ROOT/'.artifacts/inspect54-static-backend-1791421630978868568/plan.json';jsReceipt=jsPlan.parent/'receipt.json';jr=json.loads(jsReceipt.read_text());jp=N.decode(json.loads(jsPlan.read_text()));assert jr['planSHA256']==N.sha(jsPlan) and jr['status']=='FULL8_STATIC_DESCRIPTOR_EMITTED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in jr['commands']);files.update([jsPlan,jsReceipt])
 for name,digest in jr['logs'].items():
  f=Path(jr['logDirectory'])/name;assert N.sha(f)==digest;files.add(f)
 for name,digest in jr['generated'].items():assert N.sha(name)==digest;files.add(Path(name))
 assert (Path(jr['logDirectory'])/'static-run-js.stdout').read_bytes()==json.loads((HERE/'BINDING-ALLFIELD-ORACLE.json').read_text())['IOString'].encode()
 for name,digest in jr['probePins'].items():assert N.sha(name)==digest;files.add(Path(name))
 B=types.ModuleType('metadata_closure');B.__file__=str(P/'control-development.py');exec((P/'control-development.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],B.__dict__)
 sources=set();B.closure(HERE/'binding-static-driver-io.bend',sources);sources.update([Path(__file__).resolve(),HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT.json',HERE/'CONTRACT-TS-JOIN.json'])
 git=N.task_runner.execute_result(['git','ls-files'],5,env=dict(os.environ),cwd=ROOT,capture='split');assert git['exit']==0 and git['failure'] is None
 (out/'tracked-source.stdout').write_bytes(git['stdout']);(out/'tracked-source.stderr').write_bytes(git['stderr']);files.update([out/'tracked-source.stdout',out/'tracked-source.stderr']);tracked=set(git['stdout'].decode().splitlines());records=[]
 for source in sorted(sources):
  rel=source.relative_to(ROOT);key=rel.as_posix();assert key in tracked or key.startswith('experiments/public-inspect/promotion-stage/metadata-v1/');assert not source.is_symlink();target=stage/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert N.sha(source)==N.sha(target);records.append({'path':key,'origin':'tracked' if key in tracked else 'selected-owned','sourceSHA256':N.sha(source),'stageSHA256':N.sha(target)})
 files.update(sources);inv=out/'source-inventory.json';inv.write_text(json.dumps({'rule':'actual transitive closure tracked union selected owned','files':records},indent=2)+'\n');files.add(inv)
 files.update([P/'native-backends.py',P/'io-check-remaining.py',N.CONFIG_TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 private=out/'private-environment.json';private.write_bytes(Path(d['privateEnvironment']).read_bytes());private.chmod(0o600);assert N.sha(private)==d['environmentSHA256'];files.add(private);env=json.loads(private.read_text());dirs=set(map(Path,d['directories']))
 oracle=out/'oracle.json';oracle.write_text(json.dumps({'metadata':json.loads((HERE/'BINDING-ALLFIELD-ORACLE.json').read_text())['pureString']},indent=2)+'\n');files.add(oracle)
 inputs=N.task_runner.Inputs(files=files,directories=[stage,*dirs]);ledger=N.ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in N.NAMES],inputs,env);receipt={'status':'INCOMPLETE','scope':'Fresh ordinary resolver snapshot only; no emission/compile/runtime'}
 beforeConfiguration=N.configurations(out,stage);receipt['configurationBefore']=beforeConfiguration
 try:
  tools=N.TOOLS.shared.snapshot(**configuration(ledger));assert ledger.index==5;afterConfiguration=N.configurations(out,stage);assert afterConfiguration==beforeConfiguration,'preparation configuration changed';receipt['configurationAfter']=afterConfiguration;receipt['configurationStable']=True;receipt['status']='OWNED_TOOL_SNAPSHOT_COMPLETE';files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
  prefix=[tools['taskset'],'-c','5'];entry=stage/HERE.relative_to(ROOT)/'binding-static-driver-io.bend';c=out/'metadata.c';binary=out/'metadata.native'
  commands=[{'label':'metadata-emit-c','argv':prefix+[tools['tools']['bend'],str(entry),'-o',str(c)],'seconds':30,'generated':str(c),'oracle':None},{'label':'metadata-compile-native','argv':prefix+[tools['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'oracle':None},{'label':'metadata-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':'metadata'}]
  if d['backend']=='js':
   output=out/'binding-static.js';commands=[{'label':'static-emit-js','argv':prefix+[tools['tools']['bend'],str(entry),'-o',str(output)],'seconds':30,'generated':str(output),'oracle':None},{'label':'static-run-js','argv':prefix+[tools['tools']['node'],str(output)],'seconds':5,'oracle':'metadata'}]
  guards=2*len(commands)+1
  plan={'status':'PREPARED_UNADMITTED','kind':'static-descriptor-'+d['backend'],'backend':d['backend'],'files':sorted(map(str,files)),'directories':sorted(map(str,dirs)),'inputs':N.task_runner.Inputs(files=files,directories=[stage,*dirs]).expected,'stage':str(stage),'inventory':N.inventory(stage),'sourceInventory':str(inv),'tools':tools,'toolConfigurationAuthority':str(N.CONFIG_TOOL),'configurationStates':N.configurations(out,stage),'privateEnvironment':str(private),'environmentSHA256':N.sha(private),'oracle':str(oracle),'commands':commands,'prepareProbeCount':ledger.index,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(guards) for name in N.NAMES],'joins':{name:d[name] for name in ['sourceJoin','cliJoin']},'jsJoin':{'plan':str(jsPlan),'planSHA256':N.sha(jsPlan),'receipt':str(jsReceipt),'receiptSHA256':N.sha(jsReceipt)},'preparationConfigurationBefore':beforeConfiguration,'preparationConfigurationAfter':afterConfiguration,'proposalSHA256':N.sha(proposal),'scope':'Full8 static canonical declaration metadata/grants and actual runtime ArraysExtra resources WorldInstance: exact original pureString+oneIO LF; trusted constructors not universal truth. No runtime Plan/law/proof/mutant/full54.'}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2,default=N.encode)+'\n');print(path);print(N.sha(path))
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['probeCount']=ledger.index;receipt['probePins']=ledger.pins();(out/'prepare-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare)
else:N.run(a.run)
