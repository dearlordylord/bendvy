"""Cheap real-consumer checks and source-bound admission for expensive cohorts."""
from pathlib import Path
import hashlib
import json
import task_runner


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def validate(checks):
    if not checks or len({c["label"] for c in checks}) != len(checks):
        raise ValueError("nonempty unique checks required")
    if any(not c["label"] or Path(c["label"]).name != c["label"] or c["label"] in (".", "..") for c in checks):
        raise ValueError("invalid check label")
    if any(not 0 < c["seconds"] <= 5 for c in checks):
        raise ValueError("preflight command cap must be within five seconds")


def binding(root, files, directories, checks, env):
    validate(checks)
    root = Path(root).resolve()
    inventory = {}
    for name in directories:
        folder = root / name
        if not folder.is_dir():
            raise RuntimeError('missing preflight input directory')
        inventory[name] = {str(p.relative_to(folder)): sha(p)
                           for p in sorted(folder.rglob('*')) if p.is_file()}
    return {'files': {name: sha(root / name) for name in files},
            'directories': inventory, 'checks': checks,
            'runnerSHA256': sha(Path(task_runner.__file__)),
            'preflightSHA256': sha(Path(__file__)),
            'environmentSHA256': hashlib.sha256(json.dumps(env, sort_keys=True).encode()).hexdigest()}


def verify(receipt, *, root, files, directories, checks, env):
    receipt = Path(receipt)
    result = json.loads(receipt.read_text())
    if result['status'] != 'PREFLIGHT_PASS' or result['binding'] != binding(root, files, directories, checks, env):
        raise RuntimeError('missing, failed or stale consumer preflight')
    if [c['label'] for c in result['commands']] != [c['label'] for c in checks]:
        raise RuntimeError('incomplete preflight commands')
    for command, check in zip(result['commands'], checks):
        if command['failure'] or command['exit'] != check.get('exit', 0):
            raise RuntimeError('nonpassing preflight command')
        for stream in ('stdout', 'stderr'):
            path = receipt.parent / (check['label'] + '.' + stream)
            wanted = (Path(root) / check[stream]).read_bytes() if stream in check else b''
            if sha(path) != command[stream + 'SHA256'] or path.read_bytes() != wanted:
                raise RuntimeError('preflight observation drift')
    return result


def run(output, *, root, files, directories, checks, env):
    root, output = Path(root).resolve(), Path(output).resolve()
    if output.exists():
        raise RuntimeError('preflight output must be absent')
    expected = binding(root, files, directories, checks, env)
    output.mkdir(parents=True)
    receipt = {'status': 'INCOMPLETE', 'binding': expected, 'commands': []}
    def save():
        (output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    save()
    try:
        for check in checks:
            if binding(root, files, directories, checks, env) != expected:
                raise RuntimeError('preflight inputs changed')
            result = task_runner.execute_result(check['argv'], check['seconds'], cwd=root, env=env, capture='split')
            label = check['label']
            for stream in ('stdout', 'stderr'):
                path = output / (label + '.' + stream)
                if path.exists():
                    raise RuntimeError('duplicate preflight label')
                path.write_bytes(result[stream])
            receipt['commands'].append({'label': label, 'exit': result['exit'], 'failure': result['failure'],
                'stdoutSHA256': sha(output / (label + '.stdout')), 'stderrSHA256': sha(output / (label + '.stderr'))})
            save()
            if result['failure'] or result['exit'] != check.get('exit', 0):
                raise RuntimeError('preflight command refused')
            for stream in ('stdout', 'stderr'):
                wanted = (root / check[stream]).read_bytes() if stream in check else b''
                if result[stream] != wanted:
                    raise RuntimeError('complete preflight observation mismatch')
        if binding(root, files, directories, checks, env) != expected:
            raise RuntimeError('in-flight preflight drift')
        receipt['status'] = 'PREFLIGHT_PASS'
    finally:
        save()
    return output / 'receipt.json'
