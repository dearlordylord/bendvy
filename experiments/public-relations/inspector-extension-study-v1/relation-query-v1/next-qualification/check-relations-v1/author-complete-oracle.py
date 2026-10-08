"""Independent full Check fixture oracle, authored before any Check outputs.
Uses logical declaration rows, not observed traces. Six actual component writes
advance each World to clock6; Check.run and marker-only body leave it at6.
Foreign values come from Build(base+1000), not a fabricated namespace owner.
"""
from pathlib import Path
import json,runpy,copy
H=Path(__file__).resolve().parent
rows=runpy.run_path(str(H/'author-query-oracle.py'),run_name='authored_check_rows')
def snapshot(namespace,base):
 return {'namespace':namespace,'clock':6,'pending':0,'owners':{'stock':[base+11,base+12,base+14],'title':[str(base+22),str(base+23),str(base+24)],'resources':[[base+31],[base+32]]}}
def schema(name,base):
 value=rows['schema'](name,base);value.pop('finalWorldClock')
 primary=snapshot(1,base);foreign=snapshot(2,base+1000)
 value['gate']={'before':copy.deepcopy(primary),'after':copy.deepcopy(primary),'bodyMarkers':1,'allowed':[{'ran':1}],'skipped':[{'skipped':1}]}
 value['foreignBefore']=copy.deepcopy(foreign);value['foreignAfter']=copy.deepcopy(foreign)
 return value
oracle={'schemas':[schema('Workshop',0),schema('Garden',100)]}
if __name__=='__main__':
 target=H/'expected-complete.json';assert not target.exists()
 target.write_text(json.dumps(oracle,indent=2)+'\n')
