"""No-child reverse-exact compiler boundary control; no behavioral proof."""
from pathlib import Path
import hashlib,json
p=Path(__file__).resolve().parent
m=json.loads((p/'SOURCE.json').read_text())
s=Path(m['referencePath']).read_text()
assert hashlib.sha256(s.encode()).hexdigest()==m['referenceSHA256']
old="""      const once = fl.sites.get(ck.k) === 1 && !ck.b
        && !def_foreign(fl.book.tlds[ck.k])
        && (!lay_box(ret) || lay_box(fl.seg.ret));
      if (fl.seg.def !== ck.k && (flat_call(fl, x) || (dst === null && once))) {"""
new="""      // Experimental compilation boundary: non-flat single-site tail calls
      // remain in their independently emitted WL segment instead of unfolding.
      if (fl.seg.def !== ck.k && flat_call(fl, x)) {"""
assert s.count(old)==1
candidate=s.replace(old,new)
assert hashlib.sha256(candidate.encode()).hexdigest()==m['candidateSHA256']
assert candidate.replace(new,old)==s
import difflib
assert (p/'comp.patch').read_text()==''.join(difflib.unified_diff(s.splitlines(True),candidate.splitlines(True),fromfile='comp.ts',tofile='comp.ts'))
for remaining in ['if (!lay_eq(fl.seg.ret, ret)', 'const cargs = emit_args(fl, ck, true);','spare_flush(fl);','emit_jump(fl, cargs, ck.k, ck.b);']:
 assert remaining in candidate
print(json.dumps({'reverseExact':True,'existingTailJumpAndLayoutAdaptationRetained':True,'compilerChildren':0,'behavioralEquivalenceNotEstablished':True}))
