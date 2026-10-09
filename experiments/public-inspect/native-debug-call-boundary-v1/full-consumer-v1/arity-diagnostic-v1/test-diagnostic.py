"""No compiler execution: exact minimal patch inverse and independent record controls."""
from pathlib import Path
import gzip,json,hashlib
HERE=Path(__file__).resolve().parent
source=json.loads((HERE/'SOURCE.json').read_text());before=gzip.decompress((HERE.parent.parent/'candidate.comp.ts.gz').read_bytes());after=gzip.decompress((HERE/'compiler-diagnostic.ts.gz').read_bytes())
assert hashlib.sha256(before).hexdigest()==source['originalCompilerSHA256']
assert hashlib.sha256(after).hexdigest()==source['diagnosticCompilerSHA256']
patch=(HERE/'compiler-diagnostic.patch').read_text().splitlines(True)
old=[];new=[]
for line in patch[2:]:
 if line.startswith('@@'):continue
 if line[0]in [' ','-']:old.append(line[1:])
 if line[0]in [' ','+']:new.append(line[1:])
old=''.join(old).encode();new=''.join(new).encode()
assert before.count(old)==1 and after.count(new)==1
assert after.replace(new,old)==before
# Guard still uses exactly its original predicate/throw, without altered limits.
text=after.decode();assert 'entries.some((s) => s.params.length > WIDE) || ars.some((n) => n > 255)'in text
assert text.count('die("an arity over " + WIDE);')==1
assert 'entries.filter((s) => s.params.length > WIDE)'in text
assert '[...cids].filter(([,n]) => (n > WIDE ? 240 + Math.log2(n) : n) > 255)'in text
print('EXACT_DIAGNOSTIC_PATCH_INVERSE_PASS: no compiler/backend child')
