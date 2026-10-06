#!/usr/bin/env python3
"""Diagnostic generated-C attribute-only change; one adjacent full-state comparison."""
import argparse,gzip,hashlib,json,os,pathlib,signal,subprocess,time
HERE=pathlib.Path(__file__).resolve().parent
BASE_C_SHA='b4b12ec1b61887b909e870454616cd46f542145f7dc43319a11b74d5e0e543b3'
ANCHORS=('OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {','OUTLINE u64 heap_alloc_miss(Env e, u32 cls) {')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def command(argv,limit,cpu):
 p=subprocess.Popen(['taskset','-c',str(cpu),*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);start=time.monotonic();timed=False
 try:out=p.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(p.pid,signal.SIGKILL);out=p.communicate()[0]
 return {'argv':argv,'limitSeconds':limit,'cpu':cpu,'exit':p.returncode,'timeout':timed,'elapsedSeconds':time.monotonic()-start,'output':out}
def main():
 p=argparse.ArgumentParser();p.add_argument('--baseline-c',type=pathlib.Path,required=True);p.add_argument('--baseline-native',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--comparison-runner',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False)
 assert sha(a.baseline_c)==BASE_C_SHA,'Unsupported generated C source'
 source=a.baseline_c.read_text();derived=source
 for header in ANCHORS:
  assert source.count(header)==1,header
  derived=derived.replace(header,header.replace('OUTLINE','INLINE',1),1)
 restored=derived
 for header in ANCHORS:restored=restored.replace(header.replace('OUTLINE','INLINE',1),header,1)
 assert restored==source,'Runtime operation/body changed'
 manifest=json.loads((a.overlay/'overlay.json').read_text());pins=manifest['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items())
 candidate=a.output/'batch.c';candidate.write_text(derived)
 receipt={'status':'INCOMPLETE','scope':'Exactly two generated runtime helper definition attributes; unchanged Bend sources, C bodies, operation order and algorithms','anchors':list(ANCHORS),'baselineCSHA256':sha(a.baseline_c),'derivedCSHA256':sha(candidate),'baselineNativeSHA256':sha(a.baseline_native),'comparisonRunnerSHA256':sha(a.comparison_runner),'recipeSHA256':sha(pathlib.Path(__file__)),'runtimeSources':pins,'commands':[],'performanceAcceptance':False,'productionAdoption':False,'canonicalCohort':False}
 for label,text in [('baseline',source),('derived',derived)]:
  (a.output/(label+'.c.gz')).write_bytes(gzip.compress(text.encode(),mtime=0))
 clang=command(['clang','-O3',str(candidate),'-o',str(a.output/'batch-native'),'-lm','-pthread'],120,a.cpu);receipt['commands'].append(clang)
 if clang['exit']!=0:receipt['status']='COMPILE_FAIL'
 else:
  receipt['derivedNativeSHA256']=sha(a.output/'batch-native')
  argv=['python3',str(a.comparison_runner),'--baseline-overlay',str(a.overlay),'--candidate-overlay',str(a.overlay),'--baseline-native',str(a.baseline_native),'--candidate-native',str(a.output/'batch-native'),'--schema','Motion','--cpu',str(a.cpu),'--output',str(a.output/'comparison')]
  comparison=command(argv,60,a.cpu);receipt['commands'].append(comparison)
  receipt['status']='ADJACENT_DIAGNOSTIC_PASS' if comparison['exit']==0 else 'COMPARISON_FAIL'
  if (a.output/'comparison/evidence.json').exists():receipt['comparisonReceiptSHA256']=sha(a.output/'comparison/evidence.json')
 assert pins==json.loads((a.overlay/'overlay.json').read_text())['sources'] and all(sha(a.overlay/n)==v for n,v in pins.items())
 (a.output/'recipe.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
if __name__=='__main__':main()
