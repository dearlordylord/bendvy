from pathlib import Path
import re,runpy
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');p=D/'private/src/ecs/ordinary-reader-system.bend';s=p.read_text()
# Closed current core begin types use the identical World and actual clock sampling.
s=s.replace('Tx.begin(~W.World<S,C,R,E>,~E,world)','Cmd.tx_begin(~S,~C,~R,~E,world)')
# Thread the detached report through exactly the existing output-preserving commit/failure chain.
# Reuse local balanced signature splitter without rerunning the closure copier.
script=(D/'tools/prepare-private.py').read_text();a=script.index('def split(s):');b=script.index('# Functions accepting',a);ns={};exec(script[a:b],ns);split,end=ns['split'],ns['end']
names=['success_succeeded','success_context','commit_success','callback_failure','inner_outcome'];targets={}
for name in names:
 m=re.search(r'^def '+name+r'\(',s,re.M);e=end(s,m.end()-1);args=split(s[m.end():e]);targets[name]=next(i for i,v in enumerate(args) if v.strip().startswith('output:Output'))
edits=[]
for m in re.finditer(r'(?<![\w.])('+ '|'.join(names)+r')\(',s):
 a=m.end()-1;e=end(s,a);args=split(s[a+1:e]);defining=bool(re.search(r'def\s+$',s[max(0,m.start()-5):m.start()]));args.insert(targets[m[1]],'report:Meter.Report' if defining else 'report');edits.append((a+1,e,','.join(args)))
for a,e,r in reversed(edits):s=s[:a]+r+s[e:]
s=s.replace('case Tx.Returned{world,outcome}:','case Tx.Returned{world,outcome,report}:')
# Completion and outward successful/failed invocation records carry the same detached report.
s=s.replace('CallbackCompleted{output:Output}','CallbackCompleted{output:Output,report:Meter.Report}').replace('CallbackFailed{error:Failure,output:Output}','CallbackFailed{error:Failure,output:Output,report:Meter.Report}')
s=s.replace('CallbackCompleted{output}','CallbackCompleted{output,report}').replace('CallbackFailed{error,output}','CallbackFailed{error,output,report}')
s=s.replace('RunCompleted{context:Context,provider:Provider,output:Output}','RunCompleted{context:Context,provider:Provider,output:Output,report:Meter.Report}').replace('RunFailed{context:Context,provider:Provider,error:Failure,output:Output}','RunFailed{context:Context,provider:Provider,error:Failure,output:Output,report:Meter.Report}')
s=s.replace('Provider{registry,reader,parameter,declaration},output}','Provider{registry,reader,parameter,declaration},output,report}').replace('Provider{registry,reader,parameter,declaration},error,output}','Provider{registry,reader,parameter,declaration},error,output,report}')
s='import ../../../meter.bend as Meter\n'+s;p.write_text(s)
