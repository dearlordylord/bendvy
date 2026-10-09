import fcntl,gzip,hashlib,importlib.util,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
old=HERE.parents[1]/'transport-v1'
a=json.loads((old/'constructor-identities.json').read_text());b=json.loads((HERE/'constructor-identities.json').read_text())
lookup={(v['source'],v['name']):k for k,v in b['constructors'].items()};mapping={}
for k,v in a['constructors'].items():
 nk=v['name'] if v['source']==a['entrypoint'] else lookup[(v['source'],v['name'])]
 if k!=nk:mapping[k.encode()]=nk.encode()
pattern=re.compile(b'|'.join(re.escape(k)+b'(?=\\{)'for k in sorted(mapping,key=len,reverse=True)))
h=hashlib.sha256();original=hashlib.sha256();size=0
with open('/tmp/bendvy-parity-heavy.lock','a')as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with gzip.open(old/'synthetic.stdout.gz','rb')as source, gzip.GzipFile(filename=str(HERE/'synthetic.stdout.gz'),mode='wb',mtime=0)as dest:
  def write(v):
   global size
   h.update(v);size+=len(v);dest.write(v)
  write(b'[');pending=b''
  while chunk:=source.read(1<<20):
   original.update(chunk);pending+=chunk;cut=pending.rfind(b', ',0,max(0,len(pending)-512))
   if cut<0:continue
   cut+=2;write(pattern.sub(lambda m:mapping[m.group()],pending[:cut]));pending=pending[cut:]
  assert pending.endswith(b'\n');write(pattern.sub(lambda m:mapping[m.group()],pending[:-1]));write(b']\n')
 assert original.hexdigest()=='0d77d821ba8e81257194c6cc1e425b5b1c29a4f332728c274465f8c206b8e912'
 fcntl.flock(lock,fcntl.LOCK_UN)
(HERE/'PREPARATION.json').write_text(json.dumps({'wholeOracleSHA256':'bda9cbe63bc0fa00c9c418d2fe21207f23e6683b883b2bbfaf8129931c2ba942','fullTypedRoundtrip':'attempt1 completed before late control failure; see preserved executed helper/result','originalSyntheticSHA256':original.hexdigest(),'rawSHA256':h.hexdigest(),'rawBytes':size,'sourceCount':len(b['sourceSHA256']),'constructors':len(b['constructors']),'nominalRemap':{k.decode():v.decode()for k,v in mapping.items()},'root':'exactly one CandidateSome','noRuntimeOutputInput':True},indent=2)+'\n')
print(size,h.hexdigest())
