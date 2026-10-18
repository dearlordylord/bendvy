"""Source-derived two-row App captured-query trace; no subject outputs read."""
from pathlib import Path
import copy,hashlib,json
from dense_state import World,listing
P=Path(__file__).parent
class DispatchWorld(World):
 def world(self):
  stored=';'.join(name+'={'+column.show(render)+'}'for name,column,render in zip(('main','aux','flag'),self.columns,(self.main,self.aux,self.flag)))
  return (f'namespace={self.namespace}|allocator={{'+self.allocator()+'}|store={'+stored+'}|resource={MotionLedger{'+self._tree(self.ledger)+';4};sibling=Unit}|events=[]|pending=0:end|registrations=[1:current-dispatch:[Position]]|nextSystem=2|clock='+str(self.clock))
 @staticmethod
 def _tree(xs):
  from dense_state import tree
  return tree(xs)
def generate():
 w=DispatchWorld('Motion',2,1);w.reserve_all();w.populate();assert w.clock==4 and not w.pending
 cursor=0;pack=[1,2,3,4]
 def snapshot(fail):
  return w.world()+'|owner={ns=1;id=1;name=current-dispatch;access=[Position];cursor='+str(cursor)+';capture={('+str(pack[0])+','+str(pack[1])+');('+str(pack[2])+','+str(pack[3])+')}};failAt='+str(fail)
 text='initial|'+snapshot(1)+'\n'
 for label,fail in [('failure',1),('retry',999),('repeat',999)]:
  undo=[];failed=False
  for entity in w.order:
   old=w.columns[0].values[entity-1].copy();a=old[0]
   for delta in (10,20):
    col=w.columns[0];undo.append((entity,col.values[entity-1].copy(),col.stamps[entity]));new=old.copy();new[0]=a+delta
    w.clock+=1;col.write(entity,new,w.clock)
   pack[:]=[pack[0]+1,pack[1]+1,pack[2]+10,pack[3]+10]
   if a==fail:failed=True;break
  if failed:
   for entity,value,stamp in reversed(undo):
    col=w.columns[0];col.values[entity-1]=value;col.stamps[entity]=stamp;col.order=[entity]+[key for key in col.order if key!=entity]
  else:cursor=w.clock
  text+=label+':'+('Failed:Unit'if failed else'Finished')+':[Ran(1)]|'+snapshot(fail)+'\n'
 assert w.clock==cursor==16 and w.columns[0].values==[[40,1,2,3],[41,2,3,4]]
 assert pack==[7,8,63,64]
 return text.encode()+b'\n' # IO.print adds one LF to the report's final LF.
if __name__=='__main__':
 raw=generate();(P/'expected.stdout').write_bytes(raw)
 print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'sourceOnly':True}))
