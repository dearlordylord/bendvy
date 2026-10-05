#!/usr/bin/env python3
"""One semantic construction per schema/backend; no ratio or qualification."""
import argparse,hashlib,importlib.util,json,os,subprocess,signal
from pathlib import Path
H=Path(__file__).resolve().parent;P=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
a=argparse.ArgumentParser();a.add_argument('--core',type=Path,required=True);a.add_argument('--output',type=Path,required=True);args=a.parse_args();args.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
r={'scope':'Finite same-work semantic method construction, not accepted loop','commands':[],'cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'batch':16}
def cmd(xs,limit=5):
 p=subprocess.Popen(list(map(str,xs)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate();r['commands'].append({'args':list(map(str,xs)),'limit':limit,'timeout':True,'output':o+e});raise
 r['commands'].append({'args':list(map(str,xs)),'limit':limit,'exit':p.returncode,'output':o+e if p.returncode else None});assert p.returncode==0,o+e;return o
try:
 for schema in ['Health','Motion']:
  folder=args.output/schema
  cmd(['python3',H/'prepare-bend.py','--core',args.core,'--output',folder,'--schema',schema,'--batch','16'])
  ts=folder/'reference.mjs';cmd(['python3',H/'prepare-ts.py','--source',P/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ts,'--schema',schema,'--batch','16'])
  tsout=folder/'reference.json';tsout.write_text(cmd(['node',ts]))
  check=cmd(['bend',folder/'batch.bend','--check-only']);assert 'ALL PROOFS CHECK' in check
  js=folder/'batch.js';c=folder/'batch.c';native=folder/'batch-native'
  cmd(['bend',folder/'batch.bend','-o',js],30);cmd(['bend',folder/'batch.bend','-o',c],30);cmd(['clang','-O3',c,'-pthread','-lm','-o',native],120)
  for backend,xs in [('JS',['node',js]),('Native',[native,'--threads','1','--gpu','off'])]:
   raw=folder/(backend+'.txt');raw.write_text(cmd(xs));receipt=folder/(backend+'-semantic.json');cmd(['python3',H/'semantic-check.py','--bend-output',raw,'--ts-output',tsout,'--schema',schema,'--batch','16','--evidence',receipt]);r['cases'].append({'schema':schema,'backend':backend,'status':'ALL_17_FULL_RECORDS_PASS','artifactSHA256':sha(js if backend=='JS' else native),'receipt':json.load(open(receipt))})
 r['status']='BOTH_SCHEMA_NATIVE_JS_FULL_BATCH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e))
r['runnerSHA256']=sha(Path(__file__));(args.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status']);raise SystemExit(r['status']=='FAIL')
