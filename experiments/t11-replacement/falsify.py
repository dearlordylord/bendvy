#!/usr/bin/env python3
"""Finite exact-statement falsification; no general law is paired with a proof.
Original reachable snapshots become fixed literals before any implementation
mutation. False-domain Unit controls are reported separately from equality cases.
"""
import hashlib,itertools,json,os,re,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import CHECK,command

MODEL_WORLDS=[
 'T.World{0n,1n,[],[]}',
 'T.World{0n,4n,[],[T.Spawn{1n,1n},T.Spawn{2n,2n},T.Spawn{3n,3n}]}',
 'T.World{0n,4n,[T.Row{3n,3n,False{}},T.Row{2n,2n,False{}},T.Row{1n,1n,False{}}],[]}',
 'T.World{0n,4n,[T.Row{3n,3n,False{}},T.Row{2n,2n,True{}},T.Row{1n,1n,False{}}],[]}',
 'T.World{0n,4n,[T.Row{3n,3n,False{}},T.Row{2n,2n,True{}},T.Row{1n,1n,False{}}],[T.Target{1n,T.Insert{}},T.Target{1n,T.Remove{}}]}',
 'T.World{0n,4n,[T.Row{3n,3n,False{}},T.Row{2n,2n,True{}}],[]}',
 'T.World{0n,2n,[],[T.Spawn{1n,7n}]}',
 'T.World{0n,4n,[T.Row{2n,2n,True{}},T.Row{1n,1n,False{}},T.Row{3n,3n,False{}}],[]}',
]
RUNTIME_WORLDS=[
 'R.World{0,1,[],[]}',
 'R.World{0,4,[],[R.Spawn{1,1},R.Spawn{2,2},R.Spawn{3,3}]}',
 'R.World{0,4,[R.Cell{3,[3 : U32^0n],False{}},R.Cell{2,[2 : U32^0n],False{}},R.Cell{1,[1 : U32^0n],False{}}],[]}',
 'R.World{0,4,[R.Cell{3,[3 : U32^0n],False{}},R.Cell{2,[2 : U32^0n],True{}},R.Cell{1,[1 : U32^0n],False{}}],[]}',
 'R.World{0,4,[R.Cell{3,[3 : U32^0n],False{}},R.Cell{2,[2 : U32^0n],True{}},R.Cell{1,[1 : U32^0n],False{}}],[R.Target{1,T.Insert{}},R.Target{1,T.Remove{}}]}',
]
POOLS={
 'Nat':['0n','1n','2n','8n'],
 'T.Factory':['T.Factory{0n}','T.Factory{1n}','T.Factory{2n}'],
 'T.World':MODEL_WORLDS,
 'T.Handle':['T.Handle{0n,0n}','T.Handle{0n,1n}','T.Handle{0n,2n}','T.Handle{1n,0n}','T.Handle{1n,1n}','T.Handle{0n,7n}'],
 'T.Selection':['T.Any{}','T.Present{}','T.Absent{}'],
 'T.Action':['T.Insert{}','T.Remove{}','T.Despawn{}'],
 'T.Step':['T.Reserve{4n}','T.Publish{T.Handle{0n,1n},T.Insert{}}','T.Publish{T.Handle{1n,1n},T.Despawn{}}','T.Bump{0n}','T.Bump{1n}','T.Barrier{}'],
 'List<&2, T.Step>':['[]','[T.Bump{1n},T.Publish{T.Handle{0n,1n},T.Insert{}}]','[T.Publish{T.Handle{0n,1n},T.Insert{}},T.Publish{T.Handle{0n,1n},T.Remove{}},T.Barrier{}]','[T.Reserve{4n},T.Barrier{},T.Bump{4n}]'],
 'U32':['0','1','2','255'],
 'R.World':RUNTIME_WORLDS,
 'R.Handle':['R.Handle{0,0}','R.Handle{0,1}','R.Handle{0,2}','R.Handle{1,0}','R.Handle{1,1}','R.Handle{0,7}'],
 'R.Factory':['R.Factory{0}','R.Factory{1}','R.Factory{2}'],
 'R.Step':['R.Reserve{4}','R.Publish{R.Handle{0,1},T.Insert{}}','R.Publish{R.Handle{1,1},T.Despawn{}}','R.Bump{0}','R.Bump{1}','R.Barrier{}'],
 'List<&2,R.Step>':['[]','[R.Bump{1},R.Publish{R.Handle{0,1},T.Insert{}}]','[R.Publish{R.Handle{0,1},T.Insert{}},R.Publish{R.Handle{0,1},T.Remove{}},R.Barrier{}]','[R.Reserve{4},R.Barrier{},R.Bump{4}]','[R.Bump{1},R.Bump{1}]'],
 'E.Cursor':['E.Cursor{0,0}','E.Cursor{1,2}'],
 'C.Reader':['C.Reader{0,0,0}','C.Reader{1,2,3}'],
 'Type':['Unit','{0n == 0n : Nat}','{0n == 1n : Nat}'],
}
MUTANTS={
 'admissibility_independent':('model.bend','Nat.is_le(next, limit)','False{}'),
 'namespace_creation_exact':('model.bend','T.World{next, 1n, [], []}','T.World{0n, 1n, [], []}'),
 'namespace_two_created':('model.bend','T.Factory{1n+next}, T.World{next','T.Factory{next}, T.World{next'),
 'reservation_exact':('model.bend','reserve_if(Nat.is_lt(next, limit),','reserve_if(False{},'),
 'reservation_pending_lookup':('model.bend','+pending: List<&2, T.Command>, value: Nat) -> T.Reservation','+pending: List<&2, T.Command>, +value: Nat) -> T.Reservation','T.World{id, 1n+next, rows, List.append','T.World{id, 1n+next, T.Row{next,value,False{}} <> rows, List.append'),
 'query_any_complete_ordered':('model.bend','case T.Any{}: True{}','case T.Any{}: False{}'),
 'query_present_complete_ordered':('model.bend','case T.Present{}: tag','case T.Present{}: Bool.not(tag)'),
 'query_absent_complete_ordered':('model.bend','case T.Absent{}: Bool.not(tag)','case T.Absent{}: tag'),
 'lookup_full_exact':('model.bend','case True{}: lookup_rows(slot, selection, rows)','case True{}: T.Missing{}'),
 'publication_authorized_target':('model.bend','publish_if(Nat.is_eq(id, namespace),','publish_if(True{},'),
 'explicit_flush_independent':('model.bend','apply_all(pending, rows), []','rows, []'),
 'schedule_execution_exact':('model.bend','case Nil{}: world\n    case Con{step, tail}: tick','case Nil{}: flush(world)\n    case Con{step, tail}: tick'),
 'admissibility_preserved':('model.bend','reserve_if(Nat.is_lt(next, limit),','reserve_if(True{},'),
 'query_independent_physical_order':('model.bend','case True{}: insert_sorted(tail, row)','case True{}: row <> tail'),
 'owned_runtime_creation_correspondence':('runtime.bend','Some{World{next,1,[],[]}}','Some{World{0,1,[],[]}}'),
 'owned_runtime_projection_exact':('runtime.bend','rows,commands_project(pending)','[],commands_project(pending)'),
 'owned_runtime_projection_preserves_owner':('runtime.bend','World{id,next,cells,pending}','World{id,next,[],pending}'),
 'owned_runtime_step_correspondence':('runtime.bend','apply_all(pending,rows),[]','apply_all(List.reverse(&2,Command,pending),rows),[]'),
 'u32_increment_no_wrap':('bridge.bend','(value + 1 : U32)','(value + 2 : U32)'),
 'u32_comparison_agrees_nat':('bridge.bend','U32.is_lt(left,right)','U32.is_lt(right,left)'),
 'message_failure_helper':('events.bend','case False{}: cursor','case False{}: complete_success(cursor, started)'),
 'message_success_helper':('events.bend','case True{}: complete_success(cursor, started)','case True{}: cursor'),
 'message_skip_helper':('events.bend','def skip(cursor: Cursor, current: U32) -> Cursor:\n  complete_success(cursor, current)','def skip(cursor: Cursor, current: U32) -> Cursor:\n  cursor'),
 'lifecycle_failure_helper':('lifecycle.bend','case False{} old: old','case False{} Reader{_, _, registered}: Reader{tick, tick, registered}'),
 'lifecycle_success_helper':('lifecycle.bend','case True{} Reader{_, _, registered}: Reader{tick, tick, registered}','case True{} old: old'),
 'owned_runtime_query_result_and_owner':('runtime.bend','(world,M.query(data,selection))','(world,[])'),
 'owned_runtime_lookup_result_and_owner':('runtime.bend','(world,M.lookup(data,T.Handle{U32.to_nat(id),U32.to_nat(slot)},selection))','(world,T.Missing{})'),
 'owned_runtime_reservation_result_and_owner':('runtime.bend','Some{Handle{id,next}}','None{}'),
 'owned_runtime_schedule_correspondence':('runtime.bend','case Nil{}: world\n    case Con{s,tail}: tick','case Nil{}: flush(world)\n    case Con{s,tail}: tick'),
 'conditional_type_true':('spec.bend','case True{}: claim','case True{}: Unit'),
 'conditional_type_false':('spec.bend','case False{}: Unit','case False{}: claim'),
}
EXTRA=[
 ('foreign-world-comparison','lookup_full_exact',('model.bend','lookup_if(Nat.is_eq(id, namespace),','lookup_if(True{},')),
 ('command-wrong-target','publication_authorized_target',('model.bend','[T.Target{slot, action}]','[T.Target{0n, action}]')),
 ('logical-fifo','explicit_flush_independent',('model.bend','apply_all(pending, rows), []','apply_all(List.reverse(&2,T.Command,pending), rows), []')),
 ('remove-is-insert','explicit_flush_independent',('model.bend','case True{} T.Remove{} T.Row{slot, value, _}: T.Row{slot, value, False{}}','case True{} T.Remove{} T.Row{slot, value, _}: T.Row{slot, value, True{}}')),
 ('despawn-noop','explicit_flush_independent',('model.bend','case True{} T.Despawn{} _: tail','case True{} T.Despawn{} r: r <> tail')),
 ('flush-does-not-clear','explicit_flush_independent',('model.bend','case T.World{id, next, rows, pending}: T.World{id, next, apply_all(pending, rows), []}','case T.World{id, next, rows, +pending}: T.World{id, next, apply_all(pending, rows), pending}')),
 ('schedule-frozen-immediate-write','schedule_execution_exact',('model.bend','case True{} T.Row{slot, value, tag}: T.Row{slot, value, tag}','case True{} T.Row{slot, value, tag}: T.Row{slot, value, tag}')),
 ('owned-frozen-bump','owned_runtime_step_correspondence',('runtime.bend','values[0] <- (value + 1 : U32)','values[0] <- value')),
 ('owned-barrier-bypass','owned_runtime_step_correspondence',('runtime.bend','case Barrier{}: flush(world)','case Barrier{}: world')),
]
# Correct exact frozen-write replacement: avoid masking this real decision path.
EXTRA[6]=('schedule-frozen-immediate-write','schedule_execution_exact',('model.bend','case True{} T.Row{slot, value, tag}: T.Row{slot, 1n+value, tag}','case True{} T.Row{slot, value, tag}: T.Row{slot, value, tag}'))
EXTRA.extend([
 ('owned-reserved-handle-wrong-slot','owned_runtime_reservation_result_and_owner',('runtime.bend','Some{Handle{id,next}}','Some{Handle{id,(next + 1 : U32)}}')),
 ('owned-schedule-ignores-steps','owned_runtime_schedule_correspondence',('runtime.bend','case Con{s,tail}: tick(tail,limit,step(limit,world,s))','case Con{s,tail}: tick(tail,limit,world)')),
 ('observation-drops-pending','owned_runtime_step_correspondence',('model.bend','T.Observation{id, next, query_rows(T.Any{}, rows), pending}','T.Observation{id, next, query_rows(T.Any{}, rows), []}')),
])
ALIASES={'T':'types.bend','M':'model.bend','S':'spec.bend','R':'runtime.bend','O':'owned-spec.bend','B':'bridge.bend','E':'events.bend','C':'lifecycle.bend'}

def header(code):
    lines=['import Base']
    for alias,module in ALIASES.items():
        if re.search(r'\b'+alias+r'\.',code):lines.append('import ./'+module+' as '+alias)
    return '\n'.join(lines)+'\n'

def read_laws():
    rows=[]
    for name,body in re.findall(r'law (\w+):\n(.*?)(?=\nlaw |\n#|\Z)',(HERE/'LAWS.bend').read_text(),re.S):
        binders=re.findall(r'^  for ([+-]?)(\w+): (.+)$',body,re.M)
        claims=[line.strip() for line in body.splitlines() if line.startswith('  ') and not line.startswith('  for ')]
        assert len(claims)==1,(name,claims)
        rows.append((name,binders,claims[0]))
    assert len(rows)==len(MUTANTS)==31
    return rows

def copies(folder,mutation=None):
    folder.mkdir()
    files={p.name:p for p in HERE.glob('*.bend') if p.name!='LAWS.bend'}
    files.update({'events.bend':HERE.parent/'t07'/'streams.bend','lifecycle.bend':HERE.parent/'t08'/'core.bend','log.bend':HERE.parent/'t08'/'log.bend'})
    for name,source in files.items():
        text=source.read_text()
        if mutation and mutation[0]==name:
            for old,new in zip(mutation[1::2],mutation[2::2]):
                assert text.count(old)==1,(name,old,text.count(old))
                text=text.replace(old,new)
        (folder/name).write_text(text)

def samples(binders):
    pools=[POOLS[t] for _,_,t in binders]
    values=list(itertools.product(*pools))
    # Complete products for every connected world/operation grid in this package.
    assert len(values)<=256,len(values)
    return values

def statement(claim,binders,values):
    env=dict(zip((n for _,n,_ in binders),values))
    return re.sub(r'(?<![.\w])\w+\b',lambda m:'('+env[m[0]]+')' if m[0] in env else m[0],claim)

def source(folder,name,claim,body):
    p=folder/'instances.bend'
    p.write_text(header(claim)+f'def literal_{name}() -> {claim}:\n  {body}\n')
    return p

def check(folder,name,claim,body,expected=0):
    return command([CHECK,source(folder,name,claim,body),'--check-only'],expected=expected)

def original_instances(folder,name,binders,claim,values):
    controls=[]
    for valueset in values:
        exact=statement(claim,binders,valueset)
        try:
            result=check(folder,name,exact,'{==}')
            assert 'ALL PROOFS CHECK' in result,result
            controls.append({'values':valueset,'active':True,'body':'{==}'})
        except RuntimeError as error:
            result=str(error)
            # False-domain Unit cases are not counterexamples or equality passes.
            assert claim.startswith('S.When(') and '- expected : Unit' in result,result
            result=check(folder,name,exact,'Unit{}')
            assert 'ALL PROOFS CHECK' in result,result
            controls.append({'values':valueset,'active':False,'body':'Unit{}'})
    assert any(c['active'] for c in controls),name+' has no true-domain witness'
    return controls

def mutate(folder,name,binders,claim,controls,mutation):
    copies(folder,mutation)
    typed=command([CHECK,folder/mutation[0],'--check-only'])
    assert 'ALL PROOFS CHECK' in typed,typed
    for control in controls:
        if not control['active']:continue
        exact=statement(claim,binders,control['values'])
        try: check(folder,name,exact,control['body'])
        except RuntimeError as error:
            out=str(error)
            assert 'SOME PROOFS FAIL' in out and 'expected :' in out and 'observed :' in out,out
            assert 'Location: literal_'+name in out,out
            # Immutable input literals and independent premise/oracle are used.
            # Encoder mutations target their own Type-equality helper laws only.
            if claim.startswith('S.When('):
                assert '- expected : Unit' not in out,'changed/false premise is not a killed mutant: '+out
            return {'mutation':list(mutation),'typechecked':True,'own_statement_rejected':True,'true_original_domain':True,'witness':dict(zip((n for _,n,_ in binders),control['values'])),'diagnostic':out.split('SOME PROOFS FAIL',1)[1]}
    raise AssertionError('surviving mutant '+name)

DESPAWN_WORLD='T.World{0n,4n,[T.Row{3n,3n,False{}},T.Row{2n,2n,True{}},T.Row{1n,1n,False{}}],[T.Target{1n,T.Despawn{}}]}'

def extra_controls(folder,label,name,binders,claim,controls):
    if label!='despawn-noop':return controls
    one_control(folder,'reachable_pending_despawn',f'{{M.publish({MODEL_WORLDS[3]},T.Handle{{0n,1n}},T.Despawn{{}}) == {DESPAWN_WORLD} : T.World}}')
    one_control(folder,'pending_despawn_valid',f'{{S.admissible(8n,{DESPAWN_WORLD}) == True{{}} : Bool}}')
    extra=original_instances(folder,name,binders,claim,[['8n',DESPAWN_WORLD]])
    return controls+extra

def one_control(folder,name,claim,expected=0,body='{==}'):
    out=check(folder,name,claim,body,expected)
    assert ('ALL PROOFS CHECK' if expected==0 else 'SOME PROOFS FAIL') in out,out

def main():
    if hasattr(os,'sched_setaffinity'):os.sched_setaffinity(0,{int(os.environ.get('BENDVY_LAWS_CPU','8'))})
    report={'method':'finite exact direct-proposition instances; fixed reachable literals; no general proofs','checker_limit_seconds':5,'external_falsifiers':'not adopted; compatibility unverified; no dependency installed','laws':[],'extra_mutants':[],'gaps':['MAX-1/MAX U32-to-unary-Nat equalities are not checker-normalized; actual compiled U32 boundary observations are separate finite evidence, not universal arithmetic proofs.']}
    with tempfile.TemporaryDirectory(prefix='t11r-',dir=HERE) as tmp:
        root=Path(tmp);original=root/'original';copies(original)
        # Prove these finite inputs are the original reachable snapshots before
        # freezing them as literals, so mutations cannot change their premises.
        f=original/'reachability.bend'
        imports='import Base\nimport ./types.bend as T\nimport ./model.bend as M\nimport ./spec.bend as S\nimport ./runtime.bend as R\nimport ./owned-spec.bend as O\nimport ./model-fixtures.bend as F\nimport ./runtime-fixtures.bend as RF\n'
        for i,fixture in enumerate(['empty','pending','live','mixed','queued','deleted','exhausted']):
            f.write_text(imports+f'def reached() -> {{F.{fixture}() == {MODEL_WORLDS[i]} : T.World}}:\n  {{==}}\n')
            command([CHECK,f,'--check-only'])
        for i,fixture in enumerate(['runtime_empty','runtime_pending','runtime_live','runtime_mixed','runtime_queued']):
            f.write_text(imports+f'def reached() -> {{O.snapshot(RF.{fixture}()) == {MODEL_WORLDS[i]} : T.World}}:\n  {{==}}\n')
            command([CHECK,f,'--check-only'])
        one_control(original,'permuted_representation',f'{{S.observe({MODEL_WORLDS[7]}) == S.observe({MODEL_WORLDS[3]}) : T.Observation}}')
        for i,w in enumerate(MODEL_WORLDS):
            one_control(original,'valid_model_'+str(i),f'{{M.admissible(8n,{w}) == True{{}} : Bool}}')
            one_control(original,'valid_spec_'+str(i),f'{{S.admissible(8n,{w}) == True{{}} : Bool}}')
        one_control(original,'invalid_duplicate','{M.admissible(8n,T.World{0n,1n,[T.Row{0n,1n,False{}},T.Row{0n,2n,True{}}],[]}) == False{} : Bool}')
        one_control(original,'invalid_overlap','{M.admissible(8n,T.World{0n,1n,[T.Row{0n,1n,False{}}],[T.Spawn{0n,2n}]}) == False{} : Bool}')
        one_control(original,'conditional_true_equality','S.When(True{}, {1n == 1n : Nat})')
        one_control(original,'conditional_false_excluded','S.When(False{}, {1n == 0n : Nat})',body='Unit{}')
        one_control(original,'conditional_true_unequal_rejected','S.When(True{}, {1n == 0n : Nat})',expected=1)
        report['premise_controls']={'reachable_model_snapshots':7,'reachable_owned_snapshots':5,'permuted_representation':1,'true_model_invariants':8,'true_independent_invariants':8,'invalid_worlds':2,'conditional_encoder_positive_negative_pairs':3,'immutable_literals_during_mutation':True}
        laws=read_laws();all_controls={}
        for name,binders,claim in laws:
            controls=original_instances(original,name,binders,claim,samples(binders));all_controls[name]=controls
            killed=mutate(root/name,name,binders,claim,controls,MUTANTS[name])
            row={'law':name,'binders':binders,'claim':claim,'active_equality_instances':sum(c['active'] for c in controls),'false_domain_unit_controls':sum(not c['active'] for c in controls),'samples':[{'arguments':dict(zip((n for _,n,_ in binders),c['values'])),'true_domain':c['active']} for c in controls],'mutant':killed}
            report['laws'].append(row)
            print(name,row['active_equality_instances'],'true-domain exact controls;',row['false_domain_unit_controls'],'excluded domain controls; compiling own-law mutant killed',flush=True)
            (HERE/'falsification.json').write_text(json.dumps(report,indent=2)+'\n')
        mapping={n:(b,c) for n,b,c in laws}
        for label,name,mutation in EXTRA:
            binders,claim=mapping[name]
            controls=extra_controls(original,label,name,binders,claim,all_controls[name])
            result=mutate(root/label,name,binders,claim,controls,mutation)
            report['extra_mutants'].append({'name':label,'law':name,**result})
            print(label,'compiling true-domain own-law mutant killed',flush=True)
        report['hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in HERE.glob('*.bend')}
        (HERE/'falsification.json').write_text(json.dumps(report,indent=2)+'\n')
    print('direct replacement-law falsification complete;31 laws remain open/unapproved',flush=True)
if __name__=='__main__':main()
