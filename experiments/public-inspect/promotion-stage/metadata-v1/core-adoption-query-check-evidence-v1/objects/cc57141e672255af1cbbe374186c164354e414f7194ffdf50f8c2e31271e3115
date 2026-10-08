"""Prepare one complete metadata consumer without probes; execute only admitted plan."""
from pathlib import Path
import argparse,hashlib,json,sys,time,types
HERE=Path(__file__).resolve().parent
PROMOTION=HERE.parent
ROOT=PROMOTION.parents[2]
sys.dont_write_bytecode=True
B=types.ModuleType('inspect54_metadata_source');B.__file__=str(PROMOTION/'control-development.py')
code=(PROMOTION/'control-development.py').read_text().split('p=argparse.ArgumentParser();')[0]
a=code.index("   try:result=runner.run")
b=code.index("  receipt['status']=",a)
code=code[:a]+"""   try:
    try:result=runner.run(command['label'],command['argv'],command['seconds'],expected=None if p['kind']=='negatives' else 0)
    except BaseException as error:
     r=getattr(error,'result',None);receipt['commands'].append({'label':command['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
    receipt['commands'].append({'label':command['label'],'exit':result['exit'],'failure':result['failure']})
   finally:
    primary=sys.exc_info()[1]
    try:guard()
    except BaseException as error:
     receipt.setdefault('postChildGuardErrors',[]).append(str(error))
     if primary is None:raise
   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'
"""+code[b:]
code=code.replace("   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'","   expected=(json.loads(Path(p['oracle']).read_text())[command['oracle']]).encode()\n   assert result['stdout']==expected,'complete public oracle mismatch'\n   receipt.setdefault('oracleResults',{})[command['oracle']]={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'expectedSHA256':hashlib.sha256(expected).hexdigest(),'records':74 if command['oracle']=='cardinality' else 84,'exactIOFinalLF':True}\n   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'")
code=code.replace("'SAFE_SOURCE_'+p['kind'].upper()+'_PASS'","'FULL74_84_CURRENT_ROOT_CLI_IO_PASS'")
exec('import sys\n'+code,B.__dict__)
def prepare(native):
 native=Path(native).resolve();n=json.loads(native.read_text());out=ROOT/'.artifacts'/('inspect54-metadata-source-'+str(time.time_ns()));out.mkdir()
 join=HERE/'core-adoption-proposal-v1/QUERY-CHECK-STAGE-INVENTORY.json';jd=json.loads(join.read_text());rootfiles=set()
 for key,record in jd['files'].items():
  actual=Path(record['source']);copied=HERE/'core-adoption-proposal-v1/query-check-stage-v1'/key;assert B.sha(actual)==record['sourceSHA256'];assert B.sha(copied)==record['stageSHA256']
  if str(actual).startswith('/workspace/formal-proofs/bendvy/src/'):assert B.sha(actual)==B.sha(copied);rootfiles.add(actual)
 sourcePlan=ROOT/'.artifacts/inspect54-metadata-source-1791428590687026885/plan.json';sourceReceipt=sourcePlan.parent/'receipt.json';sr=json.loads(sourceReceipt.read_text());sp=json.loads(sourcePlan.read_text());assert B.sha(sourcePlan)=='e91622a94a7555c7eddf0c1e56b3dbc0f91135c18b6a9a14690dbdec39d77770';assert sr['planSHA256']==B.sha(sourcePlan);assert all(c['exit']==0 and c['failure'] is None for c in sr['commands']) and len(sr['commands'])==2
 sourceIndex=Path(sp['sourceArchive']);assert B.sha(sourceIndex)==sp['sourceArchiveSHA256'];prior=json.loads(sourceIndex.read_text());qualified=set()
 for name in ['cardinality-main.bend','check-main.bend']:B.closure(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/PROMOTION.relative_to(ROOT)/name,qualified)
 for source in qualified:assert B.sha(source)==prior[str(source)]['sha256']==B.sha(prior[str(source)]['object'])
 for name,digest in sr['logs'].items():assert B.sha(sourcePlan.parent/name)==digest
 import runpy
 oracle=out/'oracle.json';oracle.write_text(json.dumps({key:runpy.run_path(str(PROMOTION/name))['EXPECTED']+'\n' for key,name in [('cardinality','cardinality-oracle.py'),('check','check-bend-oracle-v2.py')]},indent=2)+'\n')
 files={oracle,sourcePlan,sourceReceipt,sourceIndex,*[sourcePlan.parent/name for name in sr['logs']],*[Path(prior[str(source)]['object']) for source in qualified],PROMOTION/'cardinality-oracle.py',PROMOTION/'check-bend-oracle-v2.py',join,*rootfiles,HERE/'core-adoption-proposal-v1/STAGE-INVENTORY.json',HERE/'core-adoption-proposal-v1/SOURCE-MAP.json',HERE/'core-adoption-proposal-v1/IMPORT-ONLY-CORE.patch',Path(__file__).resolve(),HERE/'CONTRACT.json',HERE/'core-adoption-proposal-v1/PROPOSAL.json',HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT-TS-JOIN.json',PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',native}
 sources=set()
 for target in ['cardinality-io-main.bend','check-io-main.bend']:B.closure(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/PROMOTION.relative_to(ROOT)/target,sources)
 files.update(sources)
 for path,digest in n['tools']['pins'].items():assert B.sha(path)==digest;files.add(Path(path))
 private=out/'private-environment.json';original=Path(n['privateEnvironment']);assert B.sha(original)==n['environmentSHA256'];private.write_bytes(original.read_bytes());private.chmod(0o600);files.add(private)
 archive=out/'frozen-source';archive.mkdir();records={}
 for path in sorted(sources|{oracle,PROMOTION/'cardinality-oracle.py',PROMOTION/'check-bend-oracle-v2.py',join,*rootfiles,HERE/'core-adoption-proposal-v1/STAGE-INVENTORY.json',HERE/'core-adoption-proposal-v1/SOURCE-MAP.json',HERE/'core-adoption-proposal-v1/IMPORT-ONLY-CORE.patch',Path(__file__).resolve(),HERE/'CONTRACT.json',HERE/'core-adoption-proposal-v1/PROPOSAL.json',HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT-TS-JOIN.json',PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}):
  digest=B.sha(path);obj=archive/digest
  if not obj.exists():obj.write_bytes(path.read_bytes())
  records[str(path)]={'sha256':digest,'object':str(obj)}
 index=out/'source-archive.json';index.write_text(json.dumps(records,indent=2)+'\n');files.add(index)
 directories=[archive,Path('/home/node/.bend/bend2')];inputs=B.task_runner.Inputs(files=files,directories=directories);roots=sorted({*[file.parent for file in rootfiles],*[parent for file in rootfiles for parent in file.parents],ROOT,PROMOTION,HERE,out,Path('/home/node/.bend'),Path('/home/node/.bend/bend2'),*[source.parent for source in sources],*[parent for source in sources for parent in source.parents]})
 p={'sourceJoin':{'planSHA256':B.sha(sourcePlan),'receiptSHA256':B.sha(sourceReceipt),'sourceArchiveSHA256':B.sha(sourceIndex),'qualifiedClosure':{str(source):prior[str(source)]['sha256'] for source in sorted(qualified)}},'oracle':str(oracle),'status':'PREPARED_UNADMITTED_SOURCE_ONLY','kind':'cli-io','commands':[{'label':'adoption-'+name.removesuffix('.bend')+'-cli-io','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/PROMOTION.relative_to(ROOT)/name)],'seconds':5,'oracle':'cardinality' if name.startswith('cardinality') else 'check'} for name in ['cardinality-io-main.bend','check-io-main.bend']],'files':sorted(map(str,files)),'directories':list(map(str,directories)),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationRoots':list(map(str,roots)),'configurationStates':B.configurations(roots),'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'approvedToolSnapshotPlan':str(native),'approvedToolSnapshotPlanSHA256':B.sha(native),'scope':'Two current-root copied-core actualCLI IO consumers full74/84 original independently authored oracles plus exact IO.print LF, two nominal schemas genuine Sys/Schedule observations/read-only Check boundary, unchangedfixtureoperations/promotedgenericimports. In-process generatedJS IO, no pureinterpreter/emittedJSNative/proof/generaltruth/full54 credit.'}
 plan=out/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(plan);print(B.sha(plan))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native)
else:B.run(a.run)
