"""Prepare one complete metadata consumer without probes; execute only admitted plan."""
from pathlib import Path
import argparse,hashlib,json,sys,time,types
HERE=Path(__file__).resolve().parent
PROMOTION=HERE.parent
ROOT=PROMOTION.parents[2]
sys.dont_write_bytecode=True
B=types.ModuleType('inspect54_metadata_source');B.__file__=str(PROMOTION/'control-development.py')
exec((PROMOTION/'control-development.py').read_text().split('p=argparse.ArgumentParser();')[0],B.__dict__)
def prepare(native):
 native=Path(native).resolve();n=json.loads(native.read_text());out=ROOT/'.artifacts'/('inspect54-metadata-source-'+str(time.time_ns()));out.mkdir()
 join=HERE/'core-adoption-proposal-v1/QUERY-CHECK-STAGE-INVENTORY.json';jd=json.loads(join.read_text());rootfiles=set()
 for key,record in jd['files'].items():
  actual=Path(record['source']);copied=HERE/'core-adoption-proposal-v1/query-check-stage-v1'/key;assert B.sha(actual)==record['sourceSHA256'];assert B.sha(copied)==record['stageSHA256']
  if str(actual).startswith('/workspace/formal-proofs/bendvy/src/'):assert B.sha(actual)==B.sha(copied);rootfiles.add(actual)
 files={join,*rootfiles,HERE/'core-adoption-proposal-v1/STAGE-INVENTORY.json',HERE/'core-adoption-proposal-v1/SOURCE-MAP.json',HERE/'core-adoption-proposal-v1/IMPORT-ONLY-CORE.patch',Path(__file__).resolve(),HERE/'CONTRACT.json',HERE/'core-adoption-proposal-v1/PROPOSAL.json',HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT-TS-JOIN.json',PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',native}
 sources=set()
 for target in ['cardinality-main.bend','check-main.bend']:B.closure(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/PROMOTION.relative_to(ROOT)/target,sources)
 files.update(sources)
 for path,digest in n['tools']['pins'].items():assert B.sha(path)==digest;files.add(Path(path))
 private=out/'private-environment.json';original=Path(n['privateEnvironment']);assert B.sha(original)==n['environmentSHA256'];private.write_bytes(original.read_bytes());private.chmod(0o600);files.add(private)
 archive=out/'frozen-source';archive.mkdir();records={}
 for path in sorted(sources|{join,*rootfiles,HERE/'core-adoption-proposal-v1/STAGE-INVENTORY.json',HERE/'core-adoption-proposal-v1/SOURCE-MAP.json',HERE/'core-adoption-proposal-v1/IMPORT-ONLY-CORE.patch',Path(__file__).resolve(),HERE/'CONTRACT.json',HERE/'core-adoption-proposal-v1/PROPOSAL.json',HERE/'BINDING-ALLFIELD-ORACLE.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json',HERE/'CONTRACT-TS-JOIN.json',PROMOTION/'control-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}):
  digest=B.sha(path);obj=archive/digest
  if not obj.exists():obj.write_bytes(path.read_bytes())
  records[str(path)]={'sha256':digest,'object':str(obj)}
 index=out/'source-archive.json';index.write_text(json.dumps(records,indent=2)+'\n');files.add(index)
 directories=[archive,Path('/home/node/.bend/bend2')];inputs=B.task_runner.Inputs(files=files,directories=directories);roots=sorted({*[file.parent for file in rootfiles],*[parent for file in rootfiles for parent in file.parents],ROOT,PROMOTION,HERE,out,Path('/home/node/.bend'),Path('/home/node/.bend/bend2'),*[source.parent for source in sources],*[parent for source in sources for parent in source.parents]})
 p={'status':'PREPARED_UNADMITTED_SOURCE_ONLY','kind':'metadata','commands':[{'label':'adoption-'+name.removesuffix('.bend')+'-source','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(HERE/'core-adoption-proposal-v1/query-check-stage-v1'/PROMOTION.relative_to(ROOT)/name),'--check-only'],'seconds':5} for name in ['cardinality-main.bend','check-main.bend']],'files':sorted(map(str,files)),'directories':list(map(str,directories)),'inputs':inputs.expected,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationRoots':list(map(str,roots)),'configurationStates':B.configurations(roots),'sourceArchive':str(index),'sourceArchiveSHA256':B.sha(index),'approvedToolSnapshotPlan':str(native),'approvedToolSnapshotPlanSHA256':B.sha(native),'scope':'Two current-root copied-core cardinality/query and real registered Check/System/Schedule pure drivers source checks only, two nominal schemas; all original operations and diagnostics unchanged, promoted generic import identities; no runtime/oracle/proof credit. Full74/84 independent original oracles will govern fresh actualCLI after sourcePASS.'}
 plan=out/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(plan);print(B.sha(plan))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native)
else:B.run(a.run)
