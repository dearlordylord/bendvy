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

def render(ns):
    world,foreign=query.World(ns,high=3),query.World(ns+1)
    world.replace(1,10);world.replace(2,20)
    owner=query.Owner(ns);cells=[100,101]
    text=row('registered',first.PLAN,True,world,foreign,owner,10,cells)
    query.invoke(world,owner,1,0);cells=[110,111]
    text+=row('before-removal-run:success:[phase:outer, ran:1, phase:inner, ran:2, barrier]',first.PLAN,True,world,foreign,owner,20,cells)
    text+='both-removed|'+world_text(world,20,'[]')+'|'+base.show_pack(owner.cells)+'|('+','.join(map(str,cells))+')\n'
    # Actual recovered Pack is re-registered via O.define: newID3,cursor0.
    # Same returned resource Array registers ID4; neither capture is reseeded.
    owner.cursor=0
    plan='(phase:reregistered:[],(system:3:0:[component:1],(system:4:0:[resource:2],barrier:[])))'
    regs='[4:resource-counter:[Counter], 3:captured-query:[Value, Value]]'
    text+=row('reregistered',plan,True,world,foreign,owner,20,cells,regs,qid=3,rid=4,sid=5).replace('nested-captures:','lifecycle:').replace('args=1:0:True,10:False:True','args=1:0:True,3:False:True')
    query.invoke(world,owner,1,0);cells=[113,114]
    text+=row('retry-new-ids:success:[phase:reregistered, ran:3, ran:4, barrier]',plan,True,world,foreign,owner,23,cells,regs,qid=3,rid=4,sid=5).replace('nested-captures:','lifecycle:').replace('args=1:0:True,10:False:True','args=1:0:True,3:False:True')
    assert owner.cells==[5,6,43,44] and owner.cursor==6 and world.clock==6
    assert world.values=={1:12,2:22} and world.stamps=={1:(1,5),2:(2,6)}
    assert text.count('both-removed|')==1 and text.count(':cursor=0:')==2
    return text

def expected():return ('Workshop\n'+render(1)+'Garden\n'+render(3)+'\n').encode()
def main():
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');a=p.parse_args();source_checks();raw=expected();assert raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')
    if a.write:(HERE/'normal.stdout').write_bytes(raw);(HERE/'normal.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    assert raw==(HERE/'normal.stdout').read_bytes()==gzip.decompress((HERE/'normal.stdout.gz').read_bytes())
    print(json.dumps({'status':'PASS','bytes':len(raw),'sha256':base.digest(raw)}))
if __name__=='__main__':main()
