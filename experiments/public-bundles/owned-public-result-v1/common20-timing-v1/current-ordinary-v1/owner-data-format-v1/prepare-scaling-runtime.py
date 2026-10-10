"""Mechanically bind independent complete scale2/4 models to unchanged timed collectors."""
from pathlib import Path
import hashlib,importlib.util,json,sys,gzip
HERE=Path(__file__).resolve().parent;BASE=HERE.parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 role,scale,attempt=sys.argv[1:];assert role in ['js','native'] and scale in ['2','4'];out=HERE/attempt;assert not out.exists()
 plan=json.loads((HERE/(role+'-semantic01')/'plan.json').read_text());collector=Path(plan['collector']);spec=importlib.util.spec_from_file_location('qualified_timed',collector);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 transport=collector.parent/'transport-v1/transport.py';spec=importlib.util.spec_from_file_location('qualified_transport',transport);parser=importlib.util.module_from_spec(spec);spec.loader.exec_module(parser)
 entry=HERE/('main-scale'+scale+'.bend');inventory=parser.Transport(entry).inventory();ip=HERE/(role+'-scale'+scale+'-constructor-inventory.json');ip.write_text(json.dumps(inventory,indent=2)+'\n')
 oracle=BASE/('bend-scale'+scale+'.expected.json');raw=json.loads(oracle.read_text()).encode('utf8');assert raw==gzip.decompress((BASE/('bend-scale'+scale+'.stdout.gz')).read_bytes())
 pins=plan['pins']|json.loads((HERE/'SCALING-FREEZE.json').read_text())['sourcePins']|inventory['sourceSHA256']
 for p in [Path(__file__),ip,oracle,BASE/('bend-scale'+scale+'.stdout.gz'),HERE/'SCALING-FREEZE.json',HERE/'SCALING-SOURCE-EVIDENCE.json',HERE/'scaling-source-evidence.zip',HERE/'SCALING-APPLICABILITY.json']:
  pins[str(p.resolve())]=sha(p)
 assert all(sha(n)==h for n,h in pins.items());assert m.resource_snapshot(plan['resourceRoots'])==plan['resourceInventory']
 generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
 for c in plan['commands']:c['argv']=[str(entry) if a==plan['entrypoint'] else str(generated) if a==plan['generated'] else str(native) if a==plan['native'] else a for a in c['argv']]
 plan.update(scope='#41 complete same-process scale'+scale+' semantic qualification only; no comparative credit',entrypoint=str(entry),constructorInventory=str(ip),pins=pins,generated=str(generated),native=str(native),oracle=str(oracle),expectedSHA256=sha(oracle),independentRawSHA256=hashlib.sha256(raw).hexdigest(),independentRawBytes=len(raw),independentFNV1a32=parser.digest(raw),postConsumer='Complete independent same-process output and namespace progression; one lifecycle timer with2/4 complete lifecycles, no resetprocess sum; unchanged caps/terminal guards')
 out.mkdir();f=out/'plan.json';f.write_text(json.dumps(plan,indent=2)+'\n');print(str(f),sha(f),len(pins),len(raw),parser.digest(raw))
if __name__=='__main__':main()
