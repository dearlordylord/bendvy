"""Run only the declared connected-clock sleep and state-error controls."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('plan', type=Path)
    parser.add_argument('sha256')
    args = parser.parse_args()
    assert digest(args.plan) == args.sha256
    plan = json.loads(args.plan.read_text())
    directory = args.plan.resolve().parent
    assert not (directory / 'receipt.json').exists()
    assert digest(__file__) == plan['pins'][str(Path(__file__).resolve())]
    modules = {}
    for name in ['task_runner', 'evidence_boundary']:
        path = plan['executionHelpers'][name]
        spec = importlib.util.spec_from_file_location(name, path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        modules[name] = module
    def guard():
        assert digest(args.plan) == args.sha256
        for path, expected in plan['pins'].items():
            assert digest(path) == expected, path
        for root, files in plan['resourceRoots'].items():
            for path, expected in files.items():
                assert digest(Path(root) / path) == expected, (root, path)
    guard()
    receipt = dict(planSHA256=args.sha256, commands=[], artifactJoins=[], scope=plan['scope'])
    produced = {}
    with modules['evidence_boundary'].ReceiptBoundary(receipt, directory / 'receipt.json', [('input bytes', guard)]):
        for command in plan['commands']:
            guard()
            label = command['label']
            consumed = None
            if label == 'build':
                consumed = plan['artifacts']['emitted']
                assert command['argv'][5] == consumed
            elif label in ['sleep', 'end-before-begin', 'double-begin']:
                consumed = plan['artifacts']['native' if plan['role'] == 'native' else 'emitted']
                assert command['argv'][3 if plan['role'] == 'native' else 4] == consumed
            if consumed is not None:
                assert digest(consumed) == produced[consumed]['sha256']
                receipt['artifactJoins'].append(dict(consumer=label, path=consumed, **produced[consumed]))
            paths = {s: directory / (label + '.' + s) for s in ['stdout', 'stderr']}
            assert all(not p.exists() and not p.is_symlink() for p in paths.values())
            result = modules['task_runner'].execute_result(command['argv'], command['capSeconds'], env=plan['environment'], cwd=plan['cwd'], capture='split')
            actual = dict(command, exit=result['exit'], failure=result['failure'])
            for stream, path in paths.items():
                path.write_bytes(result[stream])
                actual[stream] = dict(path=str(path), bytes=len(result[stream]), sha256=digest(path))
            receipt['commands'].append(actual)
            guard()
            assert result['failure'] is None
            assert result['exit'] == command['expectedExit']
            if consumed is not None:
                assert digest(consumed) == produced[consumed]['sha256']
            if label in ['emit', 'build']:
                artifact = plan['artifacts']['emitted' if label == 'emit' else 'native']
                assert command['argv'][command['argv'].index('-o') + 1] == artifact
                produced[artifact] = dict(producer=label, sha256=digest(artifact), bytes=Path(artifact).stat().st_size)
                actual['producedArtifact'] = dict(path=artifact, **produced[artifact])
            if label == 'sleep':
                assert result['stderr'] == b'' and re.fullmatch(rb'[0-9]+\n', result['stdout'])
                value = int(result['stdout'])
                # IO.sleep(20) means20ms: broad unit check, not a speed threshold.
                assert 20_000_000 <= value <= (1 << 48) - 1
                actual['elapsedNs'] = value
            elif label in ['end-before-begin', 'double-begin']:
                assert result['stdout'] == b''
                assert command['expectedError'].encode() in result['stderr']
            else:
                assert result['stdout'] == b'' and result['stderr'] == b''
        receipt['status'] = 'CONNECTED_CLOCK_UNITS_AND_STATE_ERRORS_PASS'
    print(receipt['status'])


if __name__ == '__main__':
    main()
