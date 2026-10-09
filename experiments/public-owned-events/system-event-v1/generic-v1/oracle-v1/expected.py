"""Independent complete pre-backend generic event adapter observations."""
from pathlib import Path
import copy,json,importlib.util
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
CANDIDATE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-63-loader-resolver/experiments/public-owned-events/system-event-v1/generic-v1')
s=importlib.util.spec_from_file_location('prior_system_model',HERE.parent.parent/'oracle-v1/expected.py');prior=importlib.util.module_from_spec(s);s.loader.exec_module(prior)
full=copy.deepcopy(prior.expected);r=prior.r;r.ENTRY=CANDIDATE/'main.bend'
fullraw=r.render('Batch',full)+'\n'
world={'namespace':2,'nextId':1,'highWater':0,'live':[False],'capacity':1,'depth':{'nat':0},'store':[31,32],'resources':[True,False],'events':[],'pending':{'nat':0},'registrations':[{'id':1,'name':'second','access':['second-events']}],'nextSystemId':2,'clock':0}
def events(success):return {'namespace':2,'batches':[],'positions':[{'id':1,'cursor':{'nat':1},'registeredAt':{'nat':0}}]if success else [],'nextReader':2,'tick':{'nat':1 if success else 0},'frameStart':{'nat':0},'boundary':{'nat':0},'capacity':{'nat':8},'dropped':{'nat':0},'values':[]}
def owner(success):return {'slot':'second-slot','clauses':[{'name':'second-events','mode':{'Read':{}}}],'readerNamespace':2 if success else 999,'readerId':1,'expectedRegistry':1,'registryNamespace':2,'registryId':1,'name':'second','access':['second-events'],'cursor':0}
second={'success':{'Success':{'world':copy.deepcopy(world),'events':events(True),'owner':owner(True),'outputs':[[71,72]]}},'refused':{'Refused':{'world':copy.deepcopy(world),'events':events(False),'owner':owner(False),'args':[71,72]}}}
r.ENTRY=CANDIDATE/'second-schema.bend'
q=str(ROOT/'experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend');w=str(ROOT/'src/ecs/world.bend');e=str(ROOT/'src/ecs/event-runtime.bend')
r.records={'Report':('main','Report',[('success','Observed'),('refused','Observed')]),'OwnerMeta':('main','OwnerMeta',[(k,t)for k,t in [('slot','String'),('clauses',['Clause']),('readerNamespace','U32'),('readerId','U32'),('expectedRegistry','U32'),('registryNamespace','U32'),('registryId','U32'),('name','String'),('access',['String']),('cursor','U32')]]),'WorldView':('main','WorldView',[(k,t)for k,t in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('live',['Bool']),('capacity','U32'),('depth','Nat'),('store',['U32']),('resources',['Bool']),('events',['Bool']),('pending','Nat'),('registrations',['RegistrationMeta']),('nextSystemId','U32'),('clock','U32')]]),'EventView':('main','EventView',[(k,t)for k,t in [('namespace','U32'),('batches',['Batch']),('positions',['Position']),('nextReader','U32'),('tick','Nat'),('frameStart','Nat'),('boundary','Nat'),('capacity','Nat'),('dropped','Nat'),('values',['Bool'])]]),'Clause':(q,'Clause',[('name','String'),('mode','Mode')]),'RegistrationMeta':(w,'RegistrationMeta',[('id','U32'),('name','String'),('access',['String'])]),'Position':(e,'Position',[('id','U32'),('cursor','Nat'),('registeredAt','Nat')])}
r.sums={'Observed':{'Success':('main',[('world','WorldView'),('events','EventView'),('owner','OwnerMeta'),('outputs',[['U32']])]),'Refused':('main',[('world','WorldView'),('events','EventView'),('owner','OwnerMeta'),('args',['U32'])])},'Mode':{'Read':(q,[])}}
secondraw=r.render('Report',second)+'\n'
if __name__=='__main__':
 for role,value,raw in [('full',full,fullraw),('second',second,secondraw)]:
  (HERE/(role+'-expected.json')).write_text(json.dumps(value,indent=2)+'\n');(HERE/(role+'-expected.stdout')).write_text(raw)
 print('Source-derived full 24-owner trace and second-schema Type owner/output expectations frozen')
