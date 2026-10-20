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
 assert schema in ['Workshop','Garden'];clock=1;values=[[0,1,2,3],[1,2,3,4]];stamps={1:(1,1),2:(1,1)};order=[2,1];pack=[1,2,3,4];auditcursor=cursor=None;audit=[];outputs=[];failAt=1
 def fields(who,position,cur):
  cur='never' if cur is None else f'0:{cur}'
  clauses=['Cells:Read']if position==1 else['Cells:Write','Cells:Changed'];access=['Cells']if position==1 else['Cells','Cells'];slot='audit'if position==1 else'captured-query'
  return f'ns={namespace};id={position};name={who};access='+listing(access)+f';cursor={cur};slot={slot};clauses='+listing(clauses)+';kind=Component'
 def snapshot():
  world='cells='+listing(tree(xs)for xs in values)
  af='audit={fields={'+fields('audit',1,auditcursor)+'};args=Unit;outputs='+listing(tree(xs)for xs in audit)+'}'
  cursor_text='never' if cursor is None else '0:'+str(cursor)
  inner=f'ns={namespace};id=2;name=captured-query;access=[Cells, Cells];cursor={cursor_text};capture={{'+tree(pack[:2])+';'+tree(pack[2:])+'}'
  cf='captured={fields={'+fields('captured-query',2,cursor)+'};actualOwner={'+inner+'};args=Args{'+str(failAt)+'};outputs='+listing(row(xs)for xs in outputs)+'}'
  return world+'|'+af+'|'+cf
 text='initial|'+snapshot()+'\n'
 for label in ['failure','retry','no-change']:
  if label=='retry':
   failAt=999
   for entity in [1,2]:
    clock+=1;stamps[entity]=(stamps[entity][0],clock)
  clock+=1;audit=copy.deepcopy(values);auditcursor=clock
  clock+=1;this_run=clock
  undo=[];outputs=[];failed=None
  for entity in [1,2]:
   if cursor is not None and not(stamps[entity][1]>cursor):continue
   before=values[entity-1].copy();steps=[]
   for delta in [10,20]:
    undo.append((entity,values[entity-1].copy(),stamps[entity]));values[entity-1]=[n+delta for n in before];stamps[entity]=(stamps[entity][0],clock);order=[entity]+[i for i in order if i!=entity];steps.append(values[entity-1].copy())
   pack=[pack[0]+1,pack[1]+1,pack[2]+10,pack[3]+10];actual=(before,*steps)
   if before[0]==failAt:failed=actual;break
   outputs.append(actual)
  if failed:
   for entity,value,stamp in reversed(undo):values[entity-1]=value;stamps[entity]=stamp;order=[entity]+[i for i in order if i!=entity]
   outputs=[];status='Failed:Captured.CallbackFailure.UserError.Deliberate:'+row(failed)+':[Ran(1), Ran(2)]'
  else:status='Finished:[Ran(1), Ran(2)]'
  cursor=this_run
  text+=label+':'+status+'|'+snapshot()+'\n'
 assert clock==cursor==9 and auditcursor==8 and values==[[20,21,22,23],[21,22,23,24]]and pack==[5,6,43,44]and outputs==[]
 return(text+'\n').encode()
if __name__=='__main__':
 (P/'expected.stdout').write_bytes(generate('Workshop'))
