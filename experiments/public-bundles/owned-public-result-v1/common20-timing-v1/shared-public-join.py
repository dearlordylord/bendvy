"""Complete literal gates first; then alltwenty matching public query projections."""
from pathlib import Path
import json,re
HERE=Path(__file__).parent
MODES=['spawn-insert','invalid-return','invalid-retry','rollback','cleanup']
def rows(text):
 slots=text.split('/')
 if len(slots)!=2:raise ValueError('Exactly two full handle probes required')
 out=[]
 for id,slot in enumerate(slots,1):
  fields=slot.split(':')
  if fields==['missing']*4:continue
  if len(fields)!=4 or fields[2]!='tag':raise ValueError('Unexpected partial/missing typed row')
  stock=json.loads(fields[0]);back=json.loads(fields[1]);value=json.loads(fields[3])
  if type(stock)is not list or type(back)is not list or type(value)is not int or any(type(x)is not int for x in stock+back):raise ValueError('Whole numeric component values required')
  out.append({'id':id,'stock':stock,'back':back,'tag':{},'value':value})
 return out
def compare(bend,ts):
 bend_expected=json.loads((HERE/'registered-lifecycle-v1/oracle-v1/expected.json').read_bytes())
 ts_expected=json.loads((HERE/'ts-semantic-v1/oracle-v1/expected.json').read_bytes())
 if type(bend)is not str or bend!=bend_expected:raise ValueError('Entire Bend lifecycle oracle differs before projection')
 if type(ts)is not str or ts!=ts_expected:raise ValueError('Entire TS lifecycle oracle differs before projection')
 applications=json.loads(ts);lines=bend.splitlines()
 if len(lines)!=10 or len(applications)!=10:raise ValueError('Allten lifecycles required')
 joined=[]
 for i,(line,app) in enumerate(zip(lines,applications)):
  schema='A' if i<5 else 'B';mode=MODES[i%5]
  if app['schema']!=schema or app['mode']!=mode or not line.startswith(schema+'-'+mode+'|seed-registry='):raise ValueError('Exact lifecycle identity/order required')
  if [c['label'] for c in app['checkpoints']]!=['before','after']:raise ValueError('Both checkpoint labels required')
  for checkpoint in app['checkpoints']:
   match=re.search(r'\|'+checkpoint['label']+r'=([^|]+)\|observer-registry=',line)
   if match is None:raise ValueError('Complete registered observer slot missing')
   actual=rows(match.group(1))
   if actual!=checkpoint['rows']:raise ValueError('Entire public query rows differ')
   joined.append({'schema':schema,'mode':mode,'checkpoint':checkpoint['label'],'rows':actual})
 return {'status':'FULL_LIFECYCLE_ORACLES_AND_20_PUBLIC_PROJECTIONS_EQUAL','checkpoints':joined,'scope':'Entire backend-specific lifecycle strings validatedfirst; projection is additional semanticcorrespondence, notwork/ownership normalization or timingqualification'}
