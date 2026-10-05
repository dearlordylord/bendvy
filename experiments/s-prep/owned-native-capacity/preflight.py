"""Bind authoritative base plus separately frozen derived capacity recipe."""
import hashlib,importlib.util,json,subprocess
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
 assert sha(H/'source-bindings.json')=='b645d29e0078f81741b93d5ff6869e78569cc3ada7f9a8f239a5488642d0f6b0','Frozen source bindings mismatch'
 bindings=json.loads((H/'source-bindings.json').read_text());recipe=json.loads((root/'receipt.json').read_text())
 assert sha(root/'receipt.json')==bindings['rawReceiptSHA256'],'Derived receipt mismatch'
 for backend in ('native','javascript'):
  expected=dict(bindings['sharedSourceClosure'],**bindings['backends'][backend]['sourceOverrides'])
  assert recipe['backends'][backend]['sourceClosure']==expected,'Backend recipe mismatch'
  folder=root/backend;manifest=json.loads((folder/'overlay.json').read_text());assert manifest['sources']==expected,'Backend manifest mismatch'
  for relative,digest in expected.items():
   source=folder/relative;assert not source.is_symlink() and sha(source)==digest,'Backend source mismatch: '+relative
  assert sha(H/('column-'+backend+'.bend'))==expected['experiments/s-integrate/native-columns.bend'],'Backend helper mismatch'
 return {'recipeSHA256':sha(root/'receipt.json'),'sourceBindingsSHA256':sha(H/'source-bindings.json'),'backendSources':{b:len(recipe['backends'][b]['sourceClosure']) for b in recipe['backends']}}

def evaluator_root(root):
 assert root.resolve()==PROJECT.resolve(),'Evaluator import root differs from guarded PROJECT'
 return str(PROJECT)

def control_sources():
 pins={'experiments/s-prep/owned-write-query-integration/controls-run.py':'f012ec4248a86e5ae997ad2811313203b839d7236d324c39123343f52751dbeb','experiments/s-prep/owned-write-query-integration/controls.bend':'edd39c0b345b6b60ada54f9fdc50ecebddf89574dba2f386103e0f88414c037d'}
 for relative,digest in pins.items():
  source=PROJECT/relative
  assert not source.is_symlink() and source.resolve().is_relative_to(PROJECT.resolve()),'Control source path mismatch: '+relative
  assert sha(source)==digest,'Frozen control source mismatch: '+relative
  tracked=subprocess.check_output(['git','-C',str(PROJECT),'show','HEAD:'+relative],timeout=5)
  assert source.read_bytes()==tracked,'Control source differs from tracked HEAD: '+relative
 return pins
