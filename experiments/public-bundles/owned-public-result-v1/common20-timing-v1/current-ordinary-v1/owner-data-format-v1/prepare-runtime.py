"""Mechanical changed-entry plans for unchanged qualified timed collectors."""
from pathlib import Path
import hashlib, importlib.util, json, sys
HERE=Path(__file__).resolve().parent; BASE=HERE.parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 role,attempt=sys.argv[1:];assert role in ['js','native'];out=HERE/attempt;assert not out.exists()
 plan=json.loads((BASE/(role+'-semantic02')/'plan.json').read_text());collector=Path(plan['collector']);spec=importlib.util.spec_from_file_location('unchanged_timed',collector);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 transport=collector.parent/'transport-v1/transport.py';spec=importlib.util.spec_from_file_location('unchanged_transport',transport);parser=importlib.util.module_from_spec(spec);spec.loader.exec_module(parser)
 entry=HERE/'main.bend';inv=parser.Transport(entry).inventory();ip=HERE/(role+'-constructor-inventory.json');ip.write_text(json.dumps(inv,indent=2)+'\n')
 pins=plan['pins']|json.loads((HERE/'FREEZE.json').read_text())['sourcePins']|inv['sourceSHA256']
 for p in [Path(__file__),ip,HERE/'FREEZE.json',HERE/'SOURCE-DELTA.json',HERE/'APPLICABILITY.json',HERE/'SOURCE-EVIDENCE.json',HERE/'source-evidence.zip']:
  pins[str(p.resolve())]=sha(p)
 assert all(sha(n)==h for n,h in pins.items())
 assert m.resource_snapshot(plan['resourceRoots'])==plan['resourceInventory']
 generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
 for command in plan['commands']:
  command['argv']=[str(entry) if arg==plan['entrypoint'] else str(generated) if arg==plan['generated'] else str(native) if arg==plan['native'] else arg for arg in command['argv']]
 plan.update(scope='#41 justified owner/Data formatting representation successor: exact complete same scale1 semantic qualification only, no comparative credit',entrypoint=str(entry),constructorInventory=str(ip),pins=pins,generated=str(generated),native=str(native),cwd=str(HERE),postConsumer='Complete18058-byte independent original model applicability, sole UTF8/FNV timer metric; immutable previous stockdeadline remains separate; unchanged source/tool/resource terminal guards')
 out.mkdir();f=out/'plan.json';f.write_text(json.dumps(plan,indent=2)+'\n');print(str(f),sha(f),len(pins))
if __name__=='__main__':main()
