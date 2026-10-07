"""Independent complete finite variant models; consumes no backend output.

Only the specified transition scheduling/publishing/world-inverse defects change
normal model behavior. All actual representation fields and external registry
cursors/Local observations are retained. Not a mathematical proof.
"""
import copy,importlib.util,json
from pathlib import Path
H=Path(__file__).resolve().parent
VARIANTS=['lost-retry','premature-publication','whole-marker-rollback']
def model(variant):
 assert variant in VARIANTS
 spec=importlib.util.spec_from_file_location('handler_normal_'+variant.replace('-','_'),H/'full-oracle.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 def marker(s,phase,pos):
  m.barrier(s)
  saved=copy.deepcopy(s)
  targets={k:s[k.lower()]['pending'] for k in ['Flow','Level']}
  s['flow']['flag']=False;s['level']['flag']=False
  def finish(status):
   if status!='ok' and variant=='whole-marker-rollback':
    # These owners/logs live outside the captured gameplay World or are moved
    # back from the actual failed World. Restore every other modeled field.
    preserved={key:copy.deepcopy(s[key]) for key in ['locals','cursors','attempts','deliveries','logical_attempts','logical_deliveries']}
    s.clear();s.update(copy.deepcopy(saved));s.update(preserved)
   return status
  for kind in ['Flow','Level']:
   state=s[kind.lower()];target=targets[kind]
   if target is None:continue
   old=state['current'];state.update(pending=None,previous=old,flag=False)
   if variant=='premature-publication':m.publish(s,kind,{'from':old,'to':target})
   if kind=='Flow' and old=='Boot' and target=='Play':
    for i in range(4):
     status=m.hook(s,i,old+'>'+target,i==phase*2+pos and s['locals'][i]==0)
     if status!='ok':
      if variant!='lost-retry':s['flow']['pending']=target
      return finish(status)
   state=s[kind.lower()];state.update(current=target,previous=old,flag=True);m.publish(s,kind,{'from':old,'to':target})
   if kind=='Flow' and target=='Play':
    for i in [4,5]:
     status=m.hook(s,i,old+'>'+target,i==phase*2+pos and s['locals'][i]==0)
     if status!='ok':return finish(status)
   if kind=='Level' and target=='1':
    status=m.hook(s,6,old+'>'+target)
    if status!='ok':return finish(status)
  return finish('ok')
 m.marker=marker
 return m.expected()
def expected():return {variant:{'bend':model(variant)} for variant in VARIANTS}
if __name__=='__main__':print(json.dumps(expected(),ensure_ascii=False,separators=(',',':')))
