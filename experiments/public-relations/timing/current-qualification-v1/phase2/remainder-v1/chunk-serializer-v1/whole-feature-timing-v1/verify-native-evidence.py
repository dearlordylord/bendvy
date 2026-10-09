"""Pure retained exact Native9 oracle/walk/receipt verification, no children."""
from pathlib import Path
import gzip,hashlib,importlib.util,json,sys
sys.dont_write_bytecode=True
H=Path(__file__).resolve().parent
E=H/'native-runtime-evidence-v1'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name,digest in json.loads((E/'manifest.json').read_text()).items():assert sha(E/name)==digest
spec=importlib.util.spec_from_file_location('force',H.parents[3]/'trace-cheap.py');F=importlib.util.module_from_spec(spec);spec.loader.exec_module(F)
cases={'-'.join(c['input']):c for c in json.loads((H/'prepared/manifest.json').read_text())['cases']}
r=json.loads((E/'receipt.json').read_text());assert r['status']=='NATIVE_FULL9_SEMANTICS_PASS_NO_COMPARATIVE_TIMING' and len(r['commands'])==9 and len(r['guards'])==20 and all(g['unchanged'] is True for g in r['guards'])
assert r['binarySHA256']=='b487656bfe9ef50d62bd1e4195105147d1defb17f3624d97beabfc5c240082f0'
for c in r['commands']:
 assert c['exit']==0 and c['failure'] is None and c['rawByteOraclePass'] is True and c['fullOraclePass'] is True and c['walkPass'] is True
 name=c['label'];case=cases[name];raw=gzip.decompress((E/(name+'.stdout.gz')).read_bytes());expected=gzip.decompress((H/'prepared'/case['oracle']).read_bytes());assert raw==expected and hashlib.sha256(raw).hexdigest()==r['logs'][name+'.stdout']==case['sha256'] and len(raw)==case['bytes']
 stderr=E/(name+'.stderr');assert sha(stderr)==r['logs'][name+'.stderr'];markers=[json.loads(line) for line in stderr.read_bytes().splitlines()];assert len(markers)==2 and markers[0]=={'boundary':'begin'};stop=markers[1];duration=stop.pop('elapsedNs');assert type(duration)is str and duration.isascii() and duration.isdecimal()
 for k in ('nodes','characters','sum'):assert type(stop[k])is int
 assert stop=={'boundary':'complete-trace-forced',**F.force(json.loads(expected)),'region':'whole-feature-setup-operations-full-trace'}
print(json.dumps({'status':'NATIVE_RETAINED_FULL9_BYTE_MODEL_WALK_MARKERS_PASS','completeOutputs':9,'serializedGuards':20,'JS1024':'Still blocked','comparativeTiming':False}))
