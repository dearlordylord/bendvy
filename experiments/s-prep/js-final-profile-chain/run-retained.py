#!/usr/bin/env python3
"""Actual full-schema private helper retention/order units, separate from direct Tx gate."""
import argparse,json,hashlib,subprocess,os
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--pipeline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);h=Path(__file__).resolve().parent;config=json.load(open(h/'pipeline-pins.json'));rows=[];sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd):
 v=subprocess.run(list(map(str,cmd)),text=True,capture_output=True,timeout=5);assert v.returncode==0,v.stderr;return v.stdout
for c in config['cases']:
 if not c['label'].startswith('baseline'):continue
 recipe=Path('/tmp/bendvy-js-read-wrapper-fusion-controls-audited')/(c['label']+'.js.recipe.json')
 for role,program in [('input',Path(c['input'])),('final',a.pipeline/(c['label']+'.js'))]:
  for kind in ['fused-client','world-rows']:
   out=a.output/(c['schema']+'-'+role+'-'+kind+'.js');cmd=['node','--expose-internals',h/'witnesses'/(kind+'.cjs'),program,out,c['schema']]
   if kind=='fused-client':cmd.append(recipe)
   run(cmd);raw=run(['node',out]);out.with_suffix('.json').write_text(raw);rows.append({'schema':c['schema'],'role':role,'kind':kind,'inputSHA256':sha(program),'programSHA256':sha(out),'observed':json.loads(raw)})
motion=next(c for c in config['cases'] if c['label']=='baseline');out=a.output/'selected-tx.json';run(['node','--expose-internals',h/'witnesses/selected-tx.cjs','/tmp/bendvy-cache-box-js-build/baseline.js',a.pipeline/'baseline.js',out]);(a.output/'evidence.json').write_text(json.dumps({'scope':'Eight actual full-schema trusted helper units; frozen Data/full fields/owner identity and argument order, not direct Tx or universal alias acceptance','cpu':[8],'runtimeLimitSeconds':5,'records':rows,'selectedTx':json.load(open(out))},indent=2)+'\n');print('EIGHT_ACTUAL_FULL_SCHEMA_RETAINED_ORDER_UNITS_PASS')
