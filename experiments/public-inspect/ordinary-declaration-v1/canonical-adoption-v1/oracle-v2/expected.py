"""Source-derived detached successor; no runtime output is a model input."""
import gzip,hashlib,json
from pathlib import Path
import types
HERE=Path(__file__).resolve().parent
SOURCE=Path('/workspace/formal-proofs/bendvy-worktrees/integration-ordinary-inspector-public/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2')
PARENT=HERE.parent/'oracle-v1/expected.py'
p=types.ModuleType('independent_leaf_model');p.__file__=str(PARENT);exec(compile(PARENT.read_bytes(),str(PARENT),'exec'),p.__dict__)
def boolean(v):return 'True' if v else 'False'
def array(v,show):
 if v['$']=='ALeaf':return 'leaf:'+show(v['value'])
 assert v['$']=='ANode';return 'node('+array(v['left'],show)+','+array(v['right'],show)+')'
def listed(v,show):return '['+', '.join(map(show,v))+']'
def payload(v):assert v['$']=='Payload';return 'Payload{'+array(v['values'],str)+'}'
def optional(v):return 'none' if v['$']=='None' else 'some('+payload(v['value'])+')'
def access(v):assert v['$']=='Found';return 'Found:'+str(v['value'])
def observation(d):
 w=d['owner']['world'];col=w['store'];assert col['$']=='Column'
 stamp=lambda e:str(e['id'])+':'+str(e['stamp']['added'])+':'+str(e['stamp']['changed'])
 fields=[('namespace',str(w['namespace'])),('nextId',str(w['nextId'])),('highWater',str(w['highWater'])),('live',array(w['live'],boolean)),('capacity',str(w['capacity'])),('depth',str(w['depth']['nat'])),('store','Column{values='+array(col['values'],optional)+';stamps='+listed(col['stamps'],stamp)+'}'),('resource',array(w['resource'],str)),('events',listed(w['events'],str)),('pendingCount',str(len(w['pending']))),('pendingEmpty',boolean(not w['pending'])),('registrations',listed(w['registrations'],lambda x:str(x['id'])+':'+x['name']+':'+listed(x['access'],str))),('nextSystemId',str(w['nextSystemId'])),('clock',str(w['clock']))]
 row=lambda r:str(r['entity']['namespace'])+':'+str(r['entity']['id'])+':'+access(r['value']['access'])+':'+boolean(r['value']['added'])+':'+boolean(r['value']['changed'])
 result=[('factory',str(d['factory']['nextNamespace'])),('cursor',str(d['owner']['cursor'])),('world','{'+'|'.join(k+'='+v for k,v in fields)+'}'),('rows',listed(d['rows'],row)),('clauses',listed(d['clauses'],lambda x:x['name']+':'+x['mode']['$'])),('access',access(d['access'])),('previous',optional(d['previous'])),('undoCount',str(len(d['undo']))),('undoEmpty',boolean(not d['undo'])),('commandsCount',str(len(d['commands']))),('commandsEmpty',boolean(not d['commands'])),('events',listed(d['events'],str))]
 return 'Delivered{'+'|'.join(k+'='+v for k,v in result)+'}'
def model(omit=False):
 value=p.model(omit);a=observation(value['first']);b=observation(value['second'])
 # Observe returns/rebuilds original owner, and repeated observes it again.
 return 'first.before|'+a+'\nafter|'+a+'\nsecond.before|'+b+'\nafter|'+b

def write():
 basis=json.loads((SOURCE/'SOURCE.json').read_text())
 for inv in basis['inventories'].values():
  for path,digest in inv.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
 for name,omit in [('normal',False),('mutant',True)]:
  text=model(omit);raw=(text+'\n').encode()
  (HERE/(name+'-expected.json')).write_text(json.dumps(text,indent=2)+'\n')
  (HERE/(name+'-expected.stdout')).write_bytes(raw)
  (HERE/(name+'-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0))
 basis.update(sourceCommit='2d30c303',modelInputs={str(PARENT):hashlib.sha256(PARENT.read_bytes()).hexdigest()},chronology='Independent detached successor after pure printer refusal; no runtime streams read')
 (HERE/'SOURCE-BASIS.json').write_text(json.dumps(basis,indent=2)+'\n')
if __name__=='__main__':write()
