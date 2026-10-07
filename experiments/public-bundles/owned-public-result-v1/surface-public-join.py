"""Compare declared public query rows from actual full consumer outputs only.
Physical clocks/namespace/owner queues/constructor counters and failed-system
Type outputs are separate contracts. Bend unwind has no TS consumer analogue.
"""
import ast,json,re,sys
from pathlib import Path
def rows(text):
 fields=text.split('|');columns=[]
 for field in fields[1:5]:
  payload=field.split('@')[0]
  payload=re.sub(r'\btag\b',repr('tag'),payload)
  payload=re.sub(r'\babsent\b','None',payload)
  columns.append(ast.literal_eval(payload))
 live=ast.literal_eval(next(f[5:] for f in fields if f.startswith('live=')))
 out=[]
 for index,alive in enumerate(live[1:]):
  if not alive or any(index>=len(c) or c[index] is None for c in columns):continue
  a,b,tag,value=(c[index] for c in columns)
  assert tag=='tag'
  out.append(dict(id=index+1,stock=a,back=b,tag={},value=value))
 return out
def compare(bend,ts):
 bylabel=dict(line.split('=',1) for line in bend.splitlines())
 actual=json.loads(ts);assert len(actual)==10
 joined=[]
 mapping={'spawn-insert':('spawn-insert-before','spawn-insert-after'),'invalid-return':('invalid-spawn-return','invalid-spawn-return'),'invalid-retry':('invalid-spawn-retry-before','invalid-spawn-retry-after'),'rollback':('rollback-before','rollback-after'),'cleanup':('cleanup-before','cleanup-after')}
 for app in actual:
  assert len(app['checkpoints'])==2
  for checkpoint,case in zip(app['checkpoints'],mapping[app['mode']]):
   label=app['schema']+'-'+case;observed=rows(bylabel[label]);assert observed==checkpoint['rows'],(label,observed,checkpoint)
   joined.append(dict(schema=app['schema'],mode=app['mode'],checkpoint=checkpoint['label'],bendLabel=label,rows=observed))
 assert len(joined)==20
 return {'status':'DECLARED_PUBLIC_ROWS_JOIN_PASS','publicCheckpoints':joined,'separate':'Physical metadata, constructors, affine ownership, failed-system output and Bend unwind are not TS-equal fields. Invalid-return public before/after shares one unchanged Bend query state; physical barrier effects remain independently checked.'}
if __name__=='__main__':
 assert len(sys.argv)==3
 print(json.dumps(compare(Path(sys.argv[1]).read_text(),Path(sys.argv[2]).read_text()),indent=2))
