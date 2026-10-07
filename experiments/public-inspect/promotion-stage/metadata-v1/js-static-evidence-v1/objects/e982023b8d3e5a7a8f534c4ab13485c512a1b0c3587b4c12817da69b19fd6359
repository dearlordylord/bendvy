"""Freeze actual TS metadata consumer only; no Bend/backend/probe preparation."""
from pathlib import Path
import argparse,hashlib,json,sys,time,types,os
HERE=Path(__file__).resolve().parent
PROMOTION=HERE.parent
ROOT=PROMOTION.parents[2]
sys.dont_write_bytecode=True
B=types.ModuleType('inspect54_metadata_source');B.__file__=str(PROMOTION/'control-development.py')
exec((PROMOTION/'control-development.py').read_text().split('p=argparse.ArgumentParser();')[0],B.__dict__)
def prepare(source):
 source=Path(source).resolve();sp=source.parent/'plan.json';s=json.loads(sp.read_text());r=json.loads(source.read_text());assert r['status']=='SAFE_SOURCE_METADATA_PASS' and r['planSHA256']==B.sha(sp)
 assert r['commands']==[{'label':'metadata-affine-witness-source','exit':0,'failure':None}]
 assert B.task_runner.Inputs(files=s['files'],directories=map(Path,s['directories'])).expected==s['inputs']
 out=ROOT/'.artifacts'/('inspect54-metadata-node-'+str(time.time_ns()));out.mkdir();node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node');taskset=Path('/usr/bin/taskset')
 files={Path(__file__).resolve(),HERE/'reference.mjs',HERE/'oracle.py',HERE/'oracle.json',HERE/'CONTRACT.json',HERE/'CONTRACT-TS-JOIN.json',HERE/'BINDING-PROPOSAL.md',PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json',node,taskset,source,sp,Path(s['sourceArchive'])}
 for name,digest in r['logs'].items():p=source.parent/name;assert B.sha(p)==digest;files.add(p)
 for name,record in json.loads(Path(s['sourceArchive']).read_text()).items():p=Path(record['object']);assert B.sha(p)==record['sha256'];files.add(p)
 ts=(ROOT/'.references/bevy-ts/packages/core').resolve();files.update([ts/'package.json',ts.parents[1]/'package.json'])
 private=out/'private-environment.json';private.write_bytes(Path(s['privateEnvironment']).read_bytes());private.chmod(0o600);files.add(private)
 archive=out/'frozen-source';archive.mkdir();records={}
 for path in [HERE/'reference.mjs',HERE/'oracle.py',HERE/'oracle.json',HERE/'CONTRACT.json',HERE/'CONTRACT-TS-JOIN.json',HERE/'BINDING-PROPOSAL.md',Path(__file__).resolve()]:
  digest=B.sha(path);obj=archive/digest;obj.write_bytes(path.read_bytes());records[str(path)]={'sha256':digest,'object':str(obj)}
 index=out/'source-archive.json';index.write_text(json.dumps(records,indent=2)+'\n');files.add(index);directories=[ts/'src',archive];inputs=B.task_runner.Inputs(files=files,directories=directories);roots=[ROOT,PROMOTION,HERE,out,ts,Path('/home/node/.bend')]
 p={'status':'PREPARED_UNADMITTED_ACTUAL_NODE_ONLY','commands':[{'label':'actual-ts-metadata','argv':[str(taskset),'-c','5',str(node),str(HERE/'reference.mjs')],'seconds':5}],'files':sorted(map(str,files)),'directories':list(map(str,directories)),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationRoots':list(map(str,roots)),'configurationStates':B.configurations(roots),'oracle':str(HERE/'oracle.json'),'sourceJoin':{'receipt':str(source),'receiptSHA256':B.sha(source),'planSHA256':B.sha(sp)},'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'scope':'One actual pinned TS metadata consumer; full independent24 JSON records, actual Inspector/System constructors and nominal symbol-key identity/order. No Inspector callback execution/World availability preflight/Bend backend/probes/law/proof/full54 or automatic Bend Plan coupling acceptance.'}
 plan=out/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(plan);print(B.sha(plan))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;env_path=Path(p['privateEnvironment']);assert B.sha(env_path)==p['environmentSHA256'];env=json.loads(env_path.read_text())
 assert B.task_runner.Inputs(files=p['files'],directories=map(Path,p['directories'])).expected==p['inputs'];inputs=B.task_runner.Inputs(files=[path,*p['files']],directories=map(Path,p['directories']));logs=B.runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in p['commands']]);runner=B.task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);receipt={'status':'INCOMPLETE','planSHA256':B.sha(path),'commands':[],'scope':p['scope']}
 def guard():
  inputs.guard();logs.guard();assert B.sha(env_path)==p['environmentSHA256'];assert B.configurations(list(map(Path,p['configurationRoots'])))==p['configurationStates']
 try:
  for c in p['commands']:
   guard()
   try:r=runner.run(c['label'],c['argv'],c['seconds'])
   except BaseException as error:
    r=getattr(error,'result',None);receipt['commands'].append({'label':c['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
   receipt['commands'].append({'label':c['label'],'exit':r['exit'],'failure':r['failure']});assert json.loads(r['stdout'])==json.loads(Path(p['oracle']).read_text())['TS'],'complete actual TS metadata oracle mismatch';guard()
  receipt['status']='COMPLETE_ACTUAL_TS_METADATA_PASS'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--source');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.source)
else:run(a.run)
