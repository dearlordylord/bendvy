"""Archive selected finite capability caller evidence without executable children."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
runs=['cheap-js-1791432710709125093','authority-source-1791432764067041420','native-A-diagnostic-1791432923643306535','native-runtime-A-1791433304208921455','native-runtime-B-1791433305186823405','native-full14-reconciliation-20261008']
source=['types.bend','world.bend','systems.bend','application.bend','main.bend','consumer.mjs','expected-draft.json','AUTHORITY-AND-NATIVE-PLAN.md','authority-positive.bend','negative-undeclared.bend','negative-read-write.bend','negative-cross-schema.bend','negative-owner-duplication.bend','source-review-manifest.json','native-a.bend','native-b.bend','run-cheap-js.py','run-authority-source.py','run-native-a-diagnostic.py','run-native-runtime.py','reconcile-native.py','prepare-handoff.py','verify-handoff.py']
selected={}
for name in runs:
 for f in (H/name).rglob('*'):
  if f.is_file() and f.name!='private-environment.json' and f.name not in ['caller-A','caller-B']:
   selected[name+'/'+str(f.relative_to(H/name))]=f.read_bytes()
for name in ['authority-source-1791432688610785483','reconcile-native-before-admitted-plan-pin.py.txt','reconcile-native-failed-interleaved-oracle-order.py.txt','reconciliation-order-failure-observation.json']:
 p=H/name
 if p.is_dir():
  for f in p.rglob('*'):
   if f.is_file() and f.name!='private-environment.json':selected['history/'+name+'/'+str(f.relative_to(p))]=f.read_bytes()
 else:selected['history/'+name]=p.read_bytes()
out=H/'delivery-v2';assert not out.exists();out.mkdir()
buffer=io.BytesIO();members={}
with tarfile.open(fileobj=buffer,mode='w') as t:
 for name,data in sorted(selected.items()):
  info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;info.mtime=0;t.addfile(info,io.BytesIO(data));members[name]={'sha256':sha(data),'bytes':len(data)}
blob=gzip.compress(buffer.getvalue(),mtime=0);(out/'source-js-native.tar.gz').write_bytes(blob)
report="""# Capability-bound independent public caller: finite source/JS/Native evidence

The independently authored caller uses actual public core machine/world/condition modules, registered systems, affine component and resource Arrays, actual Local owners and separately tracked namespace-validated machine-stream Reader and Sys cursor. The rank-two gameplay callback receives abstract F and existing Cap.ValueWrite/Action grants; only trusted transaction adapters have raw world access. Trusted author-owned Local storage/inverse closures are explicit; this does not create a public capture, Local storage or owned-event policy.

Two source-current positive programs produced the exact check-only typing banner. Four complete single-location diagnostics were collected as UNCLASSIFIED, then independently classified separately: undeclared abstract-F world escape, read-to-write grant mismatch, cross-schema application and affine-owner duplication. Original collection/classification receipts and the unexecuted substring-classifier plan are preserved. These are concrete type refusals, not mathematical proofs.

Fresh JS emitted the current capability closure and all fourteen complete JSON observations matched the unchanged independently authored oracle. Native A source/C emission was reused exactly for compile/run; B was source-checked, emitted, compiled and run separately. Both seven-row outputs and their exact concatenation matched the same full fourteen-field-complete observations, including failed transaction Local persistence, retry and self-queued next marker, false-condition and missing-requirement untouched owners, and nonempty-stream MissingReader refusal. Counts: JS two subjects/25 guard probes; authority six/65; Native diagnostic two/25; A runtime two/25; B four/45. Every probe has JSON/stdout/stderr pins. Caps remain source5/emit30/Clang120/runtime5, CPU8, runtime thread1/GPUoff.

The first no-child union attempt had an incorrect aggregate insertion-order assertion (oracle interleaves schemas, physical union groups A then B). Its helper and transcribed tool failure are retained; independently reviewed correction preserved every key/value and per-schema order. Corrected no-child reconciliation passed without backend replay. Private environments, native binaries and dependency installations are excluded from this portable capsule, while their admitted hashes remain in receipts.

This is bounded executable caller evidence. It does not complete issues48/49, choose late-key/capture/owned-event policy, establish mathematical validity or report comparative performance. Existing production helper adoption and its separate regression gate are root-owned. The earlier v1 source typing output remains transcribed development evidence; current capability-v2 raw source/refusal receipts are separate actual evidence.
"""
(out/'REPORT.md').write_text(report)
m={'status':'FINITE_CAPABILITY_BOUND_INDEPENDENT_CALLER_SOURCE_JS_NATIVE','source':{n:sha((H/n).read_bytes()) for n in source},'reportSHA256':sha((out/'REPORT.md').read_bytes()),'archive':{'name':'source-js-native.tar.gz','sha256':sha(blob),'members':members},'historicalRoot':str(H),'completeIssue49':False,'proofCredit':False,'performanceQualified':False}
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(sha((out/'manifest.json').read_bytes()))
