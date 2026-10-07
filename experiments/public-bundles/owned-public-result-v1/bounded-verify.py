from pathlib import Path
import hashlib,json,zipfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((HERE/'bounded-delivery.json').read_text())
for name,want in m['selectedLiveFiles'].items():assert sha((HERE/name).read_bytes())==want,name
assert sha((HERE/'bounded-evidence-v1.zip').read_bytes())==m['archiveSHA256']
with zipfile.ZipFile(HERE/'bounded-evidence-v1.zip') as z:
 assert set(z.namelist())==set(m['archiveEntries'])
 for name,want in m['archiveEntries'].items():assert sha(z.read(name))==want,name
 assert not any('environment' in Path(n).name or Path(n).suffix=='.native' for n in z.namelist())
 r=json.loads(z.read('history/controls-003/receipt.json'))
 assert r['status']=='OWNED_PUBLIC_RESULT_AFFECTED_CONTROLS_FINITE_PASS'
 assert len(r['commands'])==17 and len(r['probeCommands'])==136 and len(r['toolGuardSnapshots'])==34
 p=json.loads(z.read('history/controls-plan-003.json'))
 assert len(p['preparationProbeResults'])==4
 assert sha(z.read('history/controls-plan-003.json'))==m['controlsPlanSHA256']
 assert sha(z.read('history/controls-003/receipt.json'))==m['controlsReceiptSHA256']
 assert r['normalNativeRows']==22 and set(r['mutantRows'].values())=={22}
 assert z.read('history/controls-003/Native-full22.stdout')==(HERE/'expected.stdout').read_bytes()
 for name in ['mutant-JS-full22','mutant-Native-full22']:assert z.read('history/controls-003/'+name+'.stdout')==(HERE/'expected-omitted-value.stdout').read_bytes()
 assert (HERE/'expected.stdout').read_bytes()!=(HERE/'expected-omitted-value.stdout').read_bytes()
print('BOUNDED_DELIVERY_HASH_LEDGER_PASS: no child executed; 17 subjects / 140 probes')
