"""Typed full raw from independent model with exact changed entry namespaces."""
from pathlib import Path
import importlib.util,json
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('independent_raw',HERE.parent/'expected-raw.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
R.ENTRY=Path('/workspace/formal-proofs/bendvy-worktrees/parity-63-loader-resolver/experiments/public-owned-events/registered-read-v1/mutants/retirement-loss-v1/main.bend')
if __name__=='__main__':
 for n in ['expected','baseline-relocated']:
  (HERE/(n+'.stdout')).write_text(R.render('Batch',json.loads((HERE/(n+'.json')).read_text()))+'\n')
