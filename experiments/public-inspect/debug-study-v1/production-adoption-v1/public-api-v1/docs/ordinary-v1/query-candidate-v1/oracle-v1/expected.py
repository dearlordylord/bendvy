"""Independent source-derived whole #56 scenario, pre-backend neutral DTO."""
import copy,json
NAMES=['main','added','changed','withoutHealth','withHealth']
BASE=[{'name':'Position','mode':'Read'},{'name':'Velocity','mode':'Write'},{'name':'Health','mode':'Optional'}]
FILTERS=[None,('Position','Added'),('Position','Changed'),('Health','Without'),('Health','With')]
def clauses(index):return copy.deepcopy(BASE)+([] if FILTERS[index] is None else [{'name':FILTERS[index][0],'mode':FILTERS[index][1]}])
def registry(index,cursor=0):
    cs=clauses(index);return {'namespace':1,'id':index+1,'name':NAMES[index],'access':[x['name'] for x in cs],'cursor':cursor,'slot':'entities','clauses':cs}
def full(values):return {'length':{'nat':len(values)},'values':values}
def row(state,i):
    return {'position':full(state['Position'][i][0]),'velocityBefore':full(state['Velocity'][i][0]),'health':{'ComponentAbsent':{}} if i not in state['Health'] else {'Found':full(state['Health'][i][0])}}
def world(category,state,clock,registered=True):
    storage={category:({} if category!='Constructed' else {'codec':{'ArrayValue':{'Integer':{}}}})}
    columns={}
    for name in ['Position','Velocity','Health']:
        columns[name.lower()]={'storage':copy.deepcopy(storage),'cells':[{'id':i,'payload':{'None':{}} if i not in state[name] else {'Some':full(state[name][i][0])},'stamp':{'added':0,'changed':0} if i not in state[name] else {'added':state[name][i][1],'changed':state[name][i][2]}} for i in [1,2,3]]}
    regs=[{'id':i+1,'name':NAMES[i],'access':[x['name'] for x in clauses(i)]} for i in reversed(range(5))] if registered else []
    return {'namespace':1,'nextId':4,'highWater':3,'capacity':4,'depth':{'nat':2},'liveBits':[True,True,True,False],'resource':{'Unit':{}},'events':[],'pendingCount':0,'registrations':regs,'nextSystemId':6 if registered else 1,'clock':clock,'columns':columns}
def description():return {'namespace':1,'name':'Update','steps':[{'Phase':{'name':'Update'}}]+[{'System':{'id':i,'condition':0}} for i in range(1,6)]+[{'Barrier':{}}],'systems':[{'id':i+1,'name':NAMES[i],'slot':'entities','clauses':clauses(i)} for i in range(5)]}
def scenario(category):
    state={'Position':{1:[[1,101],1,1],2:[[2,102],4,4],3:[[3,103],6,6]},'Velocity':{1:[[10,201],2,2],2:[[20,202],5,5]},'Health':{1:[[100,301],3,3],3:[[300,303],7,7]}}
    cursor=[0]*5;clock=7;phases=[]
    def observe(label,operation,registered=True,descriptions=None,factory=2):
        phases.append({'label':label,'factoryNextNamespace':factory,'world':world(category,state,clock,registered),'registries':[registry(i,cursor[i]) for i in range(5)] if registered else [],'operation':operation,'descriptions':descriptions or []})
    def run(label,index,ids,fail=False):
        nonlocal clock
        if fail: result={'Fail':{'UserError':{'Unit':{}}}}
        else:
            values=[]
            for i in ids:
                values.append(row(state,i));clock+=1;state['Velocity'][i][0][0]+=state['Position'][i][0][0];state['Velocity'][i][2]=clock
            cursor[index]=clock;result={'Done':values}
        observe(label,{'Run':{'result':result}})
    observe('seed',{'Observed':{}},False);observe('register',{'Observed':{}})
    run('main-fail',0,[1],True);run('main-retry',0,[1,2]);run('main-second',0,[1,2]);run('added-first',1,[1,2]);run('added-empty',1,[])
    clock+=1;state['Position'][2][0]=[5,102];state['Position'][2][2]=clock
    observe('position-e2-replace',{'PositionReplaced':{'result':{'Accepted':{}}}})
    run('changed-first',2,[1,2]);run('changed-empty',2,[]);run('without-health',3,[2]);run('with-health',4,[1])
    observe('app-enabled-descriptions',{'Observed':{}},descriptions=[{'Some':description()},{'Some':description()}])
    observe('app-disabled-description',{'Observed':{}},descriptions=[{'None':{}}])
    foreign={'namespace':2,'nextId':1,'highWater':0,'capacity':1,'depth':{'nat':0},'liveBits':[False],'resource':{'Unit':{}},'events':[],'pendingCount':0,'registrations':[],'nextSystemId':1,'clock':0,'columns':{k:{'storage':copy.deepcopy(v['storage']),'cells':[]} for k,v in world(category,state,clock)['columns'].items()}}
    observe('foreign-registration-refusal',{'RefusedRegistration':{'args':{'fail':False,'cursor':11},'foreignWorld':foreign,'registry':registry(0,11)}},factory=3)
    return {'category':category.lower(),'phases':phases}
def expected():return {name:scenario(category) for name,category in [('plain','Plain'),('transient','Transient'),('constructed','Constructed')]}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
