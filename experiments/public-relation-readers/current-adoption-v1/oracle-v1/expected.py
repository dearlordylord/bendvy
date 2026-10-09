"""Complete source-derived fixture model; never reads execution observations."""
import copy,json
from pathlib import Path

def tag(ctor,**fields):return {'$':ctor,**fields}
def some(value):return tag('Some',value=value)
def none():return tag('None')
def key(id):return tag('DeclaredKey',id=id)
def failure(id,target):
 name='Parent' if id==1 else 'ParentB'
 error=tag('SelfRelationNotAllowed',source=1,relation=name) if target==1 else tag('MissingTargetEntity',source=1,target=target,relation=name)
 return tag('RelationFailed',failure=tag('Failure',relation=tag('Descriptor',key=id,name=name,inverseName='Children' if id==1 else 'ChildrenB',kind=tag('Hierarchy')),operation=tag('Relate'),source=1,target=target,error=error))
def batch(tick,values):return tag('Batch',tick=tick,count=len(values),values=values)
def domain(id,batches,readers,dropped=0,normalized=False):return tag('Domain',key=key(id),queue=tag('Queue',front=batches if normalized else [],back=[] if normalized else list(reversed(batches)),size=sum(b['count'] for b in batches),dropped=dropped),readers=readers)
def position(id,cursor,registeredAt):return tag('Position',id=id,cursor=cursor,registeredAt=registeredAt)
def reading(id,values):return tag('KeyReading',key=key(id),values=values,lagged=False)
def registration(id,name,access=None):return tag('RegistrationMeta',id=id,name=name,access=[] if access is None else access)
def base():
 return tag('Final',deliveries=[],domains=[],positions=[],tick=0,frameStart=0,boundary=0,retentionCapacity=65536,namespace=1,nextId=2,highWater=1,live=[False,True],capacity=2,depth=1,left=[11,12],right=[21,22],graph=tag('Graph',edges=[],inverses=[]),baseline=[301,302],returned=[],events=[],pendingCount=0,registrations=[registration(2,'slow',['Parent:read']),registration(1,'fast',['Parent:read'])],nextSystemId=3,clock=0,fastPrivate=[101,102],slowPrivate=[201,202])
def retry():
 self_notice,missing,beta=failure(1,1),failure(1,99),failure(2,1)
 def pos(fast,slow=None):return ([position(2,slow,1)] if slow is not None else [])+[position(1,fast,0)]
 def empty(ids):return [domain(1,[],ids)]
 def published():return [domain(1,[batch(8,[self_notice]),batch(8,[missing])],[2,1]),domain(2,[batch(8,[beta])],[])]
 def delivery(who,result,values,domains,positions):return tag('Delivery',who=who,result=result,readings=[reading(1,values)],privateCells=[101,102] if who=='fast' else [201,202],domains=domains,positions=positions)
 value=base();value.update(deliveries=[delivery('fast',0,[],empty([1]),pos(1)),delivery('slow',0,[],empty([2,1]),pos(1,2)),delivery('fast',0,[],empty([2,1]),pos(6,2)),delivery('slow',0,[],empty([2,1]),pos(6,7)),delivery('fast',0,[self_notice,missing],published(),pos(9,7)),delivery('slow',77,[self_notice,missing],published(),pos(9,7)),delivery('slow',0,[self_notice,missing],published(),pos(9,11)),delivery('fast',0,[],published(),pos(12,11))],domains=[domain(1,[],[2,1],8),domain(2,[],[],8)],positions=pos(12,11),tick=12,frameStart=12,boundary=12,clock=12)
 return value

def foreign():
 source=base();receiver=copy.deepcopy(source);receiver.update(namespace=2,tick=3,clock=3,domains=[domain(1,[batch(3,[failure(1,1)])],[])])
 return tag('ForeignResult',status=tag('MissingEntity'),before=1,after=1,source=some(source),receiver=some(receiver))
def lifecycle():
 empty=base();empty.pop('fastPrivate');empty.pop('slowPrivate');empty.update(registrations=[registration(3,'both'),registration(2,'beta'),registration(1,'alpha')],nextSystemId=4,alphaPrivate=[501,502],betaPrivate=[601,602],bothPrivate=[701,702])
 a=failure(1,1);b=[failure(2,target) for target in [1000,1001,1002]]
 active=copy.deepcopy(empty);active.update(deliveries=[[reading(1,[])],[reading(2,[])],[reading(1,[]),reading(2,[])],[reading(1,[a])],[reading(2,b)],[reading(1,[a]),reading(2,b)]],domains=[domain(1,[batch(5,[a])],[3,1],normalized=True),domain(2,[batch(5,[v]) for v in b],[3,2],normalized=True)],positions=[position(3,8,2),position(2,7,1),position(1,6,0)],tick=8,frameStart=5,clock=8)
 skipped=copy.deepcopy(active);skipped['positions'][2]['cursor']=8
 disposed=copy.deepcopy(active);disposed['positions'].pop();disposed['registrations'].pop();disposed['domains'][0]['readers']=[3]
 return tag('Cases',neverActivatedSkip=tag('Scheduled',final=some(empty),observations=[tag('Skipped',id=1)]),activatedSkip=tag('Scheduled',final=some(skipped),observations=[tag('Skipped',id=1)]),successfulDisposal=some(disposed))
def mixed():
 handle=tag('Handle',namespace=1,id=1);removed=tag('Removed',entity=handle,family=tag('Stock'));notice=tag('Original',event=tag('Removal',notice=tag('Notice',tick=7,record=removed)));events=[tag('Original',event=tag('Ordinary',value=v)) for v in [31,32]]
 def registry(id,name,cursor=0,access=None):return tag('RegistrySnapshot',namespace=1,id=id,name=name,access=[] if access is None else access,cursor=cursor)
 def mark(stage,tick,clock,added,component,cursor=None):return tag('ClockMark',stage=stage,relationTick=tick,worldClock=clock,stamp=tag('Stamp',added=added,changed=added),component=component,cursor=none() if cursor is None else some(cursor),added=none() if cursor is None else some(added>cursor),changed=none() if cursor is None else some(added>cursor))
 absent=tag('ComponentAbsent');found=tag('Found',value=[11,12,13,14]);f=failure(1,999)
 return tag('Final',marks=[mark('registered',1,1,0,absent,0),mark('activated',1,1,0,absent),mark('inserted',3,3,3,found),mark('registered',4,4,3,found,1),mark('registered',5,5,3,found,4),mark('registered',8,8,0,absent,5),mark('published',8,8,0,absent)],deliveries=[[reading(1,[])],[reading(1,[])],[reading(1,[])],[reading(1,[f])]],relationDomains=[domain(1,[batch(7,[f])],[1])],relationPositions=[position(1,8,0)],relationTick=8,relationStart=0,relationBoundary=0,relationCapacity=65536,relationRegistry=registry(1,'relation',8),relationKeys=[key(1)],private=[501,502],beforePartition=[*events,notice],removed=[removed],removalReader=tag('RemovalSnapshot',namespace=1,id=2,name='removals',cursor=1),eventReading=tag('Reading',values=events,lagged=False),eventBatches=[tag('Batch',tick=1,values=events)],eventPositions=[position(1,2,1)],eventTick=2,eventStart=0,eventBoundary=0,eventCapacity=65536,eventDropped=0,eventRegistry=registry(3,'ordinary'),namespace=1,nextId=2,highWater=1,live=[False,True],capacity=2,depth=1,column=some(tag('ColumnSnapshot',values=[none()],stamps=[])),retired=[[11,12,13,14]],graph=tag('Graph',edges=[],inverses=[]),resources=[301,302],worldEvents=events,pendingCount=0,registrations=[registration(3,'ordinary'),registration(2,'removals',['removal','removals']),registration(1,'relation')],nextSystemId=4,clock=8)
def expected():
 def report():return tag('Report',retry=some(retry()),foreign=some(foreign()),lifecycle=lifecycle(),mixed=some(mixed()))
 return tag('Output',alpha=report(),beta=report())
if __name__=='__main__':
 Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
