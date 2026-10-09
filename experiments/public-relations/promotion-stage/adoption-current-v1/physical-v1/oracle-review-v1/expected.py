"""Independent complete source-derived physical/rollback oracle; no output input."""
from pathlib import Path
import json,gzip,hashlib
HERE=Path(__file__).resolve().parent
PAYLOADS=[(100,[10]),(200,[20,21]),(300,[30,31,32,33]),(400,list(range(40,48)))]
def ids(values):return ''.join(str(x)+','for x in values)
OWNERS=''.join(ids([tag,*cells])+';'for tag,cells in PAYLOADS)
LIVE=[False,True,True,True,True,False,False,False]
def world(namespace,resource,linked=False,pending=0):
 graph='3,:'if linked else ':'
 edge='1:Link:LinkedBy:Ordinary:3:1;'if linked else ''
 inverse='1:Link:LinkedBy:Ordinary:1:3,;'if linked else ''
 return OWNERS+'|'+graph+'|events=|meta='+ids([namespace,5,4,8,3,resource,2,0])[:-1]+'|pending='+str(pending)+'|columnVariant=Column|columnSize=8|columnSlots='+OWNERS+'absent;absent;absent;absent;'+'|lifecycle=1:7:9;|edges='+edge+'|inverseRows='+inverse+'|liveSize=8|liveBits='+''.join(('True'if x else 'False')+','for x in LIVE)+'|registrations=1:foreign-provider:relation:Link:write,;'
def expected():
 lines=[]
 for schema in ['Workshop','Other']:
  lines.extend([schema,'before|'+world(1,77),'second|'+world(2,88)])
  lines.extend(operation+'=MissingEntity'for operation in ['relate-source','relate-target','unrelate','reorder-parent','reorder-child','cleanup'])
  lines.extend(['queued|'+world(1,77,pending=1),'second|'+world(2,88),'after|'+world(1,77,linked=True),'second|'+world(2,88),'rollback-command=Queued','rollback-resource-before=999','rollback-outcome=Failure:99','rollback|'+world(1,77,linked=True),'second|'+world(2,88),'rollback-barrier|'+world(1,77,linked=True),'second|'+world(2,88)])
 return ('\n'.join(lines)+'\n').encode()
if __name__=='__main__':
 raw=expected();(HERE/'expected.stdout').write_bytes(raw)
 with (HERE/'complete-expected.txt.gz').open('wb')as target:
  with gzip.GzipFile(fileobj=target,mode='wb',mtime=0)as stream:stream.write(raw)
 print(len(raw),len(raw.splitlines()),hashlib.sha256(raw).hexdigest())
