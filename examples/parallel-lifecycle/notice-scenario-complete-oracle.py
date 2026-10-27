"""Full pre-capture observation for the ordinary genuine-World notice scenario."""
from pathlib import Path
import runpy

root = Path(__file__).resolve().parent
publication = runpy.run_path(str(root / 'notice-scenario-oracle.py'))
foreign = runpy.run_path(str(root / 'notice-foreign-oracle.py'))

if __name__ == '__main__':
    print('First=' + publication['scenario'](1))
    print('Foreign=' + foreign['scenario'](2, 3))
