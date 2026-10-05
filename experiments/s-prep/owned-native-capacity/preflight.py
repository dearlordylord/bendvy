"""Bind authoritative base plus separately frozen derived capacity recipe."""
import hashlib,importlib.util,json
from pathlib import Path
H=Path(__file__).resolve().parent
PROJECT=Path('/workspace/formal-proofs/bendvy')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def base(overlay):
 source=PROJECT/'experiments/s-prep/owned-write-query-integration/provenance.py'
 assert sha(source)=='d560f0834d0f4373936402eb3e266e75ab6deebd30335059602768da2e25a215','Base guard version changed'
 sp=importlib.util.spec_from_file_location('authoritative_base_guard',source);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m)
 result=m.verify(overlay)
 return {'baseGuardSHA256':sha(source),'protectedSources':result['protectedSources'],'baseDerivedSources':result['derivedSources'],'referenceCommit':result['referenceCommit'],'referenceClosureDigest':hashlib.sha256(json.dumps(result['referenceClosureSHA256'],sort_keys=True).encode()).hexdigest(),'basePinsSHA256':result['pinsSHA256']}
def prepared(root):
 recipe=json.loads((root/'receipt.json').read_text());bindings=json.loads((H/'source-bindings.json').read_text())
 assert sha(root/'receipt.json')==bindings['rawReceiptSHA256'],'Derived receipt mismatch'
 for backend in ('native','javascript'):
  expected=dict(bindings['sharedSourceClosure'],**bindings['backends'][backend]['sourceOverrides'])
  assert recipe['backends'][backend]['sourceClosure']==expected,'Backend recipe mismatch'
  folder=root/backend;manifest=json.loads((folder/'overlay.json').read_text());assert manifest['sources']==expected,'Backend manifest mismatch'
  for relative,digest in expected.items():
   source=folder/relative;assert not source.is_symlink() and sha(source)==digest,'Backend source mismatch: '+relative
  assert sha(H/('column-'+backend+'.bend'))==expected['experiments/s-integrate/native-columns.bend'],'Backend helper mismatch'
 return {'recipeSHA256':sha(root/'receipt.json'),'sourceBindingsSHA256':sha(H/'source-bindings.json'),'backendSources':{b:len(recipe['backends'][b]['sourceClosure']) for b in recipe['backends']}}
