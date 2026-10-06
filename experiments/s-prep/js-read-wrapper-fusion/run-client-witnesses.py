#!/usr/bin/env python3
"""Four original/fused Motion/Health actual-client frozen-history/order units."""
import argparse,hashlib,json,subprocess,os
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--candidates',type=Path,required=True);p.add_argument('--recipes',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.recipes=a.recipes or a.candidates;os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);h=Path(__file__).resolve().parent;records=[]
for digest,pin in json.load(open(h/'input-pins.json')).items():
 if not pin['label'].startswith('normal-cached-'):continue
 candidate=a.candidates/(pin['label']+'.js');recipe=a.recipes/(pin['label']+'.js.recipe.json')
 for role,program in [('original',Path(pin['inputPath'])),('candidate',candidate)]:
  target=a.output/(pin['schema']+'-'+role+'.js');cmd=['node','--expose-internals',str(h/'witnesses/fused-client.cjs'),str(program),str(target),pin['schema'],str(recipe)];r=subprocess.run(cmd,capture_output=True,text=True,timeout=5);assert r.returncode==0,r.stderr;r=subprocess.run(['node',str(target)],capture_output=True,text=True,timeout=5);assert r.returncode==0,r.stderr;(target.with_suffix('.json')).write_text(r.stdout);records.append({'schema':pin['schema'],'role':role,'observed':json.loads(r.stdout),'inputSHA256':hashlib.sha256(program.read_bytes()).hexdigest(),'programSHA256':hashlib.sha256(target.read_bytes()).hexdigest()})
(a.output/'evidence.json').write_text(json.dumps({'scope':'Trusted private helper units: actual scalar fused client, frozen immutable history and side-effect argument ordering. Harness functions are not shipping source/FFI.','cpu':[8],'runtimeLimitSeconds':5,'records':records},indent=2)+'\n');print('FOUR_ACTUAL_FUSED_CLIENT_HISTORY_ORDER_WITNESSES_PASS')
