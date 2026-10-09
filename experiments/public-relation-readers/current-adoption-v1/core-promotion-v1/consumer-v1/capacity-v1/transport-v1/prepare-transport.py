"""Cheap complete controls FIRST, then lossless streaming constructor remap.
No runtime output is model input and no giant decoded object graph is allocated.
"""
import fcntl,gzip,hashlib,importlib.util,json,re,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
runpy.run_path(str(HERE/'test-boundary.py'),run_name='__main__')
root=HERE.parents[6];h=root/'experiments/public-relation-readers/current-adoption-v1'
old=h/'fullcount-current-v1/boxed-capacity-v1/transport-v1';consumer=HERE.parents[1]
s=importlib.util.spec_from_file_location('typed',HERE/'transport.py');T=importlib.util.module_from_spec(s);s.loader.exec_module(T)
b=T.Transport(HERE.parent/'main.bend').inventory();(HERE/'constructor-identities.json').write_text(json.dumps(b,indent=2)+'\n');a=json.loads((old/'constructor-identities.json').read_text())
migration=json.loads((consumer/'IMPORT-MAPPING.json').read_text());sources={m['before']:m['after'] for m in migration['sources']};sources.update(migration['externalMapping']);sources[a['entrypoint']]=b['entrypoint']
lookup={(v['source'],v['name']):k for k,v in b['constructors'].items()};mapping={};unused=[]
for k,v in a['constructors'].items():
 target=sources.get(v['source']);key=(target,v['name'])
 if key not in lookup:
  assert v['source'].endswith('/closed-access.bend');unused.append(k);continue
 nk=lookup[key]
 if k!=nk:mapping[k.encode()]=nk.encode()
pattern=re.compile(b'|'.join(re.escape(k)+b'(?=\\{)' for k in sorted(mapping,key=len,reverse=True)))
record={'wholeOracleSHA256':'bda9cbe63bc0fa00c9c418d2fe21207f23e6683b883b2bbfaf8129931c2ba942','originalSyntheticSHA256':'8380b7c7900f8133bf9a547e15168c0cb96d8f21984a4c96520262d00df87c0e','noRuntimeOutputInput':True,'nominalRemap':{k.decode():v.decode() for k,v in mapping.items()},'unobservedRemovedPhantomConstructors':unused,'root':'exact singleton List<Candidate Some full Output>','sourceCount':len(b['sourceSHA256']),'constructors':len(b['constructors']),'controls':'six complete count3/root/last-owner/omission controls before streaming'}
hashraw=hashlib.sha256();original=hashlib.sha256();size=0
with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with gzip.open(old/'synthetic.stdout.gz','rb') as source,gzip.GzipFile(filename=str(HERE/'synthetic.stdout.gz'),mode='wb',mtime=0) as dest:
  pending=b''
  def write(chunk):
   global size
   assert not any(token.encode()+b'{' in chunk for token in unused)
   chunk=pattern.sub(lambda m:mapping[m.group()],chunk);hashraw.update(chunk);size+=len(chunk);dest.write(chunk)
  while chunk:=source.read(1<<20):
   original.update(chunk);pending+=chunk;cut=pending.rfind(b', ',0,max(0,len(pending)-1024))
   if cut<0:continue
   cut+=2;write(pending[:cut]);pending=pending[cut:]
  write(pending)
 assert original.hexdigest()==record['originalSyntheticSHA256']
record.update(rawSHA256=hashraw.hexdigest(),rawBytes=size,wholeShapeBinding='same independent entire nested model; sole source-derived constructor namespace remap, original singleton unchanged')
(HERE/'PREPARATION.json').write_text(json.dumps(record,indent=2)+'\n');print(size,hashraw.hexdigest())
