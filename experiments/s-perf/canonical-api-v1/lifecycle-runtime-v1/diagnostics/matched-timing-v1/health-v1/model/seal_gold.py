"""Seal independent source-state gold, before any Lifecycle method subject."""
from pathlib import Path
import json,gzip,hashlib
import common_model as C
from ts_model import full
P=Path(__file__).parent
sha=lambda x:hashlib.sha256(x).hexdigest()
def main():
 basis=json.loads((P/'SOURCE-BASIS.json').read_text())
 for n,h in basis['parameterizedSourcePins'].items():assert sha((P/'source'/n).read_bytes())==h
 for r in basis['consumerSourcePins']+[basis['tsReference']]:assert sha((P/r['copy']).read_bytes())==r['sha256']
 worlds=[];canon=[];summaries=[]
 for label,ns,foreign in [('WARMUP',1,2),('SAMPLE',3,4)]:
  f=C.derive(ns,foreign);raw=C.LC2.encode_report(f['typed'])
  if ns==1:
   q=basis['qualifiedCanonical'];assert len(raw)==q['bytes']and sha(raw)==q['sha256'];assert raw==gzip.decompress((P/q['path']).read_bytes())
  canon.append(raw);(P/f'canonical-ns{ns}-{foreign}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
  f.pop('captured');f.pop('typed');f['label']=label;f['namespace']=ns;f['foreignNamespace']=foreign
  f['tuple']=C.cells(f['common']);f['fold']=C.fold(f['tuple']);f['foreignTuples']={r:C.cells(v)for r,v in f['foreign'].items()};f['foreignFolds']={r:C.fold(v)for r,v in f['foreignTuples'].items()}
  worlds.append(f);summaries.append({'label':label,'primaryNamespace':ns,'foreignNamespace':foreign,'records':len(f['common']),'tupleValues':len(f['tuple']),'fold':f['fold'],'canonical':{'bytes':len(raw),'sha256':sha(raw)},'foreign':{r:{'records':len(f['foreign'][r]),'tupleValues':len(f['foreignTuples'][r]),'fold':f['foreignFolds'][r]}for r in ['bend','ts']}})
 assert worlds[0]['tuple']==worlds[1]['tuple']
 assert worlds[0]['foreignTuples']['ts']==worlds[1]['foreignTuples']['ts']
 assert worlds[0]['foreignTuples']['bend']!=worlds[1]['foreignTuples']['bend']
 assert worlds[0]['foreignTuples']['bend']!=worlds[0]['foreignTuples']['ts']
 (P/'observer-fixtures.json.gz').write_bytes(gzip.compress(C.compact(worlds).encode(),mtime=0))
 output={}
 for role in ['bend','ts']:
  pieces=[]
  for f,raw in zip(worlds,canon):
   array=lambda x:(json.dumps(x)if role=='bend'else C.compact(x)).encode()
   pieces += [(f['label']+'\nFORCE:'+str(f['fold'])+'\nFOREIGN-FORCE:'+str(f['foreignFolds'][role])+'\nTUPLE:').encode(),array(f['tuple']),b'\nFOREIGN-TUPLE:',array(f['foreignTuples'][role]),b'\nACTORS:',C.compact(f['actors']if role=='bend'else [{'actor':i,'rawId':i}for i in range(1,129)]).encode(),b'\n']
   if role=='bend':pieces += [b'CANONICAL-BEGIN\n',raw,b'CANONICAL-END\n']
   else:pieces += [b'FULL:',C.compact(full(f)).encode(),b'\n']
  raw=b''.join(pieces);target=P/f'{role}-expected.stdout';target.write_bytes(raw);packed=gzip.compress(raw,mtime=0);target.with_suffix('.stdout.gz').write_bytes(packed)
  output[role]={'bytes':len(raw),'sha256':sha(raw),'gzipBytes':len(packed),'gzipSHA256':sha(packed)}
 result={'status':'PASS','scope':'Independent Lifecycle Health64 B1 gold only; no subject execution or timing qualification. Shared tuples equal; foreign carriers compared only to their own role/world gold.','worlds':summaries,'oracles':output,'sourceBasisSHA256':sha((P/'SOURCE-BASIS.json').read_bytes()),'modelPins':{n:sha((P/n).read_bytes())for n in ['common_model.py','ts_model.py','seal_gold.py']},'compactJSON':{'ensureAscii':False,'separators':[',',':'],'keyOrder':'Insertion order as in common_model.py and ts_model.py; records serialized individually before scalar tuple encoding.','scalarTuple':'record count decimal scalars+0; each record scalar length decimal scalars+0 then every JSON Unicode scalar. Fold=(fold*33+scalar) mod2^32 from0.'}}
 (P/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
