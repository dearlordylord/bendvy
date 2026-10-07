#!/usr/bin/env python3
"""Reuse unchanged paired runner, restricting this admitted experiment to readers."""
import pathlib,sys
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import run,execute,preflight
SELF=pathlib.Path(__file__).resolve()
SELF_SHA=preflight.digest(SELF)
original_guard=execute.Harness.guard
def guarded(self):
    original_guard(self)
    assert preflight.digest(SELF)==SELF_SHA,'Measurement adapter drift'
    assert all(preflight.digest(pathlib.Path(n))==v for n,v in self.staged['candidateSourcePins'].items()),'Candidate source drift'
    self.receipt['measurementAdapter']={'path':str(SELF),'SHA256':SELF_SHA,'scope':'Only readers; identical pairing/output/telemetry/statistical contract'}
execute.Harness.guard=guarded
source=pathlib.Path(run.__file__).read_text()
old="for feature in ['nested','readers','fragments']:"
assert source.count(old)==1
source=source.replace(old,"for feature in ['readers']:")
old="assert semantic['status']=='PASS'"
assert source.count(old)==1
source=source.replace(old,"assert semantic['status']=='FULL_READERS_TWO_LIFECYCLES_PASS'")
# Exact two scope seams above; every pairing/output/telemetry/statistical line stays.
exec(compile(source,run.__file__,'exec'),{'__name__':'__main__','__file__':run.__file__})
