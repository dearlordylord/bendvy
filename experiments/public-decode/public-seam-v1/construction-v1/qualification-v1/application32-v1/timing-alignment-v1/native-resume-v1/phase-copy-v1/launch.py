"""Bounded exact-payload phase diagnostic, never production qualification."""
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import sys


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    path = Path(sys.argv[1]).resolve(strict=True)
    if sha(path) != sys.argv[2]:
        raise ValueError('Plan changed')
    plan = json.loads(path.read_text())
    if Path(sys.executable).resolve() != Path(plan['python']).resolve():
        raise ValueError('Interpreter changed')
    out = Path(plan['output'])
    out.mkdir(exist_ok=False)
    record = {'scope': plan['scope'], 'planSHA256': sys.argv[2], 'commands': []}
    primary = None
    try:
        spec = importlib.util.spec_from_file_location('phase_owner', plan['runner'])
        runner = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(runner)
        with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            for p, digest in plan['pins'].items():
                if Path(p).is_symlink() or sha(p) != digest:
                    raise ValueError('Input changed: ' + p)
            for p, target in plan['links'].items():
                if not Path(p).is_symlink() or str(Path(p).resolve()) != target:
                    raise ValueError('Link changed: ' + p)
            for command in plan['commands']:
                artifact = Path(command['artifact'])
                if artifact.exists() or artifact.is_symlink():
                    raise ValueError('Artifact must start absent')
                result = runner.execute_result(command['argv'], command['capSeconds'], command['environment'], plan['cwd'], 'split')
                row = {k:v for k,v in result.items() if k not in ('stdout','stderr')}
                row['label'] = command['label']
                record['commands'].append(row)
                for stream in ('stdout','stderr'):
                    raw = result[stream]
                    (out / (command['label'] + '.' + stream)).write_bytes(raw)
                    row[stream] = {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}
                if artifact.is_file() and not artifact.is_symlink():
                    row['artifact'] = {'bytes':artifact.stat().st_size,'sha256':sha(artifact)}
                if command['label'].startswith('control') and (result['exit'] != 0 or result['failure'] is not None or 'artifact' not in row):
                    record['status'] = 'CONTROL_FAILED_FULL_ENTRY_SKIPPED'
                    break
                if command['label'] == 'control-observed':
                    if record['commands'][0]['artifact'] != row['artifact']:
                        record['status'] = 'CONTROL_C_DIFFERED_FULL_ENTRY_SKIPPED'
                        break
            else:
                record['status'] = 'PHASE_DIAGNOSTIC_CAPTURED_NO_PRODUCTION_CREDIT'
    except BaseException as error:
        primary = error
        record['primaryFailure'] = type(error).__name__ + ': ' + str(error)
    finally:
        try:
            record['postPinsUnchanged'] = all(sha(p) == d for p,d in plan['pins'].items())
            record['postLinksUnchanged'] = all(Path(p).is_symlink() and str(Path(p).resolve()) == t for p,t in plan['links'].items())
            if not record['postPinsUnchanged'] or not record['postLinksUnchanged']:
                raise ValueError('Post bindings changed')
        except BaseException as error:
            record['postFailure'] = type(error).__name__ + ': ' + str(error)
            if primary is None: primary = error
        try:
            (out/'RESULT.json').write_text(json.dumps(record,indent=2)+'\n')
        except BaseException as error:
            record['terminalSaveFailure'] = type(error).__name__ + ': ' + str(error)
            try: sys.stderr.write(json.dumps(record)+'\n')
            except BaseException: pass
            if primary is None: primary = error
    if primary is not None: raise primary


if __name__ == '__main__':
    main()
