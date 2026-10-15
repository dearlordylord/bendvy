#!/usr/bin/env python3
"""Source-shaped physical observation renderer; no final fixture output sealed."""
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('frozen_fragment_primitives',HERE.parent/'fullcapacity-scheduled-oracle-v7/successor-v9/verify.py')
doc=importlib.util.module_from_spec(spec)
spec.loader.exec_module(doc)
j=lambda value:json.dumps(value,separators=(',',':'))

def graph(value):
    def inverse(v):return doc.O([('relation',doc.scalar(v['relation'])),('target',doc.scalar(v['target'])),('sources',doc.flatarray(v['sources']))])
    return doc.O([('edges',doc.flatarray(value['edges'])),('inverses',doc.A(value['inverses'],inverse))])
doc.graph=graph

def view(value):
    return doc.P([doc.T('{"query":'),doc.flatarray(value['query']),doc.T(',"eventA":'),doc.eventview(value['eventA']),
                  doc.T(',"added":'),doc.T(j(value['added'])),doc.T(',"changed":'),doc.T(j(value['changed'])),
                  doc.T(',"removals":'),doc.flatarray(value['removals']),doc.T(',"relations":'),doc.A(value['relations'],doc.reading),doc.T('}')])

def row(value):
    kind=value['kind']
    if kind=='reader':
        text='{"kind":"reader","reader":'+j(value['reader'])
        if value.get('status')=='failed':text+=',"status":"failed","error":'+j(value['error'])
        return doc.P([doc.T(text+',"cursor":'),doc.scalar(value['cursor']),doc.T(',"view":'),view(value['view']),doc.T(',"world":'),doc.world(value['world']),doc.T('}')])
    if kind=='scheduleOutcome':return doc.P([doc.T('{"kind":"scheduleOutcome","status":'),doc.scalar(value['status']),doc.T(',"observations":'),doc.T(j(value['observations'])),doc.T('}')])
    return doc.row(value)

def quoted_row(value):return doc.P([doc.T('"'),row(value),doc.T('"')])

def pack(root):
    budget=visits=0;fragments=[];chunks=[];count=0
    def flush():
        nonlocal fragments,count
        if count:chunks.append(''.join(fragments));fragments=[];count=0
    for kind,text in root:
        if kind=='parts':budget+=2;visits+=2
        elif kind=='child':budget+=1;visits+=1
        else:
            budget+=3;visits+=2;length=len(text)
            assert text.isascii()
            if not length:continue
            if count+length>4096:
                if count:flush();visits+=1
                if length>4096:chunks.append(text);continue
            fragments.append(text);count+=length
    flush();visits+=1
    assert visits<=budget
    return chunks,{'fuel':budget,'loopVisits':visits,'chunks':len(chunks),'maxChunkBytes':max(map(len,chunks),default=0)}

def render(rows,final,scenario='ordinary-scheduled-failure-retry'):
    root=doc.P([doc.T('{"scenario":'+j(scenario)+',"trace":'),doc.A(rows,quoted_row),doc.T(',"final":'),doc.image(final),doc.T('}')])
    chunks,stats=pack(root)
    wire=(''.join(chunks)+'\n').encode()
    direct=('{"scenario":'+j(scenario)+',"trace":['+','.join('"'+j(value)+'"' for value in rows)+'],"final":'+j(final)+'}\n').encode()
    assert wire==direct
    return wire,stats

if __name__=='__main__':
    import bend_state
    state=bend_state.State();state.writer_begin();state.enqueue_spawn(42);state.enqueue_spawn(43);state.writer_success();state.barrier()
    observed=state.read('fast',1,1)
    rows=[{'kind':'reader','reader':'fast','cursor':state.query['fast'],'view':observed,'world':state.world()}]
    wire,stats=render(rows,state.image())
    assert b'"found":42' in wire and b'"added":[{"namespace":1,"id":1},{"namespace":1,"id":2}]' in wire
    print(json.dumps({'rendererInvariants':'passed','primitiveState':'passed','io':stats}))
