"""Seal Health B1 gold exclusively from independent operation/common/TS models."""
from pathlib import Path
import json,gzip,hashlib,io,sys,subprocess
import common_model as C
from ts_model import full
SOURCE=Path(__file__).parent;P=None;M=C.M;sha=lambda x:hashlib.sha256(x).hexdigest()
def generate():
 global P
 import argparse
 parser=argparse.ArgumentParser();parser.add_argument("--count",type=int,choices=[64,256,1024],default=64);parser.add_argument("--iterations",type=int,choices=[64],default=64);parser.add_argument("--output",type=Path,required=True);args=parser.parse_args();P=args.output
 assert not P.exists(), "Use a fresh output directory"
 P.mkdir(parents=True)
 basis=json.loads((SOURCE/'SOURCE-BASIS.json').read_text());assert sha((SOURCE/'operation_model.py').read_bytes())==basis['healthOperationModelSHA256']=='62dce81d79630514c5c44eef915b5eb6b39240acd0b5e6894eb775f74a41b134'
 for name,h in basis['sourcePins'].items():assert sha((SOURCE/name).read_bytes())==h
 spool=P/'observer-tmp';spool.mkdir(exist_ok=True);realPath=Path;M.Path=lambda v:spool/realPath(v).name if str(v).startswith('/tmp/failedtxn-oracle-')else realPath(v)
 control=M.generate(P/'canonical-control',args.count,args.iterations);qualified=basis['qualifiedCanonical']
 if args.count==64:assert(control['bytes'],control['sha256'])==(qualified['bytes'],qualified['sha256'])
 fixtures=[];canonical=[];originalClass=M.Model;M.Model=C.Observer
 try:
  for label,ns in [('warmup',1),('measured',2)]:
   stream=io.StringIO();stream.write(label+'={');m,boundaries=M.setup_output(args.count,args.iterations,ns,stream)
   for i in range(64):M.do_iteration(m,i)
   M.write_state('final={',m,stream,boundaries=boundaries);stream.write('}\n');boundaries.unlink();canonical.append(stream.getvalue().encode())
   records=m.completed();cells=C.tuple_records(records);fold=0
   for v in cells:fold=(fold*33+v)%2**32
   counts={'callbacks':len(m.callback_records),'publications':len(m.publication_records),'boundaries':len(m.boundary_records),'phases':len(m.phase_records)};assert counts=={'callbacks':193,'publications':129,'boundaries':256,'phases':385};assert len(records)==965 and len(m.raw_map())==args.count+192
   for record in records:
    for row in record.get('rows',[]):
     main=row['main']['value'];assert list(main)==['levels','reserve','class'] and len(main['levels'])==4 and (main['reserve'],main['class'])==(9,2)
     if row['aux']['kind']=='Found':assert list(row['aux']['value'])==['layers','grade'] and len(row['aux']['value']['layers'])==4 and row['aux']['value']['grade']==3
     if row['flag']['kind']=='Found':assert row['flag']['value']=={'group':8}
   fixtures.append({'role':label,'namespace':ns,'records':records,'rawActorMap':m.raw_map(),'tuple':cells,'fold':fold,'counts':counts})
 finally:M.Model=originalClass
 assert b''.join(canonical)==gzip.decompress((P/'canonical-control/expected.stdout.gz').read_bytes());assert fixtures[0]['tuple']==fixtures[1]['tuple'] and fixtures[0]['fold']==fixtures[1]['fold']
 (P/'observer-fixtures.json.gz').write_bytes(gzip.compress(C.compact(fixtures).encode(),mtime=0));(P/'expected-common.json.gz').write_bytes(gzip.compress(C.compact({'tuple':fixtures[0]['tuple'],'fold':fixtures[0]['fold']}).encode(),mtime=0))
 for ns,raw in enumerate(canonical,1):(P/f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
 result={'status':'PASS','count':args.count,'iterations':args.iterations,'scope':'Complete independent Health64 B1 gold only; no subject execution, ratios, timing precision, RSS or batching qualification','sourceBasisSHA256':sha((SOURCE/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':control,'worlds':[{'namespace':f['namespace'],'records':len(f['records']),'tupleValues':len(f['tuple']),'fold':f['fold'],'actorCount':len(f['rawActorMap']),'counts':f['counts']}for f in fixtures],'modelPins':{n:sha((SOURCE/n).read_bytes())for n in ['operation_model.py','common_model.py','ts_model.py','seal_gold.py']},'oracles':{}}
 for role in ['bend','ts']:
  target=P/f'{role}-expected.stdout';h=hashlib.sha256();count=0
  with target.open('wb')as out:
   def write(raw):
    nonlocal count;out.write(raw);h.update(raw);count+=len(raw)
   for i,label in enumerate(['WARMUP','SAMPLE']):
    f=fixtures[i];write(f"{label}\nFORCE:{f['fold']}\nTUPLE:".encode());write((json.dumps(f['tuple'])if role=='bend'else C.compact(f['tuple'])).encode());write(b'\n')
    if role=='bend':write(('ACTORS:'+C.compact(f['rawActorMap'])+'\nCANONICAL-BEGIN\n').encode());write(canonical[i]);write(b'CANONICAL-END\n')
    else:write(('FULL:'+C.compact(full(f))+'\n').encode())
  raw=target.read_bytes();assert len(raw)==count and sha(raw)==h.hexdigest();packed=gzip.compress(raw,mtime=0);gz=target.with_suffix(target.suffix+'.gz');gz.write_bytes(packed);assert gzip.decompress(packed)==raw
  result['oracles'][role]={'path':str(gz),'bytes':count,'sha256':h.hexdigest(),'gzipBytes':len(packed),'gzipSHA256':sha(packed)}
 if args.count==64:
  assert result['oracles']['bend']['bytes']==70498700 and result['oracles']['bend']['sha256']=='7ef460e3d312e862618c31a8f1ebebd894b23e260e45a439de4332f88e100ec2'
 if args.count==64:
  assert result['oracles']['ts']['bytes']==38129202 and result['oracles']['ts']['sha256']=='568e9d354d789e4d65bdbd12f64b4fe12d650bec9eda903928cc9d7b32e820ac'
 if args.count==64:
  assert all(w['tupleValues']==3608414 and w['fold']==1350975224 for w in result['worlds'])
 (P/'COMMON-GOLD-BASIS.json').write_text(json.dumps({k:v for k,v in result.items()if k!='oracles'},indent=2)+'\n');(P/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,sort_keys=True))
if __name__=='__main__':generate()
