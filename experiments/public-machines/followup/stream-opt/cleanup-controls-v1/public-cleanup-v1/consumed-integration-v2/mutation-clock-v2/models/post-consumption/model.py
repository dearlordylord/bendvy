"""Independent full accepted-cleanup clock defect oracle; authored before outputs."""
import importlib.util
from pathlib import Path
H=Path(__file__).resolve().parent
def load(path,name):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
def expected():
 normal=load(H.parents[3]/'models'/'post-consumption'/'model.py','independent_normal_cleanup_model')
 mutation=load(H.parents[1]/'model.py','independent_accepted_clock_mutation')
 return mutation.expected(normal.expected(),'post-consumption')
