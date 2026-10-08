"""Corrected independent fixed128 decoder model; original model preserved.
Validation array root plus 127 children exhaust128 before child127. Struct64
validation uses65 expansions and passes. Canonical 1n++more is one successor
with reusable +more binder, consuming one fuel per field. Struct64 therefore
reaches empty declaration list with fuel64 and drops extra input fields.
"""
import copy,json
import importlib.util
from pathlib import Path
_spec=importlib.util.spec_from_file_location("complete_oracle",Path(__file__).with_name("expected-complete.py"))
_module=importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)
complete_expected=_module.expected

def expected():
    result=copy.deepcopy(complete_expected())
    for name in ('array128','array256','lateInvalid'):
        result[name]['checked']={'Rejected':{'FuelExhausted':{'path':'$[127]'}}}
    return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
