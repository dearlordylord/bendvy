"""Full22 native Candidate transport reusing the reviewed complete field inventory."""
from pathlib import Path
import importlib.util
import os


def inventory(entry, base, role):
    assert role == 'native-consuming'
    entry = Path(entry).resolve()
    helper = entry.parent.parent / 'transport-inventory.py'
    spec = importlib.util.spec_from_file_location('native_existing_inventory', helper)
    module = importlib.util.module_from_spec(spec)
    exec(compile(helper.read_bytes(), str(helper), 'exec'), module.__dict__)
    canonical = entry.parent.parent / 'canonical-v1/source'
    types, _ = module.inventory(canonical / 'qualification-v1/complete-spine.bend', base, 'construction-spine')
    original = str(canonical / 'materialization-v1/fixture.bend')
    actual = str(entry.parent / ('mutant-handle-fixture.bend' if entry.name == 'mutant-main.bend' else 'handle-fixture.bend'))
    for key, value in list(types.items()):
        if isinstance(value, tuple) and value[0] == original:
            types[key] = (actual, value[1])
    fields = lambda **kw: list(kw.items())
    types['HandleCases'] = (actual, {'Cases': fields(**{k:'MaterialReport' for k in ('spawn','insert','failure','failedInsert','invalid','invalidSpawn','lateMissing','skip')})})
    types['Resources'] = (str(entry), {'Resources': fields(valid='ResourceReport',invalid='ResourceReport',rollback='ResourceReport')})
    types['Report'] = (str(entry), {'Candidate': fields(first='HandleCases',second='HandleCases',firstResource='Resources',secondResource='Resources')})
    def nominal(module, tag):
        return tag if module == 'Base' or module == str(entry) else os.path.relpath(Path(module).with_suffix(''), entry.parent) + '.' + tag
    return types, nominal
