"""Independent single-machine bundle application model, authored before Bend/TS outputs."""
import copy,json
from pathlib import Path
H=Path(__file__).resolve().parent
ENTRIES=[
 {'id':1,'name':'enterPlay1','phase':'enter','from':None,'to':'Play','delta':1000,'requirements':['owned','machine']},
 {'id':2,'name':'exitBoot0','phase':'exit','from':'Boot','to':None,'delta':1,'requirements':['owned','machine']},
 {'id':3,'name':'transitionBootPause','phase':'transition','from':'Boot','to':'Pause','delta':20,'requirements':['owned','machine']},
 {'id':4,'name':'enterPlay0','phase':'enter','from':None,'to':'Play','delta':100,'requirements':['owned','machine']},
 {'id':5,'name':'exitBoot1','phase':'exit','from':'Boot','to':None,'delta':10,'requirements':['owned','machine']},
 {'id':6,'name':'transitionBootPlay','phase':'transition','from':'Boot','to':'Play','delta':30,'requirements':['owned','machine']},
 {'id':7,'name':'enterPause','phase':'enter','from':None,'to':'Pause','delta':200,'requirements':['owned','machine']},
 {'id':8,'name':'inactiveExitPause','phase':'exit','from':'Pause','to':None,'delta':10000,'requirements':['owned','extra','machine']},
]
UNION=list(dict.fromkeys(q for e in ENTRIES for q in e['requirements']))
def initial(ns,current='Boot',extra=True):
 return {'namespace':ns,'entity':1,'component':[0,7],'resource':[0,19],'extraPresent':extra,'extraPayload':[5,29] if extra else None,'current':current,'pending':None,'previous':None,'changed':False,'locals':[0]*8,'registryIds':list(range(1,9)),'registryNames':[e['name'] for e in ENTRIES],'registryNamespaces':[ns]*8,'registryCursors':[0]*8,'readerId':9,'readerNamespace':ns,'readerCursor':0,'readerPosition':None,'tick':0,'clock':0,'attempts':[],'prefix':[],'publications':[],'deliveries':[],'pendingStructural':0,'structuralApplied':0,'requirements':UNION,'entries':ENTRIES,'missing':[],'outcome':'idle'}
def request(s,value,skip=False):s['pending']={'value':value,'skipIfSame':skip}
def marker(s,fail=None,foreign=False):
 s['missing']=[]
 if foreign:s['outcome']='foreign';return
 if not s['extraPresent']:s['missing']=['extra'];s['outcome']='requirements';return
 s['tick']+=1;s['structuralApplied']+=s['pendingStructural'];s['pendingStructural']=0;s['changed']=False
 pending=s['pending']
 if pending is None:s['outcome']='ok';return
 s['pending']=None;old=s['current'];new=pending['value']
 if pending['skipIfSame'] and old==new:s['outcome']='ok';return
 s['previous']=old
 for phase in ['exit','transition','enter']:
  if phase=='enter':s['current']=new;s['changed']=True;s['publications'].append({'from':old,'to':new,'tick':s['tick']})
  selected=[e for e in ENTRIES if e['phase']==phase and (e['from'] is None or e['from']==old) and (e['to'] is None or e['to']==new)]
  selected=list(reversed(selected))
  for e in selected:
   i=e['id']-1;s['locals'][i]+=1;s['attempts'].append(e['name'])
   if fail==e['name']:
    if phase!='enter':s['pending']=pending
    s['outcome']='failed:'+e['name'];return
   s['component'][0]+=e['delta'];s['resource'][0]+=e['delta'];s['clock']+=1;s['registryCursors'][i]=s['clock'];s['prefix'].append(e['name']);s['pendingStructural']+=1
   if e['name']=='enterPlay1':request(s,'Pause')
 s['outcome']='ok'
def read(s):
 s['readerPosition']={'cursor':s['tick'],'registeredAt':s['tick'] if s['readerPosition'] is None else s['readerPosition']['registeredAt']}
 s['readerCursor']=s['clock'];s['deliveries']=[{'from':e['from'],'to':e['to']} for e in s['publications']]
def scenarios(ns):
 rows={}
 def point(name,s):rows[name]=copy.deepcopy(s)
 for target in ['Play','Pause']:
  s=initial(ns);request(s,target);point('boot_'+target+'_queued',s);marker(s);read(s);point('boot_'+target+'_applied',s)
 s=initial(ns);request(s,'Play');marker(s);read(s);marker(s);read(s);point('self_queued_next',s)
 for current in ['Boot','Play']:
  for skip in [False,True]:
   s=initial(ns,current);request(s,current,skip);marker(s);read(s);point('same_'+current+'_'+str(skip).lower(),s)
 for fail in ['exitBoot0','exitBoot1','transitionBootPlay','enterPlay1','enterPlay0']:
  s=initial(ns);request(s,'Play');marker(s,fail);point('failed_'+fail,s);marker(s);read(s);point('later_'+fail,s)
 s=initial(ns,extra=False);request(s,'Play');point('missing_queued',s);marker(s);point('inactive_missing',s);s['extraPresent']=True;s['extraPayload']=[5,29];marker(s);read(s);point('inactive_restored',s)
 source=initial(ns);target=initial(ns+1);request(source,'Boot',True)
 rows['foreign_refused']={'source':copy.deepcopy(source),'target':copy.deepcopy(target),'result':'foreign'}
 marker(source);read(source);rows['foreign_legitimate_retry']={'source':copy.deepcopy(source),'target':copy.deepcopy(target),'result':'ok'}
 return rows
if __name__=='__main__':
 output={'status':'INDEPENDENT_BUNDLE_ORACLE_BEFORE_SOURCE_AND_EXECUTABLE_OUTPUT','entries':ENTRIES,'requirementUnion':UNION,'rows':{schema:scenarios(ns) for schema,ns in [('A',1),('B',2)]}}
 path=H/'expected.json';assert not path.exists();path.write_text(json.dumps(output,indent=2)+'\n')
