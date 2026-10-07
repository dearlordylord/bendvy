"""Read-only generated mechanism audit; counts are syntax, not allocations."""
import pathlib,re,json,hashlib,argparse
p=argparse.ArgumentParser();p.add_argument('artifacts',type=pathlib.Path);a=p.parse_args();d=a.artifacts
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
js=(d/'normal.js').read_text();c=(d/'normal.c').read_text()
functions=re.findall(r'(function ([^\s(]+)\([^\n]*\) \{.*?)(?=\nfunction |\Z)',js,re.S)
selected={name:body for body,name in functions if '$058indexed_view_' in name}
loops={n:b for n,b in selected.items() if '$058indexed_view_loop$' in n};choose=next(b for n,b in selected.items() if '$058indexed_view_choose$' in n)
advance=choose[choose.index('return {$: "../../../src/ecs/column.IndexedViewAdvance"'):]
assert all('for (;;)' in b and 'continue;' in b for b in loops.values())
assert 'HandoffCon' not in advance and 'HistoryCon' in advance
assert all('column.Inspect' not in b and 'column.Choice' not in b for b in selected.values())
spins=re.findall(r'((?:INLINE|FAR) Term (spin_\d+)\([^\n]*\) \{.*?)(?=\n(?:INLINE|FAR) Term |\Z)',c,re.S)
decisionloops={name:body for body,name in spins if re.search(r'Term _decision_0 = r\d+;',body) and 'term_aux(_decision_0)' in body}
assert decisionloops and all('term_aux(_decision_0)' in b and 'term_loc(_decision_0)' in b for b in decisionloops.values())
r={'generated_sources':{'normal.js':sha(d/'normal.js'),'normal.c':sha(d/'normal.c')},'audit_source_sha256':sha(pathlib.Path(__file__)),'js_fast_helpers':list(selected),'js_loop_helpers':list(loops),'js_advance_no_handoff_reconstruction':True,'js_fast_no_inspect_choice_literals':True,'native_decision_loops':{n:{'signature':b.splitlines()[0],'decision_binding':re.search(r'Term _decision_0 = r\d+;',b).group()} for n,b in decisionloops.items()},'native_actual_boxed_decision':True,'limits':'Syntactic generated-code audit, not runtime allocation or speed. Native chooses heap-backed tagged Decision and boxes Payload inside; no zero-cost carrier claim. Existing legacy/indexed oracle emission remains unchanged.'}
(d/'generated-audit.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
