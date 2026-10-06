#!/usr/bin/env python3
"""Root-only reviewed diagnostic execution; each complete rotation outer-cap60."""
import argparse,json,sys
sys.path.insert(0,"/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates")
import supervisor
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--prefix',required=True);a=p.parse_args()
for schema in ['Motion','Health']:
 for rotation in range(10):
  output=Path(a.prefix+'-'+schema.lower()+'-r'+str(rotation));assert not output.exists()
  argv=[sys.executable,str(Path(__file__).with_name('observe.py')),'--plan',str(a.plan),'--schema',schema,'--rotation',str(rotation),'--output',str(output)]
  try:
   code,log=supervisor.execute(argv,60);result={'exit':code,'timeout':False,'output':log}
  except TimeoutError as error:
   result={'exit':124,'timeout':True,'error':repr(error)}
  Path(str(output)+'-outer.json').write_text(json.dumps({'argv':argv,'outerSeconds':60,**result},indent=2)+'\n')
  if result['exit']:sys.exit(result['exit'])
