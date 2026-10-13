"""Independent source-only complete22 models; never consumes evaluated output."""
import copy,json,runpy
from pathlib import Path
BASE=Path(__file__).resolve().parents[3]/'oracle-v1/expected.py'
B=runpy.run_path(str(BASE));c=B['c'];some=B['some'];owner=B['owner'];incoming=B['incoming'];meta=B['meta'];snapshot=B['snapshot'];invalid=B['invalid'];UNIT=B['UNIT'];SEED=B['CANON']
def handle(ns):return c('Handle',namespace=ns,id=4)
def cases(required):
 access=['constructed-raw-owner','constructed-raw-resource'];registration=c('RegistrationMeta',id=1,name='constructed-materialization',access=access);seed=owner(SEED)
 def snap(nextId=2,live=None,clock=1,slots=None,stamps=None,pending=0,retired=None,returned=None,errors=None):
  return c('Snapshot',meta=meta(nextId,nextId-1,2 if nextId==2 else 4,1 if nextId==2 else 2,clock,[registration],2),live=[False,True] if live is None else live,column=c('ColumnView',supported=True,slots=[some(seed)] if slots is None else slots,stamps=[c('Entry',id=1,stamp=c('Stamp',added=1,changed=1))] if stamps is None else stamps),mail=c('MailView',value=owner(B['number'](100)),retired=retired or [],returned=returned or [],errors=errors or []),pending=pending)
 def report(mode):
  raw=handle(2 if mode in ('invalid','invalidSpawn') else 1);bad=raw['namespace']!=required;spawn=(mode in ('spawn','failure','invalidSpawn')) and not bad;failed=mode in ('failure','failedInsert');skip=mode=='skip';late=mode=='lateMissing';packet=c('PacketView',owner=some(owner(raw,raw,True)),original=raw,canonical=raw)
  output=c('Refused',owner=some(incoming(raw)),error=c('Validation',error=invalid(raw,expected='same-world handle'))) if bad else c('Accepted',target=c('Handle',namespace=1,id=2 if spawn else 1),spawned=spawn,canonical=raw,undoAvailable=True)
  recoveries=[c('RecoveryView',output=output,packets=[] if bad else [packet])] if failed else []
  instance=c('InstanceView',namespace=1,id=1,name='constructed-materialization',access=access,recoveries=recoveries)
  before=snap(pending=1 if late else 0);committed=snap(nextId=3 if spawn and not skip else 2,live=[False,True,False,False] if spawn and not skip else None,pending=(1 if late else 0)+(0 if bad or skip or failed else 2 if spawn else 1));barrier=copy.deepcopy(committed);barrier['pending']=0
  if late:
   barrier['live']=[False,False]
   if not bad:barrier['mail']['returned']=[packet];barrier['mail']['errors']=[c('MissingEntity')]
  elif not (bad or skip or failed):
   barrier['meta']['clock']=2
   if spawn:barrier['live']=[False,True,True,False];barrier['column']['slots']=[some(seed),some(owner(raw,raw,True))];barrier['column']['stamps']=[c('Entry',id=2,stamp=c('Stamp',added=2,changed=2)),c('Entry',id=1,stamp=c('Stamp',added=1,changed=1))]
   else:barrier['column']['slots']=[some(owner(raw,raw,True))];barrier['column']['stamps']=[c('Entry',id=1,stamp=c('Stamp',added=1,changed=2))];barrier['mail']['retired']=[seed]
  result=c('Failed',error=UNIT) if failed else c('Skipped',input=incoming(raw)) if skip else c('Completed',output=output)
  return c('Report',before=before,committed=committed,barrier=barrier,instance=instance,result=result)
 return c('Cases',**{m:report(m)for m in ['spawn','insert','failure','failedInsert','invalid','invalidSpawn','lateMissing','skip']})
def resources():
 def report(ns,abort=False):
  raw=handle(ns);bad=ns!=1;result=c('Refused',owner=owner(raw),error=invalid(raw,expected='same-world handle')) if bad else c('Replaced',canonical=raw)
  return c('ResourceReport',before=snapshot(),after=snapshot(resource=owner(B['number'](100)) if bad or abort else owner(raw)),result=result,outcome=c('Failure',error=UNIT) if abort else c('Success'),pending=0,undoCount=0 if bad else 1)
 return c('Resources',valid=report(1),invalid=report(2),rollback=report(1,True))
def expected(required=1):return c('Candidate',first=cases(required),second=cases(required),firstResource=resources(),secondResource=resources())
if __name__=='__main__':
 for name,n in [('expected.json',1),('mutant-expected.json',2)]:Path(__file__).with_name(name).write_text(json.dumps(expected(n),indent=2)+'\n')
