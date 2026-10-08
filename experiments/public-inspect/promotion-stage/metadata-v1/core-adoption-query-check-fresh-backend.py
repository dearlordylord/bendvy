"""Fresh ordinary Native preparation; execute only separately admitted plan."""
from pathlib import Path
import argparse,json,os,shutil,time,types
HERE=Path(__file__).resolve().parent
P=HERE.parent
ROOT=P.parents[2]
N=types.ModuleType('metadata_native');N.__file__=str(P/'native-backends.py')
code=(P/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
exec(code.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL74_84_CURRENT_ROOT_EMITTED_PASS'"),N.__dict__)
original=(P/'native-backends.py').read_text().rsplit('parser = argparse.ArgumentParser()',1)[0]
original=original.replace("'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'","'FULL74_84_CURRENT_ROOT_EMITTED_PASS'")
original=original.replace("    logs = LOGS.CommandLogs(out, [command['label'] for command in plan['commands']])","    command_logs=out/'command-logs'\n    command_logs.mkdir()\n    logs=LOGS.CommandLogs(command_logs, [command['label'] for command in plan['commands']])")
original=original.replace("receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}","receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope'], 'logDirectory':str(command_logs)}")
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
                assert result['stdout']==(oracle[command['oracle']]+'\\n').encode(),'full74/84 normal oracle mismatch'
"""+original[end:]
original="import sys\n"+original
exec(original,N.__dict__)
def configuration(ledger):
 value=N.TOOLS.configuration();value.update(cpu=5,env=ledger.env,execute=ledger.execute);return value
N.configuration=configuration
def configurations(out,stage):
 roots={ROOT,P,HERE,Path.cwd(),out,stage,Path('/home/node/.bend/bend2'),*[source.parent for source in stage.rglob('*.bend')]}
 paths={parent/name for root in roots for parent in [root,*root.parents] for name in N.CONFIG_NAMES}
 return {str(path):N.sha(path) if path.is_file() else None for path in sorted(paths)}
N.configurations=configurations
def prepare(proposal):
 proposal=Path(proposal).resolve();d=json.loads(proposal.read_text());assert d['status']=='SOURCE_ONLY_BACKEND_PROPOSAL_NEEDS_RESOLVER_REVIEW'
 assert N.task_runner.Inputs(files=d['files'],directories=map(Path,d['directories'])).expected==d['inputs']
 out=ROOT/'.artifacts'/('inspect54-static-backend-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,d['files']));files.add(proposal)
 B=types.ModuleType('metadata_closure');B.__file__=str(P/'control-development.py');exec((P/'control-development.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],B.__dict__)
 sources=set()
 for name in ['cardinality-io-main.bend','check-io-main.bend']:B.closure(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/P.relative_to(ROOT)/name,sources)
 sources.update([Path(__file__).resolve(),HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT.json',HERE/'CONTRACT-TS-JOIN.json'])
 git=N.task_runner.execute_result(['git','ls-files'],5,env=dict(os.environ),cwd=ROOT,capture='split');assert git['exit']==0 and git['failure'] is None
 (out/'tracked-source.stdout').write_bytes(git['stdout']);(out/'tracked-source.stderr').write_bytes(git['stderr']);files.update([out/'tracked-source.stdout',out/'tracked-source.stderr']);tracked=set(git['stdout'].decode().splitlines());records=[]
 for source in sorted(sources):
  rel=source.relative_to(ROOT);key=rel.as_posix();assert key in tracked or key.startswith('experiments/public-inspect/promotion-stage/metadata-v1/');assert not source.is_symlink();target=stage/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert N.sha(source)==N.sha(target);records.append({'path':key,'origin':'tracked' if key in tracked else 'selected-owned','sourceSHA256':N.sha(source),'stageSHA256':N.sha(target)})
 files.update(sources);inv=out/'source-inventory.json';inv.write_text(json.dumps({'rule':'actual transitive closure tracked union selected owned','files':records},indent=2)+'\n');files.add(inv)
 files.update([P/'native-backends.py',P/'io-check-remaining.py',N.CONFIG_TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 private=out/'private-environment.json';private.write_bytes(Path(d['privateEnvironment']).read_bytes());private.chmod(0o600);assert N.sha(private)==d['environmentSHA256'];files.add(private);env=json.loads(private.read_text());dirs=set(map(Path,d['directories']))
 oracle=out/'oracle.json';oracle.write_text(json.dumps({key:value[:-1] for key,value in json.loads(Path(d['oracle']).read_text()).items()},indent=2)+'\n');files.add(oracle)
 inputs=N.task_runner.Inputs(files=files,directories=[stage,*dirs]);ledger=N.ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in N.NAMES],inputs,env);receipt={'status':'INCOMPLETE','scope':'Fresh ordinary resolver snapshot only; no emission/compile/runtime'}
 beforeConfiguration=N.configurations(out,stage);receipt['configurationBefore']=beforeConfiguration
 try:
  tools=N.TOOLS.shared.snapshot(**configuration(ledger));assert ledger.index==5;afterConfiguration=N.configurations(out,stage);assert beforeConfiguration==afterConfiguration,'preparation configuration changed';receipt['configurationAfter']=afterConfiguration;receipt['configurationStable']=True;receipt['status']='OWNED_TOOL_SNAPSHOT_COMPLETE';files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
  prefix=[tools['taskset'],'-c','5'];commands=[]
  for name in ['cardinality','check']:
   entry=stage/HERE.relative_to(ROOT)/'core-adoption-proposal-v1/query-check-stage-v1'/P.relative_to(ROOT)/(name+'-io-main.bend');output=out/(name+'.js' if d['backend']=='js' else name+'.c')
   commands.append({'label':name+'-emit-'+d['backend'],'argv':prefix+[tools['tools']['bend'],str(entry),'-o',str(output)],'seconds':30,'generated':str(output),'oracle':None})
   if d['backend']=='js':commands.append({'label':name+'-run-js','argv':prefix+[tools['tools']['node'],str(output)],'seconds':5,'oracle':name})
   else:
    binary=out/(name+'.native');commands.append({'label':name+'-compile-native','argv':prefix+[tools['tools']['clang-wrapper'],'-O3',str(output),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'oracle':None});commands.append({'label':name+'-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':name})
  guards=2*len(commands)+1
  plan={'status':'PREPARED_UNADMITTED','kind':'static-descriptor-'+d['backend'],'backend':d['backend'],'files':sorted(map(str,files)),'directories':sorted(map(str,dirs)),'inputs':N.task_runner.Inputs(files=files,directories=[stage,*dirs]).expected,'stage':str(stage),'inventory':N.inventory(stage),'sourceInventory':str(inv),'tools':tools,'toolConfigurationAuthority':str(N.CONFIG_TOOL),'configurationStates':N.configurations(out,stage),'privateEnvironment':str(private),'environmentSHA256':N.sha(private),'oracle':str(oracle),'commands':commands,'prepareProbeCount':ledger.index,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(guards) for name in N.NAMES],'joins':{name:d[name] for name in ['sourceJoin','cliJoin']},'preparationConfigurationBefore':beforeConfiguration,'preparationConfigurationAfter':afterConfiguration,'proposalSHA256':N.sha(proposal),'scope':'Full74/84 current-root generic proposed-core cardinality/query and Check actual Sys/Schedule callbacks, complete fields/readonly Worlds/owners with exact originalString+oneIO LF. Trusted raw constructors not universal truth; diagnostics outside readonly boundary; no proof/mutant/full54.'}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2,default=N.encode)+'\n');print(path);print(N.sha(path))
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['probeCount']=ledger.index;receipt['probePins']=ledger.pins();(out/'prepare-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare)
else:N.run(a.run)
