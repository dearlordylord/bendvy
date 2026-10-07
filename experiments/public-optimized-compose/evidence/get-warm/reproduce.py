import pathlib,json,subprocess,hashlib,gzip

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

root=pathlib.Path.cwd();out=root/'.artifacts/storage30-get-warm-timeline';out.mkdir(exist_ok=False)
stage=root/'.artifacts/frontier-get-fusion-prepared-regression'
old=(root/'.artifacts/storage30-warm-timeline/candidate.js').read_text();header=old.split('function freshProgram(){')[0]+'function freshProgram(){\n';tail=old[old.rfind('\n}\nfor(let iteration='):]
receipt={'scope':'Exploratory 20 complete ten-application iterations; not performance acceptance','roles':{},'sourceHashes':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (root/'src/ecs').glob('*.bend')}}
for role in ['baseline','candidate']:
 source=stage/role/'workshop.js';wrapper=out/(role+'.js');wrapper.write_text(header+source.read_text()+tail)
 command=['taskset','-c','0','node','--cpu-prof','--cpu-prof-interval=100','--cpu-prof-dir='+str(out),'--cpu-prof-name='+role+'.cpuprofile',str(wrapper)]
 r=_run_command(command,capture_output=True,text=True,timeout=5);assert r.returncode==0,r.stderr
 actual=[json.loads(x) for x in r.stdout.splitlines()]; expected=[json.loads(x) for x in gzip.open(stage/('warmup-0-'+role+'-JS.stdout.gz'),'rt').read().splitlines()];assert len(expected)==10 and len(actual)==200
 assert all(actual[i]==expected[i%10] for i in range(200))
 audit=json.loads(r.stderr);assert audit['completed']==20 and audit['zeroExits']==20
 gzip.open(out/(role+'.stdout.gz'),'wt').write(r.stdout)
 receipt['roles'][role]={'command':command,'limit':5,'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'wrapperSHA256':hashlib.sha256(wrapper.read_bytes()).hexdigest(),'profileSHA256':hashlib.sha256((out/(role+'.cpuprofile')).read_bytes()).hexdigest(),'validatedApplications':200,'audit':audit}
(out/'receipt.json').write_text(json.dumps(receipt,indent=2));print('PASS')
