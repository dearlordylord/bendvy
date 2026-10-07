"""Independent adjacency-table model; never calls Bend graph helpers."""
from copy import deepcopy
import json
from pathlib import Path
D=Path(__file__).resolve().parent
def rows(outgoing,incoming):
    live=set(range(1,6))
    components={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,*range(40,48)]}
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
    return query()
def records(root,case='normal',ts=False):
    answer=[]
    for phase in ['before','queued','applied']:
        for role in ['local','peer']:
            edges={1:{},2:{},3:{}};inverse={1:{},2:{},3:{}}
            if role=='local' and phase=='applied':
                sources=[] if case=='seeded-command-omitted' else [3]
                if ts or case=='foreign-namespace-erased':sources.append(2)
                for source in sources:edges[1][source]=1;inverse[1].setdefault(1,[]).append(source)
            graphs=[{'key':key,'name':name,'targets':[edges[key].get(i) for i in range(1,6)],'sources':[deepcopy(inverse[key].get(i,[])) for i in range(1,6)]} for key,name in [(1,'Link'),(2,'OtherLink'),(3,'Parent')]]
            answer.append({'root':root,'role':role,'phase':phase,'rows':rows(edges,inverse),'graphs':graphs,'failures':[],'retained':rows({1:{},2:{},3:{}},{1:{},2:{},3:{}})['optional']})
    return answer
def applications(case='normal',ts=False):
    return [{'root':root,'sourceIds':[1,2,3,4,5],'peerIds':[1,2,3,4,5],'records':records(root,case,ts)} for root in ['Workshop','Other']]
if __name__=='__main__':
    actual=[json.loads(l) for l in (D/'observations/1791377930138080322/actual-ts.stdout').read_text().splitlines()]
    assert applications(ts=True)==actual
    (D/'expected-ts.json').write_text(json.dumps(applications(ts=True),indent=2)+'\n')
    (D/'expected-bend.json').write_text(json.dumps(applications(),indent=2)+'\n')
