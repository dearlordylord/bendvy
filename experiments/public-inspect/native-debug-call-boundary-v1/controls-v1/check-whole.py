"""Reuse exact existing source-derived Data term transport for complete Report."""
from pathlib import Path
import importlib.util,json,sys
sys.dont_write_bytecode=True
TRANSPORT=Path('/workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/declaration-adoption-v1/transport-v1/transport.py')
spec=importlib.util.spec_from_file_location('existing_transport',TRANSPORT);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def check(entry,raw,expected):
 t=m.Transport(entry);observed=t.convert(m.TERM.parse_term(Path(raw).read_text()),t.resolve('Report',t.entry,{}));m.TERM.strict_equal(observed,json.loads(Path(expected).read_text()));return t.inventory()
if __name__=='__main__':
 check(*sys.argv[1:]);print('WHOLE_REPORT_PASS')
