import copy,fcntl,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('typed',HERE/'transport.py');T=importlib.util.module_from_spec(s);s.loader.exec_module(T)
s=importlib.util.spec_from_file_location('model','/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-relation-readers/current-adoption-v1/oracle-v1/fullcount-current-v1/expected.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
t=T.Transport(HERE.parent/'main.bend');kind=t.resolve('Candidate',t.entry,{})
with open('/tmp/bendvy-parity-heavy.lock','a')as f:
 fcntl.flock(f,fcntl.LOCK_EX)
 expected=M.expected(3);raw=T.TERM.render_term([t.inverse(expected,kind)])+'\n';T.TERM.strict_equal(t.normalize(raw),expected)
 for bad in ['[]','[Candidate{None{}}]','[Candidate{None{}}, Candidate{None{}}]']:
  try:t.normalize(bad)
  except ValueError:pass
  else:raise AssertionError('Root refusal missing')
 changed=copy.deepcopy(expected);changed['result']['value']['beta']['capacity']['value']['clock']+=1
 try:T.TERM.strict_equal(t.normalize(T.TERM.render_term([t.inverse(changed,kind)])),expected)
 except ValueError:pass
 else:raise AssertionError('Last capacity owner field mutation accepted')
 missing=copy.deepcopy(expected);del missing['result']['value']['beta']['capacity']['value']['clock']
 try:t.inverse(missing,kind)
 except ValueError:pass
 else:raise AssertionError('Last field omission accepted')
 fcntl.flock(f,fcntl.LOCK_UN)
print('Six complete count3/root/last-owner/omission controls PASS; full65537 roundtrip retained separately')
