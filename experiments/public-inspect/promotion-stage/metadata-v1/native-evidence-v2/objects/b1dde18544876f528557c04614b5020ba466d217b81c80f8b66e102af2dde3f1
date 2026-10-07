"""Fresh ordinary Native preparation; execute only separately admitted plan."""
from pathlib import Path
import argparse,json,os,shutil,time,types
HERE=Path(__file__).resolve().parent
P=HERE.parent
ROOT=P.parents[2]
N=types.ModuleType('metadata_native');N.__file__=str(P/'native-backends.py')
code=(P/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
exec(code.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL24_METADATA_NATIVE_IO_PASS'"),N.__dict__)
def configuration(ledger):
 value=N.TOOLS.configuration();value.update(cpu=5,env=ledger.env,execute=ledger.execute);return value
N.configuration=configuration
def prepare(proposal):
 proposal=Path(proposal).resolve();d=json.loads(proposal.read_text());assert d['status']=='SOURCE_ONLY_NATIVE_PROPOSAL_PENDING_FRESH_RESOLVER_PREPARATION'
 assert N.task_runner.Inputs(files=d['files'],directories=map(Path,d['directories'])).expected==d['inputs']
 out=ROOT/'.artifacts'/('inspect54-metadata-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,d['files']));files.add(proposal)
 B=types.ModuleType('metadata_closure');B.__file__=str(P/'control-development.py');exec((P/'control-development.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],B.__dict__)
 sources=set();B.closure(HERE/'consumer-io.bend',sources);sources.update([Path(__file__).resolve(),HERE/'oracle.py',HERE/'oracle.json',HERE/'CONTRACT.json',HERE/'CONTRACT-TS-JOIN.json'])
 git=N.task_runner.execute_result(['git','ls-files'],5,env=dict(os.environ),cwd=ROOT,capture='split');assert git['exit']==0 and git['failure'] is None
 (out/'tracked-source.stdout').write_bytes(git['stdout']);(out/'tracked-source.stderr').write_bytes(git['stderr']);files.update([out/'tracked-source.stdout',out/'tracked-source.stderr']);tracked=set(git['stdout'].decode().splitlines());records=[]
 for source in sorted(sources):
  rel=source.relative_to(ROOT);key=rel.as_posix();assert key in tracked or key.startswith('experiments/public-inspect/promotion-stage/metadata-v1/');assert not source.is_symlink();target=stage/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert N.sha(source)==N.sha(target);records.append({'path':key,'origin':'tracked' if key in tracked else 'selected-owned','sourceSHA256':N.sha(source),'stageSHA256':N.sha(target)})
 files.update(sources);inv=out/'source-inventory.json';inv.write_text(json.dumps({'rule':'actual transitive closure tracked union selected owned','files':records},indent=2)+'\n');files.add(inv)
 files.update([P/'native-backends.py',P/'io-check-remaining.py',N.CONFIG_TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 private=out/'private-environment.json';private.write_bytes(Path(d['privateEnvironment']).read_bytes());private.chmod(0o600);assert N.sha(private)==d['environmentSHA256'];files.add(private);env=json.loads(private.read_text());dirs=set(map(Path,d['directories']))
 oracle=out/'oracle.json';oracle.write_text(json.dumps({'metadata':json.loads((HERE/'oracle.json').read_text())['BendPureString']},indent=2)+'\n');files.add(oracle)
 inputs=N.task_runner.Inputs(files=files,directories=[stage,*dirs]);ledger=N.ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in N.NAMES],inputs,env);receipt={'status':'INCOMPLETE','scope':'Fresh ordinary resolver snapshot only; no emission/compile/runtime'}
 try:
  tools=N.TOOLS.shared.snapshot(**configuration(ledger));assert ledger.index==5;receipt['status']='OWNED_TOOL_SNAPSHOT_COMPLETE';files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
  prefix=[tools['taskset'],'-c','5'];entry=stage/HERE.relative_to(ROOT)/'consumer-io.bend';c=out/'metadata.c';binary=out/'metadata.native'
  commands=[{'label':'metadata-emit-c','argv':prefix+[tools['tools']['bend'],str(entry),'-o',str(c)],'seconds':30,'generated':str(c),'oracle':None},{'label':'metadata-compile-native','argv':prefix+[tools['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'oracle':None},{'label':'metadata-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':'metadata'}]
  plan={'status':'PREPARED_UNADMITTED','kind':'metadata-native-io','files':sorted(map(str,files)),'directories':sorted(map(str,dirs)),'inputs':N.task_runner.Inputs(files=files,directories=[stage,*dirs]).expected,'stage':str(stage),'inventory':N.inventory(stage),'sourceInventory':str(inv),'tools':tools,'toolConfigurationAuthority':str(N.CONFIG_TOOL),'configurationStates':N.configurations(out,stage),'privateEnvironment':str(private),'environmentSHA256':N.sha(private),'oracle':str(oracle),'commands':commands,'prepareProbeCount':ledger.index,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(7) for name in N.NAMES],'joins':{name:d[name] for name in ['sourceJoin','nodeJoin','jsJoin']},'proposalSHA256':N.sha(proposal),'scope':'Full24 resource-only metadata Native IO diagnostic: all actualArray cells/opaquePlan threadback, exact pureString+oneIO LF. No automatic Plan declaration coupling/World callback/availability/law/proof/mutant/full54.'}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2,default=N.encode)+'\n');print(path);print(N.sha(path))
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['probeCount']=ledger.index;receipt['probePins']=ledger.pins();(out/'prepare-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare)
else:N.run(a.run)
