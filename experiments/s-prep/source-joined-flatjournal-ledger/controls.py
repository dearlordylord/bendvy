#!/usr/bin/env python3
"""Execute unchanged protected finite controls with exact local live-family recognition."""
import argparse,pathlib,json,hashlib,importlib.util,importlib.machinery,os,sys,subprocess,time,signal
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--gate',choices=['tx','access','static'],required=True);p.add_argument('--mutation',choices=['lost-mark','inverse-order']);a=p.parse_args();a.output.mkdir(exist_ok=False)
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';HERE=pathlib.Path(__file__).resolve().parent;BFILE=ROOT/'experiments/t05/run.py';FAFILE=BASE/'fused-adaptation.py';LOCAL=HERE/'local-fused-adaptation.py';PCFILE=BASE/'provider_controls.py';LOCALPC=HERE/'local-provider-controls.py';os.sched_setaffinity(0,{10});os.environ['BENDVY_CHECKER_SECONDS']='15'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','gate':a.gate,'mutation':a.mutation,'CPU':10,'checkerDiagnosticSeconds':15,'defaultProofSeconds':5,'codegenSeconds':30,'clangSeconds':120,'runtimeSeconds':5,'localRecognizerSHA256':sha(LOCAL),'localStaticRegistrationSHA256':sha(LOCALPC),'sharedProviderControlsSHA256':sha(PCFILE),'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'commands':[],'scope':'Fresh finite exact-source controls; no full22/proof/performance acceptance'}
assert len(r['sourcePins'])==29 and all(sha(a.overlay/name)==pin for name,pin in r['sourcePins'].items()),'Actual source29 differs from input manifest'

def save():(a.output/'executor.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 st=time.monotonic();child=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=child.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 rec={'argv':argv,'limitSeconds':timeout,'exit':child.returncode,'timeout':timed,'seconds':time.monotonic()-st,'output':out};r['commands'].append(rec);save();assert child.returncode==expected,rec;return out
original_loader=importlib.machinery.SourceFileLoader.exec_module
spec=importlib.util.spec_from_file_location('local_fused',LOCAL);local=importlib.util.module_from_spec(spec);spec.loader.exec_module(local)
pcspec=importlib.util.spec_from_file_location('local_pc',LOCALPC);localpc=importlib.util.module_from_spec(pcspec);pcspec.loader.exec_module(localpc)
def hook(loader,module):
 original_loader(loader,module)
 if pathlib.Path(loader.path).resolve()==BFILE.resolve():module.command=command
 if pathlib.Path(loader.path).resolve()==FAFILE.resolve():module.main_sites=local.main_sites;module.mutation=local.mutation
 if pathlib.Path(loader.path).resolve()==PCFILE.resolve():module.static_registration=localpc.static_registration;module.adapt_tx_fixture=localpc.adapt_tx_fixture
importlib.machinery.SourceFileLoader.exec_module=hook;sys.path.insert(0,str(BASE))
path=BASE/({'tx':'tx-controls-run.py','access':'access-run.py','static':'static-world-run.py'}[a.gate]);r['runnerSHA256']=sha(path);r['sharedRecognizerSHA256']=sha(FAFILE)
try:
 sys.argv=[str(path),'--overlay',str(a.overlay),'--output',str(a.output/'actual'),'--cpu','10']
 if a.gate=='access':sys.argv=[str(path),str(a.overlay),'--evidence',str(a.output/'actual.json'),'--cpu','10']
 if a.gate=='tx':sys.argv+=['--split-schemas']+(['--mutation',a.mutation] if a.mutation else [])
 path=(HERE/'static-world-run.py') if a.gate=='static' else path
 r['actualRunnerPath']=str(path);r['actualRunnerSHA256']=sha(path)
 spec=importlib.util.spec_from_file_location('protected_runner',path);runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
 if a.gate!='access':runner.main()
 r['status']='PROTECTED_FINITE_EXECUTOR_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:importlib.machinery.SourceFileLoader.exec_module=original_loader;save()
