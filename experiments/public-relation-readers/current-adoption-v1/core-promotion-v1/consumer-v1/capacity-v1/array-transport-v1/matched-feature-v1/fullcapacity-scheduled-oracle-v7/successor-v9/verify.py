#!/usr/bin/env python3
"""Independent source-only structured-fragment reconstruction of the full fixture."""
import hashlib
import importlib.util
import json
import re
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('v7_model',HERE.parent/'derive.py')
model=importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)
j=model.j

def T(text):
    yield ('text',text)

def P(children):
    # JsonParts fuel = 2 + sum(1 + each child's fuel).
    yield ('parts','')
    for child in children:
        yield ('child','')
        yield from child

def A(values,render):
    def children():
        yield T('[')
        for i,value in enumerate(values):
            if i:yield T(',')
            yield render(value)
        yield T(']')
    return P(children())

def O(items):
    def children():
        for i,(key,value) in enumerate(items):
            yield T(('{' if i==0 else ',')+j(key)+':')
            yield value
        yield T('}')
    return P(children())

def scalar(value):return T(j(value))
def flatarray(values):return A(values,scalar)
def quote(value):return P([T('"'),T(value),T('"')])
def publication(v):
    if v['kind']=='value':return scalar(v)
    assert v['kind']=='removed'
    return P([T('{"kind":"removed","record":'),scalar(v['record']),T('}')])
def notice(v):
    if v['kind']=='original':return P([T('{"kind":"original","event":'),publication(v['event']),T('}')])
    assert v['kind']=='relationFailure'
    return P([T('{"kind":"relationFailure","failure":'),scalar(v['failure']),T('}')])
def notices(v):return A(v,notice)
def batch(v,render):return O([(key,render(value) if key=='values' else scalar(value)) for key,value in v.items()])
def stream(v):
    return O([(k,quote(x) if k=='domain' else A(x,lambda b:batch(b,notices)) if k=='batches' else flatarray(x) if k=='positions' else scalar(x)) for k,x in v.items()])
def queue(v):
    return O([(k,A(x,lambda b:batch(b,notices)) if k in ['front','back'] else scalar(x)) for k,x in v.items()])
def domain(v):return O([('key',scalar(v['key'])),('queue',queue(v['queue'])),('readers',flatarray(v['readers']))])
def failures(v):return O([(k,A(x,domain) if k=='domains' else flatarray(x) if k=='positions' else scalar(x)) for k,x in v.items()])
def typed(v):return O([('stream',stream(v['stream'])),('journal',A(v['journal'],lambda b:batch(b,lambda values:A(values,publication)))),('frameStart',scalar(v['frameStart']))])
def shared(v):return O([('typed',typed(v['typed'])),('relationFailures',failures(v['relationFailures']))])
def metadata(v):return O([('routeTick',scalar(v['routeTick'])),('shared',shared(v['shared']))])
def graph(v):
    assert v=={'edges':[],'inverses':[]}
    return O([('edges',flatarray(v['edges'])),('inverses',A(v['inverses'],lambda x:None))])
def world(v):
    def children():
        for i,(k,x) in enumerate(v.items()):
            if k=='resource':
                yield T(',"resource":"');yield T(x)
                continue
            prefix=('{' if i==0 else ',')+j(k)+':'
            if k=='registrations':prefix='"'+prefix
            yield T(prefix)
            if k in ['live','inactiveReservations','components','registrations']:yield flatarray(x)
            elif k=='graph':yield graph(x)
            elif k=='events':yield notices(x)
            else:yield scalar(x)
        yield T('}')
    return P(children())
def image(v):return O([('world',world(v['world'])),('metadata',metadata(v['metadata']))])
def eventview(v):return O([('values',notices(v['values'])),('lagged',scalar(v['lagged']))])
def reading(v):return O([('key',scalar(v['key'])),('values',notices(v['values'])),('lagged',scalar(v['lagged']))])
def view(v):return O([('query',flatarray(v['query'])),('eventA',eventview(v['eventA'])),('eventB',eventview(v['eventB'])),('removals',flatarray(v['removals'])),('relations',A(v['relations'],reading))])
def row(v):
    if v['kind']=='skipState':
        b,a=v['before'],v['after']
        return P([T('{"kind":"skipState","before":{"context":'),image(b['context']),T(',"fastCursor":'),scalar(b['fastCursor']),T(',"slowCursor":'),scalar(b['slowCursor']),T('},"after":{"context":'),image(a['context']),T(',"fastCursor":'),scalar(a['fastCursor']),T(',"slowCursor":'),scalar(a['slowCursor']),T('}}')])
    if v['kind']=='writer':return P([T('{"kind":"writer","queued":'),scalar(v['queued']),T(',"refused":'),scalar(v['refused']),T(',"world":'),world(v['world']),T('}')])
    if v['kind']=='barrierFrame':return P([T('{"kind":"barrierFrame","state":'),image(v['state']),T('}')])
    assert v['kind']=='reader'
    return P([T('{"kind":"reader","reader":'+j(v['reader'])+',"cursor":'),scalar(v['cursor']),T(',"view":'),view(v['view']),T(',"world":'),world(v['world']),T('}')])
def trace_entry(raw):return P([T('"'),row(json.loads(raw)),T('"')])

def derive_rows():
    m=model.Model();rows=[m.skip(),m.read('fast',1)[0],m.read('slow',2)[0],m.writer(),m.barrier_frame(),m.read('fast',1)[0],m.read('slow',2)[0]]
    steps=[{'kind':'skipped','id':3},{'kind':'ran','id':2},{'kind':'ran','id':4},{'kind':'ran','id':1},{'kind':'barrier-applied'},{'kind':'ran','id':5},{'kind':'ran','id':6}]
    return P([T('{"steps":'),T(j(steps)),T(',"trace":'),A(rows,trace_entry),T(',"final":'),image(m.image()),T('}')])

def verify():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    freeze=json.loads((HERE/'source-freeze.json').read_text())
    rel=Path(freeze['entrypoint']).relative_to('/workspace/formal-proofs/bendvy-worktrees/parity43-ordinary-full-lifecycle-sparse')
    current=(Path(freeze['immutableRoot'])/rel).read_text()
    previous=(Path('/tmp/bendvy43-fullcapacity-v8-oracle-source01')/rel.with_name(rel.name.replace('-v9.bend','-v8.bend'))).read_text()
    def blocks(source):
        lines=source.splitlines()
        starts=[i for i,line in enumerate(lines) if re.match(r'^(def|type) ',line)]
        return {re.match(r'(?:def|type) ([\w]+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}
    old,new=blocks(previous),blocks(current)
    allowed={'ScheduleOwners','metadata_after_split','metadata_after','skip_capture_finish_split','skip_capture_split','skip_capture_finish','skip_capture_after','skip_capture_results','skip_capture_start','trace_append','writer_success_observed','writer_success_controlled_split','writer_success_controlled_context','writer_success_controlled','writer_success_reserved','writer_success_parts','writer_success_args','writer_success','writer_fault_split','writer_fault','writer_result','reader_success_fast_meta','reader_success_slow_meta','reader_success_fast_observed','reader_success_slow_observed','reader_success_fast_parts','reader_success_slow_parts','reader_success_fast','reader_success_slow','reader_fault_fast_split','reader_fault_slow_split','reader_fault_fast','reader_fault_slow','reader_result_fast','reader_result_slow','barrier_ordinary_split_result','barrier_ordinary_image_result','barrier_ordinary_image','barrier_ordinary_context','schedule_finished_state','schedule_finished'}
    assert not set(old)-set(new)
    assert {name for name in old if old[name]!=new[name]}==allowed
    for name in allowed-{'skip_capture_finish_split','trace_append','reader_success_fast_meta','reader_success_slow_meta','reader_success_fast_observed','reader_success_slow_observed','writer_success_observed','writer_success_controlled_split','barrier_ordinary_split_result','schedule_finished_state'}:
        # The remaining changed definitions only thread JsonDoc or choose its equivalent observer.
        before=old[name].replace('trace:List<&2,String>','trace:List<&2,JsonDoc>').replace('context_type() & String','context_type() & JsonDoc').replace('beforeContext:String','beforeContext:JsonDoc').replace('afterContext:String','afterContext:JsonDoc').replace('image:String','image:JsonDoc')
        before=before.replace('context_image(', 'json_context_image(')
        assert before==new[name],name
    assert new['write_output_chunks']==old['write_output_chunks']
    assert new['main']==old['main']
    model.verify_pins()
    expected=model.derive()
    budget=actual=parts=leaves=retries=0
    fragments=[];count=0;chunks=[];maxleaf=0
    def flush():
        nonlocal fragments,count
        if count:chunks.append(''.join(fragments));fragments=[];count=0
    for kind,text in derive_rows():
        if kind=='parts':budget+=2;actual+=2;parts+=1
        elif kind=='child':budget+=1;actual+=1
        else:
            leaves+=1;budget+=3;actual+=2;length=len(text);maxleaf=max(maxleaf,length)
            if not length:continue
            if count+length>4096:
                if count:flush();actual+=1;retries+=1
                if length>4096:chunks.append(text);continue
            fragments.append(text);count+=length
    actual+=1  # Final positive-fuel empty-stack branch.
    flush()
    written=''.join(chunks).encode()+b'\n'
    assert written==expected
    assert actual<=budget and maxleaf<=4096
    assert all(0<len(chunk)<=4096 for chunk in chunks)
    assert hashlib.sha256(written).hexdigest()=='804d5dbf564e859ece28200e92fe147cdad070b4db4a37392526c2fd5262520b'
    result={'sourcePins':len(pins),'bytes':len(written),'sha256':hashlib.sha256(written).hexdigest(),'parts':parts,'textLeaves':leaves,'fuel':budget,'transitions':actual,'flushRetries':retries,'chunks':len(chunks),'maxLeafBytes':maxleaf,'maxChunkBytes':max(map(len,chunks)),'invariants':'passed'}
    print(json.dumps(result))
if __name__=='__main__':verify()
