"""Complete compound output parsing; no row/notice/owner field is ignored.
Development validator: scalar metadata literals are added after source audit.
"""
import json,re
from pathlib import Path
D=Path(__file__).resolve().parent
QUERIES=['other-optional','optional','outgoing','incoming','with-out','without-out','with-in','without-in','multi','cross-filters','empty']
PHASES=['initial',*[value for phase in [0,1,2,5,6,3,4] for value in [f'queued-{phase}',f'applied-{phase}']]]
def handles(text):
    result=[]
    for value in text.split(','):
        if not value:continue
        match=re.fullmatch(r'1:(\d+)',value);assert match,('foreign or malformed projected handle',value);result.append(int(match[1]))
    return result

def rows(text):
    result=[]
    for row in text.split('|'):
        if not row:continue
        match=re.fullmatch(r'1:(\d+)\[([0-9,]*)\]\{(.*)\}',row);assert match,row
        cells=[]
        for cell in match[3].split(';'):
            if not cell:continue
            key,value=cell.split('=',1)
            if value=='none':value=None
            elif value.startswith('['):value=handles(value[1:-1])
            else:ids=handles(value);assert len(ids)==1;value=ids[0]
            cells.append({'key':key,'value':value})
        result.append({'id':int(match[1]),'component':[int(x) for x in match[2].split(',') if x],'cells':cells})
    return result

def graph_fields(text):
    edges=[];inverses=[]
    for value in text.split('graph-edges=',1)[1].split('|graph-inverses=',1)[0].split(';'):
        if not value:continue
        key,name,inverse,kind,source,target=value.split(':');assert (int(key),name,inverse,kind) in [(1,'Link','LinkedBy','ordinary'),(2,'OtherLink','OtherIncoming','ordinary'),(3,'Parent','Children','hierarchy')];edges.append((int(key),int(source),int(target)))
    encoded=text.split('|graph-inverses=',1)[1].split('|live=',1)[0]
    for value in encoded.split(';'):
        if not value:continue
        match=re.fullmatch(r'(\d+):([^:]+):([^:]+):(ordinary|hierarchy):(\d+):\[([0-9,]*)\]',value);assert match,value
        key,name,inverse,kind,target,sources=match.groups();assert (int(key),name,inverse,kind) in [(1,'Link','LinkedBy','ordinary'),(2,'OtherLink','OtherIncoming','ordinary'),(3,'Parent','Children','hierarchy')];inverses.append((int(key),int(target),[int(x) for x in sources.split(',') if x]))
    assert len({(k,s) for k,s,t in edges})==len(edges),'duplicate outgoing state';assert len({(k,t) for k,t,ids in inverses})==len(inverses),'duplicate inverse state'
    live=[int(x) for x in text.split('|live=',1)[1].split(',') if x];assert len(live)==6 and set(live)<=set([0,1]);graphs=[]
    for key,name in [(1,'Link'),(2,'OtherLink'),(3,'Parent')]:
        targets={s:t for k,s,t in edges if k==key};sources={t:ids for k,t,ids in inverses if k==key}
        graphs.append({'key':key,'name':name,'targets':[targets.get(id) if live[id-1] else None for id in range(1,int(text.split('|meta=',1)[1].split(',')[2])+1)],'sources':[sources.get(id,[]) if live[id-1] else None for id in range(1,int(text.split('|meta=',1)[1].split(',')[2])+1)]})
    return graphs,edges,inverses,live

def notices(text):
    result=[];removed=[];despawned=[]
    value=text.split('|events=',1)[1].split('|meta=',1)[0]
    for notice in value.split(';'):
        if not notice:continue
        if notice.startswith('Removed:'):removed.append(int(notice.split(':')[1]));continue
        if notice.startswith('Original:'):
            id=int(notice.split(':')[1])-1000;assert 1<=id<=6;despawned.append(id);continue
        p=notice.split(':');assert p[:6]==['Failure','1','Link','LinkedBy','ordinary','relate'];source,target=int(p[6]),int(p[7]);tag=p[8]
        if tag=='SelfRelationNotAllowed':assert p[9:]==[str(source),'Link'];error={'_tag':tag,'entityId':source,'relation':'Link'}
        else:assert tag=='MissingTargetEntity' and p[9:]==[str(source),str(target),'Link'];error={'_tag':tag,'entityId':source,'targetId':target,'relation':'Link'}
        result.append({'operation':'relate','relation':'Link','source':source,'target':target,'error':error})
    return result,removed,despawned

def parse(text):
    apps=[];current=None;phase=None;retained=None;physical=[]
    for line in text.splitlines():
        if line in ['Workshop','Other']:
            current={'root':line,'records':[]};apps.append(current);phase=None;continue
        if line in PHASES:
            assert current is not None;phase={'root':current['root'],'phase':line,'rows':{}};current['records'].append(phase);continue
        if line.startswith('retained='):
            retained=rows(line.split('=',1)[1]);
            for record in current['records']:record['retained']=retained
            continue
        if line.startswith('system='):
            assert phase is not None and 'systemResult' not in phase;status=line.split('=',1)[1];assert status in ['none','SystemFailure:relation-write-5:903'];phase['systemResult']=None if status=='none' else {'kind':'SystemFailure','system':'relation-write-5','error':903};continue
        if line.startswith('fields='):
            assert phase is not None;value=line.split('=',1)[1];phase['graphs'],edges,inverses,live=graph_fields(value);phase['failures'],phase['removed'],phase['despawned']=notices(value)
            owner_text=value.split('|',1)[0];owners=[]
            for cell in owner_text.split(';'):
                if cell=='':continue
                owners.append(None if cell=='absent' else [int(x) for x in cell.split(',') if x])
            assert len(owners)==8 and owners[5:]==[None,None,None];assert phase['rows']['empty']==[{'id':i+1,'component':owner,'cells':[]} for i,owner in enumerate(owners[:5]) if owner is not None and live[i]]
            physical.append({'root':current['root'],'phase':phase['phase'],'owners':owners,'edges':edges,'inverses':inverses,'live':live,'stamps':value.split('|stamps=',1)[1].split('|',1)[0],'metadata':value.split('|meta=',1)[1].split('|pending=',1)[0],'pending':int(value.split('|pending=',1)[1].split('|',1)[0])})
            continue
        if '=' in line:
            name,value=line.split('=',1);assert name in QUERIES and phase is not None and name not in phase['rows'];phase['rows'][name]=rows(value);continue
        assert not line,('unparsed output',line)
    assert [x['root'] for x in apps]==['Workshop','Other']
    for app in apps:
        assert [x['phase'] for x in app['records']]==PHASES
        assert all(set(x['rows'])==set(QUERIES) and 'retained' in x and 'graphs' in x and 'systemResult' in x for x in app['records'])
    return apps,physical


import importlib.util
spec=importlib.util.spec_from_file_location('independent_variants',D/'variant-model.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
CASES=['normal','failed-notice-omitted','component-write-omitted','inverse-order-reversed','rollback-omitted','future-order-reversed']
META=[2,4,5,7,8,10,11,13,14,16,17,19,20,22,23]
PENDING=[0,3,0,3,0,1,0,0,0,2,0,1,0,1,0]
def validate(text,case='normal'):
    assert case in CASES
    actual,physical=parse(text);expected=[{'root':root,'records':model.records(root,case)} for root in ['Workshop','Other']]
    assert actual==expected,[(a['root'],x['phase'],x,y) for a,b in zip(actual,expected) for x,y in zip(a['records'],b['records']) if x!=y]
    for app in expected:
        records=[p for p in physical if p['root']==app['root']];assert len(records)==15
        for i,(record,raw) in enumerate(zip(app['records'],records)):
            owners=[None]*8
            for row in record['rows']['empty']:owners[row['id']-1]=row['component']
            assert raw['owners']==owners,raw
            live=[1,1,1,1,1,int(i>=10)] if i<12 else [1,1,0,0,1,1] if i<14 else [0,0,0,0,1,1]
            assert raw['live']==live,raw
            edges={(g['key'],id+1):target for g in record['graphs'] for id,target in enumerate(g['targets']) if target is not None}
            inverses={(g['key'],id+1):sources for g in record['graphs'] for id,sources in enumerate(g['sources']) if sources}
            assert {(k,s):t for k,s,t in raw['edges']}==edges,raw
            assert {(k,t):ids for k,t,ids in raw['inverses']}==inverses,raw
            tick=0 if case=='component-write-omitted' or i<3 else 1 if i<7 else 2
            assert raw['metadata']==f'1,{6 if i<9 else 7},{5 if i<9 else 6},8,3,77,{META[i]},{tick}',raw
            assert raw['pending']==PENDING[i],raw
            changed=2 if case=='rollback-omitted' and i>=7 else 1
            assert raw['stamps']==(f'3:0:{changed};' if 3<=i<=11 and case!='component-write-omitted' else ''),raw
    witnesses=[]
    normal=json.loads((D/'expected.json').read_text())
    for app,old in zip(actual,normal):
        if case=='normal':continue
        phase={'inverse-order-reversed':'initial','failed-notice-omitted':'applied-1','component-write-omitted':'queued-1','rollback-omitted':'queued-5','future-order-reversed':'applied-6'}[case]
        got=next(r for r in app['records'] if r['phase']==phase);want=next(r for r in old['records'] if r['phase']==phase)
        if case=='inverse-order-reversed':field='rows.optional[entity=1].sources';select=lambda r:next(c['value'] for row in r['rows']['optional'] if row['id']==1 for c in row['cells'] if c['key']=='sources')
        elif case=='failed-notice-omitted':field='failures';select=lambda r:r['failures']
        elif case=='future-order-reversed':field='Link.target[entity=5]';select=lambda r:r['graphs'][0]['targets'][4]
        else:field='rows.empty[entity=3].component';select=lambda r:next(row['component'] for row in r['rows']['empty'] if row['id']==3)
        assert select(got)!=select(want),(case,app['root'],phase,field)
        witnesses.append({'root':app['root'],'phase':phase,'field':field,'normal':select(want),'mutant':select(got)})
    assert len(witnesses)==(0 if case=='normal' else 2)
    return actual,physical,witnesses
