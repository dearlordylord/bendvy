"""Pure twelve-checkpoint oracle derived from current expanded source captures; no runtime input."""
from pathlib import Path
import gzip, hashlib, json
HERE=Path(__file__).resolve().parent

def render():
    # World.factory/create seed and Sys.register; all physical owners retained.
    fixed='ns=1/next=1/high=0/capacity=1/depth=0/live=L(False)/components=N(L(N(L(13),L(29))),L(L(47)))/resource=N(L(31),L(37))/slot=Boot:10/'
    tail='/previous=Pause:90/changed=True/events=[seed]/pending=1/registrations=[1:publisher:[Flow.next]]/nextSystem=2/clock=17/registry=1:1:publisher:[Flow.next]:cursor='
    pending=None
    missing=False
    cursor=0
    status="ok"
    lines=[]
    operations=[('initial',None,False),('forced',('Play',20,False),False),('conditional-equal',('Play',21,True),False),('different',('Pause',30,True),False),('reset','reset',False),('conditional',('Play',21,True),False),('forced-equal',('Play',20,False),False),('rollback',('Pause',30,True),True),('reset-again','reset',False),('missing-fixture','missing',False),('missing-set',('Play',21,True),False),('missing-reset','reset',False)]
    for label,request,fails in operations:
        old=pending
        if request=='missing':
            missing=True
        elif request:
            if request=='reset':
                pending=None
            elif not missing:
                kind,value,conditional=request
                if not (conditional and pending and pending[2] is False and pending[0]==kind):
                    pending=request
            if fails:
                pending=old
            else:
                cursor=17
            status='rollback' if fails else 'ok'
        shown='none' if pending is None else f'{pending[0]}:{pending[1]}:skip={"True" if pending[2] else "False"}'
        if missing:
            row=fixed.removesuffix('Boot:10/')+'missing'+tail.removeprefix('/previous=Pause:90/changed=True')
        else:
            row=fixed+shown+tail
        lines.append(label+':'+row+str(cursor)+'/status='+status+'\n')
    # CLI prints a String using JSON-compatible quotes and escaped newlines.
    return (json.dumps(''.join(lines),ensure_ascii=False)+'\n').encode()

if __name__=='__main__':
    data=render()
    with (HERE/'expanded-A-expected.stdout.gz').open('wb') as f:
        with gzip.GzipFile(fileobj=f,mode='wb',mtime=0,filename='') as z:z.write(data)
    (HERE/'EXPANDED-ORACLES.json').write_text(json.dumps({'A':{'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'sourceAttempt':'expanded-A-source01','runtimeInput':False}},indent=2)+'\n')
