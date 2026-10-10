"""Mechanical scale-specific source/oracle/output selection for unchanged stock timed collectors."""
from pathlib import Path
import hashlib, importlib.util, json, sys
HERE=Path(__file__).resolve().parent; OWN=HERE.parent; BASE=OWN.parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 role,scale,attempt=sys.argv[1:];assert role in ['js','native'] and scale in ['2','4'];out=HERE/attempt;assert not out.exists()
 plan=json.loads((HERE/(role+'-semantic01')/'plan.json').read_text());collector=Path(plan['collector']);spec=importlib.util.spec_from_file_location('unchanged_timed',collector);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 transport=collector.parent/'transport-v1/transport.py';spec=importlib.util.spec_from_file_location('unchanged_transport',transport);parser=importlib.util.module_from_spec(spec);spec.loader.exec_module(parser)
 entry=Path(json.loads((HERE/'SOURCE-DELTA.json').read_text())['selectedEntries']['scale'+scale]);inv=parser.Transport(entry).inventory();ip=HERE/(role+'-scale'+scale+'-constructor-inventory.json');ip.write_text(json.dumps(inv,indent=2)+'\n')
 oracle=BASE/('bend-scale'+scale+'.expected.json');expected=oracle.read_bytes();whole=json.loads(expected);model=json.loads((BASE/'ORACLES.json').read_text())['oracles']['bend-scale'+scale] if 'oracles' in json.loads((BASE/'ORACLES.json').read_text()) else json.loads((BASE/'ORACLES.json').read_text())['bend-scale'+scale]
 assert len(whole.encode())==model['bytes'] and hashlib.sha256(whole.encode()).hexdigest()==model['sha256']
 pins=plan['pins']|inv['sourceSHA256']
 for p in [Path(__file__),ip,oracle,HERE/'RUNTIME-EVIDENCE.json',HERE/'RUNTIME-SOURCE-INPUTS.json',BASE/'ORACLES.json']:
  pins[str(p.resolve())]=sha(p)
 assert all(sha(n)==h for n,h in pins.items())
 assert m.resource_snapshot(plan['resourceRoots'])==plan['resourceInventory']
 generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
 for command in plan['commands']:
  command['argv']=[str(entry) if arg==plan['entrypoint'] else str(generated) if arg==plan['generated'] else str(native) if arg==plan['native'] else arg for arg in command['argv']]
 plan.update(scope='#41 current classified metadata fresh stock same-process scale'+scale+' semantic qualification; no comparative credit',entrypoint=str(entry),constructorInventory=str(ip),pins=pins,generated=str(generated),native=str(native),oracle=str(oracle),expectedSHA256=sha(oracle),cwd=str(HERE),postConsumer='Complete independent '+str(model['bytes'])+'-byte scale'+scale+' output and sole UTF8/FNV metric; fresh current stock artifact required, unchanged terminal guards')
 out.mkdir();f=out/'plan.json';f.write_text(json.dumps(plan,indent=2)+'\n');print(str(f),sha(f),len(pins))
if __name__=='__main__':main()
