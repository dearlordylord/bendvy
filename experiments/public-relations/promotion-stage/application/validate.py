"""Complete compound output parsing; no row/notice/owner field is ignored.
Development validator: scalar metadata literals are added after source audit.
"""
import json,re
from pathlib import Path
D=Path(__file__).resolve().parent
QUERIES=['other-optional','optional','outgoing','incoming','with-out','without-out','with-in','without-in','multi','cross-filters','empty']
PHASES=['initial',*[value for phase in range(5) for value in [f'queued-{phase}',f'applied-{phase}']]]
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
    live=[int(x) for x in text.split('|live=',1)[1].split(',') if x];assert len(live)==5 and set(live)<=set([0,1]);graphs=[]
    for key,name in [(1,'Link'),(2,'OtherLink'),(3,'Parent')]:
        targets={s:t for k,s,t in edges if k==key};sources={t:ids for k,t,ids in inverses if k==key}
        graphs.append({'key':key,'name':name,'targets':[targets.get(id) if live[id-1] else None for id in range(1,6)],'sources':[sources.get(id,[]) if live[id-1] else None for id in range(1,6)]})
    return graphs,edges,inverses,live

def notices(text):
    result=[];removed=[];despawned=[]
    value=text.split('|events=',1)[1].split('|meta=',1)[0]
    for notice in value.split(';'):
        if not notice:continue
        if notice.startswith('Removed:'):removed.append(int(notice.split(':')[1]));continue
        if notice.startswith('Original:'):
            id=int(notice.split(':')[1])-1000;assert 1<=id<=5,('unexpected diagnostic event',notice);despawned.append(id);continue
        parts=notice.split(':');assert parts[:8]==['Failure','1','Link','LinkedBy','ordinary','relate','2','2'],notice;assert parts[8:]==['SelfRelationNotAllowed','2','Link'],notice
        result.append({'operation':'relate','relation':'Link','source':2,'target':2,'error':{'_tag':'SelfRelationNotAllowed','entityId':2,'relation':'Link'}})
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
        assert all(set(x['rows'])==set(QUERIES) and 'retained' in x and 'graphs' in x for x in app['records'])
    return apps,physical

def validate(text,mutant=False):
    actual,physical=parse(text);expected=json.loads((D/'expected-v2.json').read_text());witnesses=[{'root':a['root'],'phase':x['phase'],'expected':y,'actual':x} for a,b in zip(actual,expected) for x,y in zip(a['records'],b['records']) if x!=y]
    assert bool(witnesses)==mutant,witnesses
    expected_meta=[2,4,5,7,8,10,11,13,14,16,17]
    expected_pending=[0,3,0,3,0,1,0,1,0,1,0]
    for root in ['Workshop','Other']:
        subject=[x for x in physical if x['root']==root];assert len(subject)==11
        for i,record in enumerate(subject):
            if not mutant:assert record['metadata']==f'1,6,5,8,3,77,{expected_meta[i]},0',record
            if not mutant:assert record['pending']==expected_pending[i],record
            if not mutant:assert record['stamps']==('3:0:0;' if 3<=i<=7 else ''),record
    return actual,physical,witnesses
