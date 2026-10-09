"""Source-authored full declared DTO; no runtime output is read."""
import copy,json
from pathlib import Path
H=Path(__file__).resolve().parent

def ctor(tag,**fields):return {'$':tag,**fields}
def reading():return ctor('Reading',values=[31,32],lagged=False)
def model(mutant=False):
 ticks=[0,1,2,3,3,4,4,4,4,5,5,5,5]
 labels=['registered','published','slow-failed','inspector-success','frame-one','fast-read','fast-skip','inspector-failed','frame-two','slow-read','frame-three','frame-four','direct-leaf']
 positions=[];batches=[];dropped=0;boundary=0;start=0;out=[]
 for i,(label,tick) in enumerate(zip(labels,ticks)):
  completion=ctor('NoRead')
  if i==1:batches=[ctor('Batch',tick=1,values=[31,32])]
  if i==2:
   positions=[ctor('Position',id=2,cursor=0,registeredAt=1)]
   completion=ctor('ReadFailed',value=reading())
  if i==3:
   if mutant:positions.insert(0,ctor('Position',id=0,cursor=0,registeredAt=0))
   completion=ctor('ReadSucceeded',value=reading())
  if i==5:
   positions.insert(0,ctor('Position',id=1,cursor=4,registeredAt=3))
   completion=ctor('ReadSucceeded',value=reading())
  if i==7:completion=ctor('ReadFailed',value=ctor('Reading',values=[],lagged=False))
  if i==9:
   for p in positions:
    if p['id']==2:p['cursor']=5
   completion=ctor('ReadSucceeded',value=reading())
  if i in (4,8,10,11):
   boundary,start=start,tick
   hold=min([boundary]+[p['cursor'] for p in positions])
   gone=[b for b in batches if b['tick']<=hold]
   if gone:dropped=max(dropped,max(b['tick']for b in gone))
   batches=[b for b in batches if b['tick']>hold]
  if i==12:completion=ctor('ReadSucceeded',value=ctor('Reading',values=[31,32]if mutant else [],lagged=not mutant))
  meta=ctor('Metadata',namespace=1,batches=batches,positions=positions,nextReader=3,tick=tick,frameStart=start,boundary=boundary,capacity=16,dropped=dropped)
  out.append(copy.deepcopy(ctor('Snapshot',label=label,metadata=meta,events=[v for b in batches for v in b['values']],resource=[21]*4,clock=int(i>=3),nextId=1,highWater=0,worldCapacity=1,depth=0,registrations=[ctor('RegistrationMeta',id=2,name='slow',access=['events:read']),ctor('RegistrationMeta',id=1,name='fast',access=['events:read'])],nextSystem=3,inspectorCursor=ctor('None')if i<3 else ctor('Some',value=3),readerResult=completion)))
 return out
if __name__=='__main__':
 for name,mutant in [('expected.json',False),('expected-retainer.json',True)]:
  (H/name).write_text(json.dumps(model(mutant),indent=2)+'\n')
