"""Independent chronological application oracle, no Bend graph helper calls.
Phase2 source-only: runtime population/topology/seed; no observed acceptance yet.
"""
from copy import deepcopy

def records(root,family,population,span,seed,sparse=False):
    live=set(range(1,population+1));count=population
    components={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,*range(40,48)]}
    for id in range(6,6 if sparse else population+1):
        components[id]=[(seed+1000+id)&0xffffffff,*[((seed+id*10+j)&0xffffffff) for j in range(4)]]
    outgoing={1:{},2:{},3:{}}
    incoming={1:{},2:{},3:{}}
    names={1:'Link',2:'OtherLink',3:'Parent'}
    def remove(key,source):
        target=outgoing[key].pop(source,None)
        if target is not None:
            incoming[key][target]=[id for id in incoming[key][target] if id!=source]
    def relate(key,source,target):
        remove(key,source)
        outgoing[key][source]=target
        incoming[key].setdefault(target,[]).append(source)
    for key,source,target in [(1,3,1),(1,2,1),(1,5,1),(2,1,4),(2,4,2)]:relate(key,source,target)
    def query():
        predicates={
            'other-optional':lambda id:True,'optional':lambda id:True,
            'outgoing':lambda id:id in outgoing[1],
            'incoming':lambda id:bool(incoming[1].get(id)),
            'with-out':lambda id:id in outgoing[1],
            'without-out':lambda id:id not in outgoing[1],
            'with-in':lambda id:bool(incoming[1].get(id)),
            'without-in':lambda id:not incoming[1].get(id),
            'multi':lambda id:id in outgoing[1] and not incoming[2].get(id),
            'cross-filters':lambda id:id in outgoing[2] and id not in outgoing[1],
            'empty':lambda id:True,
        }
        fields={'other-optional':[(2,'otherTarget',False),(2,'otherSources',True)],'optional':[(1,'target',False),(1,'sources',True)],'outgoing':[(1,'target',False)],'incoming':[(1,'sources',True)],'multi':[(1,'target',False),(2,'otherTarget',False),(2,'otherSources',True)],'cross-filters':[(1,'sources',True)]}
        rows={}
        for name,predicate in predicates.items():
            rows[name]=[]
            for id in sorted(live):
                if id not in components or not predicate(id):continue
                cells=[]
                for key,label,inverse in fields.get(name,[]):
                    value=(deepcopy(incoming[key].get(id)) or None) if inverse else outgoing[key].get(id)
                    cells.append({'key':label,'value':value})
                rows[name].append({'id':id,'component':deepcopy(components[id]),'cells':cells})
        return rows
    retained=deepcopy(query()['optional'])
    result=[];published=[];allremoved=[];alldespawned=[]
    def record(phase,failures=[],removed=[],despawned=[],system_result=None):
        published.extend(deepcopy(failures));allremoved.extend(removed);alldespawned.extend(despawned)
        graphs=[{'key':key,'name':names[key],'targets':[outgoing[key].get(id) if id in live else None for id in range(1,count+1)],'sources':[(deepcopy(incoming[key].get(id,[])) if id in live else None) for id in range(1,count+1)]} for key in range(1,4)]
        result.append({'root':root,'phase':phase,'rows':query(),'graphs':graphs,'failures':deepcopy(published),'removed':list(allremoved),'despawned':list(alldespawned),'retained':deepcopy(retained),'systemResult':deepcopy(system_result)})
    record('initial')
    record('queued-0')
    for source,target in [(2,1),(3,1),(4,3)]:relate(3,source,target)
    if family=='fanout':
        for id in range(6,6+span):relate(3,id,1)
    elif family=='depth':
        for id in range(6,6+span):relate(3,id,4 if id==6 else id-1)
    record('applied-0')
    components[3]=[3300,130,131,132,133]
    record('queued-1')
    relate(1,3,2);remove(2,4)
    error={'operation':'relate','relation':'Link','source':2,'target':2,'error':{'_tag':'SelfRelationNotAllowed','entityId':2,'relation':'Link'}}
    # Exact DTO schema is reconciled against the actual public observation;
    # do not normalize or silently invent this literal before admission.
    record('applied-1',[error])
    record('queued-2');incoming[3][1]=[3,2,*reversed(range(6,6+span))] if family=='fanout' else [3,2];record('applied-2')
    previous=deepcopy(components[3]);components[3]=[9000,230,231,232,233]
    # Failed writer restores its prior owning component and discards staged graph work.
    components[3]=previous
    record('queued-5',system_result={'kind':'SystemFailure','system':'relation-write-5','error':903});record('applied-5')
    count=population+1;record('queued-6');live.add(count);relate(1,5,count);record('applied-6')
    def despawn(id):
        removed=[];notices=[]
        def entered(id):
            if id not in live:return
            for key in range(1,4):
                for child in list(incoming[key].get(id,[])):
                    remove(key,child)
                    if key==3:entered(child)
                remove(key,id)
            if id in components:components.pop(id);removed.append(id)
            live.discard(id);notices.append(id)
        entered(id)
        return removed,notices
    for phase,id in [(3,3),(4,1)]:
        record('queued-'+str(phase));removed,notices=despawn(id);record('applied-'+str(phase),removed=removed,despawned=notices)
    return result



QUERY_NAMES=['other-optional','optional','outgoing','incoming','with-out','without-out','with-in','without-in','multi','cross-filters','empty']
def trace(control,seed):
    assert control in ('nonpower','sparse','empty') and isinstance(seed,int) and 0<=seed<=0xffffffff
    population=0 if control=='empty' else 7;owners=0 if control=='empty' else 4 if control=='sparse' else 6
    setup=dict(worldCreates=1,registeredSystems=0 if control=='empty' else 2,spawnCommands=population,payloadOwners=owners,seedRelations=0 if control=='empty' else 5,barriers=0 if control=='empty' else 2)
    roots=[]
    for root in ('Workshop','Other'):
        observed=([dict(root=root,phase='initial',rows={name:[] for name in QUERY_NAMES},graphs=[dict(key=key,name=name,targets=[],sources=[]) for key,name in [(1,'Link'),(2,'OtherLink'),(3,'Parent')]],failures=[],removed=[],despawned=[],retained=[],systemResult=None)] if control=='empty' else records(root,'population',7,0,seed,sparse=control=='sparse'))
        roots.append(dict(root=root,records=observed))
    return dict(input=dict(control=control,population=population,payloadSeed=seed),setup=[dict(root=root,**setup) for root in ('Workshop','Other')],roots=roots)
def operation_counts(value):
    return [dict(root=root['root'],observations=len(root['records']),queryShapes=sum(len(record['rows']) for record in root['records']),selectedRows=sum(len(rows) for record in root['records'] for rows in record['rows'].values()),visitedPayloadWriterRows=0 if value['input']['control']=='empty' else 2*len(root['records'][0]['rows']['optional']),registeredOperationSystems=1 if value['input']['control']=='empty' else 22) for root in value['roots']]
