import copy,runpy
from pathlib import Path
M=runpy.run_path(str(Path(__file__).with_name('expected.py')));normal=M['expected']();mutant=M['expected'](2)
assert normal['first']==normal['second'] and mutant['first']==mutant['second']
assert normal['firstResource']==mutant['firstResource']==normal['secondResource']
assert normal['first']['skip']==mutant['first']['skip']
for schema in ['first','second']:
 for mode,report in normal[schema].items():
  if mode=='$':continue
  assert report['before']==mutant[schema][mode]['before']
  assert report['before']['column']['slots'][0]['value']['raw']==M['SEED']
 assert normal[schema]['invalidSpawn']['committed']==normal[schema]['invalidSpawn']['before']
 assert mutant[schema]['invalidSpawn']['committed']['meta']['nextId']==3
 assert mutant[schema]['lateMissing']['barrier']['live']==[False,False]
 assert mutant[schema]['lateMissing']['barrier']['mail']['returned']==[]
 assert mutant[schema]['failure']['instance']['recoveries'][0]['packets']==[]
 original=copy.deepcopy(normal[schema]['spawn']);normal[schema]['spawn']['barrier']['column']['slots'][1]['value']['words'][1]=999
 assert normal[schema]['insert']['barrier']['column']['slots'][0]['value']['words']==[71,72]
 assert normal['firstResource']['valid']['after']['resource']['words']==[81,82]
 normal[schema]['spawn']=original
assert normal==M['expected']()
print('Complete22 shape, namespace counterfactual, full owners and detached model controls PASS')
