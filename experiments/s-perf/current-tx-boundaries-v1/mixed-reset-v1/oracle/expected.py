"""Independent finite ordinary fixture model. Never imports/executes Bend output."""
import json
from pathlib import Path

def show(values):return '['+', '.join(str(v) for v in values)+']'
ACCESS='[Payload, Ledger, Ping]'
def world(ns,phase,resource,events,pending,applied=False):
 order='[]' if phase=='Consumed' else '[1:0]'
 allocator=f'next=2;high=1;capacity=2;depth=1;slots=node(leaf:0:Consumed,leaf:0:{phase});free=[];order={order}'
 column='Column{values=leaf:some(leaf:200);stamps=[1:1:2]}' if applied else 'Column{values=leaf:none;stamps=[]}'
 return f'namespace={ns}|allocator={{{allocator}}}|store={column}|resource=leaf:{resource}|events={show(events)}|pendingCount={pending}|pendingEmpty={str(pending==0)}|pendingKinds='+('Raw;'*pending)+f'end|registrations=[1:MixedLocal:{ACCESS}]|nextSystemId=2|clock={2 if applied else 0}'
def canonical():
 lines=[]
 for ns,label,success in [(1,'success',True),(2,'failure',False)]:
  before=world(ns,'Pending',30,[],0)+f'|prepared=[P({ns}:1:0;leaf:200;1), P({ns}:1:0;leaf:100;1), R({ns}:1:0)]'
  after=world(ns,'Pending' if success else 'Consumed',30 if success else 10,[7,7,9] if success else [],3 if success else 0)
  final=world(ns,'Live' if success else 'Consumed',30 if success else 10,[7,7,9] if success else [],0,success)
  returned='[]' if success else '[leaf:100, leaf:200]'
  local=f'token=leaf:99|returned={returned}|before={{{before}}}|afterFinish={{{after}}}'
  instance=f'namespace={ns};id=1;name=MixedLocal;access={ACCESS};cursor=not-applicable'
  selected=f'[{ns}:1:0]' if success else '[]'
  lines.append(f'{label}={"Finished" if success else "Failed"}|local={{{local}}}|instance={{{instance}}}|selected={selected}|final={{{final}}}\n')
 return ''.join(lines).encode()
def boundaries(staged):
 current=[0,0,0];peak=[0,0,0];rows=[]
 ops=[('resource.replace_join',[1,0,0]),('transaction.emit',[0,0,1]),('commands.spawn_reserved',[0,1,0]),('commands.track_pending',[1,0,0]),('resource.replace_join',[1,0,0]),('transaction.emit',[0,0,1]),('transaction.emit',[0,0,1])]
 if staged:ops += [('bundle-batch.stage',[0,0,0]),('transaction.stage_command',[0,1,0]),('transaction.stage',[0,1,0]),('transaction.stage',[0,1,0])]
 for site,delta in ops:
  if site=='bundle-batch.stage':current[1]=0
  else:current=[a+b for a,b in zip(current,delta)]
  peak=[max(a,b) for a,b in zip(current,peak)]
  rows.append({'site':site,'delta':delta,'current':list(current),'peak':list(peak)})
 return rows,list(current)
def sample(ns,kind,staged,completion,tick=0):
 rows,counts=boundaries(staged)
 if kind=='query-discard':rows=[];counts=[0,0,0]
 return {'iteration':None,'completion':completion,'tx':{'kind':kind,'namespace':ns,'beginTick':tick,'endTick':tick,'appendTick':None,'boundaries':rows,'terminal':counts,'consistent':True}}
def metrics():
 success=[sample(1,'before-stage-or-discard',False,None),sample(1,'before-finish',True,'committed'),sample(1,'query-discard',False,'discarded',2)]
 failure=[sample(2,'before-stage-or-discard',False,'discarded')]
 return {'scope':'ordinary-mixed-reset-control','frame':None,'queryCursor':0,'cases':[{'case':'success','reports':success},{'case':'failure','reports':failure}]}
if __name__=='__main__':
 root=Path(__file__).parent;(root/'expected.stdout').write_bytes(canonical());(root/'expected.boundaries.json').write_text(json.dumps(metrics(),separators=(',',':'))+'\n')
