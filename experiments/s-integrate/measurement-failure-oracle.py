"""Complete actual full-field observations vs freshly executed pinned TS case."""
import hashlib,json,re

def compact(v):return json.dumps(v,separators=(',',':'),ensure_ascii=False)
def sha(v):return hashlib.sha256(compact(v).encode()).hexdigest()
def norm(v):
 if isinstance(v,list):return [norm(x) for x in v]
 if isinstance(v,dict):
  if set(v)==set('abcd'):return [v[k] for k in 'abcd']
  return {k:norm(x) for k,x in v.items()}
 return v
def handle(h):
 assert set(h)=={'namespace','id'} and type(h['namespace']) is int and type(h['id']) is int,h
 assert h['namespace']==1,h
 return h['id']
def row(r):return {'rawId':handle(r['handle']),'main':norm(r['main']),'aux':norm(r['aux']),'flag':norm(r['flag'])}
def expected_main(schema,values):return {'coordinates':values,'frame':7} if schema=='Motion' else {'levels':values,'reserve':9,'class':2}
def validate(output,reference):
 schema=reference['schema'];count=reference['count'];iterations=reference['iterations']
 assert reference['status']=='PASS' and iterations==64
 observations=[];events=[];reads=[];effects=[];results=[];counts=None;capture={'A':0,'B':0};audits=[]
 pattern=re.compile(r'^FAILURE-READ:(\d+):([^:]+):(\d+):(.+):(True|False):(\d+):(\d+)$')
 for line in output.splitlines():
  if line.startswith('FAILURE-READ:'):
   match=pattern.fullmatch(line);assert match,line
   i,who,c,messages,lag,tick,frame=match.groups();reads.append({'iteration':int(i),'who':who,'capture':int(c),'messages':json.loads(messages),'lagged':lag=='True','tick':int(tick),'frame':int(frame)})
  elif line.startswith('FAILURE-OBSERVE:'):
   observed=json.loads(line[len('FAILURE-OBSERVE:'):]);assert observed['schema']==schema
   observed_rows=[row(x) for x in observed['rows']];observed_ledger=norm(observed['ledger'])
   i=observed['iteration'];phase=observed['phase'];retry=phase!='failed-before-barrier'
   expected=[]
   for j in range(count):
    values=[j,j+1,j+2,j+3]
    if j==0:values[0]=i+1
    if j==1:values[0]=1+30*(i+int(retry))
    aux=({'rates':[1,2,3,4],'moving':True} if schema=='Motion' else {'layers':[1,2,3,4],'grade':3}) if j%3==0 else None
    expected.append({'rawId':j+1,'main':expected_main(schema,values),'aux':aux,'flag':{'group':8} if j%3==1 else None})
   p=count+3*i+1;q=p+1;r=p+2
   if phase=='applied-FIFO':
    expected.extend([{'rawId':p,'main':expected_main(schema,[i,20,30,40]),'aux':None,'flag':None},{'rawId':r,'main':expected_main(schema,[i,200,300,400]),'aux':None,'flag':None}])
   assert observed_rows==expected,{'subject':'every full row field','schema':schema,'count':count,'iteration':i,'phase':phase,'first_difference':next(({'index':k,'actual':a,'expected':b} for k,(a,b) in enumerate(zip(observed_rows,expected)) if a!=b),{'actual_length':len(observed_rows),'expected_length':len(expected)})}
   expected_ledger={'totals':[i*101+1 if not retry else (i+1)*101,101,102,103],'epoch':4}
   assert observed_ledger==expected_ledger,{'subject':'full ledger','actual':observed_ledger,'expected':expected_ledger}
   lookup_values=[]
   wanted_ids=[p,q]+([] if not retry else [r])+[count+3*k+2 for k in reversed(range(i+1))]
   actual_ids=[handle(x['handle']) for x in observed['lookups']];assert actual_ids==wanted_ids,{'subject':'actual allocation/raw lookup targets','actual':actual_ids,'expected':wanted_ids}
   for lookup in observed['lookups']:
    raw=handle(lookup['handle']);actual=lookup['result'];found=next((x for x in expected if x['rawId']==raw),None)
    if found is None:assert actual=={'kind':'Missing'},{'subject':'failed/stale/pending lookup','actual':actual,'raw':raw}
    else:assert actual['kind']=='Found' and row(actual['value'])==found,{'subject':'full live lookup','actual':actual,'expected':found}
    lookup_values.append({'rawId':raw,'result':'Found' if found else 'MissingEntity'})
   # TS emits current p/q/r; history is separately checked above, like its loop.
   ts_audit=reference['audit'][len(audits)];actual_audit={'iteration':i,'stage':phase,'count':len(observed_rows),'rowsSha256':sha(observed_rows),'ledger':observed_ledger,'lookups':lookup_values[:2+int(retry)],'captures':dict(capture)}
   assert actual_audit==ts_audit,{'subject':'fresh TS full-field audit','actual':actual_audit,'expected':ts_audit}
   audits.append(actual_audit);observations.append(observed)
  elif line.startswith('FAILURE-EVENTS:'):events.extend(json.loads(line[len('FAILURE-EVENTS:'):]))
  elif line.startswith('FAILURE-RESULT:'):results.append(line)
  elif line.startswith('FAILURE-COUNTS:'):
   raw,frame=line[len('FAILURE-COUNTS:'):].rsplit(':',1);counts={x['system']:x['value'] for x in json.loads(raw)};assert int(frame)==2+10*iterations
  elif line.startswith('{'):
   effect=json.loads(line);assert set(effect)=={'who','iteration','capture'},effect
   effects.append(effect);capture[effect['who']]=effect['capture']
  else:raise AssertionError({'unrecognized actual output':line})
 assert len(observations)==4*iterations and len(results)==2+10*iterations
 assert effects==reference['effects']
 assert counts['A']=={'a':iterations,'b':0,'c':0,'d':0} and counts['B']=={'a':1+2*iterations,'b':0,'c':0,'d':0}
 b=[x for x in reads if x['who']=='B'];pub=[x for x in reads if x['who']=='PublicationObserver'];assert len(b)==1+2*iterations and len(pub)==1+2*iterations
 source_reads=reference['reads'];source_diag=reference['diagnostics']
 for n,actual in enumerate(b):
  mode='prime' if n==0 else 'fail' if n%2 else 'retry';i=-1 if n==0 else (n-1)//2
  mapped={k:actual[k] for k in ['capture','messages','lagged']};mapped={'iteration':i,'mode':mode,**mapped}
  assert mapped==source_reads[n],{'subject':'actual same-instance B public read','actual':mapped,'expected':source_reads[n]}
  diagnostic={'iteration':i,'mode':mode,'frame':actual['frame'],'tick':actual['tick'],'outcome':'failed' if mode=='fail' else 'ok','missed':['messages'] if actual['lagged'] else []}
  assert diagnostic==source_diag[n],{'subject':'actual B diagnostic clock/lag/outcome','actual':diagnostic,'expected':source_diag[n]}
 for n,actual in enumerate(pub):
  wanted=[] if n==0 else [{'code':n-1}];assert actual['messages']==wanted and not actual['lagged'],{'subject':'independent actual Publications','actual':actual,'expected':wanted}
 reserved=[e for e in events if e['kind']=='Reserved'];own=[e for e in events if e['kind']=='OwnWrites'];assert len(reserved)==3*iterations and len(own)==3*iterations
 for n,(reservation,writes) in enumerate(zip(reserved,own)):
  i=n//3;which=n%3;who='A' if which==0 else 'B';label=['p','q','r'][which];raw=count+3*i+which+1
  assert reservation['label']==label and handle(reservation['handle'])==raw
  assert norm(reservation['components'])=={'main':expected_main(schema,[i,*([20,30,40] if which==0 else [200,300,400])]),'aux':None,'flag':None}
  assert writes['system']==who
  views=writes['views'];main=[v['value']['value'] for v in views if v['kind']=='Main'];offsets=[i+1] if which==0 else [1+30*i+10,1+30*i+30]
  field='position' if schema=='Motion' else 'vitals';variant='MotionMain' if schema=='Motion' else 'HealthMain'
  assert len(main)==len(offsets)
  for view,value in zip(main,offsets):assert view=={'kind':variant,field:dict(expected_main(schema,[value,*([1,2,3] if which==0 else [2,3,4])]))} or norm(view)=={'kind':variant,field:expected_main(schema,[value,*([1,2,3] if which==0 else [2,3,4])])}
  ledger=[norm(v['value']) for v in views if v['kind']=='Ledger'];assert ledger==[{'totals':[i*101+1 if which==0 else (i+1)*101,101,102,103],'epoch':4}]
  assert [v['value'] for v in views if v['kind']=='ReservedLookup']==[{'kind':'Missing'}]
 # Lossless range/formula summaries are emitted only after every actual value was checked.
 return {'status':'FULL_VALUES_EQUAL','schema':schema,'count':count,'iterations':iterations,'full_row_fields_checked':sum(len(x['rows']) for x in observations),'historical_and_current_lookups_checked':sum(len(x['lookups']) for x in observations),'audit':audits,'captures':reference['captures'],'reservations':reference['reservations'],'actual_reads':reads,'actual_effects':effects,'actual_output_sha256':hashlib.sha256(output.encode()).hexdigest(),'actual_output_bytes':len(output.encode()),'lossless_encoding':'Rows exactly the pinned TS source formula; all actual complete rows/lookup results/payloads/own reads verified before encoding. Raw reservation IDs preserved.'}
