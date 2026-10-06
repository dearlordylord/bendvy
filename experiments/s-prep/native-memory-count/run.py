#!/usr/bin/env python3
"""Count runtime memory operations in a diagnostic C copy, not elapsed speed."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'experiments/s-prep/fivehour-connected-gates'))
import supervisor

p = argparse.ArgumentParser()
p.add_argument('--source', type=Path, required=True)
p.add_argument('--reference', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--cpu', type=int, default=11)
a = p.parse_args()
a.output = a.output.absolute()
a.output.mkdir(exist_ok=False)
os.sched_setaffinity(0, {a.cpu})
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
r = {'status': 'INCOMPLETE', 'scope': 'Generated C single-thread phase memory-operation counts; not physical allocation bytes or elapsed acceptance', 'commands': [], 'sourceSHA256': sha(a.source), 'referenceSHA256': sha(a.reference), 'recipeSHA256': sha(Path(__file__))}

def run(argv, limit):
    code, out = supervisor.execute(list(map(str, argv)), limit)
    r['commands'].append({'argv': list(map(str, argv)), 'limitSeconds': limit, 'exit': code, 'outputSHA256': hashlib.sha256(out.encode()).hexdigest()})
    assert code == 0, out[-1000:]
    return out

try:
    text = a.source.read_text()
    hooks = {
        'heap_alloc': 'INLINE u64 heap_alloc(Env e, u32 cls) {',
        'heap_free': 'INLINE void heap_free(Env e, u32 cls, u64 loc) {',
        'rfc_wrap': 'OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {',
        'term_keep': 'INLINE Term term_keep(Env e, Term t, u32 k) {',
        'term_drop': 'FAR void term_drop(Env e, Term t) {',
        'span_fade': 'OUTLINE void span_fade(Env e, Term t, u64 src, u32 n) {',
        'ctr_take': 'INLINE u64 ctr_take(Env e, Term t, u32 n, THR Term* out) {',
    }
    decl = 'static unsigned diagnostic_active, diagnostic_clocks;\nstatic unsigned long long diagnostic_counts[7], diagnostic_words;\n'
    assert 'diagnostic_counts' not in text
    assert text.count(hooks['heap_alloc']) == 1
    text = text.replace(hooks['heap_alloc'], decl + hooks['heap_alloc'], 1)
    for i, (name, anchor) in enumerate(hooks.items()):
        assert text.count(anchor) == 1, name
        count = 'diagnostic_counts[' + str(i) + ']++;'
        if name == 'heap_alloc':
            count += ' diagnostic_words += 1ull << cls;'
        text = text.replace(anchor, anchor + '\n  if (diagnostic_active) { ' + count + ' }', 1)
    old = 'Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
    assert text.count(old) == 1
    new = '''Term io_now_run(Env e, Term* f, IoWork* w) {
  unsigned n = ++diagnostic_clocks;
  if (n == 3) diagnostic_active = 1;
  if (n == 4) {
    diagnostic_active = 0;
    fprintf(stderr, "MEMORY-COUNTS:");
    for (unsigned i = 0; i < 7; ++i) fprintf(stderr, "%s%llu", i ? "," : "", diagnostic_counts[i]);
    fprintf(stderr, ",%llu\\n", diagnostic_words);
  }
  fprintf(stderr, "MEMORY-CLOCK:%u\\n", n);
  return (Term)(io_tick() / 1000000);
}'''
    text = text.replace(old, new, 1)
    derived = a.output / 'counted.c'
    derived.write_text(text)
    r['derivedSHA256'] = sha(derived)
    run(['clang', '-O3', derived, '-pthread', '-lm', '-o', a.output / 'counted-native'], 120)
    reference = run(['node', a.reference], 5)
    # Separate stderr so diagnostic records cannot split a JSON output line.
    redirect = 'import os,sys; fd=os.open(sys.argv[1],os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600); os.dup2(fd,2); os.close(fd); os.execv(sys.argv[2],sys.argv[2:])'
    native = run([sys.executable, '-c', redirect, a.output / 'counts.txt', a.output / 'counted-native', '--threads', '1', '--gpu', 'off'], 5)
    (a.output / 'TS.raw.txt').write_text(reference)
    (a.output / 'Native.raw.txt').write_text(native)
    observed = json.loads(reference)
    assert observed['schema'] == 'Motion' and observed['count'] == 256 and observed['iterations'] == 64 and observed['batch'] == 64
    spec = importlib.util.spec_from_file_location('validator', ROOT / 'experiments/s-integrate/measurement-bend-run.py')
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    records = [line for line in native.splitlines() if line.startswith('{')]
    assert len(records) == 65 and len(observed['samples']) == 64
    for line, world in zip(records, [observed['warmup'], *observed['samples']]):
        v.validate(line, 'Motion', False, 256, world)
        assert v.normalized(json.loads(line), 'Motion') == world['final']
    logs = (a.output / 'counts.txt').read_text().splitlines()
    assert [line for line in logs if line.startswith('MEMORY-CLOCK:')] == ['MEMORY-CLOCK:' + str(i) for i in range(1, 5)]
    samples = [line for line in logs if line.startswith('MEMORY-COUNTS:')]
    assert len(samples) == 1
    counts = [int(n) for n in samples[0].split(':', 1)[1].split(',')]
    assert len(counts) == 8
    r.update(status='MEMORY_COUNTS_FULL65_WORLDS_PASS', allFullFieldsEqual=True, counts=dict(zip([*hooks, 'heapRequestedWords'], counts)), updates=64*256*64)
    r['artifacts'] = {name: sha(a.output / name) for name in ['counted.c', 'counts.txt', 'TS.raw.txt', 'Native.raw.txt']}
except Exception as error:
    r.update(status='FAIL', error=repr(error))
finally:
    (a.output / 'evidence.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r))
sys.exit(0 if r['status'] == 'MEMORY_COUNTS_FULL65_WORLDS_PASS' else 1)
