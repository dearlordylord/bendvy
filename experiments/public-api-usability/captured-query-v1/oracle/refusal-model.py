"""Declared MAX-registration boundary; no candidate output or natural exhaustion claim."""
from pathlib import Path
import hashlib,json
P=Path(__file__).parent
def tree(xs):
 if len(xs)==1:return 'leaf:'+str(xs[0])
 h=len(xs)//2;return 'node('+tree(xs[:h])+','+tree(xs[h:])+')'
def generate():
 namespace=1;clock=2;next_system=4294967295
 values=[[0,1,2,3],[1,2,3,4]];stamps=[(2,2,2),(1,1,1)];pack=[[50,51],[52,53]]
 allocator='next=3;high=2;capacity=4;depth=2;slots='+tree(['0:Consumed','0:Live','0:Live','0:Consumed'])+';free=[];order=[1:0, 2:0]'
 column='Column{values='+tree(['some('+tree(xs)+')'for xs in values])+';stamps=['+', '.join(':'.join(map(str,r))for r in stamps)+']}'
 world=f'namespace={namespace}|allocator={{'+allocator+'}|store={'+column+'}|resource=Unit|events=[]|pending=0:end|registrations=[1:audit:[Cells]]|nextSystem='+str(next_system)+'|clock='+str(clock)
 audit='audit={fields={ns=1;id=1;name=audit;access=[Cells];cursor=0;slot=audit;clauses=[Cells:Read];kind=Component};args=Unit;outputs=[]}'
 snapshot=world+'|'+audit+'|debug=False|capture={'+tree(pack[0])+';'+tree(pack[1])+'}'
 # world.register rejects MAX before registering, allocating an instance or
 # invoking the callback. Both prior App and input Type pack are returned.
 return('Refusal\nbefore|'+snapshot+'\nafter:Refused|'+snapshot+'\n\n').encode()
if __name__=='__main__':
 raw=generate();(P/'refusal.stdout').write_bytes(raw);print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}))
