#!/usr/bin/env python3
"""Exact intended authority/type controls for frozen query getters."""
import argparse,hashlib,json,pathlib,signal,subprocess,tempfile,os
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,default=HERE/'authority-evidence.json');a=p.parse_args()
receipt={'status':'INCOMPLETE','scope':'Intended finite type controls; no universal authority or proof acceptance','commands':[],'runtimeSources':{}}
def run(args,limit=15,ok=0):
 child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.communicate();raise
 receipt['commands'].append({'argv':list(map(str,args)),'limitSeconds':limit,'exit':child.returncode,'out':out,'err':err});a.output.write_text(json.dumps(receipt,indent=2)+'\n');assert child.returncode==ok,receipt['commands'][-1];return out+err
assert 'bend 2.0.35' in run(['bend','version'],5);run(['bend','guide'],5)
with tempfile.TemporaryDirectory(prefix='frozen-query-authority-') as name:
 stage=pathlib.Path(name)
 for f in (a.overlay/'experiments/s-integrate').glob('*.bend'):
  (stage/f.name).write_bytes(f.read_bytes());receipt['runtimeSources'][f.name]=hashlib.sha256(f.read_bytes()).hexdigest()
 assert len(receipt['runtimeSources'])==29
 for n in ['getter-control.bend','authority-positive.bend','authority-write-read-negative.bend','authority-undeclared-negative.bend','authority-cross-negative.bend']:(stage/n).write_bytes((HERE/n).read_bytes())
 (stage/'owners.bend').write_bytes((ROOT/'experiments/s-prep/primitive-storage-integration/owners.bend').read_bytes())
 src=(HERE/'authority-cross-negative.bend').read_text();assert src.count('S.Handle<OtherQuerySchema>')==1
 (stage/'authority-cross-positive.bend').write_text(src.replace('S.Handle<OtherQuerySchema>','S.Handle<F.QuerySchemaOne>').replace('def bad(','def control('))
 for n in ['authority-positive.bend','authority-cross-positive.bend']:assert 'ALL PROOFS CHECK' in run(['taskset','-c','8','bend',stage/n,'--check-only'])
 for n,want,got in [('write-read','A.Motion','bad~P'),('undeclared','A.Health','bad~P'),('cross','S.Handle<F.QuerySchemaOne>','S.Handle<OtherQuerySchema>')]:
  text=run(['taskset','-c','8','bend',stage/f'authority-{n}-negative.bend','--check-only'],ok=1)
  for line in ['SOME PROOFS FAIL','Location: bad',f'- expected : {want}',f'- observed : {got}']:assert line in text,(n,line,text)
receipt['status']='TWO_POSITIVE_AND_THREE_INTENDED_TYPE_NEGATIVES_PASS';a.output.write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
