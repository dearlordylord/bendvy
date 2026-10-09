"""Source-only registered lifecycle; no consumer output is an input."""
import importlib.util,json,copy
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]/'oracle-v1'/'expected.py'
spec=importlib.util.spec_from_file_location('source_business_model',BASE)
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
SEED=['bundle.spawn','write:a','write:b','write:tag','write:value']
READ=['read:a','read:b','read:tag','read:value']
def registration(id,name,access):return {'id':id,'name':name,'access':access.copy()}
def registry(ns,id,name,access,cursor):return f'{ns}:{id}:{name}:'+b.show(access)+f':{cursor}'
def world_text(w):
 text=b.world_text(w)
 regs=[str(r['id'])+':'+r['name']+':'+b.show(r['access']) for r in w['registrations']]
 return text[:text.index('|registrations=')]+'|registrations='+b.show(regs)+'|nextSystem='+str(w['nextSystemId'])
def models():
 result=[]
 for old in b.models():
  m=copy.deepcopy(old);ns=m['namespace'];failed=m['mode']=='rollback'
  seed=registration(1,'bundle-seed',SEED);business=registration(2,'owned-commands',b.ACCESS)
  before=registration(3,'bundle-observe-before',READ);after=registration(4,'bundle-observe-after',READ)
  for key in ['before','after','teardown']:
   w=m[key];w['registrations']=([before,business,seed] if key=='before' else [after,before,business,seed]);w['nextSystemId']=4 if key=='before' else 5
  m['seedRegistry']=registry(ns,1,'bundle-seed',SEED,5)
  m['beforeObserverRegistry']=registry(ns,3,'bundle-observe-before',READ,m['before']['clock'])
  m['afterObserverRegistry']=registry(ns,4,'bundle-observe-after',READ,m['after']['clock'])
  m['registry']=registry(ns,2,'owned-commands',b.ACCESS,0 if failed else 6)
  m['text']=m['schema']+'-'+m['mode']+'|seed-registry='+m['seedRegistry']+'='+('Failed' if failed else 'Succeeded')+'|before='+m['beforePublic']+'|observer-registry='+m['beforeObserverRegistry']+'|after='+m['afterPublic']+'|observer-registry='+m['afterObserverRegistry']+'|registry='+m['registry']+'|teardown='+world_text(m['teardown'])+'|delivery='+('failed' if failed else m['delivery'])
  result.append(m)
 return result
def expected():return '\n'.join(m['text'] for m in models())+'\n'
if __name__=='__main__':
 (HERE/'expected.stdout').write_text(expected());(HERE/'expected.json').write_text(json.dumps(expected(),ensure_ascii=False,indent=2)+'\n');(HERE/'observations.json').write_text(json.dumps(models(),indent=2)+'\n')
