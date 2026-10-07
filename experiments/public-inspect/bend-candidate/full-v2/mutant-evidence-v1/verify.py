"""No-child full control/mutant reconciliation; wrong reader is falsified."""
from pathlib import Path
import hashlib,json,tarfile
h=Path(__file__).resolve().parent;i=json.loads((h/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();assert sha((h/'objects.tar.gz').read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(h/'objects.tar.gz') as t:
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and m.name not in objects;b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+r['sha256'] for r in i['records'].values()}
def raw(p):
 r=i['records'][p];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'];return b
def j(p):return json.loads(raw(p))
p=j(i['mutantPlan']);r=j(i['mutantReceipt']);assert sha(raw(i['mutantPlan']))==r['planSHA256'];assert len(r['commands'])==5 and all(x['exit']==0 and x['failure'] is None for x in r['commands']);assert r['probeCommandsExecuted']==55
out=str(Path(i['mutantReceipt']).parent)
for f,d in p['pins'].items():assert (sha(raw(f)) if f in i['records'] else i['excludedHashOnly'][f])==d
for name,d in p['inventory'].items():assert sha(raw(str(Path(p['stage'])/name)))==d
for name,d in r['logs'].items():assert sha(raw(out+'/'+name))==d
for f,d in r['probePins'].items():assert sha(raw(f))==d
for label in p['executionProbeLabels']:
 x=j(out+'/execution-probes/'+label+'.json');assert x['exit']==0 and x['failure'] is None and x['seconds']==5
for label in ['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']]:
 x=j(out+'/prepare-probes/'+label+'.json');assert x['exit']==0 and x['failure'] is None and x['seconds']==5
baseline=j(i['baselineRawJS']);assert j(i['baselineRawNative'])==baseline
actual=j(out+'/run-js.stdout');assert j(out+'/run-native.stdout')==actual
oracle=j(str(Path(p['stage'])/'experiments/public-inspect/bend-candidate/full-v2/retained-oracle.json'))['retained-bend'];assert actual==oracle and actual!=baseline
mutation=p['semanticMutation'];before=raw('/workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/joint.bend').decode();after=raw(str(Path(p['stage'])/'experiments/public-inspect/bend-candidate/joint.bend')).decode();assert before.count(mutation['needle'])==1 and after==before.replace(mutation['needle'],mutation['replacement']);assert sha(before.encode())==mutation['beforeSHA256'] and sha(after.encode())==mutation['afterSHA256'];assert sha(baseline.encode())==mutation['baselineFullOracleSHA256'];assert sha(actual.encode())==mutation['mutantFullOracleSHA256']
expected=[];witnesses=0
for line in baseline.splitlines():
 if line.startswith('fail:') and 'lookup=[' in line:line=line.replace('|cursor=0/1/0/1','|cursor=0/1/1/1');witnesses+=1
 elif line.startswith('fail:'):line=line.replace('|cursor=0/1/0/1','|cursor=0/1/2/1');witnesses+=1
 elif line.startswith('success:') and '|cursor=3/1/' in line:line=line.replace('|events=[]/True','|events=[]/False');witnesses+=1
 expected.append(line)
assert actual=='\n'.join(expected)+'\n' and witnesses==6
assert i['acceptance'] is False and i['completeIssue54'] is False
print('PASS: one compiling real reader-consumption defect, six reached witnesses across two schemas on JS/Native; every other full-output field equals the correct control')
