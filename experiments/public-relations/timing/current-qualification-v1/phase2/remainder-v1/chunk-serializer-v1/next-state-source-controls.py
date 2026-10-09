"""No-child transport/fuel model and unchanged full-oracle binding; not Bend execution."""
from pathlib import Path
import gzip,hashlib,json,itertools
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def tokens(value):
 if isinstance(value,list):return [('emit','[')]+interleave([('visit',x) for x in value])+[('emit',']')]
 if isinstance(value,dict):
  entries=[]
  for key,item in value.items():entries.append([('emit',json.dumps(key)+':'),('visit',item)])
  result=[('emit','{')]
  for n,entry in enumerate(entries):
   if n:result.append(('emit',','))
   result+=entry
  return result+[('emit','}')]
 return [('emit',json.dumps(value,separators=(',',':')))]
def interleave(items):
 result=[]
 for n,item in enumerate(items):
  if n:result.append(('emit',','))
  result.append(item)
 return result
def original(fuel,pending,chunks):
 pending=list(pending);chunks=list(chunks)
 while fuel:
  if not pending:return ''.join(reversed(chunks))
  kind,value=pending.pop(0)
  if kind=='visit':pending=tokens(value)+pending
  else:chunks.insert(0,value)
  fuel-=1
 return ''.join(reversed(chunks)) if not pending else None
def candidate(fuel,pending,chunks):
 state=('next',list(pending),list(chunks))
 while True:
  if state[0]=='complete':return state[1]
  _,pending,chunks=state
  if not fuel:return ''.join(reversed(chunks)) if not pending else None
  fuel-=1
  if not pending:state=('complete',''.join(reversed(chunks)));continue
  (kind,value),*rest=pending
  state=('next',tokens(value)+rest,chunks) if kind=='visit' else ('next',rest,[value]+chunks)
def main():
 source=(HERE/'serialize-next-state.bend').read_text();original_source=(HERE/'serialize.bend').read_text()
 assert 'next:' not in source and 'pending => acc =>' not in source
 assert source[source.index('def reversed_chunks('):source.index('type EncodeStep')] == original_source[original_source.index('def reversed_chunks('):original_source.index('def step(')]
 assert source[source.index('def exhausted('):source.index('def loop(')] == original_source[original_source.index('def exhausted('):original_source.index('def walk(')]
 assert source[source.index('def encode('):] == original_source[original_source.index('def encode('):]
 driver=HERE/'whole-feature-timing-v1/driver.bend';changed=HERE/'whole-feature-timing-v1/driver-next-state.bend'
 assert changed.read_text()==driver.read_text().replace('import ../serialize.bend as Serialize','import ../serialize-next-state.bend as Serialize')
 values=[None,0,7,False,True,'','abc',[],[None,1],{}, {'a':[True,0],'b':'x'}];checks=0
 for pending in [[], [('emit','a')], [('emit','a'),('emit','b')]]+[[('visit',v)] for v in values]+[[('visit',a),('visit',b)] for a,b in itertools.product(values,repeat=2)]:
  for chunks in ([],['b','a']):
   for fuel in range(30):assert original(fuel,pending,chunks)==candidate(fuel,pending,chunks);checks+=1
 manifest=json.loads((HERE/'whole-feature-timing-v1/prepared/manifest.json').read_text());assert len(manifest['cases'])==9
 for case in manifest['cases']:
  raw=gzip.decompress((HERE/'whole-feature-timing-v1/prepared'/case['oracle']).read_bytes())
  assert len(raw)==case['bytes'] and hashlib.sha256(raw).hexdigest()==case['sha256']
 print(json.dumps({'modelFuelPairs':checks,'completeOracleBindings':9,'sourceControl':'PASS','candidateSHA256':sha(HERE/'serialize-next-state.bend'),'notBendRuntime':True}))
if __name__=='__main__':main()
