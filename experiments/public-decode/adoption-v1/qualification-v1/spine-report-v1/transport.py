"""Complete source-typed Candidate transport; no missing group/default repair."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('decode_complete_transport',HERE.parent/'transport.py')
BASE=importlib.util.module_from_spec(spec);spec.loader.exec_module(BASE)

def inventory(entry):
 entry=Path(entry).resolve()
 types,name=BASE.inventory(entry.parent.parent/'main.bend')
 maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
 types['Report']=(str(entry),{'Candidate':[(k,maybe('Cases')) for k in ('insert','spawn','resource','otherSchema')]+[('foreign','Foreign'),('extension',maybe('Extension'))]})
 # BASE inventory is bound to original qualification main, so its Cases,
 # Extension and every nested nominal constructor remain canonical imports.
 def nominal(module,tag):
  import os
  return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
 return types,nominal

def whole(value):
 assert type(value) is dict and set(value)=={'$','insert','spawn','resource','otherSchema','foreign','extension'} and value['$']=='Candidate'
 def present(group):
  assert type(group) is dict and set(group)=={'$','value'} and group['$']=='Some','internally assembled group must be Some'
  return group['value']
 return {'$':'Report','baseline':{'$':'Report',**{k:present(value[k]) for k in ('insert','spawn','resource','otherSchema')},'foreign':value['foreign']},'extension':present(value['extension'])}

def render(expected,entry):
 whole(expected)
 types,name=inventory(entry)
 return (BASE.parser().render(BASE.codec(expected,'Report',types,name,True))+'\n').encode()

def parse(raw,entry):
 assert type(raw) is bytes
 p=BASE.parser();term=p.parse(raw.decode())
 assert (p.render(term)+'\n').encode()==raw,'noncanonical complete output'
 types,name=inventory(entry)
 value=BASE.codec(term,'Report',types,name,False)
 whole(value)
 return value
