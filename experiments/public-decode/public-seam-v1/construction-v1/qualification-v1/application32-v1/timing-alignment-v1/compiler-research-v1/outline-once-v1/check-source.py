"""No child: reversible exact behavior and inherited diagnostic source deltas."""
from pathlib import Path
import ast,json,hashlib
HERE=Path(__file__).resolve().parent
m=json.loads((HERE/'COPY.json').read_text())
cache=Path(m['cachedSource']).read_text();candidate=(HERE/'comp.ts').read_text();old='if (fl.seg.def !== ck.k && (flat_call(fl, x) || (dst === null && once))) {';new='if (fl.seg.def !== ck.k && flat_call(fl, x)) {'
assert candidate.replace(new,old,1)==cache
assert hashlib.sha256(cache.encode()).hexdigest()==m['cachedSHA256']
assert hashlib.sha256(candidate.encode()).hexdigest()==m['candidateSHA256']
instrumented=(HERE/'cost-comp.ts').read_text()
extra='''if (fl.seg.def !== ck.k && !flat_call(fl, x) && dst === null && once) {
        Cost.suppressed_once(fl.def,ck.k,fl.seg.fid);
      }
      '''
restored=instrumented.replace(extra,'',1).replace(new,old,1)
assert restored==Path(m['costBaseline']).read_text()
assert hashlib.sha256(instrumented.encode()).hexdigest()==m['instrumentedCandidateSHA256']
collector=(HERE/'development.py').read_text();ast.parse(collector)
assert 'exec_module' not in collector and 'exec(compile(source' in collector
assert collector.index('actual interpreter differs before helpers')<collector.index("runner = load('task_runner'")
assert collector.index("record['commands'].append(row)")<collector.index("target=Path(row[key]['path']);write_raw")
assert 'suppressed once unmapped definition' in collector
assert 'costSummary' in collector and "pins[str(cost)]=sha(cost)" in collector
print('exact cached→outline and diagnostic inverse/guards controls PASS; no child')
