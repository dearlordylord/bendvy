"""Independently reconstruct all complete matrix Strings before outputs."""
from pathlib import Path
import runpy,json
H=Path(__file__).resolve().parent
model=runpy.run_path(str(H.parents[1]/'author-gate-strings.py'),run_name='independent_full_rows')
def authored():
 text='import Base\n\n# Complete independently authored expectations; bounded literal pieces concatenate at runtime.\n'
 for s in model['oracle']['schemas']:
  name=s['schema'].lower();text+='def '+name+'_pick(allowed:Bool) -> String:\n  match allowed:\n'
  for index,ctor in [(2,'True'),(0,'False')]:
   whole=model['encode'](s['phases'][index]['queries']);pieces=[whole[i:i+256] for i in range(0,len(whole),256)]
   assert ''.join(pieces)==whole and whole.isascii()
   text+='    case '+ctor+'{}:'+ ' ++ '.join(map(json.dumps,pieces))+'\n'
 for name in ('workshop','garden'):text+='def '+name+'(phase:U32) -> String:\n  '+name+'_pick(U32.is_eq(phase,2))\n'
 return text
if __name__=='__main__':assert (H/'expected-phases.bend').read_bytes()==authored().encode()
