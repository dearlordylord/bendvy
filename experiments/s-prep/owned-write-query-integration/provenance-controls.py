#!/usr/bin/env python3
import argparse,json,tempfile,shutil,sys
from pathlib import Path
import provenance as G
p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--evidence',required=True,type=Path);a=p.parse_args()
result={'status':'PASS','scope':'Actual provenance guard; rejects before evaluator import/build/Node','controls':[]}
baseline=G.verify(a.overlay);result['baseline']=baseline
original_git=G.git;original_sha=G.sha
def reject(name,action):
 try:action()
 except AssertionError as e:result['controls'].append({'name':name,'status':'REJECTED_BEFORE_EXECUTION','diagnostic':str(e)})
 else:raise AssertionError(name+' accepted')
try:
 G.git=lambda root,*args: b'0'*40+b'\n' if root==G.REFERENCE and args==('rev-parse','HEAD') else original_git(root,*args)
 reject('moved-reference-HEAD',lambda:G.verify(a.overlay));G.git=original_git
 G.git=lambda root,*args: b'tampered' if root==G.REFERENCE and args[0]=='show' else original_git(root,*args)
 reject('changed-reference-import-blob',lambda:G.verify(a.overlay));G.git=original_git
 for name,target in [('protected-validator','experiments/s-integrate/measurement-bend-run.py'),('protected-callback','experiments/s-integrate/measurement-bend.bend'),('reference-adapter','experiments/s-integrate/measurement-reference.mjs')]:
  G.sha=lambda path,target=target:'0'*64 if path==G.ROOT/target else original_sha(path)
  reject(name,lambda:G.verify(a.overlay));G.sha=original_sha
 G.sha=lambda path:'0'*64 if path==G.HERE/'prepare.py' else original_sha(path)
 reject('derivation-recipe',lambda:G.verify(a.overlay));G.sha=original_sha
 G.sha=lambda path:'0'*64 if path==G.HERE/'provenance-pins.json' else original_sha(path)
 reject('repinned-provenance-ledger',lambda:G.verify(a.overlay));G.sha=original_sha
 with tempfile.TemporaryDirectory(prefix='held-provenance-control-') as tmp:
  overlay=Path(tmp)/'overlay';shutil.copytree(a.overlay,overlay)
  manifest=overlay/'overlay.json';old=manifest.read_text();data=json.loads(old);data['sources']['experiments/s-integrate/held-adapter.bend']='0'*64;manifest.write_text(json.dumps(data))
  reject('self-consistent-repinned-manifest',lambda:G.verify(overlay));manifest.write_text(old)
  src=overlay/'experiments/s-integrate/held-adapter.bend';src.write_text(src.read_text()+'\n#tamper\n')
  reject('changed-derived-adapter',lambda:G.verify(overlay))
 assert 'frozen_measure' not in sys.modules
 result['evaluatorImported']=False
finally:
 G.git=original_git;G.sha=original_sha
 a.evidence.write_text(json.dumps(result,indent=2)+'\n')
print(result['status'])
