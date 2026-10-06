#!/usr/bin/env python3
"""Fresh finite cached/raw/suppressed Tx equality on pinned owned World/Rows emitted functions."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});here=Path(__file__).resolve().parent;catalog=json.load(open(here/'input-pins.json'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Fresh JS controller byte/full-record equality; no universal alias safety, new source/API/compiler acceptance or performance qualification','cpu':[8],'runtimeLimitSeconds':5,'cases':[]}
for digest,pin in catalog.items():
 if 'getter' not in pin:continue
 source=Path(pin['inputPath']);assert sha(source)==digest
 label=pin['mode']+'-'+pin['getter']+'-'+pin['schema'];target=a.output/(label+'.js');argv=['node','--expose-internals',here/'rewrite.cjs',source,target,pin['schema']]
 run=subprocess.run(list(map(str,argv)),text=True,capture_output=True,timeout=5);assert run.returncode==0,run.stderr
 raw=[]
 for role,program in [('baseline',source),('rewritten',target)]:
  command=['node',str(program)];proc=subprocess.run(command,text=True,capture_output=True,timeout=5);assert proc.returncode==0,proc.stderr;(a.output/(label+'-'+role+'.jsonl')).write_text(proc.stdout);records=[json.loads(x) for x in proc.stdout.splitlines()];assert len(records)==72;raw.append(proc.stdout)
 assert raw[0]==raw[1],label
 stored=Path(str(source)+'.jsonl')
 if stored.exists():assert stored.read_text().strip()==raw[0].strip(),label
 r['cases'].append({'label':label,'inputSHA256':digest,'outputSHA256':sha(target),'recipeSHA256':sha(Path(str(target)+'.recipe.json')),'originalRawSHA256':sha(a.output/(label+'-baseline.jsonl')),'rewrittenRawSHA256':sha(a.output/(label+'-rewritten.jsonl')),'records':72,'storedBaselineCompared':stored.exists(),'rewriteCommand':list(map(str,argv))})
r['status']='ALL_EIGHT_CONTROLLERS_576_FULL_RECORDS_EQUAL';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
