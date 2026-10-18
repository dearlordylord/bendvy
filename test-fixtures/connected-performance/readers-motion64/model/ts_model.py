"""Independent logical evaluator of pinned readers() TS story, no TS execution."""
import copy,hashlib
from common_model import compact
sha=lambda v:hashlib.sha256(compact(v).encode()).hexdigest()
def logical_row(actor,index,seeded=True):
 return {'actor':actor,'main':{'kind':'Found','value':{'coordinates':[index,index+1,index+2,index+3],'frame':7}},'aux':{'kind':'Found','value':{'rates':[1,2,3,4],'moving':True}}if seeded and index%3==0 else {'kind':'Absent'},'flag':{'kind':'Found','value':{'group':8}}if seeded and index%3==1 else {'kind':'Absent'}}
def raw_row(v):return {'rawId':v['actor'],'main':v['main']['value'],'aux':None if v['aux']['kind']=='Absent'else v['aux']['value'],'flag':None if v['flag']['kind']=='Absent'else v['flag']['value']}
def evaluate(count=64,iterations=64):
 assert count in (64,256,1024) and iterations==64
 live={i+1:logical_row(i+1,i)for i in range(count)};actors=list(live);transients=[];cursor={who:{'message':-1,'removed':-1}for who in ['Fast','Slow']};records=[{'kind':'SeedActors','actors':list(actors)}];audit=[];diagnostics=[];outcomes=[];frame=tick=0
 ok={'ok':True,'value':{'kind':'Undefined'}}
 def begin():
  nonlocal frame;frame+=1
 def system(publish=False):
  nonlocal tick;tick+=1
  if publish:tick+=1
 def barrier():
  nonlocal tick;tick+=1
 def done():outcomes.append({'frame':frame,'tick':tick,'outcome':ok})
 def stage(name,i):records.append({'kind':'Stage','stage':name,'iteration':i,'outcome':{'kind':'Success'}})
 def read(who,phase,i):
  system();rows=copy.deepcopy(list(live.values()));upper=-1 if phase=='Prime'else iterations-1 if phase=='Drain'else i-1;iteration=-1 if phase=='Prime'else iterations-1 if phase=='Drain'else i
  changed=rows if phase=='Prime'else []if phase=='Drain'else [copy.deepcopy(live[transients[-1]])]
  removed=[{'actor':a}for a in transients[cursor[who]['removed']+1:upper+1]]
  messages=[{'code':n}for n in range(cursor[who]['message']+1,iteration+1)]
  r={'kind':'Read','who':who,'phase':phase,'iteration':i,'rows':rows,'added':changed,'changed':copy.deepcopy(changed),'ping':{'values':messages,'lagged':False},'removed':{'values':removed},'despawned':{'values':copy.deepcopy(removed)},'status':{'kind':'Success'}};records.append(r)
  actualrows=[raw_row(x)for x in rows]
  audit.append({'who':who,'phase':phase.lower(),'iteration':iteration,'count':len(rows),'rowsSha256':sha(actualrows),'added':[x['actor']for x in changed],'changed':[x['actor']for x in changed],'removed':[x['actor']for x in removed],'despawned':[x['actor']for x in removed],'messages':messages,'lagged':False})
  diagnostics.append({'who':who,'phase':phase.lower(),'iteration':iteration,'frame':frame,'tick':tick,'outcome':'ok','missed':[]})
  cursor[who]={'message':iteration,'removed':upper}
 begin();system();barrier();done() # original Seed+barrier
 begin();read('Fast','Prime',None);read('Slow','Prime',None);done();stage('Prime',None)
 for i in range(iterations):
  begin();system();actor=len(actors)+1;actors.append(actor);transients.append(actor);live[actor]=logical_row(actor,i,False);barrier();done();stage('SpawnBarrier',i)
  begin();system(publish=True);live[actor]['main']['value']['coordinates'][0]+=1;read('Fast','Read',i)
  if i%4==3:read('Slow','Read',i)
  done();stage('UpdateReaders',i)
  begin();system();barrier();del live[actor];done();stage('DisposeBarrier',i)
 begin();read('Fast','Drain',None);read('Slow','Drain',None);done();stage('Drain',None)
 begin();system();done() # original actual Dump query+Ledger before end
 final={'rows':[raw_row(v)for v in live.values()],'ledger':{'totals':[0,101,102,103],'epoch':4}}
 records.append({'kind':'Final','rows':copy.deepcopy(list(live.values())),'ledger':final['ledger'],'status':{'kind':'Complete'}})
 assert len(records)==280 and len(audit)==84 and len(outcomes)==196 and frame==196 and tick==471
 full={'schema':'Motion','workload':'readers','count':count,'iterations':iterations,'status':'PASS','capacity':65536,'registration':'same Fast and Slow instances first invoked after seed+barrier, before first transient publication','initialPublicDiagnostics':diagnostics[:2],'diagnostics':diagnostics,'audit':audit,'finalSha256':sha(final),'retainedLiveCount':count,'rawTransientRange':[count+1,count+iterations],'finalLogicalUnread':{who:{'messages':[],'removed':[],'despawned':[]}for who in ['Fast','Slow']},'unreadEvidence':'Both instances drain at the final boundary; no private cursor or physical log occupancy is inspected. Subsequent empty reads are not yet performed.','scope':'Correctness only; actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.','method':{'rawActorMap':[{'actor':a,'rawId':a}for a in actors],'rawTickOutcomes':outcomes,'referenceExpectationCursors':cursor,'records':[compact(r)for r in records],'finalRows':final['rows'],'ledger':final['ledger']}}
 return records,full
