import importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location("normal",Path(__file__).with_name("expected.py"));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def expected():
 value=m.expected()
 for report in value["reports"][1:]:
  tx=report["tx"];rows=[];current=0
  for row in tx["boundaries"]:
   if row["site"]=="resource-field.journaled":continue
   current+=1;row["current"]=[current,0,0];row["peak"]=[current,0,0];rows.append(row)
  tx["boundaries"]=rows;tx["consistent"]=False
 return value
if __name__=="__main__":print(json.dumps(expected(),separators=(",",":")))
