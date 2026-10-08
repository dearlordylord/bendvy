"""Offline finite byte archive; no child stages or semantic receipt amendments."""
import pathlib, json, hashlib, tarfile, io, importlib.util, sys
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('package_backend',HERE/'js-backend.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
def build():
 out=HERE/'portable-component-v1';out.mkdir(exist_ok=False)
 runtime=pathlib.Path(B.ROOT/'.artifacts/inspect54-component-js-1791440046120018190')
 files=set();B.closure(HERE/'output-io-main.bend',files)
 selected=['physical-oracle.py','physical-oracle-v2.py','BEND-PHYSICAL-EXPECTED-v1.txt','BEND-PHYSICAL-EXPECTED-v2.txt','COMPONENT-ORACLE-v1.json','COMPONENT-ORACLE-v2.json','REFERENCE-EXPECTED-v1.json','REFERENCE-EXPECTED-v2.json','reference.mjs','reference-runner.py','RUNTIME-BOUNDARY.md','JS-PROPOSAL.json','js-backend.py','js-execution.py','cli-runner.py','source-development.py','evidence-boundary.py','reconcile-js.py','RECONCILIATION-PLAN-v2.json','PHYSICAL-ORACLE-RECONCILIATION-v2.json','package.py']
 files.update(HERE/n for n in selected)
 for d in HERE.iterdir():
  if d.is_dir() and 'history-v1' in d.name and d.name!='authority-development-history-v1':
   files.update(p for p in d.rglob('*') if p.is_file() and '__pycache__' not in p.parts and '.private.' not in p.name)
 for n in ['execution-plan.json','receipt.json','reconciliation-receipt-v2.json','plan.json','preparation-plan.json','prepare-receipt.json','tool-snapshot.json','component-complete.js','complete-emit-js.stdout.raw','complete-emit-js.stderr.raw','complete-run-js.stdout.raw','complete-run-js.stderr.raw','source-origin.stdout.raw','source-origin.stderr.raw']:files.add(runtime/n)
 for n in ['prepare-probes','execution-probes']:files.update(p for p in (runtime/n).rglob('*') if p.is_file())
 files.update(p for p in (runtime/'stage').rglob('*') if p.is_file())
 plan=json.loads((runtime/'execution-plan.json').read_text())
 files.update(pathlib.Path(x['root']) for x in plan['rootDependencies'].values())
 # Exact pinned reference source files are source objects, never installed binaries.
 rp=HERE/'reference-execution-history-v1/6948534b/plan.json'
 reference=json.loads(rp.read_text())
 for n,value in reference.get('inputs',{}).items():
  p=pathlib.Path(n)
  if isinstance(value,dict):
   for relative,digest in value.items():
    source=p/relative;assert hashlib.sha256(source.read_bytes()).hexdigest()==digest;files.add(source)
  elif p.suffix in ['.ts','.mjs','.py','.bend'] and p.is_file():files.add(p)
 records={};objects={}
 for p in sorted(files):
  assert p.is_file(),p
  assert '.private.' not in p.name and '__pycache__' not in p.parts
  data=p.read_bytes();digest=hashlib.sha256(data).hexdigest();name='objects/'+digest
  records[str(p)]={'object':name,'sha256':digest,'bytes':len(data)};objects[name]=data
 archive=out/'objects.tar.gz'
 with tarfile.open(archive,'w:gz') as t:
  for name,data in sorted(objects.items()):
   i=tarfile.TarInfo(name);i.size=len(data);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(data))
 live={str(p.relative_to(HERE)):records[str(p)] for p in sorted(files) if p.is_relative_to(HERE) and not any('history-v1' in x for x in p.parts)}
 index={'scope':'Finite full recursive component-query TS comparator and standaloneJS derived reconciliation only. Original failed receipt remains INCOMPLETE. Complete physical/owner instrumentation outside Check readonly boundary explicit; no Native/refusal/mutant/adoption/proof/full54 credit. Trusted setup constructors remain bounded.', 'records':records,'objectsArchiveSHA256':hashlib.sha256(archive.read_bytes()).hexdigest(),'liveSelected':live,'runtimeRoot':str(runtime),'referencePlan':str(rp),'reconciliationPlan':str(HERE/'RECONCILIATION-PLAN-v2.json'),'rootDependencies':plan['rootDependencies']}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(records),len(objects))
if __name__=='__main__':build()
