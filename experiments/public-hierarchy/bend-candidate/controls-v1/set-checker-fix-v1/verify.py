"""Reconcile complete independent retained set baselines/mutants without child execution."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;D=HERE/'evidence-v1';i=json.loads((D/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();assert sha((D/'objects.tar.gz').read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(D/'objects.tar.gz') as t:
 for m in t.getmembers():assert m.isfile() and m.name not in objects;b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+v['sha256'] for v in i['records'].values()}
def raw(p):
 r=i['records'][p];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'];return b
def load(p):return json.loads(raw(p))
def pinned(p,h):
 key=p+'#'+h if p+'#'+h in i['records'] else p
 assert (sha(raw(key)) if key in i['records'] else i['excludedHashOnly'][p])==h
root=i['root'];old=i['old'];r=load(old+'/receipt.json');assert r['status']=='FAIL' and r['error']=='child deadline';assert raw(old+'/omit-set-refusal-baseline-check.stdout')==raw(old+'/omit-set-refusal-baseline-check.stderr')==b''
diag,base,mut,native=[root+'/'+n for n in i['cohorts']];assert load(diag+'/receipt.json')['status']=='PASS'
for folder in [base,mut,native]:
 p=load(folder+'/plan.json');r=load(folder+'/receipt.json');assert r['planSHA256']==sha(raw(folder+'/plan.json'));assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 for n,h in r['logs'].items():pinned(folder+'/'+n,h)
 for f,h in p.get('pins',{}).items():pinned(f,h)
 for f,h in p.get('inputs',{}).items():
  if isinstance(h,dict):
   for n,d in h.items():pinned(f+'/'+n,d)
  else:pinned(f,h)
 for s in p['stages'].values():
  for n,h in s['inventory'].items():pinned(s['path']+'/'+n,h)
b=raw(base+'/baseline-oracle.txt');m=raw(mut+'/mutant-oracle.txt');assert b!=m;assert raw(base+'/baseline-run-js.stdout')==raw(native+'/baseline-run-native.stdout')==b;assert raw(mut+'/mutant-run-js.stdout')==raw(native+'/mutant-run-native.stdout')==m
# Independently authored retained model, evaluated in-process from exact source objects.
import types
comparepath=root.rsplit('/controls-v1/',1)[0]+'/full-v1/compare.py';c=types.ModuleType('retained_set_model');c.__file__=comparepath;parserpath=root.rsplit('/controls-v1/',1)[0]+'/compare-v2.py';parser=types.ModuleType('retained_initial_model');parser.__file__=parserpath;exec(raw(parserpath),parser.__dict__);c.B=parser;modelsource=raw(comparepath).decode();exec(modelsource[modelsource.index('OPS='):],c.__dict__)
oraclepath=root.rsplit('/set-checker-fix-v1',1)[0]+'/refusal-oracle.py';source=raw(oraclepath).decode();start=source.index('OPERATIONS=');o=types.ModuleType('retained_set_oracle');o.C=c;exec(source[start:],o.__dict__);assert b.decode()==o.expected('omit-set-refusal',False);assert m.decode()==o.expected('omit-set-refusal',True)
# The public-operation fixture differs from current application only in the selected operation list;
# all other baseline dependencies are source-current and the mutant is exactly one refusal arm.
pn=load(native+'/plan.json');repo=root.split('/experiments/',1)[0];operationSource=o.OPERATIONS;focused=o.MUTATIONS['omit-set-refusal']['operations']
for mode,st in pn['stages'].items():
 for n in st['inventory']:
  actual=raw(st['path']+'/'+n);current=raw(repo+'/'+n)
  if n.endswith('/full-v1/application.bend'):assert current.decode().replace(operationSource,focused).encode()==actual
  elif mode=='mutant' and n=='src/ecs/relation-reorder-core.bend':
   mutation=o.MUTATIONS['omit-set-refusal'];assert current.decode().replace(mutation['old'],mutation['new']).encode()==actual
  else:assert actual==current,n
p=load(native+'/plan.json');r=load(native+'/receipt.json');assert r['probeCommandsExecuted']==65==len(p['executionProbeLabels'])
for label in p['executionProbeLabels']:
 q=load(native+'/execution-probes/'+label+'.json');assert q['exit']==0 and q['failure'] is None and q['seconds']==5
for n in ['bend','node','python','taskset','clang']:q=load(native+'/prepare-probes/prepare-ldd-'+n+'.json');assert q['exit']==0 and q['failure'] is None
assert not i['acceptance'] and not i['completeIssue44'];print('PASS: complete six-record two-schema set baseline/reached compiling mutant JS/Native;70 owned probes; original deadline retained inconclusive.')
