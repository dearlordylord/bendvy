"""Archive actual pinned TS42/raw and first failure without child execution."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest()
source=['TS-MAPPING.md','reference-ts.mjs','consumer-ts.mjs','ts-common-oracle.py','ts-common-expected.json','ts-source-review-manifest.json','run-ts.py','prepare-ts-handoff.py','verify-ts-handoff.py']
runs=['bundle-TS-1791437636585546165','bundle-TS-1791437104734996072'];data={}
for run in runs:
 for f in (H/run).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':data[run+'/'+str(f.relative_to(H/run))]=f.read_bytes()
for name in ['history-ts-909-before-systemfailure-projection','history-ts1438-before-reader-activation','bundle-TS-1791437023818037729']:
 for f in (H/name).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':data['history/'+name+'/'+str(f.relative_to(H/name))]=f.read_bytes()
data['history/run-ts-metadata-config-expansion-failed.py.txt']=(H/'run-ts-metadata-config-expansion-failed.py.txt').read_bytes()
p=json.loads((H/runs[0]/'plan.json').read_text());core=Path(p['tsCoreRoot'])
for n,d in p['tsCoreInventory'].items():
 raw=(core/n).read_bytes();assert sha(raw)==d;data['reference-core/'+n]=raw
reference=json.loads((H/'ts-source-review-manifest.json').read_text())['pinnedTSSource'];data['references-sources.json']=Path(reference['sourceManifest']).read_bytes();assert sha(data['references-sources.json'])==reference['sourceManifestSHA256']
out=H/'delivery-ts-v1';assert not out.exists();out.mkdir();b=io.BytesIO();members={}
with tarfile.open(fileobj=b,mode='w') as t:
 for name,raw in sorted(data.items()):
  i=tarfile.TarInfo(name);i.size=len(raw);i.mode=0o644;i.mtime=0;t.addfile(i,io.BytesIO(raw));members[name]={'sha256':sha(raw),'bytes':len(raw)}
raw=gzip.compress(b.getvalue(),mtime=0);(out/'ts.tar.gz').write_bytes(raw)
report="""# Actual pinned bevy-ts: finite bundle42 common observations

The independently authored actual bevy-ts comparator uses pinned3040a3b2 core public Schema/System/nested transition schedules and eight distinct callback effects. Owned is declared by every writer, inactive Extra is declared even when unselected, and actual requirement union is Owned,Flow,Extra. Gameplay Array payloads, committed/queued/previous state, callback-local attempts, successful phase prefix, real deferred structural marker entities, actual transition deliveries and missing requirements matched all21 common checkpoints per nominal family. Strict JS deepEqual checked complete common records; complete actual debug dumps/streams/results/history are retained in raw stdout, including the real initial empty-reader result/frame/tick. Host-owned callback Local state is disclosed; no built-in TS Local or fabricated Bend authority is claimed.

The first actual comparator attempt1438 failed at later_enterPlay1: reader definition was not yet instantiated, so its publication was trimmed before first read. Pinned Runtime.slotOf1367 creates holding cursor at first run, advanceFrame1641 trims, and internal/streams.ts132 retains old entries only for registered readers. The existing qualified reference-v3 activates initial readers before publication. The independently reviewed correction runs the actual empty reader in the seed schedule before queues/publications; common oracle and operations after setup are unchanged. Failed receipt/immutable source/raw diagnostic remain INCOMPLETE. Original failing stdout was empty because old consumer asserted before printing; no full42 first-failure raw capture is claimed. The new consumer emits complete actual raw before assertions and grants acceptance only on strict success.

Corrected execution had one Node5 subject, CPU8 and15 source/tool/config/environment guard probes. It binds the full pinned TS core source inventory, runtime loader/module-sensitive ancestor configurations, exact historical tool snapshot and failure history. No new dependency, cap raise, timing comparison or unchanged rerun occurred. Earlier source outcome normalization corrected actual SystemFailure projection, and unexecuted config plans are preserved. Native/source/JS Bend full48 qualification remains separate committed evidence.

Six mandatory Bend observations are not falsely mapped to TS: paired real affine foreign-world refusal/retry per family and same-owner missing Extra restoration per family. TS resources are provided at construction, and snapshot restore resets pending/reader state; fresh provisioning is not a same-owner retry. TS raw frame/tick/stream metadata is retained, while Bend physical registry IDs/cursors/namespaces/affine readers remain independently checked in all48 Bend observations. This finite comparator does not choose retention/owned-event/capture/late-key policy, adopt a production API, establish universal proof/performance or complete issue48/49. Reached bundle composition mutants remain independent work.
"""
(out/'REPORT.md').write_text(report)
m={'status':'ACTUAL_PINNED_TS_BUNDLE_FORTY_TWO_COMMON_FINITE','source':{n:sha((H/n).read_bytes()) for n in source},'reportSHA256':sha((out/'REPORT.md').read_bytes()),'archive':{'name':'ts.tar.gz','sha256':sha(raw),'members':members},'historicalRoot':str(H),'baselineManifestSHA256':sha((H/'delivery-v1/manifest.json').read_bytes()),'nativeManifestSHA256':sha((H/'delivery-native-v1/manifest.json').read_bytes()),'completeIssue49':False,'proofCredit':False,'performanceQualified':False}
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(sha((out/'manifest.json').read_bytes()))
