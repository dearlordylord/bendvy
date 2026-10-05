import re

def defs(text):return {m[1]:m[0] for m in re.finditer(r'^def ([A-Za-z0-9_]+)[\s\S]*?(?=^def |\Z)',text,re.M)}
def fused_presence(text):
 names=['motion_set_fused_done','health_set_fused_done'];d=defs(text);present=[n in d for n in names]
 assert not any(present) or all(present),'partial fused catalog: reject, no generic fallback'
 if all(present):
  for prefix,stem in [('motion','position'),('health','vitals')]:
   assert d[prefix+'_set'].count(prefix+'_set_fused_done(')==1
   assert d[prefix+'_set'].count('P.prototype_'+stem+'_raw_swap(raw,value)')==1
  return True
 return False

def mutation(text,kind):
 assert fused_presence(text),'expected fused live targets';d=defs(text);sites=[]
 for prefix,stem,raw,view in [('motion','position','Position','PositionView'),('health','vitals','Vitals','VitalsView')]:
  name=prefix+'_set_fused_done';before=d[name];after=before
  if kind=='lost-mark':
   assert before.count('handle <> marks')==1;after=before.replace('handle <> marks','marks')
  elif kind=='inverse-order':
   assert before.count('X.MainInverse{handle,old} <> undo')==1;schema=prefix.title();after=before.replace('X.MainInverse{handle,old} <> undo','List.append(&2,X.Inverse<S.Handle<T.'+schema+'Schema>>,undo,[X.MainInverse{handle,old}])')
  elif kind=='suppressed-setter':
   old=',cached:T.'+view+',value:U32,result:T.'+raw+' & U32';new=',result:CC.Cache<T.'+raw+',T.'+view+'> & T.'+view;assert before.count(old)==1;after=before.replace(old,new)
   pattern='T.'+view+'{T.Four{old,_,_,_},'+('_' if prefix=='motion' else '_,_')+'}'
   assert after.count('case (raw,old):')==1;after=after.replace('case (raw,old):','case (CC.Cache{raw,cached},'+pattern+'):');assert after.count('P.'+stem+'_patch(cached,value)')==1;after=after.replace('P.'+stem+'_patch(cached,value)','cached')
   setter=d[prefix+'_set'];needle='cached,value,P.prototype_'+stem+'_raw_swap(raw,value)';assert setter.count(needle)==1;changed=setter.replace('      +value = value\n','').replace(needle,'P.'+stem+'_uncached(CC.Cache{raw,cached})');assert changed!=setter;text=text.replace(setter,changed,1)
  else:raise ValueError(kind)
  assert after!=before and text.count(before)==1;text=text.replace(before,after,1);sites.append(name)
 return text,sites
