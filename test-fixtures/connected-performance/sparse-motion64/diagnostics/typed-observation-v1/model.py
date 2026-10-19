"""Independent typed-field gold from qualified semantic fixtures; no subject input."""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HELPER=Path(__file__).resolve().parents[3]/'dense-motion64/diagnostics/typed-observation-v1/model.py'
spec=importlib.util.spec_from_file_location('qualified_typed_arithmetic',HELPER);H=importlib.util.module_from_spec(spec);spec.loader.exec_module(H)
natural,sized,fold=H.natural,H.sized,H.fold
VERSION=H.VERSION
def cells(fixture,typed):
 def row(r):return natural(r['rawId'],typed)+[2,*r['main']['coordinates'],r['main']['frame']]+([1]if r['aux']is None else[2,*r['aux']['rates'],int(r['aux']['moving'])])+([1]if r['flag']is None else[2,r['flag']['group']])
 def scan(s):return sized(s['rows'],row,typed)+sized(s['included'],row,typed)+[s['score']]
 def audit(a):return sized(a['values'],lambda x:[x],typed)+[a['readsum']]+natural(a['updated'],typed)+sum((scan(a['scans'][k])for k in ['all','present','absent']),[])+[a['scans']['weighted'],a['cumulative']]
 final=fixture['final'];audits=fixture['audits'];assert len(audits)==64
 # Actual operation model has one successful ordinary invocation per audit, as
 # retained complete old tuple equality below checks; no new runtime status.
 return sized(final['rows'],row,typed)+final['ledger']['totals']+[final['ledger']['epoch']]+sized(audits,audit,typed)+sized(audits,lambda _:[0],typed)+[fixture['cumulative']]
SCHEMA='Motion';WORKLOAD='Sparse';COUNT=256;GOLD='/tmp/bendvy21-sparse-motion-count256-independent-gold01'
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();base=Path(__file__).resolve().parents[2];sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
 expected=json.loads((base/'model/COUNT-EXPECTED.json').read_text())[str(COUNT)]
 for name,h in expected['sourcePins'].items():assert sha(base.parent/name.removeprefix('connected-performance/'))==h,name
 gold=Path(GOLD);fp=gold/'expected-common.json';assert sha(fp)==expected['outputs']['expected-common.json']['sha256'];fixture=json.loads(fp.read_text())
 assert cells(fixture,False)==fixture['tuple']and fold(fixture['tuple'])==fixture['fold'];token=fold(cells(fixture,True));assert not a.output.exists();a.output.mkdir();outputs={}
 for role in ['bend','ts']:
  source=gold/(role+'-expected.stdout.gz');raw=gzip.decompress(source.read_bytes());v=expected['outputs'][source.name];assert(len(raw),hashlib.sha256(raw).hexdigest())==(v['bytes'],v['sha256']);lines=raw.splitlines(keepends=True);assert sum(x.startswith(b'FORCE:')for x in lines)==2
  target=VERSION+b''.join((b'FORCE:'+str(token).encode()+b'\n')if x.startswith(b'FORCE:')else x for x in lines);out=a.output/source.name;out.write_bytes(gzip.compress(target,mtime=0));outputs[role]=dict(path=str(out),bytes=len(target),sha256=hashlib.sha256(target).hexdigest(),gzipSHA256=sha(out),original=dict(path=str(source),bytes=len(raw),sha256=v['sha256'],gzipSHA256=sha(source)))
 receipt=dict(status='PASS_INDEPENDENT_TYPED_FIELD_GOLD',schema=SCHEMA,workload=WORKLOAD,count=COUNT,iterations=64,token=token,oldTupleValues=len(fixture['tuple']),typedFieldCells=len(cells(fixture,True)),unchangedOriginalTuple='COMPLETE_BYTE_VALUE_EQUALITY',originalCommon=dict(path=str(fp),sha256=sha(fp)),modelSHA256=sha(__file__),arithmeticHelper=dict(path=str(HELPER),sha256=sha(HELPER)),countBasisSHA256=sha(base/'model/COUNT-EXPECTED.json'),outputs=outputs)
 (a.output/'MODEL-RECEIPT.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt))
if __name__=='__main__':main()
