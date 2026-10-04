#!/usr/bin/env python3
"""Supplement the bounded lifecycle mutant gate with exact public witnesses."""
import hashlib, importlib.util, json, os, pathlib, tempfile
HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('life', HERE / 'measurement-lifecycle-timed-run.py')
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)
def first(a, b, path):
    if type(a) != type(b): return {'path': path, 'expected': a, 'actual': b}
    if isinstance(a, dict):
        if a.keys() != b.keys(): return {'path': path, 'expectedKeys': list(a), 'actualKeys': list(b)}
        for k in a:
            value = first(a[k], b[k], path + '.' + k)
            if value: return value
    elif isinstance(a, list):
        if len(a) != len(b): return {'path': path, 'expectedLength': len(a), 'actualLength': len(b)}
        for i, (x, y) in enumerate(zip(a, b)):
            value = first(x, y, path + '[' + str(i) + ']')
            if value: return value
    elif a != b: return {'path': path, 'expected': a, 'actual': b}
    return None
os.sched_setaffinity(0, {2})
evidence = {'scope': 'exact finite Motion64 public lifecycle mutation witnesses; no timing acceptance',
 'limits': {'checker': 5, 'runtime': 5, 'codegen': 30, 'clang': 120},
 'sourceHashes': {n: hashlib.sha256(v).hexdigest() for n, v in L.frozen.items()},
 'runnerSha256': hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(), 'mutants': []}
with tempfile.TemporaryDirectory(prefix='lifecycle-witness-') as temporary:
    root = pathlib.Path(temporary)
    legacy = json.loads(L.L.command(['node', HERE/'measurement-reference.mjs', 'Motion', 'lifecycle', '64']))
    for name, old, new in [('head-only-target', 'case 1: U32.div(count,2)', 'case 1: 0'), ('omit-disposal', 'motion_dispose_host(host,target)', 'host')]:
        entry = L.copied(root/name)
        p = entry.parent/'measurement-lifecycle.bend'
        text = p.read_text(); assert text.count(old) == 1
        p.write_text(text.replace(old, new))
        bins = L.L.build(entry, entry.parent)
        record = {'name': name, 'observations': []}
        for i, backend in enumerate(['Native', 'JS']):
            text = L.L.execute(bins[i], ['0', '64', '1'])
            values = [json.loads(line) for line in text.splitlines()]
            expected = L.expected('Motion', 64, backend)[0]
            witness = None
            for j, wanted in enumerate(expected):
                actual = L.decode_observation(values[j], 'Motion')
                witness = first(wanted, actual, 'observations['+str(j)+']')
                if witness: break
            assert witness, (name, backend)
            record['observations'].append({'backend': backend, 'compiling': True, 'outputSha256': hashlib.sha256(text.encode()).hexdigest(), 'witness': witness})
        evidence['mutants'].append(record)
        print(name, record['observations'][0]['witness'], flush=True)
evidence['status'] = 'PASS'
(HERE/'measurement-lifecycle-mutation-witness-evidence.json').write_text(json.dumps(evidence, indent=2)+'\n')
