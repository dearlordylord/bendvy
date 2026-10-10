"""Prepare current-source scale1 plans for unchanged qualified timed collectors."""
from pathlib import Path
import hashlib, importlib.util, json, sys
HERE=Path(__file__).resolve().parent; OWN=HERE.parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 role,attempt=sys.argv[1:];assert role in ['js','native'];out=HERE/attempt;assert not out.exists()
 plan=json.loads((OWN/(role+'-semantic01')/'plan.json').read_text());collector=Path(plan['collector']);spec=importlib.util.spec_from_file_location('unchanged_timed',collector);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 transport=collector.parent/'transport-v1/transport.py';spec=importlib.util.spec_from_file_location('unchanged_transport',transport);parser=importlib.util.module_from_spec(spec);spec.loader.exec_module(parser)
 freeze=json.loads((HERE/'FREEZE.json').read_text());entry=Path(json.loads((HERE/'SOURCE-DELTA.json').read_text())['selectedEntries']['scale1']);inv=parser.Transport(entry).inventory();ip=HERE/(role+'-constructor-inventory.json');ip.write_text(json.dumps(inv,indent=2)+'\n')
 # Preserve old basis documents as history while binding the actual current source closure.
 pins=plan['pins']|freeze['sourcePins']|inv['sourceSHA256']
 for p in [Path(__file__),ip,HERE/'FREEZE.json',HERE/'SOURCE-DELTA.json',HERE/'SOURCE-EVIDENCE.json',HERE/'source-evidence.zip',HERE/'APPLICABILITY.md']:
  pins[str(p.resolve())]=sha(p)
 assert all(sha(n)==h for n,h in pins.items())
 assert m.resource_snapshot(plan['resourceRoots'])==plan['resourceInventory']
 generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
 for command in plan['commands']:
  command['argv']=[str(entry) if arg==plan['entrypoint'] else str(generated) if arg==plan['generated'] else str(native) if arg==plan['native'] else arg for arg in command['argv']]
 plan.update(scope='#41 current classified schema metadata compatibility: full scale1 semantic qualification only; old artifacts historical, no comparative credit',entrypoint=str(entry),constructorInventory=str(ip),pins=pins,generated=str(generated),native=str(native),cwd=str(HERE),postConsumer='Complete independently source-current applicable18058-byte output and sole UTF8/FNV timer metric; fresh stock generated artifact/build required; unchanged source/tool/resource terminal guards')
 out.mkdir();f=out/'plan.json';f.write_text(json.dumps(plan,indent=2)+'\n');print(str(f),sha(f),len(pins))
if __name__=='__main__':main()
