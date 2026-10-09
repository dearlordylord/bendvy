"""Independent source model for5733ca0a; no backend inputs."""
import copy,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=json.loads((HERE/'baseline.json').read_text())
def expected(mutant=False):
 out={}
 for category,baseline in BASE.items():
  original=copy.deepcopy(baseline['phases'][-1])
  original.update(label='before-repeated-dumps',operation={'Observed':{}},descriptions=[])
  original['world']['events']=[{'Unit':{}},{'Unit':{}}]
  original['world']['pendingCount']=1
  after=copy.deepcopy(original);after['label']='after-repeated-dumps'
  if mutant:
   for row in after['world']['columns']['position']['cells']:
    row['payload']['Some']['values'][1]+=2
  final=copy.deepcopy(after);final['label']='after-explicit-barrier'
  final['world']['events'].append({'Unit':{}});final['world']['pendingCount']=0
  rows=[{'entity':{'namespace':original['world']['namespace'],'id':row['id']},'value':{'Found':copy.deepcopy(row['payload']['Some'])},'error':{'None':{}}} for row in original['world']['columns']['position']['cells']]
  population={'Some':{'clauses':[{'name':'Position','mode':'Read'}],'rows':rows}}
  report={'baseline':copy.deepcopy(baseline),'observations':[original,after,final],'dumps':[population,copy.deepcopy(population),{'None':{}},{'None':{}}]}
  out[category]={'Kept':{'reader':{'namespace':original['world']['namespace'],'offset':{'nat':0}},'outcome':{'Reported':{'report':report}}}}
 return out
if __name__=='__main__':print(json.dumps(expected(),indent=2))
