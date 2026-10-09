"""Complete source-derived normal App inventory; no execution observations."""
import copy,json
from pathlib import Path
PRIOR=Path(__file__).parents[1]/'app-run-v1/expected.json'
def schema_entry(kind,name):return {'kind':{kind:{}},'key':name,'name':name}
def expected():
 prior=json.loads(PRIOR.read_bytes());result={}
 for category in ['plain','transient','constructed']:
  baseline=copy.deepcopy(prior[category]['Report']);last=baseline['phases'][-1];details=last['details'];old=last['snapshot']
  origin={'debug':{'Disabled':{}},'entries':[],'namespace':details['namespace'],'name':details['name'],'steps':copy.deepcopy(details['steps']),'requirements':copy.deepcopy(details['requirements'])}
  systems=[{k:copy.deepcopy(v) for k,v in registry.items() if k in ['id','name','access','slot','clauses']} for registry in old['registries']]
  description={'schema':[schema_entry('Component',name) for name in ['Position','Velocity','Health']],'namespace':1,'name':'Update','steps':copy.deepcopy(details['steps']),'systems':systems}
  observations=[]
  for label,events,pending in [('before-repeated-app-descriptions',2,1),('after-repeated-app-descriptions',2,1),('after-explicit-barrier',3,0)]:
   snap=copy.deepcopy(old);snap.update(label=label,operation={'Observed':{}},descriptions=[]);snap['world']['events']=[{} for _ in range(events)];snap['world']['pendingCount']=pending;observations.append(snap)
  result[category]={'Reported':{'report':{'baseline':baseline,'origin':origin,'observations':observations,'descriptions':[{'Some':copy.deepcopy(description)},{'Some':copy.deepcopy(description)},{'None':{}},{'Some':copy.deepcopy(description)}]}}}
 return result
def resource_expected():
 snapshot={'namespace':1,'nextId':1,'highWater':0,'capacity':1,'depth':{'nat':0},'liveBits':[False],'store':{},'resource':{'length':{'nat':2},'values':[17,17]},'events':[],'pendingCount':0,'registrations':[],'nextSystemId':1,'clock':0}
 description={'schema':[schema_entry('Resource','Settings')],'namespace':1,'name':'Update','steps':[{'Phase':{'name':'Update'}}],'systems':[]}
 return {'Reported':{'report':{'factoryNext':2,'before':copy.deepcopy(snapshot),'after':copy.deepcopy(snapshot),'descriptions':[{'Some':copy.deepcopy(description)},{'Some':copy.deepcopy(description)},{'None':{}}]}}}
if __name__=='__main__':
 p=Path(__file__)
 p.with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n');p.with_name('resource-expected.json').write_text(json.dumps(resource_expected(),indent=2)+'\n')
