"""Source-only concrete backend plan freezer; no probes or backend launch."""
from pathlib import Path
import argparse,contextlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('static_cli');S.__file__=str(HERE/'core-adoption-query-check-cli.py')
exec((HERE/'core-adoption-query-check-cli.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
p=argparse.ArgumentParser();p.add_argument('--backend',choices=['js','native'],required=True);p.add_argument('--native',required=True);a=p.parse_args()
cli=B.ROOT/'.artifacts/inspect54-metadata-source-1791429196958512599/receipt.json';cp=cli.parent/'plan.json';cr=json.loads(cli.read_text());prior=json.loads(cp.read_text());assert cr['planSHA256']==B.sha(cp) and cr['status']=='FULL74_84_CURRENT_ROOT_CLI_IO_PASS';assert len(cr['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in cr['commands'])
for name,digest in cr['logs'].items():assert B.sha(cli.parent/name)==digest
ci=Path(prior['sourceArchive']);assert B.sha(ci)==prior['sourceArchiveSHA256'];records=json.loads(ci.read_text());closure=set()
for name in ['cardinality-io-main.bend','check-io-main.bend']:B.closure(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/HERE.parent.relative_to(B.ROOT)/name,closure)
for f in closure:assert B.sha(f)==records[str(f)]['sha256'];assert B.sha(records[str(f)]['object'])==records[str(f)]['sha256']
buf=io.StringIO()
with contextlib.redirect_stdout(buf):S.prepare(a.native)
path=Path(buf.getvalue().splitlines()[0]);plan=json.loads(path.read_text());out=path.parent;files=set(map(Path,plan['files']));files.update([cli,cp,ci,*[cli.parent/name for name in cr['logs']],*[Path(records[str(f)]['object']) for f in closure],Path(__file__).resolve(),HERE/'core-adoption-query-check-fresh-backend.py'])
prefix=['/usr/bin/taskset','-c','5'];bend='/home/node/.bend/bin/bend';commands=[]
for name in ['cardinality','check']:
 entry=str(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/HERE.parent.relative_to(B.ROOT)/(name+'-io-main.bend'));output=out/(name+'.js' if a.backend=='js' else name+'.c')
 commands.append({'label':name+'-emit-'+a.backend,'argv':prefix+[bend,entry,'-o',str(output)],'seconds':30,'generated':str(output)})
 if a.backend=='js':
  node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node');files.add(node);commands.append({'label':name+'-run-js','argv':prefix+[str(node),str(output)],'seconds':5,'oracle':name})
 else:
  clang=Path('/tmp/bendvy-clang19-diagnostic/clang19');files.add(clang);binary=out/(name+'.native');commands.append({'label':name+'-compile-native','argv':prefix+[str(clang),'-O3',str(output),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)});commands.append({'label':name+'-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':name})
archive=Path(plan['sourceArchive']);ar=json.loads(archive.read_text())
for f in [Path(__file__).resolve(),HERE/'core-adoption-query-check-fresh-backend.py']:
 digest=B.sha(f);obj=out/'frozen-source'/digest;obj.write_bytes(f.read_bytes());ar[str(f)]={'sha256':digest,'object':str(obj)}
archive.write_text(json.dumps(ar,indent=2)+'\n');plan.update(backend=a.backend,status='SOURCE_ONLY_BACKEND_PROPOSAL_NEEDS_RESOLVER_REVIEW',commands=commands,sourceArchiveSHA256=B.sha(archive),cliJoin={'receipt':str(cli),'receiptSHA256':B.sha(cli),'planSHA256':B.sha(cp),'sourceArchiveSHA256':B.sha(ci)},scope='Complete74/84 current-root proposed generic core cardinality and genuine registered Check/Sys/Schedule operations, complete actual callback projections/readonly World comparisons and Array/owner/resource observations; trusted canonical setup not universal truth. Baseline only, no mutant/proof/full54. Ordinary existing pins reused; fresh resolver admission required before execution.')
plan['files']=sorted(map(str,files));plan['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,plan['directories'])).expected;path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(B.sha(path))
