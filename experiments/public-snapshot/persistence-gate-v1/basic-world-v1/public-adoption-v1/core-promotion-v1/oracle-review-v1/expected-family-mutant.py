"""Full pre-backend counterfactual: put_column replaces retained codec with Integer."""
import importlib.util,json,copy
from pathlib import Path
spec=importlib.util.spec_from_file_location('family_expected',Path(__file__).with_name('expected-family.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
def expected():
    result=copy.deepcopy(module.expected())
    for name in ('Workshop','Garden'):
        result[name]['trace']['afterA']['owner']['store']['codec']={'ArrayValue':{'Integer':{}}}
    return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
