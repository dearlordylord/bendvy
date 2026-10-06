#!/usr/bin/env python3
"""Standalone finite type/restore witness; no source29 or benchmark integration."""
from pathlib import Path
import json,hashlib,subprocess,signal,os,argparse
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--fixture',type=Path,default=H/'miniature.bend');p.add_argument('--counterexample',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'runnerSHA256':sha(Path(__file__)),'expectedSHA256':sha(H/'expected.txt'),'installedBaseSHA256':sha(Path('/home/node/.bend/bend2/base.bend')),'status':'INCOMPLETE','cpu':10,'commands':[],'scope':'Standalone affine carrier witness, not ECS callback/integration acceptance'}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args,cap,label):
 cmd=['taskset','-c','10',*map(str,args)];env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';c=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env);entry={'argv':cmd,'capSeconds':cap};r['commands'].append(entry)
 try:o,e=c.communicate(timeout=cap)
 except subprocess.TimeoutExpired:os.killpg(c.pid,signal.SIGKILL);o,e=c.communicate();entry['timeout']=True
 for suffix,text in [('stdout',o),('stderr',e)]:f=a.output/(label+'.'+suffix);f.write_text(text);entry[suffix+'SHA256']=sha(f)
 entry['exit']=c.returncode;save();return c.returncode,o,e
try:
 src=a.output/'miniature.bend';src.write_bytes(a.fixture.read_bytes());r['sourceSHA256']=sha(src);c,o,e=run(['bend',src,'--check-only'],15,'check');assert c==0 and 'ALL PROOFS CHECK' in o+e,(o,e)
 for backend in ['JS','Native']:
  dst=a.output/('mini.js' if backend=='JS' else 'mini.c');c,o,e=run(['bend',src,'-o',dst],30,backend+'-emit');assert c==0,(o,e)
  if backend=='Native':c,o,e=run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dst,'-o',a.output/'native','-lm','-pthread'],120,'clang');assert c==0,(o,e)
  c,o,e=run(['node',dst] if backend=='JS' else [a.output/'native','--threads','1','--gpu','off'],5,backend+'-run');assert c==0 and ((o==(H/'lost-owner-expected.txt').read_text() and o!=(H/'expected.txt').read_text()) if a.counterexample else (o==(H/'expected.txt').read_text())),(o,e);r[backend]={'programSHA256':sha(dst),'records':3}
 s=src.read_text();head=s[:s.index('def main()')];negatives={'clone':'def bad(batch:DetachedBatch<MiniSchema,OwnedPayload>) -> DetachedBatch<MiniSchema,OwnedPayload> & DetachedBatch<MiniSchema,OwnedPayload>:\n  (batch,batch)\n','cross-schema':'type OtherSchema is Data:\n  OtherSchema{}\ndef bad(batch:DetachedBatch<MiniSchema,OwnedPayload>) -> DetachedBatch<OtherSchema,OwnedPayload>:\n  batch\n'}
 for label,body in negatives.items():
  subject=a.output/(label+'.bend');subject.write_text(head+body+'def main() -> IO(Unit):\n  IO.pure(Unit,Unit{})\n');c,o,e=run(['bend',subject,'--check-only'],15,label+'-check');assert c!=0 and 'SOME PROOFS FAIL' in o+e and 'Location: bad' in o+e,(o,e)
 r['status']='TYPED_TWO_BACKEND_RUNTIME_COUNTEREXAMPLE_DETECTED' if a.counterexample else 'FINITE_AFFINE_CARRIER_RESTORE_ORDER_BOTH_BACKENDS_AND_TWO_NEGATIVES_PASS'
except BaseException as e:r['error']=repr(e);save();raise
save();print(r['status'])
