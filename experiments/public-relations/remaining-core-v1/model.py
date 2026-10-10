"""Independent finite cleanup frame model; no compiler/runtime output inputs."""
import copy, gzip, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
LINK=(1,'Link','LinkedBy','ordinary');PARENT=(2,'Parent','Children','hierarchy');DESCRIPTORS=[LINK,PARENT]
def descriptor(d): return ':'.join(map(str,d))
def ls(values): return '['+', '.join(values)+']'
def payload(i): return f'P(L({i}),N(L({i+10}),L({i+20})))'
def tree(values): return f'N(N(L({values[0]}),L({values[1]})),N(L({values[2]}),L({values[3]})))'
def frame(f):
 kind,i,*tail=f
 if kind=='enter' or kind=='finish': return f'{kind}:{i}'
 if kind=='descriptors': return f'descriptors:{i}:'+ls(list(map(descriptor,tail[0])))
 d,remaining,children=tail
 return f'children:{i}:{descriptor(d)}:'+ls(list(map(descriptor,remaining)))+':'+ls(list(map(str,children)))
class World:
 def __init__(self,namespace):
  self.namespace=namespace;self.live=[False,True,True,True];self.slots=[None,1,2,3];self.removed=[];self.edges=[(LINK,3,1),(PARENT,2,1)];self.inverses=[(LINK,1,[3]),(PARENT,1,[2])];self.events=['original:99'];self.pending=1;self.clock=13
 def unrelate(self,d,source):
  old=[e for e in self.edges if e[0][0]==d[0] and e[1]==source];self.edges=[e for e in self.edges if e not in old]
  for _,_,target in old:
   new=[]
   for actual,t,sources in self.inverses:
    remaining=[i for i in sources if i!=source] if actual[0]==d[0] and t==target else sources
    if remaining: new.append((actual,t,remaining))
   self.inverses=new
 def observe(self):
  slots=tree(['absent' if i is None else payload(i) for i in self.slots]);removed=''.join(payload(i)+';' for i in self.removed)
  edges=ls([descriptor(d)+f':{s}>{t}' for d,s,t in self.edges]);inverses=ls([descriptor(d)+f':{t}:'+ls(list(map(str,sources))) for d,t,sources in self.inverses]);live=tree([str(v) for v in self.live])
  return f'world={self.namespace},4,3,{live},4,2/{slots}/removed={removed}/graph={edges}/{inverses}/resource=N(L(77),L(88))/events={ls(self.events)}/pending={self.pending}/regs=[1:Existing:[Link, Parent]]/nextSystem=2/clock={self.clock}'
def step(world,frames):
 f=frames.pop(0);kind,i,*tail=f
 if kind=='enter':
  if world.live[i]: frames.insert(0,('descriptors',i,DESCRIPTORS.copy()))
 elif kind=='descriptors':
  ds=tail[0]
  if ds:
   d=ds[0];children=next((sources.copy() for actual,t,sources in world.inverses if actual[0]==d[0] and t==i),[]);frames.insert(0,('children',i,d,ds[1:],children))
  else:frames.insert(0,('finish',i))
 elif kind=='children':
  d,remaining,children=tail
  if not children:
   world.unrelate(d,i);frames.insert(0,('descriptors',i,remaining))
  elif d[3]=='hierarchy':frames[:0]=[('enter',children[0]),('children',i,d,remaining,children[1:])]
  else:
   world.unrelate(d,children[0]);frames.insert(0,('children',i,d,remaining,children[1:]))
 elif kind=='finish':
  if world.slots[i] is not None:
   world.removed.insert(0,world.slots[i]);world.slots[i]=None;world.events.append(f'removed:{i}')
  world.live[i]=False;world.events.append(f'original:{i}')
 else:raise ValueError(kind)
def advance(world,frames,fuel):
 for _ in range(fuel):
  if not frames:break
  step(world,frames)
def observed(world,frames):return ('incomplete/frames='+ls(list(map(frame,frames)))+'/' if frames else 'complete/')+world.observe()
def report(namespace):
 world=World(namespace);frames=[('enter',1)];records=[observed(world,frames)];advance(world,frames,4);records.append(observed(world,frames));advance(world,frames,32);assert not frames;records.append(observed(world,frames));world.pending=0;world.clock+=1;records.append(observed(world,frames))
 trace='\n'.join(records)+'\n';return (json.dumps(trace)+'\n').encode()
if __name__=='__main__':
 for case,namespace in [('workshop',31),('garden',47)]:
  raw=report(namespace);(HERE/(case+'-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0));print(case,len(raw),hashlib.sha256(raw).hexdigest())
