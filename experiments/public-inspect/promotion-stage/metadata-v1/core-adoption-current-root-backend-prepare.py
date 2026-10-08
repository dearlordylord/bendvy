"""Source-only concrete backend plan freezer; no probes or backend launch."""
from pathlib import Path
import argparse,contextlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('static_cli');S.__file__=str(HERE/'core-adoption-current-root-cli.py')
exec((HERE/'core-adoption-current-root-cli.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
p=argparse.ArgumentParser();p.add_argument('--backend',choices=['js','native'],required=True);p.add_argument('--native',required=True);a=p.parse_args()
cli=B.ROOT/'.artifacts/inspect54-metadata-source-1791427564887666065/receipt.json';cp=cli.parent/'plan.json';cr=json.loads(cli.read_text());prior=json.loads(cp.read_text());assert cr['planSHA256']==B.sha(cp) and cr['status']=='FULL8_CURRENT_ROOT_CORE_CLI_IO_PASS';assert cr['commands'][0]['exit']==0 and cr['commands'][0]['failure'] is None
for name,digest in cr['logs'].items():assert B.sha(cli.parent/name)==digest
ci=Path(prior['sourceArchive']);assert B.sha(ci)==prior['sourceArchiveSHA256'];records=json.loads(ci.read_text());closure=set();B.closure(HERE/'core-adoption-proposal-v1/current-root-stage-v2'/HERE.relative_to(B.ROOT)/'adoption-driver-io.bend',closure)
for f in closure:assert B.sha(f)==records[str(f)]['sha256'];assert B.sha(records[str(f)]['object'])==records[str(f)]['sha256']
buf=io.StringIO()
with contextlib.redirect_stdout(buf):S.prepare(a.native)
path=Path(buf.getvalue().splitlines()[0]);plan=json.loads(path.read_text());out=path.parent;files=set(map(Path,plan['files']));files.update([cli,cp,ci,*[cli.parent/name for name in cr['logs']],*[Path(records[str(f)]['object']) for f in closure],Path(__file__).resolve(),HERE/'core-adoption-current-root-fresh-backend.py'])
prefix=['/usr/bin/taskset','-c','5'];entry=str(HERE/'core-adoption-proposal-v1/current-root-stage-v2'/HERE.relative_to(B.ROOT)/'adoption-driver-io.bend');bend='/home/node/.bend/bin/bend'
if a.backend=='js':
 node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node');files.add(node);output=out/'binding-static.js';commands=[{'label':'emit-js','argv':prefix+[bend,entry,'-o',str(output)],'seconds':30,'generated':str(output)},{'label':'run-js','argv':prefix+[str(node),str(output)],'seconds':5,'oracle':'IOString'}]
else:
 clang=Path('/tmp/bendvy-clang19-diagnostic/clang19');files.add(clang);c=out/'binding-static.c';binary=out/'binding-static.native';commands=[{'label':'emit-c','argv':prefix+[bend,entry,'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'compile-native','argv':prefix+[str(clang),'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)},{'label':'run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':'IOString'}]
archive=Path(plan['sourceArchive']);ar=json.loads(archive.read_text())
for f in [Path(__file__).resolve(),HERE/'core-adoption-current-root-fresh-backend.py']:
 digest=B.sha(f);obj=out/'frozen-source'/digest;obj.write_bytes(f.read_bytes());ar[str(f)]={'sha256':digest,'object':str(obj)}
archive.write_text(json.dumps(ar,indent=2)+'\n');plan.update(backend=a.backend,status='SOURCE_ONLY_BACKEND_PROPOSAL_NEEDS_RESOLVER_REVIEW',commands=commands,sourceArchiveSHA256=B.sha(archive),cliJoin={'receipt':str(cli),'receiptSHA256':B.sha(cli),'planSHA256':B.sha(cp),'sourceArchiveSHA256':B.sha(ci)},scope='Complete8 current-root proposed generic core declaration metadata and genuine grants, actual runtime Array/Extra/World/Instance observations; trusted canonical setup not universal truth. Baseline only, no mutant/proof/full54. Ordinary existing pins reused; fresh resolver admission required before execution.')
plan['files']=sorted(map(str,files));plan['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,plan['directories'])).expected;path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(B.sha(path))
