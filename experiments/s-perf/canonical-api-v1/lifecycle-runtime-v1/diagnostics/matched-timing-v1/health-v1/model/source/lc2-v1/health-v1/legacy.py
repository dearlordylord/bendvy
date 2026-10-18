"""Source-bound imports of the immutable LC1 schema and verbose grammar."""
import importlib.util
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2] / 'lc1-v1/health-v1'


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / filename)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


previous = sys.path[:]
try:
    sys.path.insert(0, str(ROOT))
    LC1 = load('immutable_lc1_schema', 'codec.py')
    VERBOSE = load('immutable_lc1_verbose', 'verbose.py')
    from primitives import (Chars, InvalidLC1, Leaf, Node, Reader as LC1Reader,
                            U32_MAX, natural)
finally:
    sys.path[:] = previous
