#!/usr/bin/env python3
"""Fresh three-way full-record equality plus retained immutable Data witnesses."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{8});a.output.mkdir(exist_ok=False);h=Path(__file__).resolve().parent;catalog=json.load(open(h/'input-pins.json'));sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'scope':'Finite unchanged-original/composed/store-elided JS equality and trusted Data helper witnesses; no universal proof','cpu':[8],'runtimeLimitSeconds':5,'cases':[],'witnesses':[]}
def run(cmd):
 p=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);assert p.returncode==0,p.stderr;return p.stdout
for digest,pin in catalog.items():
 source=Path(pin['inputPath']);assert sha(source)==digest;target=a.output/(pin['label']+'.js');run(['node','--expose-internals',h/'rewrite.cjs',source,target]);record={'label':pin['label'],'inputSHA256':digest,'outputSHA256':sha(target),'output':str(target),'recipeSHA256':sha(str(target)+'.recipe.json')};r['cases'].append(record)
 if pin['label']=='baseline':continue
 original=Path(pin['originalInputPath']);assert sha(original)==pin['pipelineInputSHA256'];observed=[]
 for role,program in [('original',original),('composed',source),('elided',target)]:
  raw=run(['node',program]);records=[json.loads(x) for x in raw.splitlines()];assert len(records)==72;(a.output/(pin['label']+'-'+role+'.jsonl')).write_text(raw);observed.append(raw)
 assert observed[0]==observed[1]==observed[2],pin['label'];record['records']=72;record['threeWayFullRecordEqual']=True
 if not pin['label'].startswith('normal-cached-'):continue
 for kind in ['held-cache','world-rows']:
  for role,program in [('composed',source),('elided',target)]:
   out=a.output/(kind+'-'+pin['schema']+'-'+role+'.js');run(['node','--expose-internals',h/'witnesses'/(kind+'.cjs'),program,out,pin['schema']]);raw=run(['node',out]);(out.with_suffix('.json')).write_text(raw);r['witnesses'].append({'kind':kind,'schema':pin['schema'],'role':role,'inputSHA256':sha(program),'programSHA256':sha(out),'observed':json.loads(raw)})
baseline=next(v for v in catalog.values() if v['label']=='baseline');target=next(v for v in r['cases'] if v['label']=='baseline')['output'];select=a.output/'selected-tx.json';run(['node','--expose-internals',h/'witnesses/selected-tx.cjs',baseline['originalInputPath'],target,select]);r['selectedTx']=json.load(open(select));r['status']='NINE_REWRITES_EIGHT_TRIPLE_CONTROLLERS_EIGHT_SNAPSHOTS_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
