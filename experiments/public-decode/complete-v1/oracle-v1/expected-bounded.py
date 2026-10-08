"""Independent old fixed128 decoder model; no Bend runtime-output input.
Validation array root plus 127 children exhaust128 before child127. Struct64
validation uses65 expansions and passes. Canonical struct recursion consumes2
fuel per field:64 fields consume128 then the zero-fuel branch returns the whole
original65-field object, which is prepended by64 canonical fields.
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
    original=result['struct64']['original']['Object']
    prefix=copy.deepcopy(original[:64])
    result['struct64']['checked']={'Accepted':{'Object':prefix+copy.deepcopy(original)}}
    return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
