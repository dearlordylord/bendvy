#!/usr/bin/env python3
"""Dependency-free literal law instantiation; never invokes open law as evidence."""
import itertools,json,os,random,re,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command,paired,CHECK
if os.environ.get('BENDVY_LAWS_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_LAWS_CPU'])})

ROWS=['[]','[M.Row{0n, 1n, False{}}]','[M.Row{0n, 1n, True{}}]','[M.Row{0n, 1n, False{}}, M.Row{1n, 2n, True{}}]','[M.Row{1n, 3n, True{}}, M.Row{0n, 2n, False{}}]']
CMDS=['[]','[M.Spawn{0n, 1n}]','[M.Tag{0n, True{}}, M.Spawn{0n, 1n}]','[M.Despawn{0n}, M.Tag{0n, True{}}]']
POOLS={'Nat':['0n','1n','2n'],'U32':['0','1','4294967295'],'List<&2, M.Row>':ROWS,'List<&2, M.Command>':CMDS,'M.Selection':['M.Any{}','M.Present{}','M.Absent{}'],'M.Command':['M.Tag{0n, True{}}','M.Despawn{1n}'],'M.World':['M.World{0n, 0n, [], []}','M.World{1n, 2n, '+ROWS[3]+', '+CMDS[2]+'}'],'E.Cursor':['E.Cursor{0, 0}','E.Cursor{1, 0}','E.Cursor{0, 4294967295}'],'C.Reader':['C.Reader{0, 0, 0}','C.Reader{1, 2, 0}','C.Reader{0, 1, 4294967295}']}
MUTANTS={
 'query_any_exact':('model.bend','case Any{}: True{}','case Any{}: False{}'),
 'query_present_exact':('model.bend','case Present{}: tagged','case Present{}: True{}'),
 'query_absent_exact':('model.bend','case Absent{}: Bool.not(tagged)','case Absent{}: tagged'),
 'foreign_lookup_guard':('model.bend','case False{}: Missing{}','case False{}: lookup_rows(slot, selection, rows)'),
 'foreign_command_guard':('model.bend','case False{}: World{id, next, rows, pending}','case False{}: World{id, next, rows, command <> pending}'),
 'reserve_projection':('model.bend','Handle{id, next}}','Handle{id, 1n+next}}'),
 'reserve_rejection':('model.bend','Rejected{World{id, next, rows, pending}}','Rejected{World{id, 1n+next, rows, pending}}'),
 'bounded_reservation':('model.bend','World{id, 1n+next, rows, Spawn{next, value} <> pending}','World{id, 1n+1n+next, rows, Spawn{next, value} <> pending}'),
 'flush_fifo_projection':('model.bend','apply_all(List.reverse(&2, Command, pending), rows)','apply_all(pending, rows)'),
 'tick_preserves_pending':('model.bend','def tick(w: World) -> World:\n  w','def tick(w: World) -> World:\n  flush(w)'),
 'despawn_exact':('model.bend','case Despawn{slot}: modify(slot, True{}, False{}, rows)','case Despawn{slot}: modify(slot, False{}, False{}, rows)'),
 'message_failure_position':('events.bend','case False{}: cursor','case False{}: complete_success(cursor, started)'),
 'message_skip_position':('events.bend','def skip(cursor: Cursor, current: U32) -> Cursor:\n  complete_success(cursor, current)','def skip(cursor: Cursor, current: U32) -> Cursor:\n  cursor'),
 'lifecycle_failure_position':('lifecycle.bend','case False{} old: old','case False{} Reader{_, _, registered}: Reader{tick, tick, registered}'),
}

def read_laws():
    text=(HERE/'LAWS.bend').read_text()
    rows=[]
    for name,body in re.findall(r'law (\w+):\n(.*?)(?=\nlaw |\n#|\Z)',text,re.S):
      binders=re.findall(r'^  for \+?(\w+): (.+)$',body,re.M)
      claim=re.search(r'^  (\{.*\})$',body,re.M).group(1)
      rows.append((name,binders,claim))
    assert len(rows)==len(MUTANTS)==14
    return rows

def copies(folder,mutation=None):
    folder.mkdir()
    for name,source in [('model.bend',HERE/'model.bend'),('spec.bend',HERE/'spec.bend'),('events.bend',HERE.parent/'t07'/'streams.bend'),('lifecycle.bend',HERE.parent/'t08'/'core.bend'),('log.bend',HERE.parent/'t08'/'log.bend')]:
      text=source.read_text()
      if mutation and mutation[0]==name:
        old,new=mutation[1:]
        assert text.count(old)==1,(name,old)
        text=text.replace(old,new)
      (folder/name).write_text(text)

def sample_instances(binders):
    dimensions=[POOLS[t] for _,t in binders]
    samples=list(itertools.product(*dimensions))
    # Enumerate all manageable products. For larger products cover each binder's
    # entire catalog first, then fixed-seed combinations; no coverage percentage.
    if len(samples)<=40:return samples
    rng=random.Random(20261003)
    indexes={0,len(samples)-1}
    stride=1
    for pool in reversed(dimensions):
      indexes.update(j*stride for j in range(len(pool)))
      stride*=len(pool)
    indexes.update(rng.sample(range(len(samples)),30))
    return [samples[i] for i in sorted(indexes)]

def generate(folder,name,binders,claim,instances):
    header='import Base\nimport ./model.bend as M\nimport ./spec.bend as S\nimport ./events.bend as E\nimport ./lifecycle.bend as C\n\n'
    definitions=[]
    for i,values in enumerate(instances):
      substitutions=dict(zip([n for n,_ in binders],values))
      statement=re.sub(r'\b\w+\b',lambda m:'('+substitutions[m[0]]+')' if m[0] in substitutions else m[0],claim)
      definitions.append(f'def probe_{name}_{i}() -> {statement}:\n  {{==}}\n')
    p=folder/'instances.bend';p.write_text(header+'\n'.join(definitions));return p

report={'method':'literal instantiation of exact draft statements; finite checker controls, not proofs','seed':20261003,'checker_limit_seconds':5,'external_lawcheck_or_bend_falsify':'not installed/adopted; compatibility unverified','laws':[]}
with tempfile.TemporaryDirectory(prefix='b11-') as d:
    folder=Path(d)
    for name,binders,claim in read_laws():
      samples=sample_instances(binders)
      original=folder/(name+'-original');copies(original)
      source=generate(original,name,binders,claim,samples)
      passed=command([CHECK,source,'--check-only'])
      assert 'ALL PROOFS CHECK' in passed,passed
      mutant=folder/(name+'-mutant');copies(mutant,MUTANTS[name])
      # The defective implementation must itself typecheck, with no proof claim.
      valid=command([CHECK,mutant/MUTANTS[name][0],'--check-only'])
      assert 'ALL PROOFS CHECK' in valid,valid
      wrong=generate(mutant,name,binders,claim,samples)
      rejected=command([CHECK,wrong,'--check-only'],expected=1)
      assert 'SOME PROOFS FAIL' in rejected and 'expected :' in rejected and 'observed :' in rejected,rejected
      assert 'Location: probe_'+name in rejected,rejected
      row={'law':name,'instances':len(samples),'binders':binders,'typechecked_mutant':MUTANTS[name],'rejection':rejected.strip(),'samples':[dict(zip([n for n,_ in binders],v)) for v in samples]}
      report['laws'].append(row)
      print(name,len(samples),'literal controls PASS; own-statement mutant rejected',flush=True)
      (HERE/'falsification.json').write_text(json.dumps(report,indent=2)+'\n')
    runtime_outputs=[]
    for label,mutation in [('original',None),('foreign-guard-mutant',MUTANTS['foreign_lookup_guard'])]:
      target=folder/('runtime-'+label);copies(target,mutation)
      entry=target/'main.bend'
      entry.write_text('import Base\nimport ./model.bend as M\ndef code(result: M.Lookup) -> U32:\n  match result:\n    case M.Missing{}: 0\n    case M.Mismatch{}: 1\n    case M.Found{_}: 2\ndef main() -> U32:\n  code(M.lookup_guard(False{}, 0n, M.Any{}, [M.Row{0n, 1n, False{}}]))\n')
      runtime_outputs.append(paired(build(entry,target)))
    assert runtime_outputs==['0','2'],runtime_outputs
    report['compiled_model_control']={'subject':'foreign_lookup_guard','native_js_original':'0 (Missing)','native_js_mutant':'2 (Found)','scope':'one finite model runtime instance; no owned runtime refinement'}
    (HERE/'falsification.json').write_text(json.dumps(report,indent=2)+'\n')
    print('model foreign-guard compiling native/JS mutant detected',flush=True)
print('T11 literal falsification complete; draft laws remain unproved/unapproved',flush=True)
