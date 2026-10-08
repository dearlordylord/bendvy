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
code=code.replace("   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'","   expected=(json.loads(Path(p['oracle']).read_text())[command['oracle']]).encode()\n   assert result['stdout']==expected,'complete public oracle mismatch'\n   if p['baselineIOString'] is not None:\n    different=[i for i,(actual,original) in enumerate(zip(result['stdout'].decode().splitlines(),p['baselineIOString'].splitlines())) if actual!=original]\n    assert different==p['expectedDifferentRows'],'precise fullsemantic differences mismatch'\n   receipt.setdefault('oracleResults',{})[command['oracle']]={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'expectedSHA256':hashlib.sha256(expected).hexdigest(),'records':p['recordCount'],'exactIOFinalLF':True}\n   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'")
code=code.replace("'SAFE_SOURCE_'+p['kind'].upper()+'_PASS'","'FULL_CURRENT_ROOT_CONTROL_CLI_IO_PASS'")
exec('import sys\n'+code,B.__dict__)
def prepare(native,subject):
 native=Path(native).resolve();n=json.loads(native.read_text());out=ROOT/'.artifacts'/('inspect54-metadata-source-'+str(time.time_ns()));out.mkdir()
 model=HERE/'core-adoption-proposal-v1/remaining-controls-v1/MODELS-AND-JOINS.json';m=json.loads(model.read_text());assert B.sha(model)=='06b17fa8043cd06614d780a638b64f0b33f900afe3ad6c7c44e4a5563a834ef9'
 stamps={'reader':'1791430827586471528','lens-routing':'1791430863197059208','metadata-order':'1791430948164463067','retainer':'1791430976698082937'};sourcePlan=ROOT/'.artifacts'/('inspect54-metadata-source-'+stamps[subject])/'plan.json';sourceReceipt=sourcePlan.parent/'receipt.json';sr=json.loads(sourceReceipt.read_text());sp=json.loads(sourcePlan.read_text());assert sr['planSHA256']==B.sha(sourcePlan);assert sr['commands']==[{'label':subject+'-pure-source','exit':0,'failure':None}]
 sourceIndex=Path(sp['sourceArchive']);assert B.sha(sourceIndex)==sp['sourceArchiveSHA256'];prior=json.loads(sourceIndex.read_text());qualified=set();B.closure(Path(sp['commands'][0]['argv'][4]),qualified)
 for f in qualified:assert B.sha(f)==prior[str(f)]['sha256']==B.sha(prior[str(f)]['object'])
 for name,digest in sr['logs'].items():assert B.sha(sourcePlan.parent/name)==digest
 if subject=='reader':entry=Path(sp['commands'][0]['argv'][4]).with_name('cardinality-io-main.bend');expected=m['reader']['independentDefectIOString'];baseline=m['reader']['originalIOString'];different=m['reader']['semanticDifferenceRows'];count=75
 elif subject=='retainer':entry=Path(sp['commands'][0]['argv'][4]).with_name('retention-fail-skip-io.bend');expected=m['retainer']['IOString'];baseline=None;different=[];count=20
 else:
  entry=Path(sp['commands'][0]['argv'][4]).with_name('adoption-driver-io.bend');mm=next(x for x in m['closedState'] if x['name']==subject);expected=mm['independentFullIOString'];baseline=json.loads((HERE/'BINDING-ALLFIELD-ORACLE.json').read_text())['IOString'];different=[i for i,(actual,original) in enumerate(zip(expected.splitlines(),baseline.splitlines())) if actual!=original];assert len(different)==mm['expectedDifferentSemanticRows'];count=8
 oracle=out/'oracle.json';oracle.write_text(json.dumps({subject:expected},indent=2)+'\n');files={oracle,model,Path(__file__).resolve(),sourcePlan,sourceReceipt,sourceIndex,*[sourcePlan.parent/name for name in sr['logs']],*[Path(prior[str(f)]['object']) for f in qualified],PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',native};sources=set();B.closure(entry,sources);files.update(sources);rootfiles={Path(f) for f in sp['files'] if str(f).startswith('/workspace/formal-proofs/bendvy/src/')};files.update(rootfiles)
 for path,digest in n['tools']['pins'].items():assert B.sha(path)==digest;files.add(Path(path))
 private=out/'private-environment.json';original=Path(n['privateEnvironment']);assert B.sha(original)==n['environmentSHA256'];private.write_bytes(original.read_bytes());private.chmod(0o600);files.add(private)
 archive=out/'frozen-source';archive.mkdir();records={}
 for path in sorted(sources|{model,oracle,Path(__file__).resolve(),PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',*rootfiles}):
  digest=B.sha(path);obj=archive/digest
  if not obj.exists():obj.write_bytes(path.read_bytes())
  records[str(path)]={'sha256':digest,'object':str(obj)}
 index=out/'source-archive.json';index.write_text(json.dumps(records,indent=2)+'\n');files.add(index)
 directories=[archive,Path('/home/node/.bend/bend2')];inputs=B.task_runner.Inputs(files=files,directories=directories);roots=sorted({*[file.parent for file in rootfiles],*[parent for file in rootfiles for parent in file.parents],ROOT,PROMOTION,HERE,out,Path('/home/node/.bend'),Path('/home/node/.bend/bend2'),*[source.parent for source in sources],*[parent for source in sources for parent in source.parents]})
 p={'subject':subject,'recordCount':count,'baselineIOString':baseline,'expectedDifferentRows':different,'sourceJoin':{'plan':str(sourcePlan),'planSHA256':B.sha(sourcePlan),'receipt':str(sourceReceipt),'receiptSHA256':B.sha(sourceReceipt),'sourceArchiveSHA256':B.sha(sourceIndex),'qualifiedClosure':{str(f):prior[str(f)]['sha256'] for f in sorted(qualified)}},'oracle':str(oracle),'status':'PREPARED_UNADMITTED_SOURCE_ONLY','kind':'cli-io','commands':[{'label':subject+'-cli-io','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(entry)],'seconds':5,'oracle':subject}],'files':sorted(map(str,files)),'directories':list(map(str,directories)),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationRoots':list(map(str,roots)),'configurationStates':B.configurations(roots),'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'approvedToolSnapshotPlan':str(native),'approvedToolSnapshotPlanSHA256':B.sha(native),'scope':'One current-root '+subject+' actualCLI in-processgeneratedJS IO completeindependentlyauthored fulloracle+exactIO LF. SameclosedDescriptor/affineOwnerArraysExtra/genuineSysSch callbacks; controlmustreach exactfullsemanticdefect or actual20retentionstate, notframing/unrelatedfailure. No emittedJSNative/proof/adoption/generaltruth/full54 credit.'}
 plan=out/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(plan);print(B.sha(plan))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--native');p.add_argument('--subject',choices=['reader','lens-routing','metadata-order','retainer']);p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native,a.subject)
else:B.run(a.run)
