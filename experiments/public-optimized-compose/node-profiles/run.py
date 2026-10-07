"""Profile frozen generated JS; preserve every complete application output."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command


parser = argparse.ArgumentParser()
parser.add_argument('--generated', type=Path, required=True)
parser.add_argument('--expected', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--iterations', type=int, default=20)
parser.add_argument('--cpu', type=int, default=0)
args = parser.parse_args()
assert args.iterations > 0
source = args.generated.resolve()
expected_path = args.expected.resolve()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=False)
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
expected_text = gzip.open(expected_path, 'rt').read() if expected_path.suffix == '.gz' else expected_path.read_text()
expected = [json.loads(line) for line in expected_text.splitlines() if line.strip()]
assert expected
receipt = {'status': 'INCOMPLETE', 'generatedSHA256': sha(source),
           'expectedSHA256': sha(expected_path), 'runnerSHA256': sha(Path(__file__)),
           'iterations': args.iterations, 'cpu': args.cpu, 'runs': {},
           'scope': 'Diagnostic CPU samples and sampled allocation stacks, including collected objects; fresh generated-program scope per iteration. Not physical allocation totals or performance acceptance.'}
header = """const inspector=require('node:inspector');
const {PerformanceObserver}=require('node:perf_hooks');
const session=new inspector.Session();session.connect();
const gc=[];const observer=new PerformanceObserver(list=>{for(const e of list.getEntries())gc.push({duration:e.duration,kind:e.detail.kind});});observer.observe({entryTypes:['gc']});
const post=(method,params={})=>new Promise((resolve,reject)=>session.post(method,params,(error,result)=>error?reject(error):resolve(result)));
let zeroExits=0,completed=0;const times=[];const originalExit=process.exit;
process.exit=code=>{if(code!==0)throw Error('Nonzero generated exit: '+code);zeroExits++;};
function freshProgram(){
"""
try:
    receipt['nodeVersion'] = _run_command(['node', '--version'], capture_output=True, text=True, check=True, timeout=5).stdout.strip()
    for mode in ['cpu', 'heap']:
        start = "await post('Profiler.enable');await post('Profiler.setSamplingInterval',{interval:100});await post('Profiler.start');" if mode == 'cpu' else "await post('HeapProfiler.enable');await post('HeapProfiler.startSampling',{samplingInterval:16384,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});"
        stop = "const result=await post('Profiler.stop');" if mode == 'cpu' else "const result=await post('HeapProfiler.stopSampling');"
        profile = out / (mode + ('.cpuprofile' if mode == 'cpu' else '.heapprofile'))
        tail = '\n}\n(async()=>{\n' + start + '\n' + f"for(let i=0;i<{args.iterations};i++){{const t=performance.now();freshProgram();times.push(performance.now()-t);completed++;}}\n" + "await new Promise(resolve=>setTimeout(resolve,20));\n" + stop + '\n' + "require('node:fs').writeFileSync(" + json.dumps(str(profile)) + ",JSON.stringify(result.profile));observer.disconnect();session.disconnect();process.exit=originalExit;process.stderr.write(JSON.stringify({completed,zeroExits,times,gc})+'\\n');})().catch(error=>{process.stderr.write(String(error));originalExit(1);});\n"
        wrapper = out / (mode + '.js')
        wrapper.write_text(header + source.read_text() + tail)
        command = ['taskset', '-c', str(args.cpu), 'node', str(wrapper)]
        result = _run_command(command, capture_output=True, text=True, timeout=5)
        (out / (mode + '.stderr')).write_text(result.stderr)
        with gzip.open(out / (mode + '.stdout.gz'), 'wt') as f:
            f.write(result.stdout)
        assert result.returncode == 0, result.stderr
        actual = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
        assert len(actual) == len(expected) * args.iterations
        assert all(row == expected[i % len(expected)] for i, row in enumerate(actual))
        audit = json.loads(result.stderr)
        assert audit['completed'] == args.iterations and audit['zeroExits'] == args.iterations
        data = json.loads(profile.read_text())
        assert data.get('nodes') if mode == 'cpu' else data.get('head') and data.get('samples')
        receipt['runs'][mode] = {'command': command, 'limitSeconds': 5,
                                'validatedApplications': len(actual), 'audit': audit,
                                'wrapperSHA256': sha(wrapper), 'profileSHA256': sha(profile)}
    assert sha(source) == receipt['generatedSHA256']
    assert sha(expected_path) == receipt['expectedSHA256']
    receipt['status'] = 'PASS'
finally:
    (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({'status': receipt['status'], 'output': str(out)}))
