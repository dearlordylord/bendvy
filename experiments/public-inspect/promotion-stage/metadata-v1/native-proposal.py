"""Source-only proposal freezer; intentionally no execution entry point."""
from pathlib import Path
import argparse,contextlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('metadata_future');S.__file__=str(HERE/'consumer-source.py')
exec((HERE/'consumer-source.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
p=argparse.ArgumentParser();p.add_argument('--source',required=True);p.add_argument('--node',required=True);p.add_argument('--js',required=True);p.add_argument('--kind',choices=['native'],required=True);a=p.parse_args()
source=Path(a.source).resolve();node=Path(a.node).resolve();sp=source.parent/'plan.json';np=node.parent/'plan.json'
assert json.loads(source.read_text())['status']=='SAFE_SOURCE_METADATA_PASS'
assert json.loads(node.read_text())['status']=='COMPLETE_ACTUAL_TS_METADATA_PASS'
s=json.loads(sp.read_text());assert B.task_runner.Inputs(files=s['files'],directories=map(Path,s['directories'])).expected==s['inputs']
buf=io.StringIO()
with contextlib.redirect_stdout(buf):S.prepare(s['approvedToolSnapshotPlan'])
pp=Path(buf.getvalue().splitlines()[0]);plan=json.loads(pp.read_text());out=pp.parent
files=set(map(Path,plan['files']));sources=set()
targets=[HERE/'consumer-io.bend'] if a.kind=='native' else [HERE/'controls'/n for n in ['positive.bend','cross-schema.bend','duplicate-plan.bend','escape-plan.bend']]
for target in targets:B.closure(target,sources)
files.update(sources|{Path(__file__).resolve(),HERE/'execution.py',HERE/'oracle.py',HERE/'oracle.json',source,sp,node,np})
for receipt in [source,node]:
 for name,digest in json.loads(receipt.read_text())['logs'].items():
  f=receipt.parent/name;assert B.sha(f)==digest;files.add(f)
index=Path(plan['sourceArchive']);records=json.loads(index.read_text());archive=index.parent/'frozen-source'
for f in sources|{Path(__file__).resolve(),HERE/'execution.py',HERE/'oracle.py',HERE/'oracle.json'}:
 digest=B.sha(f);obj=archive/digest;obj.write_bytes(f.read_bytes());records[str(f)]={'sha256':digest,'object':str(obj)}
index.write_text(json.dumps(records,indent=2)+'\n');plan['sourceArchiveSHA256']=B.sha(index)
prefix=['/usr/bin/taskset','-c','5'];bend='/home/node/.bend/bin/bend'
if a.kind=='native':
 nodebin=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node');files.add(nodebin);c=out/'metadata.c';binary=out/'metadata.native'
 commands=[{'label':'metadata-emit-c','argv':prefix+[bend,str(targets[0]),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'metadata-compile-native','argv':prefix+['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)},{'label':'metadata-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':'BendIOStringWithExactLF'}]

else:
 reasons={'positive':'exit0 safe source','cross-schema':'nominal resource schema mismatch','duplicate-plan':'opaque Definition owner consumed twice','escape-plan':'opaque Plan expected String'}
 commands=[{'label':t.stem,'argv':prefix+[bend,str(t),'--check-only'],'seconds':5,'intended':reasons[t.stem]} for t in targets]
plan.update(status='PREPARED_UNADMITTED_'+a.kind.upper(),commands=commands,files=sorted(map(str,files)),oracle=str(HERE/'oracle.json'),sourceJoin={'receipt':str(source),'sha256':B.sha(source),'planSHA256':B.sha(sp)},nodeJoin={'receipt':str(node),'sha256':B.sha(node),'planSHA256':B.sha(np)},scope='Development proposal only: full24 metadata plus all actualArray cells, opaquePlan threadback then closed diagnostic disposal. Trusted supplied requirements, no automatic declaration coupling/World callback/availability/law/proof/full54. Source negatives require exact raw diagnostic review. Final resolver qualification separate.')
js=Path(a.js).resolve();jp=js.parent/'plan.json';jr=json.loads(js.read_text());jplan=json.loads(jp.read_text());assert jr['status']=='COMPLETE_METADATA_JS_DEVELOPMENT_PASS';files.update([js,jp,Path(jplan['sourceArchive'])])
for name,digest in jr['logs'].items():
 f=js.parent/name;assert B.sha(f)==digest;files.add(f)
for file,digest in jr['generated'].items():assert B.sha(file)==digest;files.add(Path(file))
for original,record in json.loads(Path(jplan['sourceArchive']).read_text()).items():
 f=Path(record['object']);assert B.sha(f)==record['sha256'];files.add(f)
 if original.endswith(('/consumer.bend','/consumer-io.bend','/definition.bend','/oracle.json')):assert B.sha(original)==record['sha256']
plan['files']=sorted(map(str,files));plan['jsJoin']={'receipt':str(js),'sha256':B.sha(js),'planSHA256':B.sha(jp),'generated':jr['generated'],'sourceArchiveSHA256':B.sha(jplan['sourceArchive'])}
plan['status']='SOURCE_ONLY_NATIVE_PROPOSAL_PENDING_FRESH_RESOLVER_PREPARATION'
plan['scope']='Source-only Native full24 proposal, emit30/privateClang19 compile120/run5 CPU5 threads1 GPUoff. Exact alreadyqualifiedJS source/oracle/actualArray owner bytes. No fresh toolresolver probes/preparation or Native execution yet, no automatic declaration coupling/proof/full54. Fresh ordinary resolver preparation must be separately admitted before executable plan freeze.'
plan['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,plan['directories'])).expected
pp.write_text(json.dumps(plan,indent=2)+'\n');print(pp);print(B.sha(pp))
