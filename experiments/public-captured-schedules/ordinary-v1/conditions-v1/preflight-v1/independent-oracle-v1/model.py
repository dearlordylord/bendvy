"""Independent stateful condition / heterogeneous captured schedule oracle."""
from pathlib import Path
from copy import deepcopy
import argparse,gzip,json,hashlib
import first_model as first
import query_model as query
import base_model as base
HERE=Path(__file__).resolve().parent
PLAN=first.PLAN.replace('[component:1]','[component:1, resource:3]')
REGS='[3:mode-changed:[machine.Mode.changed], 2:resource-counter:[Counter], 1:captured-query:[Value, Value]]'

def derive(ns):
    world,foreign=query.World(ns,high=3),query.World(ns+1)
    world.replace(1,10);world.replace(2,20)
    owner=query.Owner(ns);counter=10;cells=[100,101]
    mode,revision,event_tick=None,0,0
    cc=cr=0;plan=PLAN;rd=10;regs=REGS;rows=[]
    def record(label):rows.append(deepcopy((label,rd,False,world,foreign,owner,counter,cells,mode,revision,event_tick,cc,cr,plan,regs)))
    record('registered-missing-mode')
    # Missing actual slot returns present=False, but successful condition read
    # consumes current revision0 and records actual World clock2.
    cc=2;rd=1;counter=11;cells=[101,102]
    record('missing-mode-false:success:[phase:outer, skipped:1, phase:inner, ran:2, barrier]')
    world.clock+=1;mode,revision,event_tick=1,1,3
    record('insert-state:1')
    record('missing-condition-token:missing:[resource:3]')
    plan='(phase:must-not-enter:[],('+PLAN+',system:3:0:[]))'
    record('condition-id-plan')
    record('condition-id-refused:refused:[]')
    plan=PLAN
    record('restore-plan')
    cc=3;cr=1;query.invoke(world,owner,1,0);counter=12;cells=[102,103]
    record('admitted:success:[phase:outer, ran:1, phase:inner, ran:2, barrier]')
    regs='[2:resource-counter:[Counter], 1:captured-query:[Value, Value]]'
    record('remove-condition-registration:True')
    record('stale-condition-refused:refused:[]')
    return rows

def state_text(mode,revision,tick):
    if mode is None:return 'missing:[]:[]:0:0:0:[]:0:revision=0'
    return str(mode)+':none:none:True:[]:['+str(tick)+':1:[initial:'+str(mode)+']]:1:0:1:[]:0:revision='+str(revision)

def world_text(world,counter,mode,revision,tick,primary):
    text=query.world_text(world).replace(',Unit,',','+str(counter)+':'+state_text(mode,revision,tick)+',')
    text=text.replace('[1:captured-query:[Value, Value]]',REGS if primary else '[]')
    return text.replace(',2,'+str(world.clock)+'}',','+('4' if primary else '1')+','+str(world.clock)+'}')

def conditions(ns,cursor,revision):
    return '1:'+str(ns)+':3:mode-changed:[machine.Mode.changed]:cursor='+str(cursor)+':revision='+str(revision)+';2:True:descriptions=[1:mode-changed:[machine.Mode.changed]:[changed:'+str(ns)+':3:mode-changed:[machine.Mode.changed]], 2:True:[]:[constant:True]]'

def render(ns):
    text=''
    for label,delta,fail,world,foreign,owner,counter,cells,mode,revision,tick,cc,cr,plan,regs in derive(ns):
        args='args=1:0:True,'+str(delta)+':'+('True' if fail else 'False')+':True'
        resource_owner=str(ns)+':2:resource-counter:[Counter]:('+','.join(map(str,cells))+')'
        text+='|'.join([label,'nested-captures:'+plan,args,world_text(world,counter,mode,revision,tick,True).replace(REGS,regs),world_text(foreign,10,None,0,0,False),query.owner_text(owner),resource_owner,'conditions='+conditions(ns,cc,cr)])+'\n'
    return text

def expected():return ('Workshop\n'+render(1)+'Garden\n'+render(3)+'\n').encode()
def selftest():
    for ns in [1,3]:
        rows=derive(ns);assert len(rows)==10
        assert [r[3].clock for r in rows]==[2,2,3,3,3,3,3,5,5,5]
        assert [r[5].cursor for r in rows]==[0,0,0,0,0,0,0,5,5,5]
        assert [r[11] for r in rows]==[0,2,2,2,2,2,2,3,3,3]
        assert [r[12] for r in rows]==[0,0,0,0,0,0,0,1,1,1]
        assert rows[2][3:13]==rows[3][3:13]
        assert rows[4][3:]==rows[5][3:]
        assert rows[-1][3:]==rows[-2][3:]
        assert rows[-1][3].values=={1:11,2:21}
        assert rows[-1][3].stamps=={1:(1,4),2:(2,5)}
        assert rows[-1][5].cells==[3,4,23,24]
        assert rows[-1][6:8]==(12,[102,103])
        assert rows[-1][14]=='[2:resource-counter:[Counter], 1:captured-query:[Value, Value]]'
    base.source_bindings()
    for name,h in json.loads((HERE/'model-basis.json').read_text())['modelHashes'].items():assert hashlib.sha256((HERE/name).read_bytes()).hexdigest()==h
    assert expected().count(b'\n')==23 and expected().endswith(b'\n\n')

def main():
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');a=p.parse_args();selftest();raw=expected()
    if a.write:(HERE/'normal.stdout').write_bytes(raw);(HERE/'normal.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    assert raw==(HERE/'normal.stdout').read_bytes()==gzip.decompress((HERE/'normal.stdout.gz').read_bytes())
    print(json.dumps({'status':'PASS','bytes':len(raw),'sha256':base.digest(raw),'snapshots':20}))
if __name__=='__main__':main()
