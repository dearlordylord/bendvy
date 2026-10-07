"""Independent full expected defect model: successful runs never consume cursor.

Authored before mutant execution. Input operations still insert 11 then 31;
retained initial cursor means both lifecycle declarations see every present row
on repetitions and on the later two-row phase. Ordinary reads/resources agree.
"""
from pathlib import Path
import copy,importlib.util
p=Path(__file__).resolve().parent/'cardinality-oracle.py'
s=importlib.util.spec_from_file_location('original_public_cardinality_oracle',p)
m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
PHASES=copy.deepcopy(m.PHASES)
for phase in ['one-repeat','many','many-repeat']:
 for name in ['added','changed']:
  PHASES[phase][name]=copy.deepcopy(PHASES[phase]['required'])
def complete_text():
 lines=[]
 for schema in ['Workshop','Garden']:
  lines.append(schema)
  for phase,queries in PHASES.items():
   lines.append(phase)
   for name,(rows,lookup) in queries.items():
    if not rows:single,optional='NoEntities','None'
    elif len(rows)==1:single=optional='Found:'+rows[0]
    else:single=optional='MultipleEntities:'+str(len(rows))
    lines.append(name+'|each=['+', '.join(rows)+']|get='+lookup+'|single='+single+'|optional='+optional)
   lines.append('score=[21, 21, 21, 24]')
 return '\n'.join(lines)+'\n'
EXPECTED=complete_text()
