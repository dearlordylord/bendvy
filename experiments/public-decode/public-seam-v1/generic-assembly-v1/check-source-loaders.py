"""Portable stale-pyc/cached-module controls for both actual transport load chains."""
import hashlib,importlib.util,json,os,py_compile,sys,tempfile,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
QUALIFICATION=HERE.parents[1]/'adoption-v1/qualification-v1'
ROOT=Path('/workspace/formal-proofs/bendvy')
def h(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def load_source(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec)
 exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
 return module
def stale_subject(path,body):
 source=b'CACHE_SENTINEL="SRC"\n'+body;cached=b'CACHE_SENTINEL="PYC"\n'+body
 assert len(source)==len(cached)
 path.write_bytes(cached);os.utime(path,(1700000000,1700000000));py_compile.compile(str(path),doraise=True)
 path.write_bytes(source);os.utime(path,(1700000000,1700000000));pin=h(path)
 # Positive discriminator: timestamp loader really executes the stale bytes.
 spec=importlib.util.spec_from_file_location('stale_positive_control',path);old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
 assert old.CACHE_SENTINEL=='PYC' and h(path)==pin
 return pin
with tempfile.TemporaryDirectory() as temporary:
 home=Path(temporary);spine=home/'spine-report-v1';spine.mkdir()
 subject=home/'transport.py';pin=stale_subject(subject,(QUALIFICATION/'transport.py').read_bytes())
 copied=spine/'transport.py';copied.write_bytes((QUALIFICATION/'spine-report-v1/transport.py').read_bytes())
 poison=types.ModuleType('decode_complete_transport');poison.CACHE_SENTINEL='SYS_MODULES'
 previous=sys.modules.get('decode_complete_transport');sys.modules['decode_complete_transport']=poison
 try:
  transport=load_source('actual_spine_chain',copied)
  assert transport.BASE.CACHE_SENTINEL=='SRC' and transport.BASE is not poison and h(subject)==pin
 finally:
  if previous is None:sys.modules.pop('decode_complete_transport',None)
  else:sys.modules['decode_complete_transport']=previous
 parser=home/'parse-report.py';parserpin=stale_subject(parser,(ROOT/'experiments/public-simulation/bend-v1/parse-report.py').read_bytes())
 transport.BASE.PARSER=parser
 poison=types.ModuleType('strict_bend_structural');poison.CACHE_SENTINEL='SYS_MODULES'
 previous=sys.modules.get('strict_bend_structural');sys.modules['strict_bend_structural']=poison
 try:
  actual=transport.BASE.parser()
  assert actual.CACHE_SENTINEL=='SRC' and actual is not poison and h(parser)==parserpin
  assert actual.parse('Unit{}')=={'constructor':'Unit','fields':[]}
 finally:
  if previous is None:sys.modules.pop('strict_bend_structural',None)
  else:sys.modules['strict_bend_structural']=previous
print(json.dumps({'status':'PASS','staleTimestampLoaderPositiveReached':True,'spineBaseUsesPinnedSourceBytes':True,'baseParserUsesPinnedSourceBytes':True,'sameSizeSameMtimePycIgnored':True,'cachedModulesIgnored':True,'backendChildren':0}))
