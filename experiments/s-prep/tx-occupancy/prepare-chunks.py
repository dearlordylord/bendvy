"""Use reversed diagnostic chunks; retain every physical snapshot and original operation."""
from pathlib import Path
import re

def prepare(dest):
 dest=Path(dest)
 for p in dest.glob('*.bend'):
  if p.name.startswith('occupancy'):continue
  text=p.read_text().replace('meter: String','meter: List<&2,String>').replace('meter:String','meter:List<&2,String>')
  text=text.replace('& String','& List<&2,String>')
  if p.name=='transaction.bend':
   text=re.sub(r'meter \+\+ (.*?"[^"\n]*;")',lambda m:'(('+m[1]+') <> meter)',text)
   text=text.replace('Tx{world,selected,[],[],[],[],""}','Tx{world,selected,[],[],[],[],[]}')
   at=text.index('def diag_cons(');text=text[:at]+'def diag_render(meter: List<&2,String>) -> String:\n  String.join(List.reverse(&2,String,meter),"")\n'+text[at:]
  if '"txdiag:" ++ meter' in text:
   alias='X' if p.name=='measurement-bend.bend' else 'XM'
   if alias=='XM':text=text.replace('import Base\n','import Base\nimport ./transaction.bend as XM\n',1)
   text=text.replace('"txdiag:" ++ meter','"txdiag:" ++ '+alias+'.diag_render(meter)')
  p.write_text(text)
