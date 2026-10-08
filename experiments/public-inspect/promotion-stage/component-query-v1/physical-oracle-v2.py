"""Independent finite fixture model authored before any Bend runtime outputs.
Public query expectations come exclusively from the pre-output literal model.
Physical states follow source operations, not executions of the Bend backend.
"""
import json,pathlib,hashlib
HERE=pathlib.Path(__file__).resolve().parent
MODEL=HERE/'COMPONENT-ORACLE-v2.json'
assert hashlib.sha256(MODEL.read_bytes()).hexdigest()=='73d269167d7bffa03843b62eb179121a72d6386794a55e5ff9fcd8cf2b0b38fa'
M=json.loads(MODEL.read_text());FAMILIES=['stock','title','active','count'];NAMES=[q['name'] for q in M['queries']]
def show(xs):return '['+', '.join(map(str,xs))+']'
def boolean(v):return 'True' if v else 'False'
def tree(xs):
 assert len(xs)>0 and len(xs)&(len(xs)-1)==0
 if len(xs)==1:return 'leaf:'+xs[0]
 half=len(xs)//2;return 'node('+tree(xs[:half])+','+tree(xs[half:])+')'
def repeated(n,v):return tree([str(v)]*n)
def compact(v):return json.dumps(v,separators=(',',':'),ensure_ascii=False)
def fresh_diag():return dict(targets=[],record='',before='',after='',same=False,allowed=False,checks=0,ran=0)
def diag(d):return 'targets='+show(d['targets'])+'|record='+d['record']+'|before='+d['before']+'|after='+d['after']+'|same='+boolean(d['same'])+'|allowed='+boolean(d['allowed'])+'|checks='+str(d['checks'])+'|ran='+str(d['ran'])
class World:
 def __init__(self,schema,registered):
  self.schema=schema;self.clock=1;self.values={f:[None]*16 for f in FAMILIES};self.stamps={f:[] for f in FAMILIES};self.live=[False]+[True]*16+[False]*15;self.d=fresh_diag();self.registered=registered
  # fixture.populate: ascending real entity IDs; stock/title/active/count order.
  for entity in range(1,17):
   for bit,f in enumerate(FAMILIES):
    if (entity-1)&(1<<bit):self.write(f,entity,1-entity%2 if f=='active' else entity*10+bit+1)
  assert self.clock==33
 def write(self,f,entity,value):
  self.clock+=1;old=self.values[f][entity-1];prior=next(((a,c) for i,a,c in self.stamps[f] if i==entity),(0,0))
  self.values[f][entity-1]=value
  stamp=(0,0) if value is None else ((self.clock,self.clock) if old is None else (prior[0],self.clock))
  self.stamps[f]=[(entity,*stamp)]+[s for s in self.stamps[f] if s[0]!=entity]
 def dump(self):
  cols=[]
  for f in FAMILIES:
   vals=['none' if x is None else 'some(leaf:'+str(x)+')' for x in self.values[f]]
   cols.append(f+'='+tree(vals)+';stamps='+show(str(i)+':'+str(a)+':'+str(c) for i,a,c in self.stamps[f]))
  regs=show(str(i+1)+':'+self.schema+'/ComponentQueryGate/'+NAMES[i]+':[]' for i in reversed(range(9))) if self.registered else '[]'
  resource=repeated(4,101)+';'+repeated(2,201)+';'+repeated(2,301)+';'+diag(self.d)
  return 'namespace=1|nextId=18|highWater=17|live='+tree([boolean(x) for x in self.live])+'|capacity=32|depth=5|store='+'|'.join(cols)+'|resource='+resource+'|events=[]|pending=0|registrations='+regs+'|nextSystemId='+('10' if self.registered else '1')+'|clock='+str(self.clock)
 def independent(self):
  self.clock+=1
  for f,i,v in [('stock',4,None),('stock',4,41),('stock',8,None),('stock',8,81),('title',4,None),('title',4,42),('title',12,None),('title',12,122),('stock',16,161),('title',16,162),('active',8,1),('count',12,124)]:self.write(f,i,v)
 def structural(self):
  self.clock+=1
  for f,i,v in [('stock',4,None),('stock',1,1001),('title',1,1002),('active',8,None),('count',12,None),('stock',8,None),('stock',8,81),('title',12,None),('title',12,122)]:self.write(f,i,v)
  self.live[16]=False
  for f in FAMILIES:self.values[f][15]=None;self.stamps[f]=[x for x in self.stamps[f] if x[0]!=16]
def holder(schema,i,ran):return 'Registry:1:'+str(i+1)+':'+schema+'/ComponentQueryGate/'+NAMES[i]+':[]:0;args='+repeated(2,401)+';'+repeated(4,501)+';ran='+str(ran)
def build(schema):
 out=[]
 def line(tag,value):out.append(tag+'|'+str(value))
 w=World(schema,True);instances=['Fresh']*14;registeredAt=[None]*14;ran=[0]*9
 line('schema',schema)
 for p in M['phases']:
  if p['name']=='independentLifecycle':w.independent()
  if p['name']=='structuralMutations':w.structural()
  start=w.dump();regbefore=[holder(schema,i,ran[i]) for i in range(9)];bs=[];qs=[compact(q) for q in p['completeQueryRecords']]
  line('phase',p['name'])
  for q in qs:line('query',q)
  for i,q in enumerate(qs):
   before=w.dump();ib=instances[i]
   if registeredAt[i] is None:registeredAt[i]=w.clock
   w.clock+=1;instances[i]='Active:'+str(w.clock)+':'+str(registeredAt[i]);bs.append((before,w.dump(),ib,instances[i]))
  for b in bs:
   for tag,v in zip(['queryWorldBefore','queryWorldAfter','instanceBefore','instanceAfter'],b):line(tag,v)
  for i,q in enumerate(qs[:9]):
   hb=holder(schema,i,ran[i]);w.d=dict(targets=['1:'+str(i) for i in range(1,18)],record=q,before='',after='',same=False,allowed=False,checks=0,ran=0)
   checkbefore=w.dump();allowed=bool(p['completeQueryRecords'][i]['each'])
   # Actual callback independently recomputes complete record equality and nonempty rows.
   w.d.update(before=checkbefore,after=checkbefore,same=True,allowed=allowed,checks=1)
   if allowed:ran[i]+=1
   line('observations',show([('Ran:' if allowed else 'Skipped:')+str(i+1)]));line('argsBefore',hb);line('argsAfter',holder(schema,i,ran[i]));line('diagnostic',diag(w.d))
  line('phaseWorldBefore',start);line('phaseWorldAfter',w.dump())
  for r in regbefore:line('registryBefore',r)
  for i in range(9):line('registryAfter',holder(schema,i,ran[i]))
 line('finalWorld',w.dump())
 for v in instances:line('finalInstance',v)
 for i in range(9):line('finalRegistry',holder(schema,i,ran[i]))
 line('errors','');line('retry',schema)
 w=World(schema,False);instance='Fresh';registeredAt=w.clock
 retryqs=[compact(M['phases'][0]['completeQueryRecords'][9])]*2+[compact(M['phases'][1]['completeQueryRecords'][9])]
 for i,q in enumerate(retryqs):
  before=w.dump();ib=instance
  if i>0:w.clock+=1
  instance='Active:'+str(0 if i==0 else w.clock)+':'+str(registeredAt)
  line('retryWorldBefore',before);line('retryWorldAfter',w.dump());line('retryInstanceBefore',ib);line('retryInstanceAfter',instance);line('retryQuery',q);line('retryFailed',boolean(i==0))
 line('finalWorld',w.dump());line('finalInstance',instance);line('retryErrors','')
 return '\n'.join(out)+'\n'
if __name__=='__main__':
 text=build('Workshop')+build('Garden')
 # pure main is this exact String; additive IO.print contributes one further LF.
 dest=HERE/'BEND-PHYSICAL-EXPECTED-v2.txt';dest.write_text(text+'\n')
 print(len((text+'\n').encode()),hashlib.sha256(dest.read_bytes()).hexdigest())
