#!/usr/bin/env python3
"""Current joined-source full diagnostic parity; no unequal-work timing ratios."""
import hashlib, importlib.util, json, os, pathlib, re, shutil, sys, tempfile
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE.parent/'t05'))
from run import command, execute
spec = importlib.util.spec_from_file_location('oracle', HERE/'measurement-failure-oracle.py')
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
files = {}
def closure(p):
    if p in files: return
    files[p] = p.read_bytes()
    for ref in re.findall(r'^import (\./\S+\.bend)', files[p].decode(), re.M): closure((p.parent/ref).resolve())
closure(HERE/'measurement-failure-driver.bend')
os.sched_setaffinity(0, {2})
report = {'scope': 'current joined runtime, full diagnostic FailedTxn workload; timing and RSS unavailable for equivalent quiet work', 'sourceCommit': command(['git','rev-parse','HEAD']).strip(), 'cpu': 2, 'limits': {'checker':5,'runtime':5,'reference':5,'codegen':30,'clang':120}, 'sources': {str(p.relative_to(ROOT)):hashlib.sha256(v).hexdigest() for p,v in files.items()}, 'runnerSha256': sha(pathlib.Path(__file__)), 'oracleSha256': sha(HERE/'measurement-failure-oracle.py'), 'referenceSha256':sha(HERE/'measurement-reference.mjs'), 'compiler':command(['bend','version']).strip(), 'compilerSha256':sha(pathlib.Path(shutil.which('bend')).resolve()), 'baseSha256':sha(pathlib.Path.home()/'.bend/bend2/base.bend'), 'node':command(['node','--version']).strip(), 'clang':command(['clang','--version']).splitlines()[0], 'cases': []}
def save(): (HERE/'measurement-failure-source-current-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
save()
with tempfile.TemporaryDirectory(prefix='failure-current-') as temporary:
    folder = pathlib.Path(temporary)
    for p,v in files.items():
        q=folder/p.relative_to(ROOT);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(v)
    entry=folder/'experiments/s-integrate/measurement-failure-driver.bend'
    try:
        assert 'ALL PROOFS CHECK' in command([HERE.parent/'t01'/'bend-check',entry,'--check-only'])
        command(['bend',entry,'-o',folder/'driver.c'],timeout=30)
        command(['bend',entry,'-o',folder/'driver.js'],timeout=30)
        command(['clang','-std=c11','-O3',folder/'driver.c','-lpthread','-lm','-o',folder/'driver-native'],timeout=120)
        report['build']={'status':'PASS','optimization':'O3','artifacts':{p.name:sha(p) for p in [folder/'driver.c',folder/'driver.js',folder/'driver-native']}};save()
    except (RuntimeError,AssertionError) as error:
        report['build']={'status':'FAILED','error':str(error)};report['status']='BUILD_BLOCKED';save();raise SystemExit(1)
    for idx,schema in enumerate(['Motion','Health']):
        for count in [64,256,1024]:
            case={'schema':schema,'count':count,'iterations':64,'backends':{}};report['cases'].append(case)
            try:
                reference=json.loads(command(['node',HERE/'measurement-reference.mjs',schema,'failed-transaction',str(count)]))
                case['reference']={'status':'PASS','resultSha256':hashlib.sha256(json.dumps(reference,sort_keys=True).encode()).hexdigest()}
            except (RuntimeError,json.JSONDecodeError) as error:
                case['reference']={'status':'FAILED','error':str(error)};case['status']='REFERENCE_FAILED';save();continue
            outputs={}
            for backend,path in [('NativeO3',folder/'driver-native'),('JS',folder/'driver.js')]:
                try:
                    text=execute(path,[str(idx),str(count),'64']);validation=O.validate(text,reference)
                    case['backends'][backend]={'status':'FULL_VALUES_EQUAL','outputSha256':hashlib.sha256(text.encode()).hexdigest(),'validation':validation};outputs[backend]=text
                except (RuntimeError,AssertionError,json.JSONDecodeError) as error:case['backends'][backend]={'status':'FAILED','error':str(error)}
                save()
            if len(outputs)==2: assert outputs['NativeO3']==outputs['JS'], 'full backend trace mismatch'
            case['status']='PASS' if len(outputs)==2 else 'PARTIAL';save();print(schema,count,{b:v['status'] for b,v in case['backends'].items()},flush=True)
report['status']='PASS' if all(c['status']=='PASS' for c in report['cases']) else 'PARTIAL'
assert report['sources']=={str(p.relative_to(ROOT)):sha(p) for p in files}
save()
raise SystemExit(0 if report['status']=='PASS' else 1)
