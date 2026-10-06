#!/usr/bin/env python3
"""Diagnostic C-only sampling gate around the frozen Motion batch's third/fourth clocks."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--source', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
source = a.source.read_text()
old = 'Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
new = '''extern void moncontrol(int);
static unsigned diagnostic_clock_count = 0;
Term io_now_run(Env e, Term* f, IoWork* w) {
  unsigned n = ++diagnostic_clock_count;
  if (n == 3) moncontrol(1);
  if (n == 4) moncontrol(0);
  fprintf(stderr, "DIAGNOSTIC-CLOCK:%u\\n", n);
  return (Term)(io_tick() / 1000000);
}'''
assert source.count(old) == 1
assert source.count('int main(int argc, char** argv) {') == 1
derived = source.replace(old, new).replace('int main(int argc, char** argv) {', 'int main(int argc, char** argv) {\n  moncontrol(0);', 1)
assert not a.output.exists()
a.output.write_text(derived)
sha = lambda b: hashlib.sha256(b).hexdigest()
r = {'scope': 'Diagnostic generated-C copy only; profile sampling enabled between clocks 3 and 4. Require exactly four observed clocks and full65 fresh reference worlds. Not timing acceptance.', 'originalSHA256': sha(source.encode()), 'derivedSHA256': sha(derived.encode()), 'recipeSHA256': sha(Path(__file__).read_bytes())}
a.output.with_suffix('.recipe.json').write_text(json.dumps(r, indent=2)+'\n')
print(json.dumps(r))
