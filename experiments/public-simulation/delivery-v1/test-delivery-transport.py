"""No-child complete source-derived synthetic transport admission controls."""
import copy
import json
from pathlib import Path
import sys
import types
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')

def source(name, path):
    module = types.ModuleType(name); module.__file__ = str(path); sys.modules[name] = module
    exec(compile(path.read_bytes(), str(path), 'exec'), module.__dict__); return module

def main():
    base = ROOT / 'experiments/public-simulation/delivery-v1'
    source('prepare', base / 'prepare.py')
    comparator = source('synthetic_compare', base / 'compare.py')
    parser = source('synthetic_parser', ROOT / 'experiments/public-simulation/bend-v1/parse-report.py')
    comparator.parser_functions = lambda: (parser.parse, parser.render)
    joins = comparator.stage_joins(Path('/tmp/bendvy63-ordinary-delivery-stage-v1'))
    expected = json.loads((ROOT / 'experiments/public-simulation/bend-v1/independent-expected.json').read_bytes())
    literal = comparator.transform(expected, {neutral: name for name, neutral in joins.items()})
    raw = (parser.render(literal) + '\n').encode()
    comparator.validate_report(raw, joins)
    changed = copy.deepcopy(literal); changed['fields'][1].pop()
    try: comparator.validate_report((parser.render(changed) + '\n').encode(), joins)
    except AssertionError: pass
    else: raise AssertionError('Omitted last phase incorrectly accepted')
    changed = copy.deepcopy(literal); changed['constructor'] = 'wrongnamespace.TwoSchemaReport'
    try: comparator.validate_report((parser.render(changed) + '\n').encode(), joins)
    except KeyError: pass
    else: raise AssertionError('Wrong namespace incorrectly accepted')
    changed = copy.deepcopy(literal)
    def corrupt(value):
        if isinstance(value, dict):
            for key, item in value.items():
                if isinstance(item, dict) and set(item) == {'nat'}: value[key] = item['nat']; return True
                if corrupt(item): return True
        elif isinstance(value, list):
            for index, item in enumerate(value):
                if isinstance(item, dict) and set(item) == {'nat'}: value[index] = item['nat']; return True
                if corrupt(item): return True
        return False
    assert corrupt(changed['fields'][1][-1])
    try: comparator.validate_report((parser.render(changed) + '\n').encode(), joins)
    except AssertionError: pass
    else: raise AssertionError('Last-phase Nat/U32 confusion incorrectly accepted')
    print(json.dumps({'fullSyntheticOracleMatch': True, 'constructorJoins': len(joins), 'rejectControls': 3, 'newChildren': 0}))

if __name__ == '__main__': main()
