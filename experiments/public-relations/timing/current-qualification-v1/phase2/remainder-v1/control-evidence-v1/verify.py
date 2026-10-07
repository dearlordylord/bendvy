"""No-child retained evidence verification; no compilation/runtime/proof."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
index=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==index['archiveSHA256']
with tarfile.open(H/'objects.tar.gz') as t:
 objects={m.name:t.extractfile(m).read() for m in t.getmembers()}
assert set(objects)==set(index['objects'])
for digest,data in objects.items():assert sha(data)==digest and len(data)==index['objects'][digest]
def raw(name):return objects[index['files'][name]]
def read(name):return json.loads(raw(name))
for group in ['first','remaining','js']:
 receipt=read(group+'/receipt.json');assert receipt['planSHA256']==sha(raw(group+'/plan.json'))
 for name,digest in receipt['logs'].items():assert sha(raw(group+'/'+name))==digest
assert read('first/receipt.json')['error']=='child deadline'
assert read('remaining/receipt.json')['status']=='DEVELOPMENT_FULL_CONTROL_CONSUMERS_PASS_NOT_DELIVERY'
j=read('js/receipt.json');assert j['status']=='THREE_CONTROL_FULL_JS_CONSUMERS_PASS_NO_TIMING_VERDICT' and len(j['commands'])==6 and j['probeCommandsExecuted']==52
for control,group,n in [('nonpower','first',30),('sparse','remaining',30),('empty','remaining',2)]:
 expected=read('oracle/'+control+'-seed-0.json')
 for name in [group+'/'+control+'-ts.stdout','js/js-'+control+'.stdout']:
  assert read(name)==expected and sum(len(r['records']) for r in expected['roots'])==n
for group in ['prepare-probes','execution-probes']:
 pins=j['probePins'] if group=='execution-probes' else read('js/prepare-receipt.json')['probePins']
 for path,digest in pins.items():assert sha(raw('js/'+group+'/'+Path(path).name))==digest
print('PASS: 3 TS + 3 standalone JS full controls; 6 JS subjects/56 owned probes; CLI timeout retained. Evidence only.')
