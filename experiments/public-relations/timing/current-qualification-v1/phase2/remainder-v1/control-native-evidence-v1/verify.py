"""No-child Native control evidence reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def capsule(h):
 index=json.loads((h/'index.json').read_text());assert sha((h/'objects.tar.gz').read_bytes())==index['archiveSHA256']
 with tarfile.open(h/'objects.tar.gz') as t:objects={m.name:t.extractfile(m).read() for m in t.getmembers()}
 assert set(objects)==set(index['objects'])
 for digest,data in objects.items():assert sha(data)==digest and len(data)==index['objects'][digest]
 return lambda name:objects[index['files'][name]]
raw=capsule(H);js=capsule(H.parent/'control-evidence-v1');read=lambda n:json.loads(raw(n));r=read('native/receipt.json');p=read('native/plan.json');assert r['planSHA256']==sha(raw('native/plan.json'));assert r['status']=='THREE_CONTROL_FULL_NATIVE_CONSUMERS_PASS_NO_TIMING_VERDICT' and len(r['commands'])==9 and r['probeCommandsExecuted']==95
for name,digest in r['logs'].items():assert sha(raw('native/'+name))==digest
for control,count in [('nonpower',30),('sparse',30),('empty',2)]:
 expected=read('oracle/'+control+'-seed-0.json');assert read('native/native-'+control+'.stdout')==expected;assert sum(len(x['records']) for x in expected['roots'])==count
 assert raw('native/native-'+control+'.stderr')==js('js/js-'+control+'.stderr')
for group,pins in [('execution-probes',r['probePins']),('prepare-probes',read('native/prepare-receipt.json')['probePins'])]:
 for name,digest in pins.items():assert sha(raw('native/'+group+'/'+Path(name).name))==digest
assert len(r['generated'])==6
print('PASS: Native full30/full30/full2; nine subjects/100 owned probes; full output/boundaries match prior JS. Evidence only.')
