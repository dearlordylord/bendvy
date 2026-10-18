"""Pinned TS logical execution and raw lookup/tick supplements; no TS execution."""
import hashlib
from common_model import compact,raw_row
sha=lambda v:hashlib.sha256(compact(v).encode()).hexdigest()
def full(f):
 count=f['common'][0]['count'];iterations=64;common=f['common'];boundaries=[r for r in common if r['kind']=='Boundary'];final=common[-1];audit=[];supplements=[]
 for r,foreign in zip(boundaries,f['foreign']['ts']):
  rows=[raw_row(x)for x in r['rows']];phase=r['phase'];pending=r['current']if phase==0 else None
  def lookup(actor):
   found=next((x for x in rows if x['rawId']==actor),None)
   return {'kind':'MissingEntity'}if found is None else {'kind':'Found','row':found}
  assert (r['currentKind']==2)==(lookup(r['current'])['kind']=='Found')
  assert (r['targetKind']==2)==(lookup(r['target'])['kind']=='Found')
  history=[{'rawId':s['actor'],'result':lookup(s['actor'])}for s in r['stale']]
  assert all(x['result']['kind']=='MissingEntity'for x in history)
  audit.append({'label':str(r['iteration'])+':'+['pending','live','disposed'][phase],'count':len(rows),'sha256':sha(rows),'pending':pending,'staleCount':len(history),'lastStale':None if not history else history[-1]['rawId'],'foreign':'receiver-local-collision'if foreign['result']['kind']=='Found'else 'MissingEntity'})
  supplements.append({'iteration':r['iteration'],'phase':phase,'rows':rows,'ledger':r['ledger'],'current':{'rawId':r['current'],'result':lookup(r['current'])},'target':{'rawId':r['target'],'result':lookup(r['target'])},'stale':history,'foreign':foreign['result']})
 ok={'ok':True,'value':{'kind':'Undefined'}}
 # Runtime tick begins one frame; each system callback advances tick once,
 # each applyDeferred advances tick once. Lookup supplements do not advance it.
 ticks=[{'frame':1,'tick':2,'outcome':ok}];frame=1;tick=2
 for i in range(64):
  for stage in range(6):
   frame+=1;tick+=2 if stage==4 else 1
   ticks.append({'frame':frame,'tick':tick,'outcome':ok})
 assert len(ticks)==385 and tick==450
 rows=[raw_row(x)for x in final['rows']]
 return {'schema':'Motion','workload':'lifecycle','count':count,'iterations':64,'status':'PASS','fullBoundaryChecks':len(audit),'retainedLiveCount':len(rows),'rawReservationRange':[1,count+iterations],'finalSha256':sha(rows),'audit':audit,'scope':'Correctness only; no timings. Actual reserve, pending lookup/query, barriers, rotating first/middle/last remove/despawn, full surviving fields, stale and foreign lookup.','foreignLookup':'Pinned TS raw-ID collision behavior retained separately; Bend MissingEntity divergence is approved, not a TS parity expectation.','method':{'rawActorMap':[{'actor':i,'rawId':i}for i in range(1,count+iterations+1)],'foreignActorMap':[{'actor':1,'rawId':1}],'foreignSetup':{'rows':[raw_row(x)for x in common[0]['foreign']['rows']],'ledger':common[0]['foreign']['ledger']},'foreignTicks':[{'frame':1,'tick':2,'outcome':ok},{'frame':2,'tick':3,'outcome':ok}],'rawTickOutcomes':ticks,'observations':supplements,'finalRows':rows}}
