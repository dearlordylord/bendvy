"""Prepare guarded cheap binding source cohorts; run only admitted plan."""
from pathlib import Path
import argparse,contextlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('binding_source');S.__file__=str(HERE/'consumer-source.py')
exec((HERE/'consumer-source.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
TARGETS={'positives':['binding-witness.bend','binding-controls/positive.bend'],'negative1':['binding-controls/cross-schema.bend','binding-controls/mismatched-index.bend','binding-controls/undeclared.bend'],'negative2':['binding-controls/write-authority.bend','binding-controls/duplicate-owner.bend','binding-controls/escape-owner.bend']}
REASONS={'cross-schema':'actual Garden nominal Declaration used where Workshop Declaration is required at W.define bonus argument','mismatched-index':'same Declaration bonus projection index passed to bind specialized to score projection at declaration argument','undeclared':'actual fixed W.Reads<H> returned as ExtraReads<H> containing fourth undeclared resource grant','write-authority':'actual score ValueRead returned where ValueWrite required','duplicate-owner':'same affine combined Definition owner consumed twice in tuple','escape-owner':'opaque combined Owner<P,Extra> returned by into_plan where String required'}
def prepare(native,kind,positive):
 manifest=HERE/'BINDING-API-MANIFEST.json';m=json.loads(manifest.read_text());assert B.sha(manifest)=='d85c195290f3bc55e749841888d9f91f7f039cbbd15835132e200faf16cc52fc'
 for name,digest in m['files'].items():assert B.sha(HERE/name)==digest
 buf=io.StringIO()
 with contextlib.redirect_stdout(buf):S.prepare(native)
 path=Path(buf.getvalue().splitlines()[0]);p=json.loads(path.read_text());out=path.parent;files=set(map(Path,p['files']));sources=set();targets=[HERE/name for name in TARGETS[kind]]
 for target in targets:B.closure(target,sources)
 files.update(sources|{Path(__file__).resolve(),manifest})
 records=json.loads(Path(p['sourceArchive']).read_text());archive=out/'frozen-source'
 for f in sources|{Path(__file__).resolve(),manifest}:
  digest=B.sha(f);obj=archive/digest;obj.write_bytes(f.read_bytes());records[str(f)]={'sha256':digest,'object':str(obj)}
 index=Path(p['sourceArchive']);index.write_text(json.dumps(records,indent=2)+'\n');p['sourceArchiveSHA256']=B.sha(index)
 commands=[{'label':target.stem,'argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(target),'--check-only'],'seconds':5,'intended':'safe source feasibility exit0' if kind=='positives' else REASONS[target.stem]} for target in targets]
 p.update(kind=kind,status='PREPARED_UNADMITTED_BINDING_'+kind.upper(),commands=commands,scope='Trusted canonical schema declaration-path source feasibility/diagnostics only. Forgeable low-level constructors are trusted, not universal public metadata truth. No callback/World/runtime/availability/proof/law/coupling/full54. Exact raw negative single-location classification separate from exit status; matched positive receipt required before negative execution.')
 if positive:
  receipt=Path(positive).resolve();r=json.loads(receipt.read_text());assert r['status']=='SAFE_BINDING_SOURCE_POSITIVES_PASS';pp=receipt.parent/'plan.json';rp=json.loads(pp.read_text());assert r['planSHA256']==B.sha(pp);assert B.task_runner.Inputs(files=rp['files'],directories=map(Path,rp['directories'])).expected==rp['inputs'];files.update([receipt,pp])
  for name,digest in r['logs'].items():f=receipt.parent/name;assert B.sha(f)==digest;files.add(f)
  p['matchedPositive']={'receipt':str(receipt),'sha256':B.sha(receipt),'planSHA256':B.sha(pp)}
 elif kind!='positives':p['status']='SOURCE_ONLY_NEGATIVE_PROPOSAL_PENDING_MATCHED_POSITIVE'
 p['files']=sorted(map(str,files));p['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,p['directories'])).expected;path.write_text(json.dumps(p,indent=2)+'\n');print(path);print(B.sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());assert p['status'].startswith('PREPARED_UNADMITTED_BINDING_');negative=p['kind']!='positives';out=path.parent
 if negative:
  join=p['matchedPositive'];assert B.sha(join['receipt'])==join['sha256'];assert B.sha(Path(join['receipt']).parent/'plan.json')==join['planSHA256']
 private=Path(p['privateEnvironment']);assert B.sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());assert B.task_runner.Inputs(files=p['files'],directories=map(Path,p['directories'])).expected==p['inputs']
 inputs=B.task_runner.Inputs(files=[path,*p['files']],directories=map(Path,p['directories']));logs=B.runpy.run_path(str(B.ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in p['commands']]);runner=B.task_runner.Runner(logs,inputs=inputs,env=env,cwd=B.ROOT);receipt={'status':'INCOMPLETE','planSHA256':B.sha(path),'commands':[],'scope':p['scope']}
 def guard():
  inputs.guard();logs.guard();assert B.sha(private)==p['environmentSHA256'];assert B.configurations(list(map(Path,p['configurationRoots'])))==p['configurationStates']
 try:
  for c in p['commands']:
   guard()
   try:r=runner.run(c['label'],c['argv'],c['seconds'],expected=None if negative else 0)
   except BaseException as error:
    r=getattr(error,'result',None);receipt['commands'].append({'label':c['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
   receipt['commands'].append({'label':c['label'],'exit':r['exit'],'failure':r['failure'],'classification':'UNCLASSIFIED' if negative else 'SOURCE_FEASIBILITY'})
   if negative:assert r['exit']==1 and r['failure'] is None,'unexpected refusal outcome; intended raw reason unclassified'
   guard()
  receipt['status']='RAW_BINDING_SOURCE_NEGATIVES_PENDING_REVIEW' if negative else 'SAFE_BINDING_SOURCE_POSITIVES_PASS'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',choices=TARGETS);p.add_argument('--native');p.add_argument('--positive');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native,a.prepare,a.positive)
else:run(a.run)
