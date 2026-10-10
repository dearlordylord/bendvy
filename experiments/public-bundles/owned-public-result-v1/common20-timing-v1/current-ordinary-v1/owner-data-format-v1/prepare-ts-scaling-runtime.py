"""Mechanical scale2/4 plan bindings to unchanged root-owned timed TS profile."""
from pathlib import Path
import hashlib,importlib.util,json,sys,gzip
HERE=Path(__file__).resolve().parent;BASE=HERE.parent;PROFILE=BASE/'ts-root-profile-v1'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 scale,attempt=sys.argv[1:];assert scale in ['2','4'];out=HERE/attempt;assert not out.exists()
 plan=json.loads((PROFILE/'actual01/plan.json').read_text());spec=importlib.util.spec_from_file_location('qualified_ts_transport',PROFILE/'transport.py');transport=importlib.util.module_from_spec(spec);spec.loader.exec_module(transport)
 entry=BASE/'ts-reference-v1'/('main-scale'+scale+'.mjs');inventory=transport.Transport(entry).inventory();ip=HERE/('ts-scale'+scale+'-constructor-inventory.json');ip.write_text(json.dumps(inventory,indent=2)+'\n')
 basis=json.loads((BASE/'INDEPENDENT-SOURCE-BASIS.json').read_text());assert all(sha(n)==h for n,h in basis['inputs'].items())
 assert all((basis['inputs']|plan['pins'])[n]==h for n,h in inventory['sourceSHA256'].items())
 oracle=BASE/('ts-scale'+scale+'.expected.json');raw=json.loads(oracle.read_text()).encode('utf8');assert raw==gzip.decompress((BASE/('ts-scale'+scale+'.stdout.gz')).read_bytes())
 pins=plan['pins']|inventory['sourceSHA256']
 for p in [Path(__file__),ip,oracle,BASE/('ts-scale'+scale+'.stdout.gz'),BASE/'ORACLES.json',BASE/'INDEPENDENT-SOURCE-BASIS.json',BASE/'PUBLIC-JOIN.md',PROFILE/'launch-review.md',PROFILE/'run.py',PROFILE/'transport.py']:
  pins[str(p.resolve())]=sha(p)
 assert all(sha(n)==h for n,h in pins.items())
 plan.update(scope='#41 current full TS sameprocessscale'+scale+' semantic timer qualification only; no comparative credit',entrypoint=str(entry),constructorInventory=str(ip),pins=pins,oracle=str(oracle),expectedSHA256=sha(oracle),generated=str(entry),independentRawSHA256=hashlib.sha256(raw).hexdigest(),independentRawBytes=len(raw),independentFNV1a32=transport.digest(raw),commands=[dict(label='consumer',argv=[plan['tools']['taskset'],'-c','5',plan['tools']['node'],str(entry)],capSeconds=5)],postConsumer='Full independent sameprocessTS output UTF8/FNV, unchanged application/reference model; no resetprocess sum or newaffineWorldclaim')
 out.mkdir();f=out/'plan.json';f.write_text(json.dumps(plan,indent=2)+'\n');print(str(f),sha(f),len(pins),len(raw),transport.digest(raw))
if __name__=='__main__':main()
