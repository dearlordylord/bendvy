#!/usr/bin/env python3
"""Separate bounded Type-payload measurements; not Data-kernel acceptance."""
import hashlib,json,os,random,statistics,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import command,build
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})
def invoke(program):
 args=['node',program] if str(program).endswith(('.js','.mjs')) else [program,'--threads','1','--gpu','off']
 text=command(args,timeout=15).splitlines()[-1]
 result,elapsed=text.rsplit(':',1)
 assert result=='10->19;restored=10;earlier=19',result
 return float(elapsed)
with tempfile.TemporaryDirectory(prefix='owned-layout-') as tmp:
 folder=Path(tmp);native,js=build(HERE/'owned-bench.bend',folder)
 lf=folder/'list';lf.mkdir()
 ln,lj=build(HERE/'owned-list-bench.bend',lf)
 programs={'native':native,'js':js,'list-native':ln,'list-js':lj,'ts':HERE/'owned-bench-reference.mjs'}
 for program in programs.values():invoke(program)
 samples={k:[] for k in programs};rng=random.Random(20261004)
 for sample in range(5):
  order=list(programs);rng.shuffle(order)
  for k in order:samples[k].append(invoke(programs[k]))
 evidence={'entities':2,'payload_array_length':4,'iterations':10000,'writes_per_failed_system':2,'earlier_successful_commits':1,'warmups_per_process':3,'samples_ms':samples,'median_ms':{k:statistics.median(v) for k,v in samples.items()},'range_ms':{k:[min(v),max(v)] for k,v in samples.items()},'observation':'10->19;restored=10;earlier=19','cpu_affinity':sorted(os.sched_getaffinity(0)),'clock':'Bend IO.now ms; TS performance.now ms','limits_seconds':{'checker':5,'codegen':30,'clang':120,'runtime':15},'list_baseline':'New T04-style owned linked list, sharing identical Cell get/set/inverse-undo and closed callback; distinct from committed T10 Data baseline.','source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'owned.bend',HERE/'owned-main.bend',HERE/'owned-bench.bend',HERE/'owned-bench-reference.mjs',HERE/'owned-list.bend',HERE/'owned-list-bench.bend']}}
 evidence['peak_rss_kib']={}
 for k,p in programs.items():
  args=['node',p] if str(p).endswith(('.js','.mjs')) else [p,'--threads','1','--gpu','off']
  evidence['peak_rss_kib'][k]=int(command(['python3',HERE.parent/'t10'/'rss.py',*args],timeout=15).strip())
 evidence['memory_method']='wait4 exact child lifetime ru_maxrss; inherited Python launcher pre-exec floor, setup/3 warmups/runtime/JIT included'
 (HERE/'owned-results.json').write_text(json.dumps(evidence,indent=2)+'\n')
 print(evidence['median_ms'])
