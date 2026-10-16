"""Finite operation-derived authority/rollback model; no runtime input."""
import copy
FIELDS=['stock','recipe','queue','enabled','locked']
def created(ns,value):
 return {'ns':ns,'values':[value,value,value,True,True],'stamps':[(i,i) for i in range(1,6)],'clock':5,'events':[]}
def checkpoints(success):
 sender=created(1,10);receiver=created(2,10)
 old=copy.deepcopy(receiver)
 receiver['clock']+=1;receiver['values'][0]=21;receiver['stamps'][0]=(1,6)
 # Foreign lookup and despawn refusal preserve receiver; one staged populate,
 # one undo owner and one staged Ping remain until commit/abort.
 rows=[('tx-before',copy.deepcopy(receiver)),('tx-after',copy.deepcopy(receiver)),('sender-final',sender)]
 if success:
  receiver['events']=['ping:71']
  for i in range(5):
   receiver['clock']+=1;receiver['stamps'][i]=(i+1,receiver['clock'])
  receiver['values']=[33,33,33,True,True]
 else:
  receiver['values']=old['values'];receiver['stamps']=old['stamps']
 rows.append(('receiver-final',receiver));return rows
def payload(n):return f'{n}:[{n}, {n+1}, {n+2}]'
def old_snapshot(label,w):
 values=w['values'];slot=','.join(f'{f}='+ (payload(values[i]) if i<3 else 'present') for i,f in enumerate(FIELDS));absent=','.join(f'{f}=absent' for f in FIELDS)
 return f'{label}|ns={w["ns"]}|next=2|high=1|capacity=2|depth=1|clock={w["clock"]}|events=['+', '.join(w['events'])+f']|registrations=0|nextSystem=1|slot1{{{slot}}}|slot2{{{absent}}}|queue=0|live=[{w["ns"]}:1]\n'
def render(success,append=lambda w:''):
 rows=checkpoints(success);out='foreign-lookup=MissingEntity\n'
 for i,(label,w) in enumerate(rows):
  if i==1:out+='foreign-queue=MissingEntity\n'
  out+=old_snapshot(label,w).rstrip('\n')+append(w)+'\n'
  if i<2:out+='staged=1|undo=1|txEvents=[ping:71]\n'
 return out+'\n'
def stamps(w):
 rows=[]
 for slot,values in [(1,w['stamps']),(2,[(0,0)]*5)]:
  rows.append('stamps'+str(slot)+'{'+','.join(f'{name}={a}:{b}' for name,(a,b) in zip(FIELDS,values))+'}\n')
 return '\n'+''.join(rows).rstrip('\n')

def full(success):return render(success,stamps)

if __name__=='__main__':
 from pathlib import Path
 import gzip,hashlib
 here=Path(__file__).resolve().parent
 b=full(True).encode()
 assert b==(here/'expected.stdout').read_bytes()==gzip.decompress((here/'expected.stdout.gz').read_bytes())
 print(len(b),hashlib.sha256(b).hexdigest())
