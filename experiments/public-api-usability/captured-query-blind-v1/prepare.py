"""Prepare the focused blind consumer for the unchanged reviewed runner."""
import importlib.util,json,hashlib,re,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
REF=Path('/workspace/formal-proofs/bendvy')
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
runner_path=REF/'experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/development-v2.py'
runner=load('reviewed',runner_path)
config_path=REF/'experiments/public-simulation/delivery-v1/installed-config.py'
config=load('config',config_path)
helper=load('helper',ROOT/'scripts/task_runner.py')
entry=HERE/'main.bend'
inventory={}
def visit(path):
    path=path.resolve()
    if str(path) in inventory:return
    inventory[str(path)]=sha(path)
    for target in re.findall(r'^import\s+(\S+)',path.read_text(),re.M):
        if target!='Base':visit(path.parent/target)
visit(entry)
resources=helper.Inputs(directories=config.RESOURCE_ROOTS).expected
for role,cpu in [('js','9'),('native','11')]:
    out=HERE/f'{role}-attempt02';out.mkdir()
    generated=out/('scenario.js' if role=='js' else 'scenario.c');native=out/'scenario.native'
    tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
    extra=[REF/'scripts/task_runner.py',REF/'scripts/evidence_boundary.py',runner_path,config_path,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',HERE/'expected.py',HERE/'expected.stdout',HERE/'expected.stdout.gz',Path(__file__),*map(Path,tools.values())]
    pins={**inventory,**{str(p.resolve()):sha(p.resolve()) for p in extra}}
    commands=[{'label':'emit','argv':[tools['taskset'],'-c',cpu,tools['bend'],str(entry),'-o',str(generated)],'capSeconds':60}]
    if role=='native':commands.append({'label':'build','argv':[tools['taskset'],'-c',cpu,tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120})
    commands.append({'label':'consumer','argv':[tools['taskset'],'-c',cpu,*([tools['node'],str(generated)] if role=='js' else [str(native),'--threads','1','--gpu','off'])],'capSeconds':180})
    plan={'scope':'Blind #73 greenhouse public ordinary component plus affine captured Changed query; complete independent oracle; no performance claim','subject':'normal','role':role,'entrypoint':str(entry),'stage':str(HERE),'sourceEntries':[str(entry)],'sourceInventory':inventory,'importClosure':sorted(inventory),'pins':pins,'resourceRoots':resources,'environment':config.environment(),'cwd':str(HERE),'oracle':str(HERE/'expected.stdout.gz'),'oracleSHA256':sha(HERE/'expected.stdout'),'oracleBytes':(HERE/'expected.stdout').stat().st_size,'generated':str(generated),'native':str(native),'tools':tools,'commands':commands}
    target=out/'plan.json';target.write_text(json.dumps(plan,indent=2)+'\n');print(target,sha(target))
