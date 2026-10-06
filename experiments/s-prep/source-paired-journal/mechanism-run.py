#!/usr/bin/env python3
"""Finite independent order oracle on actual pending/packing/unwind helpers."""
import pathlib,argparse,json,hashlib,shutil,os,sys
HERE=pathlib.Path(__file__).parent
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates');import supervisor
p=argparse.ArgumentParser();p.add_argument('--source-root',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();expected=(HERE/'expected.txt').read_text();r={'status':'INCOMPLETE','scope':'Finite seven pending/order traces with actual generic unpack/unwind and affine Array owner. Not actual full Tx/fallback authority gate.','sourceRoot':str(a.source_root),'fixtureSHA256':sha(HERE/'mechanism.bend'),'literalOracleSHA256':sha(HERE/'expected.txt'),'commands':[],'variants':{}}
def run(argv,cap):
 code,out=supervisor.execute(list(map(str,argv)),cap);n=len(r['commands']);(a.output/f'command-{n}.txt').write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':cap,'exit':code,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});assert code==0,out[-2500:];return out
try:
 m=json.load(open(a.source_root/'overlay.json'));assert len(m['sources'])==29
 for name,pin in m['sources'].items():assert sha(a.source_root/name)==pin
 r['source29']=m['sources'];r['compilerWrapperSHA256']=sha(pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19'));assert r['compilerWrapperSHA256']=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
 for variant in ['original','lost-pending','reverse-pair']:
  directory=a.output/variant;directory.mkdir();root=a.source_root
  if variant!='original':
   root=directory/'overlay';root.mkdir()
   for name in m['sources']:
    dst=root/name;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes((a.source_root/name).read_bytes())
   target=root/'experiments/s-integrate'/('held-adapter.bend' if variant=='lost-pending' else 'transaction.bend');s=target.read_text()
   old='case PrototypePendingUndo{True{},space,id,old,tail}: X.PrototypeFlatMain{space,id,old,tail}' if variant=='lost-pending' else 'restore_main(restore_ledger(world,ledger_old),S.Handle{space,id},main_old)'
   new='case PrototypePendingUndo{True{},_,_,_,tail}: tail' if variant=='lost-pending' else 'restore_ledger(restore_main(world,S.Handle{space,id},main_old),ledger_old)'
   assert s.count(old)==1;s=s.replace(old,new);target.write_text(s)
  entry=directory/'main.bend';entry.write_text((HERE/'mechanism.bend').read_text().replace('OVERLAY',str(root)))
  run(['bend',entry,'--check-only'],15);run(['bend',entry,'-o',directory/'main.js'],30);run(['bend',entry,'-o',directory/'main.c'],30);run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',directory/'main.c','-pthread','-lm','-o',directory/'main.native'],120)
  v={}
  for backend,argv in [('JS',['node',directory/'main.js']),('Native',[directory/'main.native','--threads','1','--gpu','off'])]:
   actual=run(argv,5);(directory/(backend+'.txt')).write_text(actual);equal=actual==expected;assert equal==(variant=='original'),(variant,backend,actual);v[backend]={'equalLiteralOracle':equal,'records':len(actual.splitlines()),'outputSHA256':hashlib.sha256(actual.encode()).hexdigest()}
  r['variants'][variant]={'source29':{name:sha(root/name) for name in m['sources']},'lanes':v,'entrySHA256':sha(entry)}
 for name,pin in m['sources'].items():assert sha(a.source_root/name)==pin
 r['status']='FINITE_PENDING_ORDER_AND_COMPILING_MUTANTS_PASS'
except Exception as e:r['status']='FAIL';r['error']=repr(e)
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(r['status']=='FAIL')
