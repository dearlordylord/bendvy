#!/usr/bin/env python3
"""Build the unchanged static Motion64 workload against a cache-boxed overlay."""
import argparse,hashlib,json,os,pathlib,signal,subprocess,time

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def run(argv,limit,cpu):
 start=time.monotonic()
 p=subprocess.Popen(['taskset','-c',str(cpu),*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 timed=False
 try: output=p.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:
  timed=True; os.killpg(p.pid,signal.SIGKILL); output=p.communicate()[0]
 return {'argv':argv,'cpu':cpu,'limitSeconds':limit,'exit':p.returncode,'timeout':timed,'elapsedSeconds':time.monotonic()-start,'output':output}

def main():
 a=argparse.ArgumentParser();a.add_argument('--candidate',type=pathlib.Path,required=True);a.add_argument('--baseline',type=pathlib.Path,required=True);a.add_argument('--output',type=pathlib.Path,required=True);a.add_argument('--cpu',type=int,default=10);args=a.parse_args()
 args.output.mkdir(parents=True,exist_ok=False)
 receipt={'status':'INCOMPLETE','commands':[],'inputs':{},'productionAdoption':False,'performanceAcceptance':False}
 for name in ('batch.bend','measurement-bend.bend'):
  source=args.baseline/name
  original=source.read_text()
  rewritten=original.replace('/tmp/bendvy-live-first-native/',str(args.candidate.resolve())+'/')
  assert rewritten!=original
  target=args.output/name;target.write_text(rewritten)
  receipt['inputs'][name]={'baselineSHA256':sha(source),'candidateSHA256':sha(target),'adaptation':'Only exact absolute runtime-overlay prefix replacement'}
 cmds=[(['bend',str(args.output/'batch.bend'),'--check-only'],15),(['bend',str(args.output/'batch.bend'),'-o',str(args.output/'batch.c')],30),(['clang','-O3',str(args.output/'batch.c'),'-o',str(args.output/'batch-native'),'-lm','-pthread'],120)]
 for argv,limit in cmds:
  r=run(argv,limit,args.cpu);receipt['commands'].append(r)
  (args.output/'build.json').write_text(json.dumps(receipt,indent=2)+'\n')
  if r['exit']!=0: receipt['status']='BUILD_FAIL';break
 else:receipt['status']='STATIC_NATIVE_BUILD_PASS';receipt['generatedCSHA256']=sha(args.output/'batch.c')
 (args.output/'build.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
if __name__=='__main__':main()
