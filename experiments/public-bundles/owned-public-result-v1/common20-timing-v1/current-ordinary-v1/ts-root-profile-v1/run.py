"""Reuse the unchanged timed TS executor with current fixture inventory adapter."""
from pathlib import Path
import importlib.util,sys
runner=Path('/workspace/formal-proofs/bendvy/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/timed-io-v1/development-ts.py')
spec=importlib.util.spec_from_file_location('timed_ts',runner)
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.TRANSPORT=Path(__file__).resolve().parent
module.run(sys.argv[1],sys.argv[2])
