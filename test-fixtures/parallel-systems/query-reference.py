import importlib.util
from pathlib import Path
import sys


query = Path(__file__).resolve().parents[2] / 'examples' / 'parallel-query'
sys.path.insert(0, str(query))
spec = importlib.util.spec_from_file_location('command_model', query / 'commands-oracle.py')
model = importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)


if __name__ == '__main__':
    mode = sys.argv[1]
    if mode not in ('native', 'serial'):
        raise ValueError('expected native or serial query mode')
    sys.stdout.write('root=serial/query=' + mode + '=' + model.scenario(True))
