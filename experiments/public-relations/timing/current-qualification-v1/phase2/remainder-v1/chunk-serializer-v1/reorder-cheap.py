"""Four source-only matched reorder controls; no backend or library discovery."""
import argparse, hashlib, importlib.util, json, os, re, shutil, sys, time, tarfile
from pathlib import Path
H = Path(__file__).resolve().parent
R = H.parents[6]
sys.dont_write_bytecode = True
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
T = load(R/'scripts/task_runner.py', 'task_runner')
L = load(R/'scripts/receipt-logs.py', 'receipt_logs')
def closure(path, files):
    path = path.resolve()
    if path in files:
        return
    files.add(path)
    for entry in re.findall(r'^\s*import\s+(\S+)', path.read_text(), re.M):
        if entry != 'Base' and not entry.startswith('"'):
            closure(path.parent/entry, files)
def configs(out, stage):
    paths = set()
    for root in {R, out, stage, *[p.parent for p in stage.rglob('*.bend')], Path('/home/node/.bend'), Path('/home/node/.bend/bend2')}:
        for parent in [root, *root.parents]:
            for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:
                paths.add(parent/name)
    return {str(p):sha(p) if p.is_file() else None for p in paths}
def inventory(stage):
    return {str(p.relative_to(stage)):sha(p) for p in stage.rglob('*') if p.is_file()}
def prepare():
    out = R/'.artifacts'/('relations-current-reorder-cheap-'+str(time.time_ns()))
    out.mkdir()
    stage = out/'stage'
    entries = ['reorder-owned','negative-reorder-ordinary','negative-reorder-cross-schema','negative-reorder-write-through-read']
    files = set()
    base = R/'experiments/public-relations/promotion-stage'
    for name in entries:
        closure(base/(name+'.bend'), files)
    for source in sorted(files):
        target = stage/source.relative_to(R)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(source.read_bytes())
    extra = [Path(__file__).resolve(), R/'scripts/task_runner.py', R/'scripts/receipt-logs.py', H/'adoption-negative-source-joins.json', H/'ADOPTION-JOIN-PLAN.md', Path('/home/node/.bend/bend2/base.bend')]
    tools = {name:shutil.which(name) for name in ['bend','taskset','python3']}
    assert all(tools.values())
    private = out/'private-environment.json'
    private.write_text(json.dumps(dict(os.environ),sort_keys=True)+'\n')
    private.chmod(0o600)
    rows = json.loads((H/'adoption-negative-source-joins.json').read_text())['cohorts'][-1]['negatives']
    archive_path = R/'experiments/public-relations/evidence/reorder-1791361321007561029.tar.gz'
    expected = out/'historical-diagnostics'
    expected.mkdir()
    with tarfile.open(archive_path) as archive:
        for index, label in enumerate(entries):
            number = 17 if index == 0 else 13+index
            data = archive.extractfile('reorder-1791361321007561029/command-'+str(number)+'.txt').read()
            (expected/(label+'.stdout')).write_bytes(data)
    extra.extend([archive_path, *expected.iterdir(), H/'pinned-notice.stderr'])
    prior = R/'.artifacts/relations-current-reorder-cheap-1791426163063273743'
    previous = json.loads((prior/'plan.json').read_text())
    retained = json.loads((prior/'receipt.json').read_text())
    assert retained['status']=='INCOMPLETE' and retained['planSHA256']==sha(prior/'plan.json')
    assert sha(prior/'failed-wrapper.py') == previous['pins'][str(Path(__file__).resolve())]
    assert inventory(prior/'stage') == previous['inventory']
    for name,digest in previous['pins'].items():
        if name != str(Path(__file__).resolve()):
            assert sha(name)==digest
            extra.append(Path(name))
    for name,digest in retained['logs'].items():
        assert sha(prior/name)==digest
        extra.append(prior/name)
    notice = (H/'pinned-notice.stderr').read_bytes()
    assert notice == b'bend 2.0.36 is available: run bend update\n'
    assert (prior/'reorder-owned.stdout').read_bytes() == (expected/'reorder-owned.stdout').read_bytes()+notice
    assert (prior/'reorder-owned.stderr').read_bytes()==b''
    extra.extend([prior/'plan.json',prior/'receipt.json',prior/'failed-wrapper.py'])
    commands = []
    for i,name in enumerate(entries):
        if i == 0:
            continue
        source = stage/'experiments/public-relations/promotion-stage'/(name+'.bend')
        command = {'label':name,'argv':[tools['taskset'],'-c','5',tools['bend'],str(source),'--check-only'],'seconds':5,'expectedExit':0 if i==0 else 1,'expectedMerged':str(expected/(name+'.stdout')),'expectedMergedSHA256':sha(expected/(name+'.stdout')),'diagnosticNormalization':'Only exactwhole historical bytes OR exactwholebytes followed by exact pinned39B notice; no other normalization'}
        if i:
            row = next(x for x in rows if x['case']==name)
            command['diagnostic'] = row['intendedDiagnostic']
            command['sourceSpan'] = row['intendedSourceSpan']
        commands.append(command)
    plan = {'pins':{str(p):sha(p) for p in sorted(files|set(extra)|{Path(x) for x in tools.values()}|{private})},'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'privateEnvironment':str(private),'environmentSHA256':sha(private),'commands':commands,'scope':'Remaining three current reorder authority negatives source-only; prior positive97B independently byteclassified58+39 withoutrepeat; no runtime/proof acceptance','priorPositive':{'planSHA256':sha(prior/'plan.json'),'receiptSHA256':sha(prior/'receipt.json'),'stdoutSHA256':sha(prior/'reorder-owned.stdout'),'classification':'Checker exit0 then historical58B+exact39Bnotice; original receipt remains INCOMPLETE, no mathematical proof'},'queue':'Coordinator encloses prepare/run in sharedflock; no internal lock; no probes or backend children'}
    path = out/'plan.json'
    path.write_text(json.dumps(plan,indent=2)+'\n')
    print(path)
    print(sha(path))
def run(path):
    path = Path(path).resolve()
    out = path.parent
    p = json.loads(path.read_text())
    stage = Path(p['stage'])
    private = Path(p['privateEnvironment'])
    env = json.loads(private.read_text())
    def guard():
        assert all(sha(n)==s for n,s in p['pins'].items())
        assert sha(private)==p['environmentSHA256'] and inventory(stage)==p['inventory']
        assert configs(out,stage)==p['configurationStates']
    logs = L.CommandLogs(out,[c['label'] for c in p['commands']])
    runner = T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='merged-stdout')
    receipt = {'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]}
    began = time.monotonic()
    try:
        for c in p['commands']:
            assert time.monotonic()-began<60
            guard()
            try:
                result = runner.run(c['label'],c['argv'],5,expected=c['expectedExit'])
            finally:
                logs.guard()
                guard()
            merged = result['stdout']+result['stderr']
            assert isinstance(merged, bytes)
            assert sha(c['expectedMerged']) == c['expectedMergedSHA256']
            assert merged in [Path(c['expectedMerged']).read_bytes(),Path(c['expectedMerged']).read_bytes()+(H/'pinned-notice.stderr').read_bytes()]
            receipt['commands'].append({'label':c['label'],'exit':result['exit'],'failure':result['failure']})
        receipt['status'] = 'REMAINING_THREE_REORDER_NEGATIVES_EXACT_DIAGNOSTICS_NOT_RUNTIME_OR_PROOF'
    except BaseException as error:
        receipt['error'] = str(error)
        raise
    finally:
        logs.guard()
        receipt['logs'] = dict(logs.hashes)
        (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
        print(out)
parser = argparse.ArgumentParser()
parser.add_argument('--prepare',action='store_true')
parser.add_argument('--run')
args = parser.parse_args()
prepare() if args.prepare else run(args.run)
