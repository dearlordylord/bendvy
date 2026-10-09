"""No compiler child: source-derived complete transport/model refusal controls."""
from pathlib import Path
import types,json,copy
p=Path(__file__).resolve().parent
g=types.ModuleType('whole');g.__file__=str(p/'check-whole.py');exec(compile(Path(g.__file__).read_bytes(),g.__file__,'exec'),g.__dict__)
rows=[]
for entry in sorted(p.glob('*.bend')):
 t=g.m.Transport(entry);kind=t.resolve('Report',t.entry,{});expected=json.loads(entry.with_suffix('.expected.json').read_text())
 term=t.inverse(expected,kind);observed=t.convert(term,kind);g.m.TERM.strict_equal(observed,expected)
 mutation=copy.deepcopy(expected);mutation['scalar']+=1
 try:g.m.TERM.strict_equal(observed,mutation)
 except ValueError:pass
 else:raise AssertionError('whole scalar mutation accepted')
 malformed=copy.deepcopy(term);malformed['constructor']='ForeignReport'
 try:t.convert(malformed,kind)
 except ValueError:pass
 else:raise AssertionError('foreign constructor accepted')
 rows.append({'name':entry.stem,'sourceInventory':t.inventory(),'wholeModelRoundTrip':True,'lastScalarRejected':True,'foreignConstructorRejected':True})
print(json.dumps({'scope':'Source-prepared complete models only, not observed output/independent oracle approval','compilerChildren':0,'cases':rows},indent=2))
