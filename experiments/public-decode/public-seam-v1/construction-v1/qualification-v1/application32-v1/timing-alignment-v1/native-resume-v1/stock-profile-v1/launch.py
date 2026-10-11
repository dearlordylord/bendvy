"""One bounded profiler flush control, then conditional stock emit diagnostic."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def usable_profile(data):
    if not isinstance(data, dict):
        return False
    nodes, samples, deltas = data.get('nodes'), data.get('samples'), data.get('timeDeltas')
    if not all(isinstance(value, list) and value for value in (nodes, samples, deltas)):
        return False
    if not all(isinstance(node, dict) for node in nodes):
        return False
    ids = [node.get('id') for node in nodes]
    if not all(type(value) is int for value in ids) or len(set(ids)) != len(ids):
        return False
    frames = all(isinstance(node.get('callFrame'), dict) and
                 isinstance(node['callFrame'].get('functionName'), str) for node in nodes)
    edges = all(isinstance(node.get('children', []), list) and
                all(type(child) is int and child in ids for child in node.get('children', []))
                for node in nodes)
    return (frames and edges and all(type(value) is int and value in ids for value in samples)
            and len(deltas) == len(samples)
            and all(type(value) in (int, float) and value >= 0 for value in deltas))


def main():
    plan_path = Path(sys.argv[1]).resolve(strict=True)
    if sha(plan_path) != sys.argv[2]:
        raise ValueError('Admitted diagnostic plan changed')
    plan = json.loads(plan_path.read_text())
    if Path(sys.executable).resolve() != Path(plan['python']).resolve():
        raise ValueError('Executing interpreter differs')
    for path, digest in plan['pins'].items():
        if Path(path).is_symlink() or sha(path) != digest:
            raise ValueError('Diagnostic input changed: ' + path)
    out = Path(plan['output'])
    out.mkdir(exist_ok=False)
    spec = importlib.util.spec_from_file_location('profile_command_owner', plan['runner'])
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    record = {'scope': plan['scope'], 'planSHA256': sys.argv[2], 'stages': []}
    primary = None
    try:
        for label in ('control', 'emit'):
            subplan = plan[label]
            profile = Path(subplan['profile'])
            if profile.exists() or profile.is_symlink():
                raise ValueError('Profiler output must start absent')
            argv = [plan['python'], plan['collector'], 'run', subplan['plan'], subplan['sha256']]
            # The unchanged collector owns child deadlines, process trees and lock.
            result = runner.execute_result(argv, subplan['outerCapSeconds'], plan['outerEnvironment'], plan['cwd'], 'split')
            for stream in ('stdout', 'stderr'):
                (out / (label + '.' + stream)).write_bytes(result[stream])
            row = {'label': label, 'collectorExit': result['exit'], 'outerFailure': result['failure'], 'profile': str(profile)}
            record['stages'].append(row)
            receipt = Path(subplan['plan']).parent / 'receipt.json'
            if receipt.is_file():
                row['receiptSHA256'] = sha(receipt)
                child = json.loads(receipt.read_text())['commands'][0]
                row['childExit'] = child['exit']
                row['childFailure'] = child['failure']
            if label == 'control' and row.get('childFailure') != 'child deadline':
                record['status'] = 'CONTROL_DID_NOT_REACH_TIMEOUT_EMIT_NOT_LAUNCHED'
                break
            if profile.is_symlink():
                raise ValueError('Profiler output is a symlink')
            if profile.is_file() and not profile.is_symlink():
                if profile.stat().st_size > plan['profileMaxBytes']:
                    raise ValueError('Diagnostic profile exceeds admitted storage bound')
                raw = profile.read_bytes()
                row.update(profileBytes=len(raw), profileSHA256=hashlib.sha256(raw).hexdigest())
                data = json.loads(raw)
                row['usableSamples'] = usable_profile(data)
            else:
                row['usableSamples'] = False
            if label == 'control' and not row['usableSamples']:
                record['status'] = 'TIMEOUT_PROFILE_NOT_AVAILABLE_EMIT_NOT_LAUNCHED'
                break
        if 'status' not in record:
            record['status'] = 'DIAGNOSTIC_COMPLETE_NO_PRODUCTION_QUALIFICATION'
    except BaseException as error:
        primary = error
        record['primaryFailure'] = type(error).__name__ + ': ' + str(error)
    finally:
        try:
            record['postPinsUnchanged'] = all(sha(path) == digest for path, digest in plan['pins'].items())
            if not record['postPinsUnchanged']:
                raise ValueError('Diagnostic inputs changed after attempt')
        except BaseException as error:
            record['postBindingFailure'] = type(error).__name__ + ': ' + str(error)
            if primary is None:
                primary = error
        try:
            (out / 'RESULT.json').write_text(json.dumps(record, indent=2) + '\n')
        except BaseException as error:
            record['terminalSaveFailure'] = type(error).__name__ + ': ' + str(error)
            try:
                sys.stderr.write(json.dumps(record) + '\n')
            except BaseException:
                pass  # Preserve the first failure even when both publication paths fail.
            if primary is None:
                primary = error
    if primary is not None:
        raise primary


if __name__ == '__main__':
    main()
