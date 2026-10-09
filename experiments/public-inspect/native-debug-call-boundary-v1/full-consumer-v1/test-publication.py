"""Portable no-child stale-cache and incremental-publication controls."""
from pathlib import Path
import hashlib,json,types,tempfile,sys,py_compile,os,importlib.util
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
raw=(HERE/'execution.py').read_bytes();execution=types.ModuleType('execution');execution.__file__=str(HERE/'execution.py');exec(compile(raw,execution.__file__,'exec'),execution.__dict__)
with tempfile.TemporaryDirectory(prefix='bendvy-source-publication-') as d:
 root=Path(d)
 # Exact mtime/size cache mismatch is reproducible with ordinary legacy loader.
 def poison(path,source):
  path.parent.mkdir(parents=True,exist_ok=True);bad="raise RuntimeError('STALE_CACHE_EXECUTED')\n";assert len(source)>=len(bad)
  path.write_text(bad+'#'*(len(source)-len(bad)));os.utime(path,(1700000000,1700000000));py_compile.compile(str(path),doraise=True)
  path.write_text(source);os.utime(path,(1700000000,1700000000))
 simple=root/'same.py';poison(simple,'VALUE=2\n'+'#'*100)
 legacy=importlib.util.spec_from_file_location('legacy',simple);module=importlib.util.module_from_spec(legacy)
 try:legacy.loader.exec_module(module)
 except RuntimeError as e:assert str(e)=='STALE_CACHE_EXECUTED'
 else:raise AssertionError('negative stale-cache reproduction failed')
 fresh=execution.load('fresh',simple,{str(simple):execution.sha(simple)});assert fresh.VALUE==2
 # Second publication fails after partial write: row, exit and both raw joins persist.
 record={'commands':[]};result={'exit':17,'failure':None,'stdout':b'whole-output','stderr':b'original-error'}
 row=execution.record_returned(record,{'label':'control','argv':['FAKE'],'capSeconds':5},result,root);pins={}
 originalCapture=execution.capture
 def secondCapture(path,raw):
  if str(path).endswith('.stderr'):
   Path(path).write_bytes(raw[:3]);raise OSError('controlled second capture failure')
  return originalCapture(path,raw)
 execution.capture=secondCapture
 try:execution.publish_streams(row,result,pins)
 except OSError:pass
 else:raise AssertionError('controlled capture failure absent')
 assert record['commands'][0]['exit']==17 and row['stdout']['publication']=='complete'
 assert row['stderr']['publication']=='failed' and row['stderr']['bytes']==len(result['stderr']) and row['stderr']['sha256']==hashlib.sha256(result['stderr']).hexdigest()
 assert row['stderr']['retainedPartialBytes']==3 and Path(row['stdout']['path']).read_bytes()==result['stdout']
 # Returned status/raw metadata already exist when artifact hashing later refuses.
 assert row['failure'] is None and row['stderr']['publicationError']=='controlled second capture failure'
 # Artifact hash failure happens after returned row and preserves ledger failure.
 artifact=root/'partial.c';artifact.write_bytes(b'partial-C')
 originalSha=execution.sha
 def failedSha(path):
  if Path(path)==artifact:raise OSError('controlled artifact hash failure')
  return originalSha(path)
 execution.sha=failedSha
 try:execution.capture_artifact(record,artifact,pins)
 except OSError:pass
 else:raise AssertionError('controlled artifact failure absent')
 assert row['exit']==17 and record['artifactLedger'][0]['captureError']=='controlled artifact hash failure'
 execution.sha=originalSha
 boundaryPath=execution.ROOT/'scripts/evidence_boundary.py';boundary=execution.load('boundary',boundaryPath,{str(boundaryPath):originalSha(boundaryPath)})
 guards=[];receipt=root/'failure-receipt.json'
 try:
  with boundary.ReceiptBoundary(record,receipt,[('final',lambda:guards.append('final'))]):
   with boundary.GuardBoundary([('post',lambda:guards.append('post'))]):raise OSError('retained publication failure')
 except OSError:pass
 assert guards==['post','final'] and json.loads(receipt.read_text())['commands'][0]['exit']==17
print(json.dumps({'staleTimestampSizeNegativeReproduced':True,'returnedRowAndPartialStreamPreserved':True,'artifactHashFailurePreserved':True,'namedPostAndUnconditionalReceipt':True,'compilerChildren':0}))
