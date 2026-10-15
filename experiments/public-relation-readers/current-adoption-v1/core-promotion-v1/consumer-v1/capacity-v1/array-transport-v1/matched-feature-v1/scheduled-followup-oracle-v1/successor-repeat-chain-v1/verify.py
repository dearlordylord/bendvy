#!/usr/bin/env python3
"""Reduce actual reached continuation bodies before deriving schedule observations."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('state_model',HERE.parent/'model.py')
model=importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)

def blocks(source):
    lines=source.splitlines()
    starts=[i for i,line in enumerate(lines) if line.startswith('def ')]
    return {re.match(r'def (\w+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}

def reached(source):
    definitions=blocks(source)
    # Actual successful main/Setup/registration branches, not function-name intent.
    checks={'main':'write_output_chunks(followup_start(setup()))',
            'followup_start':'case Ready{context,entity,target,missing}:followup_writer_defined(entity,target,missing,define_writer(context,"relation-writer"))',
            'followup_writer_defined':'case Ordinary.DefinitionRegistered{context,writer}:followup_fast_defined(source,target,missing,writer,define_all(context,"fast"))',
            'followup_fast_defined':'case Ordinary.DefinitionRegistered{context,fast}:followup_slow_defined(source,target,missing,writer,fast,define_all(context,"slow"))',
            'followup_slow_defined':'case Ordinary.DefinitionRegistered{context,slow}:run_followup(context,writer,fast,slow,source,target,missing)',
            'run_followup':'follow_initial(metadata_after(context,writer,fast,slow,WriteArgs{source,target,missing,[]},[]))',
            'follow_initial':'follow_after_warm(follow_warm(FollowState{world,owners}))'}
    for name,expression in checks.items():assert expression in definitions[name],name
    def reduce(name):
        body=definitions[name]
        if 'follow_final_image(trace,json_context_image(context_from(world,metadata)))' in body:return []
        if 'follow_run(' in body:
            assert name in ['follow_warm','follow_link','follow_failures','follow_fast_failure','follow_active_skip','follow_fast_retry','follow_slow_read','follow_fast_repeat','follow_slow_repeat']
            step_text=body[body.index('[Sch.'):body.rindex(']')+1]
            steps=[]
            for match in re.finditer(r'Sch\.(System\{(\d+),(\d+)\}|Barrier\{\})',step_text):
                steps.append(('system',int(match[2]),int(match[3])) if match[2] else ('barrier',))
            return [(name,steps)]
        expression=body.split('\n',1)[1].strip()
        match=re.fullmatch(r'(follow_\w+)\((follow_\w+)\(state\)\)',expression)
        assert match,(name,expression)
        # Inner invocation executes first; its resulting owners feed outer invocation.
        return reduce(match[2])+reduce(match[1])
    return reduce('follow_warm')+reduce('follow_after_warm')

def derive_actual(source):
    plan=reached(source);m=model.Model();rows=[]
    for name,steps in plan:
        observations=[];status='finished'
        for step in steps:
            if step[0]=='barrier':rows.append(m.barrier());observations.append({'kind':'barrier-applied'});continue
            _,identifier,slot=step
            if slot==2:
                rows.append(m.active_skip());observations.append({'kind':'skipped','id':identifier});continue
            assert slot==0
            if identifier==1:
                assert name in ['follow_link','follow_failures']
                targets=[(model.HANDLE,model.TARGET)] if name=='follow_link' else [(model.HANDLE,model.HANDLE),(model.HANDLE,model.TARGET),(model.HANDLE,model.MISSING)]
                rows.append(m.write(targets))
            elif identifier in [2,3,4]:
                row,_=m.read('slow' if identifier==3 else 'fast',2 if identifier==3 else 1,identifier==4)
                rows.append(row)
                if identifier==4:status='failed'
            else:raise AssertionError(identifier)
            observations.append(model.ran(identifier))
            if status=='failed':break  # Actual Sch.after_outcome returns Failed immediately.
        rows.append(model.outcome(status,*observations))
    wire=('{"scenario":"ordinary-scheduled-failure-retry","trace":['+','.join('"'+model.j(row)+'"' for row in rows)+'],"final":'+model.j(m.image())+'}\n').encode()
    return wire,plan,m,rows

pins=json.loads((HERE/'source-pins.json').read_text())
for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
freeze=json.loads((HERE/'source-freeze.json').read_text())
relative=Path(freeze['entrypoint']).relative_to('/workspace/formal-proofs/bendvy-worktrees/parity43-ordinary-full-lifecycle-sparse')
source=(Path(freeze['immutableRoot'])/relative).read_text()
old=(Path('/tmp/bendvy43-scheduled-followup-oracle-source02')/relative).read_text()
intermediate=Path('/tmp/bendvy43-followup-negative-entry01/ordinary-scheduled-followup-consumer.bend').read_text()
expected_source=old.replace('def follow_after_slow_repeat(state:FollowState)', 'def follow_finish(state:FollowState)').replace('def follow_after_fast_repeat(state:FollowState)', 'def follow_after_slow_repeat(state:FollowState) -> List<&2,String>:\n  follow_finish(follow_slow_repeat(state))\ndef follow_after_fast_repeat(state:FollowState)').replace('follow_after_slow_repeat(follow_slow_repeat(state))','follow_after_slow_repeat(follow_fast_repeat(state))')
assert source==expected_source
wire,plan,final,rows=derive_actual(source)
def setup_accepts(body):
    # Current source primitive: empty column size1; first swap1 fits; target swap2 requires ensure.
    seed=blocks(body)['seed_column_value']
    slots=[42]
    if 'Col.ensure(~Schema,~U32,components,id)' in seed:
        while len(slots)<2:slots.extend([None]*len(slots))
    if len(slots)<2:return False
    slots[1]=43
    assert slots==[42,43]
    return True
old_setup=(Path('/tmp/bendvy43-scheduled-followup-oracle-source01')/relative).read_text()
assert not setup_accepts(old_setup)
assert setup_accepts(old) and setup_accepts(source)
expected_names=['follow_warm','follow_link','follow_failures','follow_fast_failure','follow_active_skip','follow_fast_retry','follow_slow_read','follow_fast_repeat','follow_slow_repeat']
assert [name for name,_ in plan]==expected_names
intended,_,_=model.derive()
assert wire==intended==(HERE.parent/'expected.stdout').read_bytes()
io=model.verify_fragment_io(wire,rows)
assert len(rows)==21 and final.clock==11 and final.query=={'writer':5,'fast':10,'slow':11}
controls=[]
for label,body,omitted in [('omitted-fast',old,'follow_fast_repeat'),('omitted-slow',intermediate,'follow_slow_repeat')]:
    predicted,actual_plan,state,actual_rows=derive_actual(body)
    assert len(actual_plan)==8 and len(actual_rows)==19 and state.clock==10
    assert omitted not in [name for name,_ in actual_plan]
    assert [name for name,_ in actual_plan]!=expected_names
    path=HERE/('rejected-'+label+'.stdout')
    if '--write' in sys.argv:path.write_bytes(predicted)
    else:assert path.read_bytes()==predicted
    controls.append({'control':label,'bytes':len(predicted),'sha256':hashlib.sha256(predicted).hexdigest(),'clock':state.clock,'query':state.query,'scheduleCalls':[name for name,_ in actual_plan]})
result={'sourcePins':len(pins),'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'scheduleCalls':expected_names,'io':io,'negativeControls':controls,'setupControl':{'originalAccepted':False,'successorAccepted':True,'sourceDerivedRejectedWire':'setup-failed\n'},'invariants':'passed'}
if '--write' in sys.argv:(HERE/'derivation-result.json').write_text(json.dumps(result,indent=2)+'\n')
else:assert json.loads((HERE/'derivation-result.json').read_text())==result
print(json.dumps(result))
