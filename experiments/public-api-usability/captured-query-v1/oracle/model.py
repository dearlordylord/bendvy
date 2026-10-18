"""Independent declared-operation model for the ordinary captured-query helper.
No candidate generated artifact or runtime output is read.
"""
from pathlib import Path
import copy,hashlib,json
P=Path(__file__).parent
listing=lambda xs:'['+', '.join(map(str,xs))+']'
def tree(xs):
 if len(xs)==1:return 'leaf:'+str(xs[0])
 h=len(xs)//2;return 'node('+tree(xs[:h])+','+tree(xs[h:])+')'
def row(value):return 'Row{'+';'.join(tree(xs)for xs in value)+'}'
def generate(schema,namespace=1):
 assert schema in ['Workshop','Garden'];clock=2;values=[[0,1,2,3],[1,2,3,4]];stamps={1:(1,1),2:(2,2)};order=[2,1];pack=[1,2,3,4];auditcursor=cursor=0;audit=[];outputs=[];failAt=1
 def fields(who,position,cur):
  clauses=['Cells:Read']if position==1 else['Cells:Write','Cells:Changed'];access=['Cells']if position==1 else['Cells','Cells'];slot='audit'if position==1 else'captured-query'
  return f'ns={namespace};id={position};name={who};access='+listing(access)+f';cursor={cur};slot={slot};clauses='+listing(clauses)+';kind=Component'
 def snapshot():
  allocator='next=3;high=2;capacity=4;depth=2;slots='+tree(['0:Consumed','0:Live','0:Live','0:Consumed'])+';free=[];order=[1:0, 2:0]'
  cells=['some('+tree(xs)+')'for xs in values];stored='Column{values='+tree(cells)+';stamps='+listing(f'{i}:{stamps[i][0]}:{stamps[i][1]}'for i in order)+'}'
  world=f'namespace={namespace}|allocator={{'+allocator+'}|store={'+stored+'}|resource=Unit|events=[]|pending=0:end|registrations=[1:audit:[Cells], 2:captured-query:[Cells, Cells]]|nextSystem=3|clock='+str(clock)
  af='audit={fields={'+fields('audit',1,auditcursor)+'};args=Unit;outputs='+listing(tree(xs)for xs in audit)+'}'
  inner=f'ns={namespace};id=2;name=captured-query;access=[Cells, Cells];cursor={cursor};capture={{'+tree(pack[:2])+';'+tree(pack[2:])+'}'
  cf='captured={fields={'+fields('captured-query',2,cursor)+'};actualOwner={'+inner+'};args=Args{'+str(failAt)+'};outputs='+listing(row(xs)for xs in outputs)+'}'
  return world+'|'+af+'|'+cf
 text=schema+'\ninitial|'+snapshot()+'\n'
 for label in ['failure','retry','no-change']:
  if label=='retry':failAt=999
  audit=copy.deepcopy(values);auditcursor=clock
  undo=[];outputs=[];failed=None
  for entity in [1,2]:
   if not(stamps[entity][1]>cursor):continue
   before=values[entity-1].copy();steps=[]
   for delta in [10,20]:
    undo.append((entity,values[entity-1].copy(),stamps[entity]));clock+=1;values[entity-1]=[n+delta for n in before];stamps[entity]=(stamps[entity][0],clock);order=[entity]+[i for i in order if i!=entity];steps.append(values[entity-1].copy())
   pack=[pack[0]+1,pack[1]+1,pack[2]+10,pack[3]+10];actual=(before,*steps)
   if before[0]==failAt:failed=actual;break
   outputs.append(actual)
  if failed:
   for entity,value,stamp in reversed(undo):values[entity-1]=value;stamps[entity]=stamp;order=[entity]+[i for i in order if i!=entity]
   outputs=[];status='Failed:Captured.CallbackFailure.UserError.Deliberate:'+row(failed)+':[Ran(1), Ran(2)]'
  else:cursor=clock;status='Finished:[Ran(1), Ran(2)]'
  text+=label+':'+status+'|'+snapshot()+'\n'
 assert clock==cursor==auditcursor==10 and values==[[20,21,22,23],[21,22,23,24]]and pack==[5,6,43,44]and outputs==[]
 return(text+'\n').encode()
if __name__=='__main__':
 result={}
 for name in ['Workshop','Garden']:
  raw=generate(name);(P/(name.lower()+'.stdout')).write_bytes(raw);result[name]={'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'namespace':1}
 print(json.dumps(result))
