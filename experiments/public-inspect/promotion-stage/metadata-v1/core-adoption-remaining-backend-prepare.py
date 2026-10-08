"""Source-only concrete backend plan freezer; no probes or backend launch."""
from pathlib import Path
import argparse,contextlib,io,json,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('static_cli');S.__file__=str(HERE/'core-adoption-remaining-cli.py')
exec((HERE/'core-adoption-remaining-cli.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
p=argparse.ArgumentParser();p.add_argument('--backend',choices=['js','native'],required=True);p.add_argument('--native',required=True);p.add_argument('--subject',choices=['reader','lens-routing','metadata-order','retainer'],required=True);a=p.parse_args()
stamps={'reader':'1791431327981771305','lens-routing':'1791431338936435872','metadata-order':'1791431349581375867','retainer':'1791431356069652545'}
cli=B.ROOT/'.artifacts'/('inspect54-metadata-source-'+stamps[a.subject])/'receipt.json';cp=cli.parent/'plan.json';cr=json.loads(cli.read_text());prior=json.loads(cp.read_text());assert cr['planSHA256']==B.sha(cp) and cr['status']=='FULL_CURRENT_ROOT_CONTROL_CLI_IO_PASS';assert len(cr['commands'])==1 and cr['commands'][0]['exit']==0 and cr['commands'][0]['failure'] is None
for name,digest in cr['logs'].items():assert B.sha(cli.parent/name)==digest
ci=Path(prior['sourceArchive']);assert B.sha(ci)==prior['sourceArchiveSHA256'];records=json.loads(ci.read_text());closure=set()
B.closure(Path(prior['commands'][0]['argv'][4]),closure)
for f in closure:assert B.sha(f)==records[str(f)]['sha256'];assert B.sha(records[str(f)]['object'])==records[str(f)]['sha256']
buf=io.StringIO()
with contextlib.redirect_stdout(buf):S.prepare(a.native,a.subject)
path=Path(buf.getvalue().splitlines()[0]);plan=json.loads(path.read_text());out=path.parent;files=set(map(Path,plan['files']));files.update([cli,cp,ci,*[cli.parent/name for name in cr['logs']],*[Path(records[str(f)]['object']) for f in closure],Path(__file__).resolve(),HERE/'core-adoption-remaining-fresh-backend.py'])
prefix=['/usr/bin/taskset','-c','5'];bend='/home/node/.bend/bin/bend';commands=[]
name=a.subject;entry=prior['commands'][0]['argv'][4];output=out/(name+'.js' if a.backend=='js' else name+'.c')
commands.append({'label':name+'-emit-'+a.backend,'argv':prefix+[bend,entry,'-o',str(output)],'seconds':30,'generated':str(output)})
if a.backend=='js':
 node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node');files.add(node);commands.append({'label':name+'-run-js','argv':prefix+[str(node),str(output)],'seconds':5,'oracle':name})
else:
 clang=Path('/tmp/bendvy-clang19-diagnostic/clang19');files.add(clang);binary=out/(name+'.native');commands.append({'label':name+'-compile-native','argv':prefix+[str(clang),'-O3',str(output),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)});commands.append({'label':name+'-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':name})
archive=Path(plan['sourceArchive']);ar=json.loads(archive.read_text())
for f in [Path(__file__).resolve(),HERE/'core-adoption-remaining-fresh-backend.py']:
 digest=B.sha(f);obj=out/'frozen-source'/digest;obj.write_bytes(f.read_bytes());ar[str(f)]={'sha256':digest,'object':str(obj)}
archive.write_text(json.dumps(ar,indent=2)+'\n');plan.update(subject=a.subject,backend=a.backend,status='SOURCE_ONLY_BACKEND_PROPOSAL_NEEDS_RESOLVER_REVIEW',commands=commands,sourceArchiveSHA256=B.sha(archive),cliJoin={'receipt':str(cli),'receiptSHA256':B.sha(cli),'planSHA256':B.sha(cp),'sourceArchiveSHA256':B.sha(ci)},scope='Current-root '+a.subject+' complete independent control oracle and precise semantic rows/genuine retainer System/Schedule operations, actual owners preserved; trusted canonical setup not universal truth. Preparation proposal only; no reached emittedcontrol/proof/full54 credit. Ordinary existing pins reused; fresh resolver admission required before execution.')
plan['files']=sorted(map(str,files));plan['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,plan['directories'])).expected;path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(B.sha(path))
