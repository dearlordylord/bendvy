#!/usr/bin/env python3
"""Executable typing diagnostic only; no proof/default checker policy changes."""
import argparse,json,pathlib,subprocess,time
p=argparse.ArgumentParser();p.add_argument('overlay',type=pathlib.Path);p.add_argument('--evidence',type=pathlib.Path,required=True);a=p.parse_args();a.evidence.mkdir(parents=True,exist_ok=False);h=pathlib.Path(__file__).resolve().parent
subprocess.run(['python3',str(h/'verify.py'),str(a.overlay)],check=True)
receipts=[]
for name,cmd,cap in [('version',['bend','version'],5),('guide',['bend','guide'],5),('host-check',['taskset','-c','10','timeout','-k','1s','15s','bend',str(a.overlay/'experiments/s-integrate/host.bend'),'--check-only'],17)]:
 start=time.monotonic();r=subprocess.run(cmd,capture_output=True,text=True,timeout=cap);out=r.stdout+r.stderr;(a.evidence/(name+'.txt')).write_text(out);receipts.append({'name':name,'command':cmd,'returncode':r.returncode,'elapsedSeconds':time.monotonic()-start,'supervisionSeconds':cap,'diagnosticCheckerSeconds':15 if name=='host-check' else None});assert r.returncode==0
 if name=='host-check':assert 'ALL PROOFS CHECK' in out and 'SOME PROOFS FAIL' not in out
(a.evidence/'commands.json').write_text(json.dumps({'status':'EXECUTABLE_TYPE_CHECK_PASS','notProof':True,'cpu':10,'defaultProofCheckerUnchangedSeconds':5,'commands':receipts},indent=2)+'\n')
