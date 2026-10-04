#!/usr/bin/env python3
"""Actual reader/log module checks; checker and each execution have a 5s limit.
This is not the integrated dispatcher/storage gate or a performance acceptance.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('bounded_build', HERE.parent / 't05' / 'run.py')
builds = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builds)
FILES = ['types.bend', 'readers.bend', 'streams.bend', 'reader-runtime-controls.bend']

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def clone(folder):
    folder.mkdir()
    for name in FILES: shutil.copyfile(HERE / name, folder / name)
    return folder

def replace(folder, file, old, new, count=1):
    p = folder / file
    text = p.read_text()
    assert text.count(old) == count, (file, old, text.count(old))
    p.write_text(text.replace(old, new))

def execute_pair(programs):
    out = []
    for program in programs:
        start = time.monotonic()
        text = builds.execute(program)
        out.append({'backend': 'JavaScript' if program.suffix == '.js' else 'Native',
                    'seconds': time.monotonic() - start, 'stdout': text})
    assert out[0]['stdout'] == out[1]['stdout'], out
    return out

def check_type(folder, name, body, accepted):
    p = folder / (name + '.bend')
    p.write_text('import Base\nimport ./types.bend as T\nimport ./readers.bend as R\nimport ./streams.bend as S\n' + body)
    result = builds.command([builds.CHECK, p, '--check-only'], expected=0 if accepted else 1)
    assert ('ALL PROOFS CHECK' if accepted else 'SOME PROOFS FAIL') in result
    if not accepted:
        assert ('consumed more than once' in result if name == 'affine-negative' else 'HealthPing' in result and 'MotionPing' in result), result
    return {'name': name, 'accepted': accepted, 'diagnostic': result}

def main():
    evidence = {'scope': 'Actual R/S module operations; synthetic bounded hook driver, not public dispatcher integration',
                'limits': {'checkerSeconds': 5, 'executionSeconds': 5, 'codegenSeconds': 30, 'clangSeconds': 120},
                'versions': {'bend': builds.command(['bend', 'version']), 'node': builds.command(['node', '--version'])},
                'sourceSha256': {f: sha(HERE / f) for f in FILES + ['reader-runtime-run.py']}}
    mutations = [
        ('failed-completion', 'readers.bend', 'case T.Failure{_}: readers', 'case T.Failure{_}: completed(readers,run)', 1),
        ('skip-advances-lifecycle', 'readers.bend', 'T.ReaderState{registered,last,now}', 'T.ReaderState{registered,now,now}', 1),
        ('skip-preserves-message-backlog', 'readers.bend', 'T.ReaderState{registered,last,now}', 'T.ReaderState{registered,last,last}', 1),
        ('global-completion', 'readers.bend', 'replace_case(U32.is_eq(key,id)', 'replace_case(True{}', 1),
        ('missing-first-registration', 'readers.bend', 'entry <> slots,clock)', 'slots,clock)', 1),
        ('ignore-capacity', 'streams.bend', 'U32.is_gt(size,capacity)', 'False{}', 1),
        ('ignore-holders', 'streams.bend', 'minimum(window,head)', 'window', 1),
        ('ignore-registration', 'streams.bend', 'maximum(since,registered)', 'since', 2),
        ('whole-group-lifecycle-drop', 'streams.bend', 'LifeLog{append_units(H,handles,tick,buffer)}', 'LifeLog{append_buffer(H,buffer,tick,handles)}', 1),
        ('global-consumption', 'streams.bend', 'Values{Buffer{capacity,size,dropped,front,rear}', 'Values{Buffer{capacity,0,dropped,[],[]}', 1),
    ]
    with tempfile.TemporaryDirectory(prefix='build-reader-runtime-', dir=HERE) as td:
        root = Path(td)
        positive = clone(root / 'positive')
        original = execute_pair(builds.build(positive / FILES[-1], positive))
        lines = original[0]['stdout'].splitlines()
        assert len(lines) == 108 and sum(x.endswith(':PASS') for x in lines) == 104 and not any('FAIL' in x for x in lines), lines
        evidence['original'] = original
        print('104 actual checkpoints per backend: PASS', flush=True)
        evidence['typeControls'] = [
            check_type(positive, 'schema-positive', 'def main() -> S.PingLog<T.MotionPing>: S.append(T.MotionPing,S.initial(T.MotionPing,3),1,[T.MotionPing{7}])\n', True),
            check_type(positive, 'schema-negative', 'def main() -> S.PingLog<T.MotionPing>: S.append(T.MotionPing,S.initial(T.MotionPing,3),1,[T.HealthPing{7}])\n', False),
            check_type(positive, 'affine-positive', 'def use(run: R.Run) -> R.RunInfo: R.project(run)\n', True),
            check_type(positive, 'affine-negative', 'def use(run: R.Run) -> R.RunInfo & R.RunInfo: (R.project(run),R.project(run))\n', False),
        ]
        rejected = clone(root / 'setup-rejected')
        replace(rejected, FILES[-1], 'def main() -> IO(Unit): setup(65536)', 'def main() -> IO(Unit): setup(65537)')
        evidence['rejectedSetup'] = execute_pair(builds.build(rejected / FILES[-1], rejected))
        assert evidence['rejectedSetup'][0]['stdout'] == 'SETUP_REJECTED'
        evidence['mutants'] = []
        for name, file, old, new, count in mutations:
            folder = clone(root / name)
            replace(folder, file, old, new, count)
            if name == 'skip-advances-lifecycle':
                replace(folder, file, 'def skip_found(+key: U32,now:', 'def skip_found(+key: U32,+now:')
            if name == 'skip-preserves-message-backlog':
                replace(folder, file, 'T.ReaderState{registered,last,_}', 'T.ReaderState{registered,+last,_}')
            result = execute_pair(builds.build(folder / FILES[-1], folder))
            failures = [x for x in result[0]['stdout'].splitlines() if x.endswith(':FAIL')]
            assert failures, (name, result)
            evidence['mutants'].append({'name': name, 'file': file, 'old': old, 'new': new,
                'changedOccurrences': count, 'checkedAndBuilt': True, 'runs': result, 'failedCheckpoints': failures})
            print(name + ': rejected by actual observation: ' + failures[0], flush=True)
        # A message-batch split mutation requires append_units to be defined first.
        folder = clone(root / 'partial-message-batch')
        path = folder / 'streams.bend'; source = path.read_text()
        a = source.index('def append(-P:'); b = source.index('def append_units(', a)
        append = source[a:b].replace('append_buffer(P,buffer,tick,values)', 'append_units(P,values,tick,buffer)')
        source = source[:a] + source[b:]; i = source.index('def append_lifecycle(')
        path.write_text(source[:i] + append + source[i:])
        result = execute_pair(builds.build(folder / FILES[-1], folder))
        failures = [x for x in result[0]['stdout'].splitlines() if x.endswith(':FAIL')]
        assert failures
        evidence['mutants'].append({'name': 'partial-message-batch', 'mutation': 'append each message as a unit; split original atomic publication batch', 'checkedAndBuilt': True, 'runs': result, 'failedCheckpoints': failures})
        print('partial-message-batch: rejected by actual observation: ' + failures[0], flush=True)
        folder = clone(root / 'eager-lifecycle-trim'); path = folder / 'streams.bend'; source = path.read_text()
        a = source.index('def append_lifecycle('); b = source.index('def choose_min(', a)
        append = source[a:b].replace('LifeLog{append_units(H,handles,tick,buffer)}','LifeLog{trim_buffer(H,append_units(H,handles,tick,buffer),0,[])}')
        source = source[:a] + source[b:]; i = source.index('def trim(-P:')
        path.write_text(source[:i] + append + source[i:])
        result = execute_pair(builds.build(folder / FILES[-1], folder))
        failures = [x for x in result[0]['stdout'].splitlines() if x.endswith(':FAIL')]
        assert failures
        evidence['mutants'].append({'name': 'eager-lifecycle-trim', 'mutation': 'apply capacity trim while appending lifecycle, before frame', 'checkedAndBuilt': True, 'runs': result, 'failedCheckpoints': failures})
        print('eager-lifecycle-trim: rejected by actual observation: ' + failures[0], flush=True)
    # Fresh public TS executions provide independently executed source expectations;
    # they are NOT substituted for the still-required integrated Bend dispatcher trace.
    reference = HERE.parent / 's-integrate-trace' / 'reference-retention.mjs'
    evidence['freshPublicReference'] = {'adapterSha256': sha(reference), 'results': []}
    for schema in ['Motion', 'Health']:
        for lane in ['message', 'removed', 'despawned', 'unheld', 'marks']:
            result = json.loads(builds.command(['node', reference, schema, lane]))
            assert result['status'] == 'PASS', result
            evidence['freshPublicReference']['results'].append(result)
            print('fresh public reference ' + schema + '/' + lane + ': PASS', flush=True)
    (HERE / 'reader-runtime-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('reader runtime evidence written', flush=True)

if __name__ == '__main__': main()
