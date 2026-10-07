"""Freeze cheap source controls without tool probes; run only an admitted plan."""
from pathlib import Path
import argparse,hashlib,json,os,re,runpy,sys,time
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'scripts'))
import task_runner
CONFIG_NAMES=('check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json')
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def closure(path,files):
 path=Path(path).resolve()
 if path in files:return
 files.add(path)
 if path.suffix=='.bend':
  for name in re.findall(r'^\s*import\s+(\S+)',path.read_text(),re.M):
   if name!='Base':closure(path.parent/name,files)
def configurations(paths):
 parents=set()
 for path in paths:parents.update([path,*path.parents])
 return {str(parent/name):sha(parent/name) if (parent/name).is_file() else None for parent in sorted(parents) for name in CONFIG_NAMES}
def prepare(kind,native):
 native=Path(native).resolve();authority=json.loads(native.read_text());assert authority['kind']=='native-io'
 out=ROOT/'.artifacts'/('inspect54-controls-'+kind+'-'+str(time.time_ns()));out.mkdir()
 proposal=HERE/'controls/source-controls-plan.json';p=json.loads(proposal.read_text())
 if kind=='positives':commands=p['commands'][:3]
 elif kind=='negatives':commands=p['commands'][3:]
 else:
  entry=HERE/'controls/reader-mutant-stage/experiments/public-inspect/promotion-stage/cardinality-main.bend'
  commands=[{'label':'reader-mutant-pure-source','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(entry),'--check-only'],'seconds':5,'expected':'safe source check exit0; no proof validity claim'}]
 files={Path(__file__).resolve(),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',proposal,native,HERE/'controls/reader-mutant-manifest.json'}
 for command in commands:closure(Path(command['argv'][4]),files)
 # Exact already-approved tool bytes, libraries/resources and private env; no new snapshot/probe.
 for path,digest in authority['tools']['pins'].items():assert sha(path)==digest;files.add(Path(path))
 original_private=Path(authority['privateEnvironment']);assert sha(original_private)==authority['environmentSHA256']
 private=out/'private-environment.json';private.write_bytes(original_private.read_bytes());private.chmod(0o600);files.add(private)
 directories=[Path('/home/node/.bend/bend2')]
 frozen=out/'frozen-source';frozen.mkdir();archive={}
 for path in sorted(files):
  digest=sha(path);target=frozen/digest
  if not target.exists():target.write_bytes(path.read_bytes())
  archive[str(path)]={'sha256':digest,'object':str(target)}
 index=out/'source-archive.json';index.write_text(json.dumps(archive,indent=2)+'\n');files.add(index)
 inputs=task_runner.Inputs(files=files,directories=[frozen,*directories])
 plan={'status':'PREPARED_UNADMITTED_SOURCE_ONLY','kind':kind,'commands':commands,'files':sorted(map(str,files)),'directories':list(map(str,[frozen,*directories])),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':sha(private),'configurationStates':configurations([ROOT,HERE,out,*[Path(c['argv'][4]).parent for c in commands],Path('/home/node/.bend')]),'configurationRoots':list(map(str,[ROOT,HERE,out,*[Path(c['argv'][4]).parent for c in commands],Path('/home/node/.bend')])),'sourceArchive':str(index),'sourceArchiveSHA256':sha(index),'approvedToolSnapshotPlan':str(native),'approvedToolSnapshotPlanSHA256':sha(native),'scope':'Only cheap source controls. No tool probes/backend/proof/runtime/full54 acceptance. Negative raw rejection requires intended-diagnostic review and exact matched sibling receipt before acceptance.'}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent
 private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text())
 original=task_runner.Inputs(files=p['files'],directories=map(Path,p['directories']));assert original.expected==p['inputs']
 inputs=task_runner.Inputs(files=[path,*p['files']],directories=map(Path,p['directories']))
 logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in p['commands']]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT)
 receipt={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope']}
 def guard():
  inputs.guard();logs.guard();assert sha(private)==p['environmentSHA256'];assert configurations(list(map(Path,p['configurationRoots'])))==p['configurationStates']
 try:
  for command in p['commands']:
   guard()
   try:result=runner.run(command['label'],command['argv'],command['seconds'],expected=None if p['kind']=='negatives' else 0)
   except BaseException as error:
    r=getattr(error,'result',None);receipt['commands'].append({'label':command['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
   receipt['commands'].append({'label':command['label'],'exit':result['exit'],'failure':result['failure']})
   if p['kind']=='negatives':assert result['exit']!=0,'negative unexpectedly compiled'
   guard()
  receipt['status']='RAW_NEGATIVE_REJECTIONS_PENDING_DIAGNOSTIC_REVIEW' if p['kind']=='negatives' else 'SAFE_SOURCE_'+p['kind'].upper()+'_PASS'
 except BaseException as error:receipt['error']=str(error);raise
 finally:
  receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',choices=['positives','negatives','mutant']);p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.prepare,a.native)
else:run(a.run)
