"""Independent exact phase/variant expectations and complete raw-state checks.
Global graph entry list order is private; every key/source/target and inverse
source order is checked, including rejection of dead/out-of-domain entries.
"""
import json
from copy import deepcopy
from pathlib import Path
from validate import parse
D=Path(__file__).resolve().parent
META=[2,4,5,7,8,10,11,13,14,16,17]
PENDING=[0,3,0,3,0,1,0,1,0,1,0]
CASES=['normal','failed-notice-omitted','component-write-omitted','inverse-order-reversed']
def expected_case(case):
    assert case in CASES
    result=json.loads((D/'expected-v2.json').read_text())
    for app in result:
        for record in app['records']:
            if case=='failed-notice-omitted':record['failures']=[]
            if case=='component-write-omitted':
                for rows in record['rows'].values():
                    for row in rows:
                        if row['id']==3:row['component']=[300,30,31,32,33]
            if case=='inverse-order-reversed':
                for rows in [*record['rows'].values(),record['retained']]:
                    for row in rows:
                        for cell in row['cells']:
                            if isinstance(cell['value'],list):cell['value'].reverse()
                # Each record loads independent retained arrays from JSON; no
                # shared mutable row object is assumed by this oracle.
    return result

def validate(text,case='normal'):
    actual,physical=parse(text);expected=expected_case(case)
    assert actual==expected,[(a['root'],x['phase'],x,y) for a,b in zip(actual,expected) for x,y in zip(a['records'],b['records']) if x!=y]
    for app in expected:
        records=[p for p in physical if p['root']==app['root']];assert len(records)==11
        for i,(record,raw) in enumerate(zip(app['records'],records)):
            owners=[None]*8
            for row in record['rows']['empty']:owners[row['id']-1]=row['component']
            assert raw['owners']==owners,raw
            live=[1,1,1,1,1] if i<8 else [1,1,0,0,1] if i<10 else [0,0,0,0,1]
            assert raw['live']==live,raw
            edges={(g['key'],id+1):target for g in record['graphs'] for id,target in enumerate(g['targets']) if target is not None}
            inverses={(g['key'],id+1):sources for g in record['graphs'] for id,sources in enumerate(g['sources']) if sources}
            assert {(k,s):t for k,s,t in raw['edges']}==edges,raw
            assert {(k,t):ids for k,t,ids in raw['inverses']}==inverses,raw
            tick=1 if i>=3 and case!='component-write-omitted' else 0
            assert raw['metadata']==f'1,6,5,8,3,77,{META[i]},{tick}',raw
            assert raw['pending']==PENDING[i],raw
            assert raw['stamps']==('3:0:1;' if 3<=i<=7 and case!='component-write-omitted' else ''),raw
    witnesses=[]
    normal=json.loads((D/'expected-v2.json').read_text())
    for app,old in zip(actual,normal):
        if case=='normal':continue
        phase={'inverse-order-reversed':'initial','failed-notice-omitted':'applied-1','component-write-omitted':'queued-1'}[case]
        got=next(r for r in app['records'] if r['phase']==phase);want=next(r for r in old['records'] if r['phase']==phase)
        if case=='inverse-order-reversed':
            field='rows.optional[entity=1].sources';select=lambda r:next(c['value'] for row in r['rows']['optional'] if row['id']==1 for c in row['cells'] if c['key']=='sources')
        elif case=='failed-notice-omitted':field='failures';select=lambda r:r['failures']
        else:field='rows.empty[entity=3].component';select=lambda r:next(row['component'] for row in r['rows']['empty'] if row['id']==3)
        assert select(got)!=select(want),(case,app['root'],phase,field)
        witnesses.append({'root':app['root'],'phase':phase,'field':field,'normal':select(want),'mutant':select(got)})
    assert len(witnesses)==(0 if case=='normal' else 2)
    return actual,physical,witnesses
