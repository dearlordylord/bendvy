"""Pure four-checkpoint oracle derived from ordinary-frontend A-source02; no runtime input."""
from pathlib import Path
import gzip, hashlib, json
HERE=Path(__file__).resolve().parent

def render():
    # World.factory/create seed and Sys.register; all physical owners retained.
    fixed='ns=1/next=1/high=0/capacity=1/depth=0/live=L(False)/components=N(L(N(L(13),L(29))),L(L(47)))/resource=N(L(31),L(37))/slot=Boot:10/'
    tail='/previous=Pause:90/changed=True/events=[seed]/pending=1/registrations=[1:publisher:[Flow.next]]/nextSystem=2/clock=17/registry=1:1:publisher:[Flow.next]:cursor='
    pending=None
    cursor=0
    lines=[]
    operations=[('initial',None,False),('forced',('Play',20,False),False),('conditional-same',('Play',21,True),False),('rollback',('Pause',30,True),True)]
    for label,request,fails in operations:
        old=pending
        if request:
            kind,value,conditional=request
            if not (conditional and pending and pending[2] is False and pending[0]==kind):
                pending=request
            if fails:
                pending=old
            else:
                cursor=17
        shown='none' if pending is None else f'{pending[0]}:{pending[1]}:skip={"True" if pending[2] else "False"}'
        lines.append(label+':'+fixed+shown+tail+str(cursor)+'/status='+('rollback' if fails else 'ok')+'\n')
    # CLI prints a String using JSON-compatible quotes and escaped newlines.
    return (json.dumps(''.join(lines),ensure_ascii=False)+'\n').encode()

if __name__=='__main__':
    data=render()
    with (HERE/'A-expected.stdout.gz').open('wb') as f:
        with gzip.GzipFile(fileobj=f,mode='wb',mtime=0,filename='') as z:z.write(data)
    (HERE/'ORACLES.json').write_text(json.dumps({'A':{'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'sourceAttempt':'A-source02','runtimeInput':False}},indent=2)+'\n')
