#!/usr/bin/env python3
"""Actual new rank2 owner-result authority/quantity controls, exact source pins."""
import argparse,pathlib,subprocess,json,hashlib,shutil,os,time
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});h=pathlib.Path(__file__).resolve().parent;ROOT=h.parents[2];sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Fresh private flat-owner rank2 Type/access controls, no universal authority proof','cpu':[8],'checkerDiagnosticLimitSeconds':15,'defaultProofSeconds':5,'cases':[]};core=a.output/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);r['sources29']={p.name:sha(p) for p in core.glob('*.bend')};assert len(r['sources29'])==29
for p in (h/'authority').glob('*.bend'):shutil.copyfile(p,core/p.name)
shutil.copyfile(h/'getter-control-flat.bend',core/'getter-control-flat.bend');shutil.copyfile(ROOT/'experiments/s-prep/primitive-storage-integration/owners.bend',core/'owners.bend')
for name in ['positive','write-read','undeclared','duplicate-owner','inspect-owner','escape-owner-data','cross-schema']:
 args=['bend',core/(name+'.bend'),'--check-only'];t=time.monotonic();v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=15);out=v.stdout+v.stderr;(a.output/(name+'.txt')).write_text(out);expected=0 if name=='positive' else 1;assert v.returncode==expected,(name,v.returncode,out);assert ('ALL PROOFS CHECK' if expected==0 else 'SOME PROOFS FAIL') in out
 if expected:assert 'Location: bad' in out,(name,out)
 if name=='write-read':assert '- expected : A.Motion' in out and '- observed : bad~P' in out
 if name=='undeclared':assert '- expected : A.Health' in out and '- observed : bad~P' in out
 r['cases'].append({'subject':name,'sourceSHA256':sha(core/(name+'.bend')),'exit':v.returncode,'seconds':time.monotonic()-t,'diagnosticSHA256':sha(a.output/(name+'.txt'))});(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
r['status']='NEW_FLAT_OWNER_AUTHORITY_POSITIVE_SIX_INTENDED_NEGATIVES_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
