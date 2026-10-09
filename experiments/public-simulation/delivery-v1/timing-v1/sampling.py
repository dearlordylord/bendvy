"""Existing paired feature scope: grouped fresh lifecycles, no numerical verdict."""
import json,random,statistics
from pathlib import Path
def schedule(contract, scales=(1,2,4)):
    if contract['pairs']!=20 or contract['warmups']!=2 or contract['seed']!=20261007:raise ValueError('unchanged sampling contract required')
    if list(scales) not in [[1],[2,4],[1,2,4]]:raise ValueError('approved staged lifecycle scales required')
    rng=random.Random(contract['seed']);rows=[]
    def add(label,role,scale,index,pair=None,backend=None,order=None):rows.append({'label':label,'role':role,'lifecycles':scale,'lifecycle':index,'pair':pair,'backend':backend,'order':order})
    for scale in [1,2,4]:
        for role in ['TS','JS','Native']:
            for warmup in range(contract['warmups']):
                for i in range(scale):add(f'scale{scale}-{role}-warmup{warmup}-life{i}',role,scale,i)
        for backend in ['JS','Native']:
            orders=[['TS',backend]]*10+[[backend,'TS']]*10;rng.shuffle(orders)
            for pair,order in enumerate(orders):
                for role in order:
                    for i in range(scale):add(f'scale{scale}-{backend}-pair{pair}-{role}-life{i}',role,scale,i,pair,backend,order)
    return [row for row in rows if row['lifecycles'] in scales]

def summarize(rows,commands):
    observations={r['label']:r for r in rows};groups={}
    if len(observations)!=len(rows):raise ValueError('duplicate sampling label')
    for command in commands:
        spec=observations[command['label']]
        if spec['pair']is None:continue
        metric=json.loads(bytes.fromhex(command['stderr']['rawHex']))
        key=(spec['lifecycles'],spec['backend'],spec['pair']);group=groups.setdefault(key,{'order':spec['order'],'TS':[],'candidate':[]})
        group['TS'if spec['role']=='TS'else'candidate'].append(metric)
    result=[]
    for scale in sorted({row['lifecycles'] for row in rows}):
        for backend in ['JS','Native']:
            pairs=[]
            for pair in range(20):
                group=groups[(scale,backend,pair)]
                if len(group['TS'])!=scale or len(group['candidate'])!=scale:raise ValueError('complete fresh lifecycle group required')
                sums={role:sum(int(m['simulationNs'])for m in group[role])for role in ['TS','candidate']}
                if sums['TS']<=0:raise ValueError('positive reference timer required')
                pairs.append({'pair':pair,'order':group['order'],'simulationNs':sums,'ratio':sums['candidate']/sums['TS'],'transportNs':{role:sum(int(m['transportNs'])for m in group[role])for role in ['TS','candidate']}})
            result.append({'lifecycles':scale,'backend':backend,'medianPairedRatio':statistics.median(p['ratio']for p in pairs),'allPairs':pairs})
    return {'scope':'Complete separately reset application lifecycle group sums; no same-process world scaling/statistical verdict/#28 change','summary':result}
