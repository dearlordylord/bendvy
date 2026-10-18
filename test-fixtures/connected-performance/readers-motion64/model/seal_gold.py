"""Seal full Readers B1 role gold before any subject output is available."""
from pathlib import Path
import gzip,json,hashlib
import common_model as C
from ts_model import evaluate
SOURCE=Path(__file__).parent;P=None;sha=lambda x:hashlib.sha256(x).hexdigest()
def main():
 global P
 import argparse
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();P=args.output
 assert not P.exists(), 'Use a fresh directory; frozen gold is immutable'
 P.mkdir(parents=True)
 basis=json.loads((SOURCE/'SOURCE-BASIS.json').read_text())
 for group in ['sourcePins','reusedSourcePins']:
  for name,h in basis[group].items():assert sha((SOURCE/name).read_bytes())==h
 q=basis['qualifiedCanonical'];qualified,_=C.O.report(64,64,1)
 assert (len(qualified),sha(qualified))==(q['bytes'],q['sha256'])
 (P/'canonical-control.stdout.gz').write_bytes(gzip.compress(qualified,mtime=0))
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
 result={'status':'PASS','scope':'Independent Readers Motion64 B1 gold only; no subject/backend execution, timings, ratios or private TS cursor claims. No foreign workload/carrier exists.','sourceBasisSHA256':sha((SOURCE/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':{'bytes':len(qualified),'sha256':sha(qualified)},'worlds':[{k:v for k,v in f.items()if k not in ['records','rawActorMap','tuple']}|{'records':len(f['records']),'tupleValues':len(f['tuple']),'actors':len(f['rawActorMap'])}for f in worlds],'oracles':{},'modelPins':{n:sha((SOURCE/n).read_bytes())for n in ['operation_model.py','common_model.py','ts_model.py','seal_gold.py','physical.py']},'scalarGrammar':'Exact compact JSON insertion keys, Unicode scalar counts: Natdecimal+NUL record count, then Natdecimal+NUL record scalar length then all JSON scalars; fold=(fold*33+scalar)mod2^32 from0.','rawRoleFraming':'WARMUP/SAMPLE LF FORCE:<fold> LF TUPLE:<cells> LF ACTORS:<map> LF; Bend CANONICAL-BEGIN LF originalstream CANONICAL-END LF; TS FULL:<original+supplement> LF. Bend tuple List.show uses comma-space; TS compact JSON.'}
 for role in ['bend','ts']:
  pieces=[]
  for f,canonical in zip(worlds,canon):
   cells=(json.dumps(f['tuple'])if role=='bend'else C.compact(f['tuple'])).encode();actors=f['rawActorMap']if role=='bend'else tsfull['method']['rawActorMap']
   pieces += [(f['label']+'\nFORCE:'+str(f['fold'])+'\nTUPLE:').encode(),cells,('\nACTORS:'+C.compact(actors)+'\n').encode()]
   if role=='bend':pieces += [b'CANONICAL-BEGIN\n',canonical,b'CANONICAL-END\n']
   else:pieces += [b'FULL:',C.compact(tsfull).encode(),b'\n']
  raw=b''.join(pieces);(P/f'{role}-expected.stdout').write_bytes(raw);packed=gzip.compress(raw,mtime=0);(P/f'{role}-expected.stdout.gz').write_bytes(packed)
  result['oracles'][role]={'bytes':len(raw),'sha256':sha(raw),'gzipBytes':len(packed),'gzipSHA256':sha(packed)}
 assert result['oracles']['bend']['bytes']==30103222 and result['oracles']['bend']['sha256']=='a4a74d2c84d7aa64982c940dc329f7a2bbe795e563be05ec6523e47239e5f5b0'
 assert result['oracles']['ts']['bytes']==8945548 and result['oracles']['ts']['sha256']=='808a37846c7c705e2d2f1114aaebd99ae98fa2f71b858897168021946bd1aa85'
 assert all(w['records']==280 and w['tupleValues']==946819 for w in result['worlds'])
 (P/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
