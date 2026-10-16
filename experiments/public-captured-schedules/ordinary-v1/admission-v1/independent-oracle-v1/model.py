from pathlib import Path
from copy import deepcopy
import argparse,gzip,json,hashlib
import first_model as first
import query_model as query
import base_model as base
HERE=Path(__file__).resolve().parent

def world_text(world,resource,regs,pending=0,sid=3):
    value=query.world_text(world).replace(',Unit,',','+str(resource)+',').replace('[1:captured-query:[Value, Value]]',regs)
    return value.replace('pending=0','pending='+str(pending)).replace(',2,'+str(world.clock)+'}',','+str(sid)+','+str(world.clock)+'}')
REGS='[2:resource-counter:[Counter], 1:captured-query:[Value, Value]]'
def qtext(owner,id=1):
    return query.owner_text(owner).replace(':1:captured-query:',':'+str(id)+':captured-query:')
def rtext(ns,cells,id=2):
    return str(ns)+':'+str(id)+':resource-counter:[Counter]:('+','.join(map(str,cells))+')'
def row(label,plan,enabled,world,foreign,owner,resource,cells,regs=REGS,pending=0,fregs='[]',qid=1,rid=2,sid=3):
    return '|'.join([label,'nested-captures:'+plan,'args=1:0:True,10:False:'+('True' if enabled else 'False'),world_text(world,resource,regs,pending,sid),world_text(foreign,10,fregs,0,3 if fregs!='[]' else 1),qtext(owner,qid),rtext(owner.namespace,cells,rid)])+'\n'
def source_checks():
    base.source_bindings()
    for name,digest in json.loads((HERE/'model-basis.json').read_text())['modelHashes'].items():assert hashlib.sha256((HERE/name).read_bytes()).hexdigest()==digest

def prefix(tail):return '(phase:must-not-enter:[],(barrier:[],'+tail+'))'
def render(ns):
    world,foreign=query.World(ns,high=3),query.World(ns+1)
    world.replace(1,10);world.replace(2,20)
    owner=query.Owner(ns);cells=[100,101]
    text='foreign-registered|'+world_text(foreign,10,REGS)+'|'+qtext(query.Owner(ns+1))+'|'+rtext(ns+1,cells)+'\n'
    plan=first.PLAN;enabled=True;regs=REGS;pending=1;resource=10
    def emit(label):return row(label,plan,enabled,world,foreign,owner,resource,cells,regs,pending,REGS)
    text+=emit('registered')+emit('foreign:refused:[]')
    cases=[('nested-duplicate',prefix('(system:1:0:[],(empty,system:1:0:[]))'),'refused:[]'),('missing-id',prefix('system:999:0:[]'),'refused:[]'),('nonzero-slot',prefix('system:1:7:[]'),'refused:[]'),('missing-unselected-requirements',prefix('system:2:0:[resource:99, service:99, resource:99]'),'missing:[resource:99, service:99]'),('empty','empty','success:[]')]
    for label,newplan,status in cases:
        plan=newplan
        text+=emit(label+':before') # snapshot before run resets args/flag
        enabled=False
        text+=emit(label+':'+status)
    regs='[1:captured-query:[Value, Value]]';plan=first.PLAN
    text+=emit('stale:True:before')+emit('stale:True:refused:[]')
    pending=0;resource=47
    text+=emit('terminal-drain')
    assert owner.cells==[1,2,3,4] and owner.cursor==0 and world.clock==2
    assert text.count('pending=1')==14 and text.count('terminal-drain|')==1
    assert ':missing:[resource:99, service:99]' in text
    return text

def expected():return ('Workshop\n'+render(1)+'Garden\n'+render(3)+'\n').encode()
def main():
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');a=p.parse_args();source_checks();raw=expected();assert raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')
    if a.write:(HERE/'normal.stdout').write_bytes(raw);(HERE/'normal.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    assert raw==(HERE/'normal.stdout').read_bytes()==gzip.decompress((HERE/'normal.stdout.gz').read_bytes())
    print(json.dumps({'status':'PASS','bytes':len(raw),'sha256':base.digest(raw)}))
if __name__=='__main__':main()
