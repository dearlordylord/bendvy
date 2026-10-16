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
    world.clock+=1
    owner=query.Owner(ns);counter=10;cells=[100,101]
    mode,revision,event_tick=1,1,3
    condition_cursor=condition_revision=0
    rows=[]
    def record(label,delta=10,fail=False):rows.append(deepcopy((label,delta,fail,world,foreign,owner,counter,cells,mode,revision,event_tick,condition_cursor,condition_revision)))
    def run(label,delta,fail=False):
        nonlocal condition_cursor,condition_revision,counter,cells
        # The actual tracked condition commits its current World cursor before
        # deciding whether the query leaf executes. False still observes revision.
        allowed=revision>condition_revision
        condition_cursor=world.clock;condition_revision=revision
        logs=['phase:outer']
        if allowed:
            query.invoke(world,owner,1,0);logs.append('ran:1')
        else:logs.append('skipped:1')
        logs+=['phase:inner','ran:2']
        cells=[v+delta for v in cells]
        if not fail:counter+=delta;logs.append('barrier')
        record(label+(':failure:resource:Failed:' if fail else ':success:')+base.show_list(logs),delta,fail)
    record('registered')
    run('first',10)
    run('unchanged-skip',1)
    world.clock+=1;mode,revision,event_tick=2,2,world.clock
    record('insert-state:2',1)
    run('state-changed',1)
    run('resource-failure',2,True)
    run('retry',3)
    record('foreign:refused:[]',3)
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
    for label,delta,fail,world,foreign,owner,counter,cells,mode,revision,tick,cc,cr in derive(ns):
        args='args=1:0:True,'+str(delta)+':'+('True' if fail else 'False')+':True'
        resource_owner=str(ns)+':2:resource-counter:[Counter]:('+','.join(map(str,cells))+')'
        text+='|'.join([label,'nested-captures:'+PLAN,args,world_text(world,counter,mode,revision,tick,True),world_text(foreign,10,None,0,0,False),query.owner_text(owner),resource_owner,'conditions='+conditions(ns,cc,cr)])+'\n'
    return text

def expected():return ('Workshop\n'+render(1)+'Garden\n'+render(3)+'\n').encode()
def selftest():
    for ns in [1,3]:
        rows=derive(ns)
        assert len(rows)==8
        assert [r[3].clock for r in rows]==[3,5,5,6,6,6,6,6]
        assert [r[5].cursor for r in rows]==[0,5,5,5,6,6,6,6]
        assert [r[11] for r in rows]==[0,3,5,5,6,6,6,6]
        assert [r[12] for r in rows]==[0,1,1,1,2,2,2,2]
        assert [r[6] for r in rows]==[10,20,21,21,22,22,25,25]
        assert [r[7] for r in rows]==[[100,101],[110,111],[111,112],[111,112],[112,113],[114,115],[117,118],[117,118]]
        assert all(r[5].cells==[3,4,23,24] for r in rows[1:])
        assert rows[-1][3:] == rows[-2][3:]
        assert rows[-1][3].values=={1:11,2:21}
        assert rows[-1][3].stamps=={1:(1,4),2:(2,5)}
        assert 'ran:1' in rows[4][0] # condition true even though query finds no rows
        assert 'skipped:1' in rows[5][0] and 'barrier' not in rows[5][0]
        assert rows[3][8:11]==(2,2,6)
    base.source_bindings()
    for name,h in json.loads((HERE/'model-basis.json').read_text())['modelHashes'].items():assert hashlib.sha256((HERE/name).read_bytes()).hexdigest()==h
    assert expected().count(b'\n')==19 and expected().endswith(b'\n\n')
def main():
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');a=p.parse_args();selftest();raw=expected()
    if a.write:(HERE/'normal.stdout').write_bytes(raw);(HERE/'normal.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    assert raw==(HERE/'normal.stdout').read_bytes()==gzip.decompress((HERE/'normal.stdout.gz').read_bytes())
    print(json.dumps({'status':'PASS','bytes':len(raw),'sha256':base.digest(raw),'snapshots':16}))
if __name__=='__main__':main()
