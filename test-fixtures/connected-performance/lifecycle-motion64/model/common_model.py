"""Source-state projections. Role foreign results intentionally remain unequal."""
import copy,json,sys,importlib.util
from pathlib import Path
P=Path(__file__).parent
sys.path[:0]=[str(P/'source/lc1-v1'),str(P/'source')]
import capture,records,shared
spec=importlib.util.spec_from_file_location('lc2_codec',P/'source/lc2-v1/codec.py')
sys.path.insert(0,str(P/'source/lc2-v1'))
LC2=importlib.util.module_from_spec(spec);spec.loader.exec_module(LC2)
compact=lambda v:json.dumps(v,separators=(',',':'),ensure_ascii=False)
def cells(values):
 def nat(n):return list(map(ord,str(n)))+[0]
 out=nat(len(values))
 for v in values:
  s=compact(v);out+=nat(len(s))+list(map(ord,s))
 return out
def fold(values):
 n=0
 for v in values:n=(n*33+v)&0xffffffff
 return n
def ledger(values):return {'totals':list(values),'epoch':4}
def row(value,actor):
 h,m,a,f=value
 return {'actor':actor(h),'main':{'kind':'Found','value':{'coordinates':list(m),'frame':7}},'aux':{'kind':'Absent'}if a is None else {'kind':'Found','value':{'rates':list(a),'moving':True}},'flag':{'kind':'Absent'}if f is None else {'kind':'Found','value':{'group':f}}}
def raw_row(value):
 return {'rawId':value['actor'],'main':value['main']['value'],'aux':None if value['aux']['kind']=='Absent'else value['aux']['value'],'flag':None if value['flag']['kind']=='Absent'else value['flag']['value']}
def derive(primary,foreign):
 v=capture.run(64,64,primary,foreign);p=v['final'];logical=shared.compare_program(p);assert logical['captures']==[64,64,64,192];keys=list(p.initial_handles)+list(p.frame.reservations)
 assert len(keys)==len(set(keys))==128
 actor=lambda h:None if h is None else keys.index(h)+1
 foreign_handle=v['foreign_reservation'];foreign_actor=lambda h:1 if h==foreign_handle else (_ for _ in()).throw(AssertionError('foreign identity'))
 setup={'actor':foreign_actor(foreign_handle),'rows':[row(r,foreign_actor)for r in v['foreign_verified'].rows()],'ledger':ledger(v['foreign_verified'].ledger)}
 common=[{'kind':'Seed','count':64,'actors':[actor(h)for h in p.initial_handles],'foreign':setup}]
 carriers={'bend':[],'ts':[]};boundaries=[]
 for i in range(64):
  # Existing six real schedule results each Complete. Boundary occurs inside Observe,
  # before its enclosing stage result is returned to the caller.
  for stage in range(6):
   log=p.typed_logs[i*6+stage];stage_status=['Success','BodyFailed','Refused','Invalid'][log['status']]
   if stage in [1,3,5]:
    b=p.boundaries[i*3+[1,3,5].index(stage)];f=b.frame
    r={'kind':'Boundary','iteration':f.iteration,'phase':f.phase,'target':actor(f.target),'current':actor(f.pending),'reservations':[actor(h)for h in f.reservations],'rows':[row(x,actor)for x in b.rows],'ledger':ledger(b.ledger),'currentKind':b.lookups[0],'targetKind':b.lookups[1],'stale':[{'actor':actor(h),'kind':k}for h,k in b.stale]}
    common.append(r);boundaries.append(r)
    rawforeign={'world':'foreign','actor':1,'namespace':foreign_handle.namespace,'index':foreign_handle.key.index,'generation':foreign_handle.key.generation}
    carriers['bend'].append({'kind':'ForeignProbe','iteration':i,'phase':f.phase,'foreign':rawforeign,'result':{'kind':'LookupKind','value':b.lookups[2]}})
    # TS getHandle uses receiver raw ID, with actual current live main row lookup.
    collision=next((x for x in r['rows']if x['actor']==1),None)
    carriers['ts'].append({'kind':'ForeignProbe','iteration':i,'phase':f.phase,'foreign':{'world':'foreign','actor':1,'rawId':1},'result':{'kind':'MissingEntity'}if collision is None else {'kind':'Found','row':raw_row(collision)}})
   common.append({'kind':'Stage','iteration':i,'stage':stage,'outcome':{'kind':stage_status}})
 last=boundaries[-1]
 common.append({'kind':'Final','rows':copy.deepcopy(last['rows']),'ledger':copy.deepcopy(last['ledger']),'current':last['current'],'target':last['target'],'reservations':list(last['reservations']),'stale':copy.deepcopy(last['stale']),'status':{'kind':['Complete','BodyFailed','Refused','Invalid'][records.state(p)['status']]}})
 assert len(common)==578 and all(len(x)==192 for x in carriers.values())
 assert [actor(h)for h in p.world.main_handles()]==[r['actor']for r in last['rows']]
 # Actual final world unchanged since last observer, including lookup read paths.
 assert p.world.wire()==p.boundaries[-1].after
 actor_map=[{'actor':i+1,'namespace':h.namespace,'index':h.key.index,'generation':h.key.generation}for i,h in enumerate(keys)]
 return {'common':common,'foreign':carriers,'actors':actor_map,'captured':v,'typed':records.report(64,64,primary,foreign)}
