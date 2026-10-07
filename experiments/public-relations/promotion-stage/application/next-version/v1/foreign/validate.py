"""Complete two-owner physical and public-query assertions, preserving namespaces."""
import re,json
from model import applications
QUERIES=['other-optional','optional','outgoing','incoming','with-out','without-out','with-in','without-in','multi','cross-filters','empty']
def handles(text,namespace):
    result=[]
    for value in text.split(','):
        if not value:continue
        match=re.fullmatch(rf'{namespace}:(\d+)',value);assert match,('foreign or malformed projected handle',value);result.append(int(match[1]))
    return result

def rows(text,namespace):
    result=[]
    for row in text.split('|'):
        if not row:continue
        match=re.fullmatch(str(namespace)+r':(\d+)\[([0-9,]*)\]\{(.*)\}',row);assert match,row
        cells=[]
        for cell in match[3].split(';'):
            if not cell:continue
            key,value=cell.split('=',1)
            if value=='none':value=None
            elif value.startswith('['):value=handles(value[1:-1],namespace)
            else:ids=handles(value,namespace);assert len(ids)==1;value=ids[0]
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


def validate(text,case):
    expected_apps=applications(case)
    for app in expected_apps:
        for rec in app['records']:rec.pop('retained')
    result=[];physical=[];root=None;record=None;frontend={}
    for line in text.splitlines():
        if line in ['Workshop','Other']:
            root=line;result.append({'root':root,'sourceIds':[1,2,3,4,5],'peerIds':[1,2,3,4,5],'records':[]});continue
        if re.fullmatch(r'(local|peer)-(before|queued|applied)',line):
            role,phase=line.split('-');record={'root':root,'role':role,'phase':phase,'rows':{}};result[-1]['records'].append(record);continue
        if line.startswith('frontend='):
            assert root not in frontend;frontend[root]=line.split('=',1)[1];continue
        if line.startswith('fields='):
            value=line.split('=',1)[1];record['graphs'],edges,inverses,live=graph_fields(value);failed,removed,despawned=notices(value)
            assert failed==removed==despawned==[];record['failures']=[]
            ns=1 if record['role']=='local' else 2
            owners=[None if x=='absent' else [int(v) for v in x.split(',') if v] for x in value.split('|',1)[0].split(';') if x]
            assert owners==[[100,10],[200,20,21],[300,30,31,32,33],[400,*range(40,48)],None,None,None,None]
            assert live==[1,1,1,1,1,0]
            meta=[int(x) for x in value.split('|meta=',1)[1].split('|pending=',1)[0].split(',')]
            index=['before','queued','applied'].index(record['phase'])
            assert meta==[ns,6,5,8,3,77,2+index,0],(record,meta)
            pending=int(value.split('|pending=',1)[1]);expected_pending=int(record['role']=='local' and record['phase']=='queued' and case!='seeded-command-omitted')
            if case=='foreign-namespace-erased' and record['role']=='local' and record['phase']=='queued':expected_pending+=1
            assert pending==expected_pending
            assert value.split('|stamps=',1)[1].split('|',1)[0]==''
            expected=applications(case)[['Workshop','Other'].index(root)]['records'][len(result[-1]['records'])-1]
            expected_edges=[(k,i+1,t) for g in expected['graphs'] for k in [g['key']] for i,t in enumerate(g['targets']) if t is not None]
            expected_inverse=[(g['key'],i+1,ids) for g in expected['graphs'] for i,ids in enumerate(g['sources']) if ids]
            assert sorted(edges)==sorted(expected_edges) and sorted(inverses)==sorted(expected_inverse)
            physical.append({'root':root,'role':record['role'],'phase':record['phase'],'namespace':ns,'owners':owners,'edges':edges,'inverses':inverses,'live':live,'metadata':meta,'pending':pending})
            continue
        if '=' in line:
            key,value=line.split('=',1);assert key in QUERIES and key not in record['rows'];record['rows'][key]=rows(value,1 if record['role']=='local' else 2);continue
        assert not line.strip(),line
    for app in result:
        assert [(r['role'],r['phase']) for r in app['records']]==[(role,phase) for phase in ['before','queued','applied'] for role in ['local','peer']]
        for record in app['records']:
            assert set(record['rows'])==set(QUERIES)
        assert frontend[app['root']]==('Queued' if case=='foreign-namespace-erased' else 'MissingEntity')
    assert result==expected_apps,(result,expected_apps)
    witnesses=[]
    if case!='normal':
        for i,root in enumerate(['Workshop','Other']):
            actual=result[i]['records'][4];normal=applications()[i]['records'][4]
            assert actual['graphs']!=normal['graphs'];witnesses.append({'root':root,'role':'local','phase':'applied','field':'Link.targets','expectedNormal':normal['graphs'][0]['targets'],'actualVariant':actual['graphs'][0]['targets']})
    return result,physical,witnesses
