"""Full generational AppB model derived from frozen primary sources, before execution."""
import json, os
from pathlib import Path
ROOT=Path('/tmp/bendvy-audit61-current-carrier/experiments/public-audit61/app-b-current-carrier-v1')
CORE=Path('/tmp/bendvy-audit61-current-carrier/src/ecs')
def q(s): return json.dumps(s,ensure_ascii=False)
def c(name,*fields): return name+'{'+', '.join(fields)+'}'
def ls(xs): return '['+', '.join(xs)+']'
def core(mod,name): return os.path.relpath(CORE/(mod+'.bend'),ROOT)[:-5]+'.'+name
def k(mod,name,*fields): return c(core(mod,name),*fields)
def key(i): return k('entity-key','EntityKey',str(i),'0')
def handle(i): return k('world','Handle','1',key(i))
def key_text(i): return str(i)+':0'
def tree(xs):
    if len(xs)==1:return 'leaf:'+xs[0]
    m=len(xs)//2
    return 'node('+tree(xs[:m])+','+tree(xs[m:])+')'
def column(payload,ticks):
    values=[('some('+payload+')' if tick else 'none') for tick in ticks]
    stamps=ls([f'{i}:{tick}:{tick}' for i,tick in reversed(list(enumerate(ticks,1))) if tick])
    return 'Column{values='+tree(values)+';stamps='+stamps+'}'
def desc(key): return '1:Parent:Children:hierarchy' if key==1 else '2:Link:LinkedBy:ordinary'
class State:
    def __init__(self):
        self.reserved=False;self.flushed=False;self.pending=0;self.clock=0;self.edges=[];self.inverses=[]
    def relate(self,key,source,target):
        old=next((t for k,s,t in self.edges if k==key and s==source),None)
        if old==target:return
        self.edges=[x for x in self.edges if x[:2]!=(key,source)]+[(key,source,target)]
        entries=[]
        for k,t,ids in self.inverses:
            ids=[i for i in ids if not(k==key and t==old and i==source)]
            if ids:entries.append((k,t,ids))
        for i,(k,t,ids) in enumerate(entries):
            if(k,t)==(key,target):
                entries[i]=(k,t,ids+([] if source in ids else [source]));break
        else:entries.append((key,target,[source]))
        self.inverses=entries
    def world(self):
        phase='Live' if self.flushed else 'Pending'
        slots=['0:Consumed']+['0:'+phase]*3 if self.reserved else ['0:Consumed']
        allocator=(f'next={4 if self.reserved else 1};high={3 if self.reserved else 0}'
                   +f';capacity={4 if self.reserved else 1};depth={2 if self.reserved else 0}'
                   +';slots='+tree(slots)+';free=[];order='+ls([key_text(i) for i in (1,2,3)] if self.reserved else []))
        arrays=column('node(leaf:7,leaf:9)',[1,3,5,0] if self.flushed else [0])
        scalars=column('11',[2,4,6,0] if self.flushed else [0])
        graph=ls([desc(k)+':'+key_text(s)+'>'+key_text(t) for k,s,t in self.edges])+';'+ls([desc(k)+':'+key_text(t)+':'+ls(map(key_text,ids)) for k,t,ids in self.inverses])
        return ('namespace=1|allocator={'+allocator+'}'
          +f'|store=arrays={{{arrays}}};scalars={{{scalars}}};graph={graph}'
          +f'|resources=Phase=slot(1,next(2,False),none,False);Sibling=node(leaf:100,leaf:101);receipts=inverses={3 if self.flushed else 0};returned=[];errors=[];quarantines=0'
          +f'|events=[]|pending={self.pending}|pendingKinds={"Raw;" * self.pending}end|registrations=[]|nextSystem=1|clock={self.clock}')
    def selected(self):
        rows=[]
        for i in (1,2,3):
            cells=[]
            for key,end,relation in [('parent','Outgoing',1),('children','Incoming',1),('link','Outgoing',2)]:
                if end=='Outgoing':
                    target=next((t for r,s,t in self.edges if(r,s)==(relation,i)),None)
                    value=k('relation-query','Missing') if target is None else k('relation-query','Target',handle(target))
                else:
                    ids=next((ids for r,t,ids in self.inverses if(r,t)==(relation,i)),[])
                    value=k('relation-query','Sources',ls([handle(j) for j in ids])) if ids else k('relation-query','Missing')
                cells.append(k('relation-query','Cell',q(key),k('relation-query',end),value))
            product=k('inspector-query-projection','Product',c('Unit'),ls(cells))
            rows.append(k('inspector-query','ProjectedRow',handle(i),product))
        scalar=k('inspector','Value',k('component','Found','11'),c('True'),c('True'))
        return c('inspect.Selected','0',k('machine','Current','1'),ls(rows),scalar)
def values():
    state=State();snapshots=[];worlds=[]
    def snap(stage):
        import copy
        worlds.append((stage,copy.deepcopy(state)))
        snapshots.append(c('Snapshot',q(stage),q(state.world())))
    snap('created')
    state.reserved=True;state.pending=6;snap('three-bundles-committed-pending')
    state.flushed=True;state.pending=0;state.clock=6;snap('bundles-explicit-flush')
    state.pending=2;snap('relations-committed-pending')
    state.pending=0;state.relate(1,3,1);state.relate(2,3,2);snap('relations-flushed')
    first=state.selected();snap('after-initial-inspect')
    state.pending=1;snap('reparent-committed-pending')
    state.pending=0;state.relate(1,3,2);snap('reparent-flushed')
    second=state.selected();snap('after-reparent-inspect')
    third=state.selected();snap('after-repeated-inspect')
    return worlds,(first,second,third),(c('Some',c('Report',ls(snapshots),ls([handle(i) for i in (1,2,3)]),ls([k('relation-commands','Queued')]*3),first,second,third))+'\n').encode()
def render():
    return values()[2]


def selftest():
    worlds, selected, raw = values()
    assert len(worlds) == 10 and len(selected) == 3
    assert 'pending=6|pendingKinds=Raw;Raw;Raw;Raw;Raw;Raw;end|' in worlds[1][1].world()
    assert 'pending=2|pendingKinds=Raw;Raw;end|' in worlds[3][1].world()
    assert 'pending=1|pendingKinds=Raw;end|' in worlds[6][1].world()
    assert [state.pending for _,state in worlds] == [0,6,0,2,0,0,1,0,0,0]
    assert [state.clock for _,state in worlds] == [0,0,6,6,6,6,6,6,6,6]
    assert worlds[4][1].edges == [(1,3,1),(2,3,2)]
    assert worlds[4][1].inverses == [(1,1,[3]),(2,2,[3])]
    assert worlds[7][1].edges == [(2,3,2),(1,3,2)]
    assert worlds[7][1].inverses == [(2,2,[3]),(1,2,[3])]
    assert worlds[4][1].world() == worlds[5][1].world()
    assert worlds[7][1].world() == worlds[8][1].world() == worlds[9][1].world()
    assert selected[0] != selected[1] and selected[1] == selected[2]
    assert 'slots=leaf:0:Consumed' in worlds[0][1].world()
    assert 'slots=node(node(leaf:0:Consumed,leaf:0:Pending),node(leaf:0:Pending,leaf:0:Pending))' in worlds[1][1].world()
    assert 'slots=node(node(leaf:0:Consumed,leaf:0:Live),node(leaf:0:Live,leaf:0:Live))' in worlds[-1][1].world()
    assert ';free=[];order=[1:0, 2:0, 3:0]' in worlds[-1][1].world()
    assert 'stamps=[3:5:5, 2:3:3, 1:1:1]' in worlds[-1][1].world()
    assert 'stamps=[3:6:6, 2:4:4, 1:2:2]' in worlds[-1][1].world()
    assert 'receipts=inverses=3;returned=[];errors=[];quarantines=0' in worlds[-1][1].world()
    assert handle(3) == '../../../src/ecs/world.Handle{1, ../../../src/ecs/entity-key.EntityKey{3, 0}}'
    assert raw.count(b'Snapshot{') == 10 and raw.count(b'inspect.Selected{') == 3
    assert raw.count(b'../../../src/ecs/inspector-query.ProjectedRow{') == 9
    assert raw.endswith(b'\n') and not raw.endswith(b'\n\n')


if __name__ == '__main__':
    import sys
    selftest()
    if '--self-test' not in sys.argv and '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
