"""Generated transport and actual route counts; no timing/allocation estimate."""
import argparse,pathlib,json,re,hashlib,subprocess

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

p=argparse.ArgumentParser();p.add_argument('--artifacts',type=pathlib.Path,required=True);a=p.parse_args();d=a.artifacts;s=(d/'controls.js').read_text();native=(d/'controls.c').read_text()
def sha(data):return hashlib.sha256(data).hexdigest()
def body(name):
 start=s.index('function '+name+'(');end=s.find('\nfunction ',start+1);return s[start:end if end!=-1 else len(s)]
names=re.findall(r'^function (\$view[^ ]*)\(',s,re.M);blocks={n:body(n) for n in names};assert names
for n,b in blocks.items():assert '.slice(' not in b and '.concat(' not in b,n
assert 'for (;;)' in body('$view$058collect$')
assert '_array_0[_index_0 % _array_0.length]' in body('$view$058read_checked$')
assert '(_index_0 < _capacity_0)' in body('$view$058read$')
assert 'fst: _array_0, snd: _array_0.length' in body('$view$058array_view$')
assert '$oracle$058array_view$' in body('$view$058finished$')
counts='let __probe = {views:0,read_true:0,read_false:0,complete:0,refused:0}; process.on("exit",()=>process.stderr.write(JSON.stringify({array_view_probe:__probe})+"\\n"));\n'
instrumented=s
for signature,insert in [
('function $view$058array_view$(_array_0) {','__probe.views++;'),
('function $view$058read_checked$(_array_0, _index_0, _valid_0) {','__probe[_valid_0 ? "read_true" : "read_false"]++;'),
('function $view$058finished$(_collected_0) {','__probe[_collected_0.$ === "view.Complete" ? "complete" : "refused"]++;')]:
 assert instrumented.count(signature)==1;instrumented=instrumented.replace(signature,signature+'\n  '+insert)
(d/'instrumented.js').write_text(counts+instrumented)
q=_run_command(['node',str(d/'instrumented.js')],capture_output=True,text=True,timeout=5);assert q.returncode==0,q.stderr;assert q.stdout==(d/'run-JS.stdout').read_text();observed=json.loads(q.stderr)['array_view_probe'];assert observed=={'views':576,'read_true':18360,'read_false':3,'complete':576,'refused':0},observed
(d/'instrumented.stdout').write_text(q.stdout);(d/'instrumented.stderr').write_text(q.stderr)
# Preserve exact generated helper text and identifiable owned block-read snippets.
(d/'generated-view-functions.js.txt').write_text('\n\n'.join(blocks.values()))
native_start=native.index('INLINE Term spin_4(');native_end=native.index('INLINE Term spin_3(',native_start)
(d/'generated-native-read.c.txt').write_text(native[native_start:native_end]);assert 'blk_read' in native[native_start:native_end] and 'spin_5(e, _o_2, _array_1, _c_0)' in native[native_start:native_end]
r={'scope':'Finite actual helper counts and standalone emitter source audit; no measured performance/bytes allocation/universal refinement','js_sha256':sha(s.encode()),'native_sha256':sha(native.encode()),'instrumented_sha256':sha((counts+instrumented).encode()),'probe_source_sha256':sha(pathlib.Path(__file__).read_bytes()),'actual_counts':observed,'full_stdout_equals_original':True,'view_function_names':names,'new_view_functions_no_slice_or_concat':True,'collector_tail_loop':True,'bounds_check_precedes_masked_get':True,'size_and_get_actual_owner_returned':True,'explicit_fallback':'finished Refused preserves owner and calls original structural oracle; unreachable on all576size-derived valid inputs. Raw helper capacity can be forged, no universal helper-authority claim.','native_read':'spin_4 branches on checked predicate before blk_read; returns actual array word through spin_5. Same actual owner threads loop; no new Array clone.','native_standalone_WL_RESW':int(re.search(r'#define WL_RESW (\d+)',native)[1])}
(d/'generated-audit.json').write_text(json.dumps(r,indent=2)+'\n');print('PASS')
