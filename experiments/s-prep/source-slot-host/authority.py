#!/usr/bin/env python3
"""Finite opaque-provider typing controls, not a universal authority theorem."""
import argparse,hashlib,json,pathlib,shutil,subprocess,time
H=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists()
subprocess.run(['python3',str(H/'verify.py'),str(a.overlay)],check=True);shutil.copytree(a.overlay,a.output)
header='import Base\nimport ./host.bend as H\nimport ./audited-invoker.bend as IA\nimport ./types.bend as T\n'
cases={
 'declared-write':('def good(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,owner:Tx) -> Tx:\n  set(owner,T.PositionToken{},55)\n',None),
 'declared-read':('def good(-Tx:Type,get:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,owner:Tx) -> Tx & T.Access<T.PositionView>:\n  get(owner,T.PositionToken{})\n',None),
 'write-through-read':('def bad(-Tx:Type,get:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,owner:Tx) -> Tx:\n  IA.prototype_slot_host_motion_set_main0(owner,T.PositionToken{},55)\n',['expected : IA.Wrapped<transaction.Tx<storage.World<T.MotionSchema, cached-payload.PrototypeMotionMainSlot','observed : Tx','Location: bad']),
 'undeclared-access':('def bad(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,owner:Tx) -> Tx & T.Access<T.VitalsView>:\n  IA.prototype_slot_host_health_read_main(owner,T.VitalsToken{})\n',['expected : IA.Wrapped<transaction.Tx<storage.World<T.HealthSchema, cached-payload.PrototypeHealthMainSlot','observed : Tx','Location: bad']),
 'cross-schema':('def bad(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,owner:Tx) -> Tx:\n  set(owner,T.VitalsToken{},55)\n',['expected : T.PositionToken','observed : T.VitalsToken']),
 'clone-owner':('def bad(-Tx:Type,owner:Tx) -> Tx & Tx:\n  (owner,owner)\n',['owner (consumed more than once)'])}
receipts=[];failed=False
for name,(body,anchors) in cases.items():
 f=a.output/'experiments/s-integrate'/('authority-'+name+'.bend');f.write_text(header+body);cmd=['taskset','-c','10','timeout','-k','1s','15s','bend',str(f),'--check-only'];start=time.monotonic();r=subprocess.run(cmd,capture_output=True,text=True,timeout=17);out=r.stdout+r.stderr;(a.output/(name+'.txt')).write_text(out)
 good=(r.returncode==0 and 'ALL PROOFS CHECK' in out) if anchors is None else (r.returncode==1 and 'SOME PROOFS FAIL' in out and all(x in out for x in anchors))
 receipts.append({'case':name,'status':'PASS' if good else 'FAIL','expectation':'positive' if anchors is None else 'intended rejection','anchors':anchors,'returncode':r.returncode,'command':cmd,'elapsedSeconds':time.monotonic()-start,'sourceSHA256':hashlib.sha256(f.read_bytes()).hexdigest()});failed|=not good
(a.output/'authority-evidence.json').write_text(json.dumps({'status':'FAIL' if failed else 'FINITE_AUTHORITY_CONTROLS_PASS','input29':json.loads((H/'output-pins.json').read_text())['outputPins29'],'cases':receipts,'diagnosticCheckerSeconds':15,'defaultProofCheckerSeconds':5,'noRuntimeOrUniversalProof':True},indent=2)+'\n');print(json.dumps(receipts,indent=2));raise SystemExit(int(failed))
