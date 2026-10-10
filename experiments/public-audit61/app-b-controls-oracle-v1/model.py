"""Full AppB controls independently derived from frozen source, before control backend output."""
import json, os
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy-worktrees/public-audit61-app-b/experiments/public-audit61/app-b-v1')
CORE=Path('/workspace/formal-proofs/bendvy/src/ecs')
def q(s): return json.dumps(s,ensure_ascii=False)
def c(name,*fields): return name+'{'+', '.join(fields)+'}'
def ls(xs): return '['+', '.join(xs)+']'
def core(mod,name): return os.path.relpath(CORE/(mod+'.bend'),ROOT)[:-5]+'.'+name
def k(mod,name,*fields): return c(core(mod,name),*fields)
def handle(i): return k('world','Handle','1',str(i))
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
        live=tree(['False']+['True' if self.flushed else 'False']*3) if self.reserved else 'leaf:False'
        arrays=column('node(leaf:7,leaf:9)',[1,3,5,0] if self.flushed else [0])
        scalars=column('11',[2,4,6,0] if self.flushed else [0])
        graph=ls([desc(k)+f':{s}>{t}' for k,s,t in self.edges])+';'+ls([desc(k)+f':{t}:'+ls(map(str,ids)) for k,t,ids in self.inverses])
        return (f'namespace=1|next={4 if self.reserved else 1}|high={3 if self.reserved else 0}|live={live}|capacity={4 if self.reserved else 1}|depth={2 if self.reserved else 0}'
          +f'|store=arrays={{{arrays}}};scalars={{{scalars}}};graph={graph}'
          +f'|resources=Phase=slot(1,next(2,False),none,False);Sibling=node(leaf:100,leaf:101);receipts=inverses={3 if self.flushed else 0};returned=[];errors=[];quarantines=0'
          +f'|events=[]|pending={self.pending}|registrations=[]|nextSystem=1|clock={self.clock}')
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
def render(variant='namespace-normal'):
    global ROOT
    if variant not in ('namespace-normal','reparent-omission'):
        raise ValueError(variant)
    ROOT=Path('/workspace/formal-proofs/bendvy-worktrees/public-audit61-app-b/experiments/public-audit61/app-b-controls-v1')/variant
    omitted=variant=='reparent-omission'
    state=State();snapshots=[]
    def snap(stage):snapshots.append(c('Snapshot',q(stage),q(state.world())))
    snap('created')
    state.reserved=True;state.pending=6;snap('three-bundles-committed-pending')
    state.flushed=True;state.pending=0;state.clock=6;snap('bundles-explicit-flush')
    state.pending=2;snap('relations-committed-pending')
    state.pending=0;state.relate(1,3,1);state.relate(2,3,2);snap('relations-flushed')
    first=state.selected();snap('after-initial-inspect')
    state.pending=0 if omitted else 1;snap('reparent-committed-pending')
    state.pending=0
    if not omitted:state.relate(1,3,2)
    snap('reparent-flushed')
    second=state.selected();snap('after-reparent-inspect')
    third=state.selected();snap('after-repeated-inspect')
    return (c('Some',c('Report',ls(snapshots),ls([handle(i) for i in (1,2,3)]),ls([k('relation-commands','Queued')]*3),first,second,third))+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render(sys.argv[1] if len(sys.argv)>1 else 'namespace-normal'))
