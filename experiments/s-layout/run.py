#!/usr/bin/env python3
"""Validate identical projections before interleaved timed samples."""
import hashlib,json,os,platform,random,statistics,sys,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})
NAMES=['dense','sparse','update','churn','events','rollback']
SIZES=[64,256,1024]
COUNT=2000
REPS=5

def invoke(program,mode,size,count):
    args=['node',program] if str(program).endswith(('.js','.mjs')) else [program]
    args += [str(mode),str(size),str(count)]
    if len(args)==4: args+=['--threads','1','--gpu','off']
    result=command(args,timeout=15).splitlines()[-1].rsplit(':',1)
    assert len(result)==2 and '|' in result[0],result
    return result[0],float(result[1])

with tempfile.TemporaryDirectory(prefix='layout-') as d:
    folder=Path(d)
    native,js=build(HERE/'main.bend',folder)
    baseline_dir=folder/'list'; baseline_dir.mkdir()
    ln,lj=build(HERE.parent/'t10'/'main.bend',baseline_dir)
    programs={'native':native,'js':js,'list-native':ln,'list-js':lj,'ts':HERE.parent/'t10'/'reference.mjs'}
    evidence={'environment':{'bend':command(['bend','version']).strip(),'node':command(['node','--version']).strip(),'clang':command(['clang','--version']).splitlines()[0],'machine':platform.machine(),'cpu_affinity':sorted(os.sched_getaffinity(0)),'native_workers':1,'js_workers':1,'warmups_per_process':3,'samples':REPS,'iterations':COUNT,'clock':'Bend IO.now milliseconds; TS performance.now milliseconds','timed_final_projection':True,'ordered_final_projection':True,'churn_removal_observed':True,'rollback_read_your_writes_observed':True,'benchmark_process_limit_seconds':15},'cases':[]}
    if '--memory-only' in sys.argv:
        evidence=json.loads((HERE/'results.json').read_text())
        assert len(evidence['cases'])==len(NAMES)*len(SIZES)
        assert evidence.get('source_sha256'), 'missing source pins; run full measurement'
        assert all(hashlib.sha256((HERE.parent.parent/p).read_bytes()).hexdigest()==digest for p,digest in evidence['source_sha256'].items()), 'timing source changed; run full measurement'
    randomizer=random.Random(20261003)
    for mode,name in ([] if "--memory-only" in sys.argv else enumerate(NAMES)):
      for size in SIZES:
        # Exact measured inputs: compare every semantic field, not only checksum
        # of a different tiny workload. Zero-iteration runs observe setup clocks.
        controls={k:invoke(p,mode,size,COUNT) for k,p in programs.items()}
        assert len({v[0] for v in controls.values()})==1,controls
        baseline={k:invoke(p,mode,size,0) for k,p in programs.items()}
        assert len({v[0] for v in baseline.values()})==1,baseline
        samples={k:[] for k in programs}
        for rep in range(REPS):
          order=list(programs);randomizer.shuffle(order)
          for k in order:
            observed,elapsed=invoke(programs[k],mode,size,COUNT)
            assert observed==controls[k][0],(name,size,k,observed)
            samples[k].append(elapsed)
        case={'workload':name,'size':size,'iterations':COUNT,'observation':controls['ts'][0],'setup_zero_ms':{k:v[1] for k,v in baseline.items()},'samples_ms':samples,'median_ms':{k:statistics.median(v) for k,v in samples.items()},'range_ms':{k:[min(v),max(v)] for k,v in samples.items()}}
        evidence['cases'].append(case)
        print(name,size,case['median_ms'],flush=True)
        (HERE/'results.json').write_text(json.dumps(evidence,indent=2)+'\n')
    # Peak RSS is a whole-process observation: includes setup and three warmups,
    # VM/runtime baseline and allocator retention. Not bytes per component.
    evidence['peak_rss_kib']={}
    for k,p in programs.items():
      args=['node',p] if str(p).endswith(('.js','.mjs')) else [p]
      args+=['2','1024',str(COUNT)]
      if k in ('native','list-native'):args+=['--threads','1','--gpu','off']
      evidence['peak_rss_kib'][k]=int(command(['python3',HERE.parent/'t10'/'rss.py',*args],timeout=15).strip())
    evidence['memory_method']='Linux wait4 child lifetime ru_maxrss, including inherited Python pre-exec launcher floor'
    evidence['source_sha256']={str(p.relative_to(HERE.parent.parent)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'core.bend',HERE/'main.bend',HERE.parent/'t10'/'core.bend',HERE.parent/'t10'/'main.bend',HERE.parent/'t10'/'reference.mjs',HERE.parent/'t08'/'core.bend',HERE.parent/'t08'/'log.bend']}
    evidence['artifact_pins']={'bend_binary_sha256':hashlib.sha256(Path('/home/node/.bend/bin/bend').read_bytes()).hexdigest(),'base_sha256':hashlib.sha256(Path('/home/node/.bend/bend2/base.bend').read_bytes()).hexdigest(),'reference_heads':{name:command(['git','-C',Path('/workspace/formal-proofs/bendvy/.references')/name,'rev-parse','HEAD']).strip() for name in ['bevy-ts','bevy','bend2']}}
    (HERE/'results.json').write_text(json.dumps(evidence,indent=2)+'\n')
print('S-LAYOUT measurements complete; thresholds remain unapproved',flush=True)
