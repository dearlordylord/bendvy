"""Invoke unchanged reviewed1/2/4 semantic/paired timing runner with exact role pins."""
from pathlib import Path
import sys
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/public-relations/timing'));import run as reviewed;import stage
assert sys.argv[1]=='--variant' and sys.argv[2] in ['baseline','candidate'];variant=sys.argv[2];del sys.argv[1:3]
original_sources=stage.sources
extras=[D/'prepare.py',D/'run.py',D/'provenance.json',Path(__file__).resolve(),D/'prepare-protocol.py']
if variant=='candidate':extras.extend([R/'experiments/public-relations/projection-opt/candidate'/stage.APP.relative_to(R)/'owned-world.bend',R/'experiments/public-relations/capture-opt/candidate/timing.js',R/'experiments/public-relations/capture-opt/candidate/capture.mjs'])
def role_sources():
 result=original_sources();result.update({str(path.relative_to(R)):stage.sha(path) for path in extras});return result
stage.sources=role_sources
reviewed.main()
