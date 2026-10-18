"""Finite TS record oracle from approved shared observation and pinned Runtime clocks.
This does not load/execute TypeScript, Node, Bend, or a subject-produced artifact.
"""
import hashlib,json
from common_model import compact
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
def four(x):return [x[k]for k in ['a','b','c','d']]
def ledger(x):return {'totals':four(x['totals']),'epoch':x['epoch']}
def row(x,ids):
 assert x['main']['kind']=='Found';m=x['main']['value'];a=x['aux'];f=x['flag']
 return {'rawId':ids[x['actor']],'main':{'levels':four(m['levels']),'reserve':m['reserve'],'class':m['class']},'aux':None if a['kind']=='Absent'else {'layers':four(a['value']['layers']),'grade':a['value']['grade']},'flag':None if f['kind']=='Absent'else f['value']}
def clocks():
 # Runtime.ts runSystem advances once before callback; successful event publication
 # advances once in commitSystemTransaction; applyDeferred advances once.
 # advanceFrame increments frameCount but does not change world.tick.
 frame=tick=0;diagnostics=[];outcomes=[]
 def begin():
  nonlocal frame;frame+=1
 def system(who=None,iteration=-1,mode='prime',failed=False,publish=False):
  nonlocal tick;tick+=1
  if who=='B':diagnostics.append({'iteration':iteration,'mode':mode,'frame':frame,'tick':tick,'outcome':'failed'if failed else 'ok','missed':[]})
  if publish and not failed:tick+=1
 def barrier():
  nonlocal tick;tick+=1
 def done(failed=False):outcomes.append({'ok':False,'error':{'kind':'SystemFailure','system':'B','error':{'code':7}}}if failed else {'ok':True,'value':{'kind':'Undefined'}})
 begin();system();barrier();done() # Seed+applyDeferred
 begin();system('B');system();done() # Same B and Publications prime
 for i in range(64):
  begin();system(publish=True);system('B',i,'fail',True);done(True)
  begin();system();done() # Observe failure boundary
  begin();system();done() # Publications after failure
  begin();system('B',i,'retry',publish=True);done()
  begin();system();done() # Observe retry boundary
  begin();system();done() # Publications after retry
  begin();barrier();done()
  begin();system();done() # Observe applied boundary
  begin();system();barrier();done() # Dispose+barrier
  begin();system();done() # Observe disposed boundary
 assert len(diagnostics)==129 and frame==642 and len(outcomes)==642
 return diagnostics,outcomes

def full(fixture):
 records=fixture['records'];callbacks=[r for r in records if r['kind']=='Callback'];boundaries=[r for r in records if r['kind']=='Boundary'];final=records[-1];assert final['kind']=='Final'
 # Independent TS allocator: internal world starts its raw ID counter at1 and
 # increments at every actual commands.spawn reservation, including failed B.
 # Iterate the observed reservation chronology, not count+3*iteration formulas.
 next_id=1;ids={};table=[]
 def reserve(actor):
  nonlocal next_id;assert actor not in ids;ids[actor]=next_id;table.append({'actor':actor,'rawId':next_id});next_id+=1
 for actor in records[0]['actors']:reserve(actor)
 for r in callbacks:
  if r['reservation']is not None:reserve(r['reservation']['actor'])
 assert len(ids)==256
 reservations=[]
 for i in range(64):
  selected=[r for r in callbacks if r['iteration']==i];assert len(selected)==3
  reservations.append({'iteration':i,'A':ids[selected[0]['reservation']['actor']],'failedB':ids[selected[1]['reservation']['actor']],'retryB':ids[selected[2]['reservation']['actor']]})
 reads=[{'iteration':-1 if r['mode']=='Prime'else r['iteration'],'mode':r['mode'].lower(),'capture':r['capture'],'messages':r['reading']['messages'],'lagged':r['reading']['lagged']}for r in callbacks if r['who']=='B']
 audit=[]
 for r in boundaries:
  actual_rows=[row(x,ids)for x in r['rows']];lookups=[x for x in [r['pendingA'],r['latestFailed'],r['retryB']]if x is not None]
  original={'iteration':r['iteration'],'stage':r['phase'],'count':len(actual_rows),'rowsSha256':sha(compact(actual_rows)),'ledger':ledger(r['ledger']),'lookups':[{'rawId':ids[x['actor']],'result':'Found'if x['result']['kind']=='Found'else 'MissingEntity'if x['result']['kind']=='Missing'else 'ComponentAbsent'}for x in lookups],'captures':r['captures']}
  # New complete actual rows and full lookup payloads supplement original hashes/tags.
  original.update(rows=actual_rows,fullLookups=lookups,allFailed=r['allFailed'])
  audit.append(original)
 actual_final=[row(x,ids)for x in final['rows']];diagnostics,outcomes=clocks()
 return {'schema':'Health','workload':'failed-transaction','count':64,'iterations':64,'status':'PASS','capacity':65536,'registration':'B and independent publication observer invoked after seed/barrier, before A publication; priming consumes one B capture','captures':final['captures'],'reservations':reservations,'reads':reads,'diagnostics':diagnostics,'audit':audit,'effects':[json.loads(x)for x in final['effects']],'retainedLiveCount':len(actual_final),'finalSha256':sha(compact(actual_final)),'ledger':ledger(final['ledger']),'scope':'Correctness only; same actual B instance fails/retries, earlier A survives, full inverse restoration/publication discard/pending and allocation observations checked; no timing.','method':{'rawActorMap':table,'records':[compact(x)for x in records],'rawTickOutcomes':outcomes,'finalRows':actual_final}}
