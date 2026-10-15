#!/usr/bin/env python3
"""Final frozen consumer adapter for reusable source-derived state transitions.

Expected artifacts are unavailable until the complete corrected source is pinned.
"""
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
import bend_state
import bend_render
HERE=Path(__file__).resolve().parent
j=lambda value:json.dumps(value,separators=(',',':'))

def definitions(source):
    lines=source.splitlines();starts=[i for i,line in enumerate(lines) if line.startswith('def ')]
    return {re.match(r'def (\w+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}

def nested_calls(expression):
    """Finite continuation expression grammar: f(state) or f(g(...state))."""
    expression=expression.strip()
    if expression=='state':return []
    match=re.fullmatch(r'(follow_\w+)\((.*)\)',expression)
    assert match,expression
    return nested_calls(match[2])+[match[1]]

def extract_plan(source):
    defs=definitions(source)
    assert 'write_output_chunks(both_root_outputs(followup_start(setup_with_factory(W.Factory{1})),followup_start(setup_with_factory(W.Factory{2}))))' in defs['main']
    assert 'case Ready{context}:followup_writer_defined(define_writer(context,"relation-writer"))' in defs['followup_start']
    assert 'followup_fast_defined(writer,define_all(context,"fast"))' in defs['followup_writer_defined']
    assert 'followup_slow_defined(writer,fast,define_all(context,"slow"))' in defs['followup_fast_defined']
    assert 'run_followup(context,writer,fast,slow)' in defs['followup_slow_defined']
    assert 'follow_initial(metadata_after(context,writer,fast,slow,WriteArgs{None{},None{},None{},False{},None{},[]},[]))' in defs['run_followup']
    assert 'follow_after_seed(follow_command(FollowState{world,owners},"ordinary-seed-two-values",SeedPair{}))' in defs['follow_initial']
    assert 'follow_after_warm(follow_warm(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}}))' in defs['follow_after_seed']
    def steps(body):
        text=body[body.index('[Sch.'):body.rindex(']')+1]
        return [('system',int(m[2]),int(m[3])) if m[2] else ('barrier',) for m in re.finditer(r'Sch\.(System\{(\d+),(\d+)\}|Barrier\{\})',text)]
    command_steps=steps(defs['follow_command'])
    def expand(name):
        body=defs[name]
        if name=='follow_finish':
            assert 'follow_final_image(trace,json_context_image(context_from(world,metadata)))' in body
            return []
        if name in ['follow_actual_remove','follow_actual_reinsert']:
            nextname='follow_removed' if name=='follow_actual_remove' else 'follow_reinserted'
            operation='remove' if name=='follow_actual_remove' else 'insert'
            assert nextname+'(follow_run(' in body
            assert ('Some{RemoveValue{target}}' if operation=='remove' else 'Some{InsertValue{target,44}}') in body
            return [(operation,steps(body))]+expand(nextname)
        if name=='follow_despawn':
            assert 'follow_despawn_args(world,metadata,writer,fast,slow,writeArgs,trace)' in body
            assert 'DespawnEmpty{handle}' in defs['follow_despawn_args'] and 'Some{+handle}' in defs['follow_despawn_args']
            return [('despawn',command_steps)]
        if name=='follow_spawn':
            assert 'SpawnEmpty{}' in body
            return [('spawn',command_steps)]
        if 'follow_run(' in body:
            return [(name,steps(body))]
        expression=body.split('\n',1)[1].strip()
        calls=nested_calls(expression)
        return [item for call in calls for item in expand(call)]
    return [('seed',command_steps)]+expand('follow_warm')+expand('follow_after_warm')

class Model(bend_state.State):
    def __init__(self,namespace):
        super().__init__(namespace)
        access=['value','value','value','values:read','removal','value','Parent:read','OrdinaryParent:read']
        self.registrations=[{'id':3,'name':'slow','access':access},{'id':2,'name':'fast','access':access},{'id':1,'name':'relation-writer','access':[]}]
        self.next_system=4
        self.handles={}
    def checkpoint(self,label):
        self.timeline.append({'phase':label,'clock':self.clock,'routeTick':self.route,'failureTick':self.failure_tick,'queryCursors':dict(self.query),
                              'typedPositions':copy.deepcopy(self.event_positions),'keyedPositions':copy.deepcopy(self.positions),'world':self.world()})

def one_world(source,namespace):
    state=Model(namespace);plan=extract_plan(source);rows=[];outcomes=[];deliveries=[]
    for phase,steps in plan:
        observations=[];status='finished'
        for step in steps:
            if step[0]=='barrier':
                state.barrier();rows.append({'kind':'barrierFrame','state':state.image()});observations.append({'kind':'barrier-applied'});continue
            _,identifier,slot=step
            if slot==2:
                before=copy.deepcopy({'context':state.image(),'fastCursor':state.query['fast'],'slowCursor':state.query['slow']})
                after=copy.deepcopy({'context':state.image(),'fastCursor':state.query['fast'],'slowCursor':state.query['slow']})
                assert before==after and state.query['fast']>0
                rows.append({'kind':'skipState','before':before,'after':after});observations.append({'kind':'skipped','id':identifier});continue
            if identifier==1:
                state.writer_begin();queued=0
                if phase=='seed':state.handles['source']=state.enqueue_spawn(42);state.handles['target']=state.enqueue_spawn(43)
                elif phase=='remove':state.enqueue_remove(state.handles['target'])
                elif phase=='insert':state.enqueue_insert(state.handles['target'],44)
                elif phase=='spawn':state.handles['doomed']=state.enqueue_spawn()
                elif phase=='despawn':state.enqueue_despawn(state.handles['doomed'])
                elif phase=='follow_link':state.pending.append(('relate',state.handles['source']['id'],state.handles['target']['id']));queued=1
                elif phase=='follow_failures':state.pending.extend([('relate',state.handles['source']['id'],state.handles['source']['id']),('relate',state.handles['source']['id'],state.handles['doomed']['id'])]);queued=2
                else:raise AssertionError(phase)
                state.writer_success([31,32] if phase=='follow_failures' else [])
                rows.append({'kind':'writer','queued':queued,'refused':0,'world':state.world()})
            else:
                assert identifier in [2,3,4]
                reader='slow' if identifier in [3,4] else 'fast';readid=2 if reader=='slow' else 1
                oldquery=dict(state.query);oldpositions=copy.deepcopy(state.positions);oldtyped=copy.deepcopy(state.event_positions)
                view=state.read(reader,readid,readid,(1,2),identifier==4)
                row={'kind':'reader','reader':reader}
                if identifier==4:
                    assert state.query==oldquery and state.positions==oldpositions and state.event_positions==oldtyped
                    row.update(status='failed',error=77);status='failed'
                row.update(cursor=state.query[reader],view=view,world=state.world());rows.append(row)
                deliveries.append({'phase':phase,'reader':reader,'view':copy.deepcopy(view),'failed':identifier==4})
            observations.append({'kind':'ran','id':identifier})
            if status=='failed':break
        rows.append({'kind':'scheduleOutcome','status':status,'observations':observations})
        outcomes.append({'phase':phase,'status':status,'observations':observations})
        state.checkpoint(phase)
    return state,rows,outcomes,deliveries,plan

def check_selected_source(source):
    defs=definitions(source)
    assert 'case 4:reader_result_slow(writer,fast,args,trace,run_all(slow,context_from(world,metadata),True{}))' in defs['dispatch_ordinary']
    assert 'case Ordinary.RunFailed{context,provider,error,view}:reader_failed_slow(writer,fast,args,trace,context,provider,error,view)' in defs['reader_result_slow']
    assert '\\"reader\\":\\"slow\\",\\"status\\":\\"failed\\"' in defs['reader_failed_slow_observed']
    assert 'Tx.Failure{77}' in defs['callback_sent'] and 'send(owner,999)' in defs['callback_selected']
    assert 'Tx.emit(~world_type(),~event_type(),tx,Notice.Original{Value{value}})' in defs['reader_publish']
    assert 'writer_send_values(~H,emit,owner)' in defs['write_callback_with_caps']
    assert 'send(owner,[Value{31},Value{32}])' in defs['writer_send_values']
    assert 'Col.empty(~Schema,~U32)' in defs['empty_store']
    assert 'Mixed.start(' in defs['setup_created'] and 'W.create(' in defs['setup_with_factory']
    assert 'Structural.apply(' in defs['populate_value']
    assert 'Commands.tx_spawn(' in defs['structural_seed_first'] and 'tx,42)' in defs['structural_seed_first']
    assert 'Commands.tx_spawn(' in defs['structural_seed_second'] and 'tx,43)' in defs['structural_seed_second']
    assert 'OrdinaryRemoval.remove(' in defs['remove_structural']
    assert 'Structural.tx_insert(' in defs['insert_structural']
    assert 'Commands.tx_spawn(' in defs['structural_spawn'] and 'empty_population' in defs['structural_spawn']
    assert 'Commands.tx_despawn(' in defs['structural_despawn']
    assert 'completed_write_args(args,operations)' in defs['writer_success_direct']
    assert 'first_spawned(operations)' in defs['completed_write_args']
    assert 'Mixed.frame_failures(' in defs['barrier_ordinary_context'] and 'Mixed.barrier(' in defs['barrier_ordinary_context']
    assert 'json_list_trace(trace)' in defs['follow_final_image']
    assert 'case []:IO.write("\\n")' in defs['write_output_chunks']
    return defs

def shared_dto(delivery):
    view=delivery['view']
    failures=[]
    for reading in view['relations']:
        if reading['key']!=1:continue
        for notice in reading['values']:
            f=notice['failure'];e=f['error']
            error={'_tag':'SelfRelationNotAllowed','entityId':f['source'],'relation':'Parent'} if e['kind']=='self' else {'_tag':'MissingTargetEntity','entityId':f['source'],'targetId':f['target'],'relation':'Parent'}
            failures.append({'operation':f['operation'],'relation':f['relation']['name'],'source':f['source'],'target':f['target'],'error':error})
    return {'reader':delivery['reader'],'rows':[{'id':v['entity']['id'],'payload':v['data']['found']} for v in view['query']],
            'added':[v['id'] for v in view['added']],'changed':[v['id'] for v in view['changed']],
            'removed':[v['entity']['id'] for v in view['removals'] if 'component' in v],
            'events':[v['event']['value'] for v in view['eventA']['values']], 'eventLag':view['eventA']['lagged'],
            'failures':failures,'relationLag':next(v['lagged'] for v in view['relations'] if v['key']==1)}

def derive():
    freeze=json.loads((HERE/'bend-source-freeze.json').read_text());source=Path(freeze['entrypoint']).read_text()
    check_selected_source(source)
    wires=[];details=[];shared=[];ios=[]
    for namespace in [1,2]:
        state,rows,outcomes,deliveries,plan=one_world(source,namespace)
        assert len(plan)==len(outcomes)==17 and len(rows)==43 and len(deliveries)==11
        assert [name for name,_ in plan]==['seed','follow_warm','remove','follow_removed','insert','follow_reinserted','follow_link','spawn','despawn','follow_failures','follow_failure_barrier','follow_active_skip','follow_slow_failure','follow_slow_retry','follow_fast_read','follow_fast_repeat','follow_slow_repeat']
        assert [v['status'] for v in outcomes]==['finished']*12+['failed']+['finished']*4
        assert state.clock==state.route==state.failure_tick==29 and state.query=={'writer':23,'fast':28,'slow':29}
        assert state.stamps=={1:(3,3),2:(14,14)} and state.next_id==4 and state.live=={1,2}
        assert state.frame_start==24 and state.boundary==22
        assert state.event_positions==[bend_state.position(2,28,4),bend_state.position(1,27,3)]
        assert state.positions==[bend_state.position(2,28,5),bend_state.position(1,27,4)]
        assert state.removal_cursor=={'fast':3,'slow':3}
        assert state.journal==[bend_state.batch(9,[{'kind':'removed','record':{'entity':{'namespace':namespace,'id':2},'component':'value'}}]),bend_state.batch(23,[bend_state.value(31),bend_state.value(32)])]
        assert state.messages==[bend_state.batch(23,[bend_state.original(bend_state.value(31)),bend_state.original(bend_state.value(32))])]
        assert state.domains[0]['queue']['size']==2 and state.domains[0]['queue']['dropped']==0
        assert [b['tick'] for b in state.domains[0]['queue']['front']]==[24,24]
        assert [b['values'][0]['failure']['target'] for b in state.domains[0]['queue']['front']]==[1,3]
        assert state.domains[1]['queue']=={'front':[],'back':[],'size':0,'dropped':0}
        assert all(d['readers']==[2,1] for d in state.domains)
        assert not any(v.get('event',{}).get('value')==999 for v in state.events)
        dto=[shared_dto(d) for d in deliveries]
        assert dto[0]['rows']==dto[1]['rows']==[{'id':1,'payload':42},{'id':2,'payload':43}]
        assert dto[0]['added']==dto[1]['changed']==[1,2]
        assert dto[2]['removed']==dto[3]['removed']==[2] and dto[2]['rows']==[{'id':1,'payload':42}]
        assert dto[4]['added']==dto[5]['changed']==[2] and dto[4]['rows'][1]=={'id':2,'payload':44}
        assert dto[6]['reader']==dto[7]['reader']=='slow' and dto[6]==dto[7]
        assert dto[7]['events']==dto[8]['events']==[31,32] and len(dto[8]['failures'])==2
        assert dto[9]['events']==dto[10]['events']==dto[9]['failures']==dto[10]['failures']==[]
        wire,io=bend_render.render(rows,state.image());wires.append(wire[:-1]);ios.append(io)
        details.append({'namespace':namespace,'timeline':state.timeline,'scheduleOutcomes':outcomes,'final':state.image()})
        shared.append({'namespace':namespace,'deliveries':[{'phase':delivery['phase'],**v} for delivery,v in zip(deliveries,dto)]})
    # Source-model comparison only; never read candidate TS/Bend outputs.
    spec=importlib.util.spec_from_file_location('independent_ts_model',HERE/'ts_model.py')
    ts=importlib.util.module_from_spec(spec);spec.loader.exec_module(ts)
    ts_wire,_=ts.derive();observations=json.loads(ts_wire)['observations']
    for namespace,section in zip([1,2],shared):
        ts_deliveries=[d for o in observations if o['root']==('ReadersAlpha' if namespace==1 else 'ReadersBeta') for d in o['deliveries']]
        assert len(ts_deliveries)==len(section['deliveries'])==11
        for index,(bend,typescript) in enumerate(zip(section['deliveries'],ts_deliveries)):
            bend={k:v for k,v in bend.items() if k!='phase'}
            typescript={k:v for k,v in typescript.items() if k!='phase'}
            if index==8:
                assert bend['reader']==typescript['reader']=='fast'
                assert bend['events']==[31,32] and len(bend['failures'])==2
                assert typescript['events']==typescript['failures']==[]
                bend={k:v for k,v in bend.items() if k not in ['events','failures']}
                typescript={k:v for k,v in typescript.items() if k not in ['events','failures']}
            assert bend==typescript,(namespace,index,bend,typescript)
    wire=b'['+b','.join(wires)+b']\n'
    assert wire.count(b'\n')==1
    return wire,details,shared,ios

if __name__=='__main__':
    pins=json.loads((HERE/'bend-source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    bend_state.selftest()
    wire,details,shared,ios=derive()
    if '--write' in sys.argv:
        (HERE/'bend.expected.stdout').write_bytes(wire);(HERE/'bend.expected.stdout.gz').write_bytes(gzip.compress(wire,mtime=0))
        (HERE/'bend.timeline.json').write_text(json.dumps(details,indent=2)+'\n')
        (HERE/'bend.shared-dto.json').write_text(json.dumps(shared,indent=2)+'\n')
        (HERE/'bend.expected.sha256').write_text(hashlib.sha256(wire).hexdigest()+'  bend.expected.stdout\n')
    else:
        assert (HERE/'bend.expected.stdout').read_bytes()==wire
        assert gzip.decompress((HERE/'bend.expected.stdout.gz').read_bytes())==wire
        assert json.loads((HERE/'bend.timeline.json').read_text())==details
        assert json.loads((HERE/'bend.shared-dto.json').read_text())==shared
    print(j({'sourcePins':len(pins),'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'worlds':2,'nominalSchemas':1,'scheduleOutcomesPerWorld':17,'traceRowsPerWorld':43,'io':ios,'invariants':'passed'}))
