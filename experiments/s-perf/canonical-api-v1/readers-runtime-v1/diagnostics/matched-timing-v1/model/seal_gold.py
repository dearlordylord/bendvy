"""Seal full Readers B1 role gold before any subject output is available."""
from pathlib import Path
import gzip,json,hashlib
import common_model as C
from ts_model import evaluate
P=Path(__file__).parent;sha=lambda x:hashlib.sha256(x).hexdigest()
def main():
 basis=json.loads((P/'SOURCE-BASIS.json').read_text())
 for pin in basis['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
 assert sha((P/'operation_model.py').read_bytes())==basis['operationModelSHA256']
 q=basis['qualifiedCanonical'];packed=(P/q['copy']).read_bytes();assert sha(packed)==q['gzipSHA256'];qualified=gzip.decompress(packed)
 raw,_=C.O.report(64,64,1);assert raw==qualified and(len(raw),sha(raw))==(q['bytes'],q['sha256'])
 (P/'canonical-control.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
 tsrecords,tsfull=evaluate();worlds=[];canon=[];original=C.O.Program;C.O.Program=C.Observer
 try:
  for label,ns in [('WARMUP',1),('SAMPLE',2)]:
   raw,p=C.O.report(64,64,ns);rs=p.completed();assert rs==tsrecords
   assert len(p.locals)==192 and len(p.logs)==194 and len(p.reads)==84 and len(p.actor_map)==128
   if ns==1:assert raw==qualified
   assert p.actor_keys[64]==C.O.Handle(ns,C.O.Key(65,0))and p.actor_keys[-1]==C.O.Handle(ns,C.O.Key(65,63))
   (P/f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0));canon.append(raw)
   cells=C.tuple_records(rs);worlds.append({'label':label,'namespace':ns,'records':rs,'rawActorMap':p.actor_map_raw(),'tuple':cells,'fold':C.fold(cells),'canonical':{'bytes':len(raw),'sha256':sha(raw)},'counts':{'reads':len(p.method_reads),'stages':len(p.method_stages),'localCalls':len(p.locals),'txFacts':1+len(p.locals)}})
 finally:C.O.Program=original
 assert worlds[0]['tuple']==worlds[1]['tuple']
 (P/'observer-fixtures.json.gz').write_bytes(gzip.compress(C.compact(worlds).encode(),mtime=0));(P/'expected-common.json.gz').write_bytes(gzip.compress(C.compact({'tuple':worlds[0]['tuple'],'fold':worlds[0]['fold']}).encode(),mtime=0))
 result={'status':'PASS','scope':'Independent Readers Motion64 B1 gold only; no subject/backend execution, timings, ratios or private TS cursor claims. No foreign workload/carrier exists.','sourceBasisSHA256':sha((P/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':{'bytes':len(qualified),'sha256':sha(qualified)},'worlds':[{k:v for k,v in f.items()if k not in ['records','rawActorMap','tuple']}|{'records':len(f['records']),'tupleValues':len(f['tuple']),'actors':len(f['rawActorMap'])}for f in worlds],'oracles':{},'modelPins':{n:sha((P/n).read_bytes())for n in ['operation_model.py','common_model.py','ts_model.py','seal_gold.py']},'scalarGrammar':'Exact compact JSON insertion keys, Unicode scalar counts: Natdecimal+NUL record count, then Natdecimal+NUL record scalar length then all JSON scalars; fold=(fold*33+scalar)mod2^32 from0.','rawRoleFraming':'WARMUP/SAMPLE LF FORCE:<fold> LF TUPLE:<cells> LF ACTORS:<map> LF; Bend CANONICAL-BEGIN LF originalstream CANONICAL-END LF; TS FULL:<original+supplement> LF. Bend tuple List.show uses comma-space; TS compact JSON.'}
 for role in ['bend','ts']:
  pieces=[]
  for f,canonical in zip(worlds,canon):
   cells=(json.dumps(f['tuple'])if role=='bend'else C.compact(f['tuple'])).encode();actors=f['rawActorMap']if role=='bend'else tsfull['method']['rawActorMap']
   pieces += [(f['label']+'\nFORCE:'+str(f['fold'])+'\nTUPLE:').encode(),cells,('\nACTORS:'+C.compact(actors)+'\n').encode()]
   if role=='bend':pieces += [b'CANONICAL-BEGIN\n',canonical,b'CANONICAL-END\n']
   else:pieces += [b'FULL:',C.compact(tsfull).encode(),b'\n']
  raw=b''.join(pieces);(P/f'{role}-expected.stdout').write_bytes(raw);packed=gzip.compress(raw,mtime=0);(P/f'{role}-expected.stdout.gz').write_bytes(packed)
  result['oracles'][role]={'bytes':len(raw),'sha256':sha(raw),'gzipBytes':len(packed),'gzipSHA256':sha(packed)}
 (P/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
