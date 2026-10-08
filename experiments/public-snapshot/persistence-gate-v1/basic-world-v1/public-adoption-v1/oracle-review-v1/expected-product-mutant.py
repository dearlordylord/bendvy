"""Full source-derived drop-left-product-fields counterfactual, pre-backend."""
import importlib.util,json,copy
from pathlib import Path
spec=importlib.util.spec_from_file_location('ordinary_expected',Path(__file__).with_name('expected.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
def expected():
    result=copy.deepcopy(module.expected())
    for schema in result['scenario'].values():
        for name in ('first','second','after'):
            for entity in schema[name]['entities']:entity['components']={}
            schema[name]['resources']={}
        for name in ('firstValidation','afterValidation'):
            for entity in schema[name]['entities']:entity['fields']=[]
            schema[name]['resources']=[]
    return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
