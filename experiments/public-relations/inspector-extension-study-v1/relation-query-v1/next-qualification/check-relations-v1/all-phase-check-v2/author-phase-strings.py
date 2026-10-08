"""Independent complete actualCheck phase expectations, authored before outputs.
Reuses existing logical row model and source-based token encoder; never reads
an observed trace. Deferred queued phase has exactly the initial query rows.
"""
from pathlib import Path
import runpy,json
H=Path(__file__).resolve().parent
model=runpy.run_path(str(H.parent/'author-gate-strings.py'),run_name='authored_phase_strings')
def authored():
 text='import Base\n\n# Independently authored full matrices before actual Check outputs.\n'
 for value in model['oracle']['schemas']:
  name=value['schema'].lower();initial=model['encode'](value['phases'][0]['queries']);barrier=model['encode'](value['phases'][2]['queries'])
  assert initial==model['encode'](value['phases'][1]['queries'])
  text+='def '+name+'_pick(allowed:Bool) -> String:\n  match allowed:\n    case True{}:'+json.dumps(barrier)+'\n    case False{}:'+json.dumps(initial)+'\n'
 for name in ('workshop','garden'):text+='def '+name+'(phase:U32) -> String:\n  '+name+'_pick(U32.is_eq(phase,2))\n'
 return text
if __name__=='__main__':
 assert (H/'expected-phases.bend').read_bytes()==authored().encode()
