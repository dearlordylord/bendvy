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
exec('import sys\n'+code,B.__dict__)
def prepare(native,subject):
 native=Path(native).resolve();n=json.loads(native.read_text());out=ROOT/'.artifacts'/('inspect54-metadata-source-'+str(time.time_ns()));out.mkdir()
 model=HERE/'core-adoption-proposal-v1/remaining-controls-v1/MODELS-AND-JOINS.json';m=json.loads(model.read_text());assert B.sha(model)=='06b17fa8043cd06614d780a638b64f0b33f900afe3ad6c7c44e4a5563a834ef9'
 if subject=='reader':stage=ROOT/m['reader']['stage'];entry=stage/PROMOTION.relative_to(ROOT)/'cardinality-main.bend';positive=ROOT/'.artifacts/inspect54-metadata-source-1791428590687026885/plan.json';allowed={'src/ecs/inspector.bend'}
 elif subject in ['lens-routing','metadata-order']:
  selected=next(x for x in m['closedState'] if x['name']==subject);stage=ROOT/selected['stage'];entry=stage/HERE.relative_to(ROOT)/'adoption-driver-main.bend';positive=ROOT/'.artifacts/inspect54-metadata-source-1791426905398043844/plan.json';allowed={str(HERE.relative_to(ROOT)/'binding-fixtures'/name) for name in ['workshop.bend','garden.bend']}
 else:stage=ROOT/m['retainer']['stage'];entry=stage/m['retainer']['sourceEntry'];positive=None;allowed=set()
 files={model,Path(__file__).resolve(),PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',native};sources=set();B.closure(entry,sources);files.update(sources);rootfiles=set();baselineJoin=None
 if positive:
  pp=json.loads(positive.read_text());receipt=positive.parent/'receipt.json';pr=json.loads(receipt.read_text());assert pr['planSHA256']==B.sha(positive) and all(c['exit']==0 and c['failure'] is None for c in pr['commands']);archive=Path(pp['sourceArchive']);assert B.sha(archive)==pp['sourceArchiveSHA256'];records=json.loads(archive.read_text());files.update([positive,receipt,archive,*[positive.parent/name for name in pr['logs']]])
  for name,digest in pr['logs'].items():assert B.sha(positive.parent/name)==digest
  base=HERE/'core-adoption-proposal-v1'/('query-check-stage-v1' if subject=='reader' else 'current-root-stage-v2');pairs=[]
  for f in sources:
   rel=f.relative_to(stage);original=base/rel;assert B.sha(original)==records[str(original)]['sha256']==B.sha(records[str(original)]['object']);files.update([original,Path(records[str(original)]['object'])])
   if rel.as_posix() not in allowed:assert B.sha(original)==B.sha(f)
   pairs.append({'path':rel.as_posix(),'baselineSHA256':B.sha(original),'subjectSHA256':B.sha(f)})
  baselineJoin={'plan':str(positive),'planSHA256':B.sha(positive),'receipt':str(receipt),'receiptSHA256':B.sha(receipt),'sourceArchiveSHA256':B.sha(archive),'files':pairs}
 for f in sources:
  rel=f.relative_to(stage)
  if rel.as_posix().startswith('src/ecs/') and rel.name not in ['inspector.bend','inspector-query-projection.bend','inspector-query.bend','check.bend','inspector-metadata.bend','inspector-declaration.bend','inspector-definition.bend']:
   actual=Path('/workspace/formal-proofs/bendvy')/rel;assert B.sha(actual)==B.sha(f);rootfiles.add(actual)
 files.update(rootfiles)
 archiveFiles=set(files)
 for path,digest in n['tools']['pins'].items():assert B.sha(path)==digest;files.add(Path(path))
 private=out/'private-environment.json';original=Path(n['privateEnvironment']);assert B.sha(original)==n['environmentSHA256'];private.write_bytes(original.read_bytes());private.chmod(0o600);files.add(private)
 archive=out/'frozen-source';archive.mkdir();records={}
 for path in sorted(archiveFiles-{native}):
  digest=B.sha(path);obj=archive/digest
  if not obj.exists():obj.write_bytes(path.read_bytes())
  records[str(path)]={'sha256':digest,'object':str(obj)}
 index=out/'source-archive.json';index.write_text(json.dumps(records,indent=2)+'\n');files.add(index)
 directories=[archive,Path('/home/node/.bend/bend2')];inputs=B.task_runner.Inputs(files=files,directories=directories);roots=sorted({*[file.parent for file in rootfiles],*[parent for file in rootfiles for parent in file.parents],ROOT,PROMOTION,HERE,out,Path('/home/node/.bend'),Path('/home/node/.bend/bend2'),*[source.parent for source in sources],*[parent for source in sources for parent in source.parents]})
 p={'subject':subject,'model':str(model),'modelSHA256':B.sha(model),'baselineJoin':baselineJoin,'status':'PREPARED_UNADMITTED_SOURCE_ONLY','kind':'metadata','commands':[{'label':subject+'-pure-source','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(entry),'--check-only'],'seconds':5}],'files':sorted(map(str,files)),'directories':list(map(str,directories)),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationRoots':list(map(str,roots)),'configurationStates':B.configurations(roots),'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'approvedToolSnapshotPlan':str(native),'approvedToolSnapshotPlanSHA256':B.sha(native),'scope':'One affected pure closed source feasibility check only for '+subject+' current-root copied-core control. Independentfull75/full8/retainer20 oracle frozen separately; no runtime/reachedkill/proof/adoption/generaltruth/full54 credit. SameclosedDescriptor runtimeOwner arrays/Extra and genuineSys/Schedule operations preserved.'}
 plan=out/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(plan);print(B.sha(plan))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--native');p.add_argument('--subject',choices=['reader','lens-routing','metadata-order','retainer']);p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native,a.subject)
else:B.run(a.run)
