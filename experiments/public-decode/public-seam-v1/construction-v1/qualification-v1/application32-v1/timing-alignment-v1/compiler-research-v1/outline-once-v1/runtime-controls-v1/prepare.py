"""Freeze one twelve-cohort semantic batch; no compiler/runtime children."""
from pathlib import Path
import hashlib,json,sys,types,shutil
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
AUTHOR=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-timing-alignment')/HERE.relative_to(Path('/workspace/formal-proofs/bendvy-worktrees/parity-54-layout-provenance')).parent
FIXTURES=['ctr_at_position','fork_leaf_result_loop','fork_held_family','fork_shared_flat','fn_capture_owns','wide_record']
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def load(name,path):
 m=types.ModuleType(name);m.__file__=str(path);exec(compile(Path(path).read_bytes(),str(path),'exec'),m.__dict__);return m

def prepare(root):
 root=Path(root).resolve();root.mkdir(exist_ok=False)
 assets=root/'compiler';shutil.copytree('/tmp/bendvy-layout-equality-v1-batch01/candidate',assets)
 candidate=AUTHOR/'comp.ts';assert sha(candidate)=='1f139139ca08add93354823bb8ddddd6663294939c6433652351ddc2e749e548';shutil.copyfile(candidate,assets/'comp.ts')
 asset_inventory={str(p.relative_to(assets)):sha(p)for p in assets.rglob('*')if p.is_file()}
 configpath=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py';config=load('configuration',configpath);runner=load('preparation_runner',ROOT/'scripts/task_runner.py')
 env=config.environment();resources=runner.Inputs(directories=config.RESOURCE_ROOTS).expected
 tools={'python':str(Path(sys.executable).resolve()),'node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
 common=[configpath,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',*map(Path,tools.values()),*assets.rglob('*'),*HERE.rglob('*'),AUTHOR/'COPY.json',AUTHOR/'candidate.patch',candidate]
 commonpins={str(p.resolve()):sha(p)for p in common if p.is_file()and '__pycache__'not in p.parts and p.name not in('INDEX.json',)}
 index=[]
 for fixture in FIXTURES:
  oldpath=Path('/tmp/bendvy-layout-equality-v1-batch01')/(fixture+'-baseline')/'plan.json';old=json.loads(oldpath.read_text());receiptpath=oldpath.with_name('receipt.json');receipt=json.loads(receiptpath.read_text());source=ROOT/'.references/bend2/tests/run'/(fixture+'.bend');stage=Path(old['stage']);staged=stage/old['entryRelative']
  assert staged.read_bytes()==source.read_bytes();assert receipt['status']=='COPIED_COMPILER_EMIT_COMPLETE' and len(receipt['commands'])==1
  command=receipt['commands'][0];assert command['exit']==0 and command['failure']is None
  baseline_c=Path(old['generated']);assert sha(baseline_c)==receipt['emitArtifactSHA256']
  oracle=HERE/'oracle-v1'/(fixture+'.stdout');want='\n'.join(line[2:]for line in source.read_text().splitlines()if line.startswith('#|'))+'\n';assert oracle.read_bytes()==want.encode()
  for mode in ('baseline','candidate'):
   out=root/(fixture+'-'+mode);out.mkdir();generated=baseline_c if mode=='baseline' else out/'scenario.c';native=out/'scenario.native'
   pins=dict(commonpins);extra=[oldpath,receiptpath,baseline_c,source,staged,oracle]
   extra.extend(Path(row['path'])for row in receipt['guards']);pins.update({str(p.resolve()):sha(p)for p in extra})
   commands=[]
   if mode=='candidate':commands.append({'label':'emit','argv':[tools['taskset'],'-c','5',tools['node'],str(HERE/'emit.mts'),str(staged),str(generated)],'capSeconds':30})
   commands.extend([{'label':'build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':[tools['taskset'],'-c','5',str(native),'--threads','1','--gpu','off'],'capSeconds':5}])
   plan={'scope':'Unchanged '+fixture+' outlined-fusion '+mode+' semantic runtime control; no purewide/Typecapture/performance/adoption claim','fixture':fixture,'mode':mode,'tools':tools,'pins':pins,'resourceRoots':resources,'compilerAssets':str(assets),'compilerInventory':asset_inventory,'stage':str(stage),'sourceInventory':old['sourceInventory'],'entryRelative':old['entryRelative'],'importClosure':old['importClosure'],'environment':env,'cwd':str(HERE),'generated':str(generated),'native':str(native),'commands':commands,'oracle':str(oracle),'oracleSHA256':sha(oracle),'oracleBytes':oracle.stat().st_size,'baselineEvidence':{'plan':str(oldpath),'planSHA256':sha(oldpath),'receipt':str(receiptpath),'receiptSHA256':sha(receiptpath),'cSHA256':sha(baseline_c)},'suppressedOnceReach':'not instrumented; no perfixture reached-callsite claim'}
   path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');index.append({'fixture':fixture,'mode':mode,'plan':str(path),'sha256':sha(path),'launchArgv':[tools['python'],str(HERE/'development.py'),str(path),sha(path)]})
 (HERE/'INDEX.json').write_text(json.dumps({'status':'UNADMITTED_UNEXECUTED','root':str(root),'plans':index,'commands':sum(2 if x['mode']=='baseline'else 3 for x in index)},indent=2)+'\n')
 print('Prepared',len(index),'plans/30commands; no child')
if __name__=='__main__':prepare(sys.argv[1])
