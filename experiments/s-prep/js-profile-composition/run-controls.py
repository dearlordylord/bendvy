#!/usr/bin/env python3
"""Fresh actual originals versus composed outputs, plus retained Data helper witnesses."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--pipeline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent;config=json.load(open(here/'pipeline-pins.json'));pipeline=json.load(open(a.pipeline/'evidence.json'));assert pipeline['status']=='ALL_NINE_COMPOSED_INPUTS_GUARDS_PASS';assert pipeline['pipelinePinsSHA256']==hashlib.sha256((here/'pipeline-pins.json').read_bytes()).hexdigest();sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
r={'scope':'Fresh finite backend equality and trusted helper witnesses, no universal alias/authority proof','cpu':[8],'runtimeLimitSeconds':5,'controllers':[],'witnesses':[]};bylabel={x['label']:x for x in pipeline['cases']}
def run(cmd):
 v=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);assert v.returncode==0,v.stderr;return v.stdout
for case in config['cases']:
 target=Path(bylabel[case['label']]['output']);assert sha(target)==bylabel[case['label']]['outputSHA256']
 if case['label']=='baseline':continue
 original=Path(case['input']);assert sha(original)==case['inputSHA256'];observed=[]
 for role,program in [('original',original),('composed',target)]:
  raw=run(['node',program]);records=[json.loads(x) for x in raw.splitlines()];assert len(records)==72;dest=a.output/(case['label']+'-'+role+'.jsonl');dest.write_text(raw);observed.append(raw)
 assert observed[0]==observed[1],case['label'];stored=Path(str(original)+'.jsonl')
 if stored.exists():assert stored.read_text().strip()==observed[0].strip()
 r['controllers'].append({'label':case['label'],'inputSHA256':sha(original),'outputSHA256':sha(target),'records':72,'storedBaselineCompared':stored.exists(),'rawSHA256':sha(a.output/(case['label']+'-composed.jsonl'))})
 if not case['label'].startswith('normal-cached-'):continue
 for kind in ['held-cache','world-rows']:
  for role,program in [('original',original),('composed',target)]:
   out=a.output/(kind+'-'+case['schema']+'-'+role+'.js');run(['node','--expose-internals',here/'witnesses'/(kind+'.cjs'),program,out,case['schema']]);raw=run(['node',out]);result=json.loads(raw);(out.with_suffix('.json')).write_text(raw);r['witnesses'].append({'kind':kind,'schema':case['schema'],'role':role,'inputSHA256':sha(program),'programSHA256':sha(out),'observed':result})
baseline=next(c for c in config['cases'] if c['label']=='baseline');select=a.output/'selected-tx.json';run(['node','--expose-internals',here/'witnesses/selected-tx.cjs',baseline['input'],bylabel['baseline']['output'],select]);r['selectedTx']=json.load(open(select));r['status']='EIGHT_CONTROLLERS_AND_EIGHT_RETAINED_VIEWS_AND_SELECTED_TX_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
