"""Mechanical scale1 semantic plans for unchanged qualified timed collectors; no children."""
from pathlib import Path
import hashlib, importlib.util, json, sys, gzip
ROOT=Path('/workspace/formal-proofs/bendvy'); HERE=Path(__file__).resolve().parent
TIMED=ROOT/'experiments/public-bundles/owned-public-result-v1/common20-timing-v1/timed-io-v1'
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 spec=importlib.util.spec_from_file_location(name,p); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
def main():
 role,attempt=sys.argv[1:]; assert role in ('js','native','ts')
 out=HERE/attempt; assert not out.exists()
 collector=TIMED/('development-'+role+'.py'); transport=TIMED/'transport-v1/transport.py'
 module=load('qualified_profile',collector); parser=load('qualified_transport',transport)
 config_path=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'; config=load('configuration',config_path)
 basis=json.loads((HERE/'INDEPENDENT-SOURCE-BASIS.json').read_text()); freeze=json.loads((HERE/'FREEZE.json').read_text())
 entry=HERE/'ts-reference-v1/main-scale1.mjs' if role=='ts' else Path(freeze['entries']['1'])
 inventory=parser.Transport(entry).inventory(); inventory_path=HERE/(role+'-scale1-constructor-inventory.json')
 inventory_path.write_text(json.dumps(inventory,indent=2)+'\n')
 oracle=HERE/(('ts' if role=='ts' else 'bend')+'-scale1.expected.json')
 raw=json.loads(oracle.read_text()).encode('utf8'); catalogue=json.loads((HERE/'ORACLES.json').read_text())
 assert raw==gzip.decompress((HERE/(('ts' if role=='ts' else 'bend')+'-scale1.stdout.gz')).read_bytes())
 tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':str(Path('/usr/bin/taskset').resolve()),'clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
 roots=[str(p) for p in config.RESOURCE_ROOTS]; resources=module.resource_snapshot(roots)
 pins=basis['inputs']|basis['sourcePins']|inventory['sourceSHA256']
 extra=[Path(__file__),collector,transport,config_path,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',inventory_path,oracle,HERE/'ORACLES.json',HERE/'FREEZE.json',HERE/'INDEPENDENT-SOURCE-BASIS.json',HERE/'PUBLIC-JOIN.md',HERE/'BEND-OBSERVATIONS.json',HERE/'bend-model.py.source',HERE/'ts-model.py.source',HERE/'business-model.py.source',*map(Path,tools.values())]
 for root, members in resources.items():
  for member,h in members.items(): pins[str((Path(root)/member).resolve(strict=True))]=h
 pins.update({str(p.resolve(strict=True)):sha(p) for p in extra})
 assert all(sha(p)==h for p,h in pins.items()),'Pinned source drift'
 generated=entry if role=='ts' else out/('scenario.c' if role=='native' else 'scenario.js'); native=out/'scenario.native'; prefix=[tools['taskset'],'-c','5']
 commands=[] if role=='ts' else [dict(label='emit',argv=prefix+[tools['bend'],str(entry),'-o',str(generated)],capSeconds=30)]
 if role=='native': commands.extend([dict(label='build',argv=prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],capSeconds=120),dict(label='consumer',argv=prefix+[str(native),'--threads','1','--gpu','off'],capSeconds=5)])
 else: commands.append(dict(label='consumer',argv=prefix+[tools['node'],str(generated)],capSeconds=5))
 plan=dict(scope='#41 current ordinary complete scale1 semantic IO timer qualification only; no comparative timing credit',expectedSHA256=sha(oracle),entrypoint=str(entry),constructorInventory=str(inventory_path),resourceRoots=roots,resourceInventory=resources,pins=pins,environment=config.environment(),cwd=str(HERE),oracle=str(oracle),generated=str(generated),native=str(native),tools=tools,commands=commands,postConsumer='Exact independent entire UTF8 output plus sole stderr elapsedNs/bytes/FNV record; pure source PASS separate from intended IO foreign proof refusal',independentRawSHA256=hashlib.sha256(raw).hexdigest(),independentRawBytes=len(raw),independentFNV1a32=parser.digest(raw),collector=str(collector))
 out.mkdir(); (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n'); print(str(out/'plan.json'),sha(out/'plan.json'),len(pins))
if __name__=='__main__':main()
