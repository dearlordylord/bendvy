#!/usr/bin/env python3
"""Exact frozen batches: bounded inlining/deopt diagnosis, no clock comparison."""
from pathlib import Path
import sys,os,json,argparse,hashlib,importlib.util
R=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
r={'status':'INCOMPLETE','cpu':7,'commands':[],'scope':'Read-only exact generated full65 trace; no comparative clocks or candidate rewriting'}
def run(args,label):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});assert code==0,out[-1000:];return out
try:
 frozen=Path('/tmp/bendvy-swap-selective-frozen-v1');s=a.schema.lower();program=frozen/(s+'.js');receipt=frozen/(s+'.js.recipe.json');freeze=json.load(open(frozen/'freeze.json'))
 for rel,digest in freeze.items():assert sha(frozen/rel)==digest
 rec=json.load(open(receipt));cat=json.load(open(frozen/'recipe/input-pins.json'));pin=cat[rec['inputSHA256']] if 'inputSHA256' in rec else cat[rec['inputSHA']]
 for rel,digest in pin['runtimeSourcePins'].items():assert sha(Path(pin['sourceRoot'])/rel)==digest
 for path,digest in pin['provenancePins'].items():assert sha(path)==digest
 native=Path('/tmp/bendvy-cursor-descending-'+s+'-build-v1');r['pins']={str(p):sha(p) for p in [program,receipt,frozen/'freeze.json',frozen/'recipe/rewrite.cjs',frozen/'recipe/input-pins.json',frozen/'recipe/parent-joins.json',native/'build.json',native/'batch.c',native/'batch-native']};r.update(sourceRoot=pin['sourceRoot'],sourcePins=pin['runtimeSourcePins'])
 ref=a.output/'reference.mjs';run([sys.executable,R/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',R/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64'],'prepare');ts=json.loads(run(['node',ref],'ts'))
 spec=importlib.util.spec_from_file_location('V',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 preload=a.output/'blocking-stdout.cjs';preload.write_text("if(!process.stdout._handle)throw Error('stdout handle');process.stdout._handle.setBlocking(true);\n");r['contextPins']={str(preload):sha(preload)}
 raw=run(['node','--require',preload,'--trace-turbo-inlining','--trace-deopt',program],'trace');records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==65
 for line,w in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,w);assert V.normalized(json.loads(line),a.schema)==w['final']
 names=['__fold_state_reuse_3__swap_split_0','__fold_state_reuse_2','__fold_state_reuse_4'];lines=[x for x in raw.splitlines() if any(n in x for n in names)];(a.output/'selected-trace.txt').write_text('\n'.join(lines)+'\n');r.update(status='EXACT_FROZEN_FULL65_INLINING_TRACE_PASS',worlds=65,selectedTraceSHA=sha(a.output/'selected-trace.txt'),limits='Trace proves observed JIT decisions, not all calls or comparative elapsed performance')
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
