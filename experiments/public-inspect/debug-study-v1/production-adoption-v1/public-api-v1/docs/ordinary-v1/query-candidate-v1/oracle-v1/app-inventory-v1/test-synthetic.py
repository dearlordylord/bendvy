"""Focused no-child full typed acceptance and corruption controls."""
import importlib.util,json,copy
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('synthetic',HERE/'synthetic-raw.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
checks=[]
for role,expected,ids in [('main','expected-v2.json','main-identities.json'),('resource','resource-expected-v2.json','resource-identities.json')]:
 inv=json.loads((M.SUBJECT/ids).read_bytes());raw=(HERE/(role+'-synthetic.stdout')).read_text();value=json.loads((HERE/expected).read_bytes());M.P.BASE.strict_equal(M.P.normalize(raw,inv,M.join),value)
 for name,changed in [('wrongUnitType',raw.replace('Unit{}','0',1)),('trailingTerm',raw+' Unit{}'),('unknownNominalToken',raw.replace('Reported{','ReportedBogus{',1)),('wrongNullaryArity',raw.replace('None{}','None{0}',1))]:
  try:M.P.BASE.strict_equal(M.P.normalize(changed,inv,M.join),value)
  except (ValueError,KeyError,IndexError):checks.append(role+':'+name)
  else:raise AssertionError('Accepted corrupted complete term '+name)
# A complete same-shape mutation must be rejected at full semantic gate.
role='main';inv=json.loads((M.SUBJECT/'main-identities.json').read_bytes());value=json.loads((HERE/'expected-v2.json').read_bytes());mutant=copy.deepcopy(value);mutant['plain']['Reported']['report']['descriptions'][0]['Some']['schema'][0]['key']='WrongPosition'
raw=M.render(M.inverse(mutant,'Output.Report',inv))+'\n'
try:M.P.BASE.strict_equal(M.P.normalize(raw,inv,M.join),value)
except ValueError:checks.append('main:reachedSchemaKeyDifference')
else:raise AssertionError('Full gate ignored schema key')
print(json.dumps({'positiveWholeRoles':2,'rejectedControls':checks,'scope':'Synthetic no-child complete transport controls only'},indent=2))
