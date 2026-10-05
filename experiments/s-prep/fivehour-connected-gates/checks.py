#!/usr/bin/env python3
"""Fresh authoritative semantic gates for the exact immutable two-role snapshot."""
import argparse,datetime,hashlib,importlib.util,json,os,re,signal,subprocess,sys,shutil,time
from pathlib import Path
import supervisor
import provider_controls as PC
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
assert int(os.environ.get("BENDVY_CHECKER_SECONDS","5")) in (5,15), "Unreviewed checker limit"
CHECK_LIMIT_SECONDS=3600
CHECK_STARTED_MONOTONIC=time.monotonic()
def remaining():
 return CHECK_LIMIT_SECONDS-(time.monotonic()-CHECK_STARTED_MONOTONIC)
EXPECTED_GATES={'materialize-controls':'PASS_DERIVED_CONTROL_SOURCE_MAP','host12':'PASS','access':'ACTUAL_ACCESS_9_PASS','e11':'BOUNDED_JOINED_PASS','owned-storage':'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS','staging':'PASS_BOUNDED_STAGING_TYPE_BOUNDARY','tx-baseline':'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS',**{'tx-'+v:'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' for v in ('stale-head','torn-tail','lost-mark','inverse-order')}}
def validate_gates(gates):
 assert [g['name'] for g in gates]==list(EXPECTED_GATES),'Missing, duplicate or unexpected gate IDs'
 assert all(g['exit']==0 and g['status']==EXPECTED_GATES[g['name']] for g in gates),'Wrong gate status or exit'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def validate_suppressed_owner(baseline_receipt,overlay):
 """Revalidate the mandatory live fused setter witness, including consumed bytes."""
 spec=importlib.util.spec_from_file_location('gate_fused_adaptation',HERE/'fused-adaptation.py')
 adapter=importlib.util.module_from_spec(spec);spec.loader.exec_module(adapter)
 core=Path(overlay)/'experiments/s-integrate';fused=adapter.fused_presence((core/'held-adapter.bend').read_text(),(core/'cached-payload.bend').read_text())
 baseline=json.loads(Path(baseline_receipt).read_text());sub=baseline.get('suppressedOwner')
 if not fused:
  assert sub is None,'Unexpected fused suppression receipt for generic source'
  return
 status='PASS_LIVE_NOOP_TRUEOLD_JOURNAL_MARK_FULLFIELDS_BOTH'
 assert isinstance(sub,dict) and sub.get('status')==status,'Missing or incomplete mandatory fused suppressedOwner receipt'
 receipt=Path(sub['receipt']);assert receipt.absolute()==receipt.resolve() and sha(receipt)==sub['receiptSHA256'],'Suppressed owner receipt changed/escaped'
 evidence=json.loads(receipt.read_text());assert evidence.get('status')==status and evidence.get('records')==144,'Suppressed owner status/record mismatch'
 assert evidence.get('liveMutationSites')==['motion_set_fused_done','health_set_fused_done'],'Missing live fused setter sites'
 pins=evidence['sourcePins'];assert set(pins)=={'overlaySHA256','heldAdapterSHA256','cachedPayloadSHA256','fixtureSHA256','protectedRawSHA256','adapterSHA256','fusedAdapterSHA256'},'Suppression source pin set mismatch'
 assert pins['overlaySHA256']==sub['overlaySHA256'],'Suppression original overlay provenance differs'
 binding=source_binding(Path(overlay));assert evidence['runtimeSources']==binding['runtimeSources'] and evidence['runtimeClosureSHA256']==binding['runtimeClosureSHA256'],'Suppression full runtime differs'
 assert pins['heldAdapterSHA256']==sha(core/'held-adapter.bend') and pins['cachedPayloadSHA256']==sha(core/'cached-payload.bend'),'Suppression runtime differs'
 for field in ('sourceFiles','rawObserverFiles'):
  mapping=evidence[field];assert isinstance(mapping,dict) and mapping,'Missing consumed suppression source map'
  for name,digest in mapping.items():
   path=Path(name);assert path.absolute()==path.resolve() and sha(path)==digest,'Suppression source/raw observer drift'
 assert pins['fixtureSHA256']==sha(HERE/'tx-controls.bend') and pins['adapterSHA256']==sha(HERE/'suppressed-owner.py') and pins['fusedAdapterSHA256']==sha(HERE/'fused-adaptation.py'),'Suppression protected adapter/fixture differs'
 assert pins['protectedRawSHA256']==sha(ROOT/'experiments/s-integrate/payload.bend'),'Suppression original raw payload differs'
 assert set(evidence['rawObserverPins'])=={'cached','raw'},'Suppression observer modes differ'
 for observer in evidence['rawObserverPins'].values():
  assert set(observer)=={'CP','protectedRaw','HA','callbacks'} and set(observer.values()).issubset(set(evidence['rawObserverFiles'].values())),'Observer pin lacks consumed file'
 assert set(pins.values()).issubset(set(evidence['sourceFiles'].values())),'Source pin lacks consumed file'
 cases=evidence['cases'];assert len(cases)==4 and {(x['getter'],x['backend']) for x in cases}=={(mode,backend) for mode in ('cached','raw') for backend in ('Native','JS')},'Suppression case coverage differs'
 for case in cases:
  assert case['records']==144 and all(case.get(key) is True for key in ('compiling','exactNoopFullfieldsEffects','trueOldJournalPreserved','journalPreserved','marksPreserved')),'Suppression semantic checks incomplete'
  for field,pin in (('outputPath','outputSHA256'),):
   path=Path(case[field]);assert path.absolute()==path.resolve() and path.resolve().is_relative_to(receipt.parent) and sha(path)==case[pin],'Suppression output/program drift/escape'
  programs=case['programs'];assert len(programs) in (1,2) and sum(x['records'] for x in programs)==144,'Suppression program coverage differs'
  assert ([x['schema'] for x in programs]==['both'] if len(programs)==1 else {x['schema'] for x in programs}=={'motion','health'}),'Suppression schema coverage differs'
  for program in programs:
   assert program['records']==(144 if len(programs)==1 else 72),'Suppression per-program record count differs'
   for field,pin in (('programPath','programSHA256'),('sourcePath','sourceSHA256')):
    path=Path(program[field]);assert path.absolute()==path.resolve() and path.resolve().is_relative_to(receipt.parent) and sha(path)==program[pin],'Suppression program/source drift/escape'
  records=[json.loads(line) for line in Path(case['outputPath']).read_text().splitlines() if line.strip()];assert len(records)==144,'Suppression raw record count differs'
  assert hashlib.sha256(json.dumps(records,sort_keys=True,separators=(',',':')).encode()).hexdigest()==evidence['expectedRecordsSHA256'],'Suppression complete raw fields differ'
 assert sha(receipt)==sub['receiptSHA256'],'Suppressed receipt drift during verification'


def validate_static_access(receipt,overlay,control_sources):
 from static_provider_boundary import CASES
 data=json.loads(Path(receipt).read_text());core=Path(overlay)/'experiments/s-integrate'
 if not PC.static_registration(core):
  assert data.get('staticProviderBoundary') is None and data.get('staticWorldBoundary') is None
  return
 boundary=data['staticProviderBoundary'];assert boundary['status']=='FRESH_ACTUAL_STATIC_PROVIDER_BOUNDARY_PASS'
 assert boundary['staticClientSHA256']==sha(core/PC.STATIC_MODULE) and boundary['heldAdapterSHA256']==sha(core/'held-adapter.bend')
 assert len(boundary['cases'])==8 and {c['name'] for c in boundary['cases']}==set(CASES)
 for case in boundary['cases']:
  contract=CASES[case['name']];assert case['exit']==contract['exit'] and case['archiveSHA256']==contract['sourceSHA256']
  assert case['seconds']<=int(os.environ.get('BENDVY_CHECKER_SECONDS','5')) and all(d in case['output'] for d in contract['diagnostics'])
 world=data['staticWorldBoundary'];path=Path(world['receipt']);assert sha(path)==world['receiptSHA256']
 actual=json.loads(path.read_text());assert world['status']==actual['status']=='FINITE_ACTUAL_STATIC_FOREIGN_WORLD_FIELDS_PASS'
 assert actual['sourcePins']==control_sources and actual['fixtureSHA256']==sha(HERE/'static-world-controls.bend')
 assert actual['backendPolicy']['Native']=={'clang':'-O3','threads':1,'gpu':'off'}
 expected_keys={(schema,observer,client,backend) for schema in ('motion','health') for observer in ('cached','raw') for client in ('static','original-point') for backend in ('JS','Native')}
 assert len(actual['cases'])==16 and {(c['schema'],c['observer'],c['client'],c['backend']) for c in actual['cases']}==expected_keys
 expected=actual['independentExpectations'];assert len(expected)==16
 for case in actual['cases']:
  assert case['status']=='FULL_FIELDS_PASS' and case['records']==8
  for name,digest in (('programPath','programSHA256'),('outputPath','outputSHA256')):
   source=Path(case[name]);assert source.absolute()==source.resolve() and source.resolve().is_relative_to(path.parent.resolve()) and sha(source)==case[digest]
  rows=[json.loads(line) for line in Path(case['outputPath']).read_text().splitlines() if line.strip()]
  assert rows==expected[(0 if case['schema']=='motion' else 8):(8 if case['schema']=='motion' else 16)]

def source_binding(overlay):
 assert not overlay.is_symlink();overlay=overlay.resolve();manifest=json.loads((overlay/'overlay.json').read_text())
 for name,digest in manifest['sources'].items():
  source=overlay/name;assert not source.is_symlink() and source.resolve().is_relative_to(overlay) and sha(source)==digest,'Snapshot source drift/escape'
 seen={}
 def visit(source):
  source=source.resolve();assert source.is_relative_to(overlay) and not source.is_symlink()
  relative=str(source.relative_to(overlay))
  if relative in seen:return
  assert relative in manifest['sources'],'Actual import missing manifest'
  seen[relative]=sha(source)
  for name in re.findall(r'^import (\S+)',source.read_text(),re.M):
   if name=='Base':continue
   assert name.startswith('./') and name.endswith('.bend'),'Unsupported or unconfined actual import'
   visit(source.parent/name)
 visit(overlay/'experiments/s-integrate/measurement-bend.bend')
 assert seen==PC.runtime_sources(overlay),'Checked runtime membership differs'
 return {'manifestSources':dict(sorted(manifest['sources'].items())),'overlayManifestSHA256':sha(overlay/'overlay.json'),'runtimeSources':dict(sorted(seen.items())),'runtimeClosureSHA256':hashlib.sha256(json.dumps(dict(sorted(seen.items())),separators=(',',':')).encode()).hexdigest()}
def clang_runtime_binding():
 root=Path('/home/node/.local/opt/dnd-clang14/usr');actual=(root/'lib/llvm-14/bin/clang').resolve();assert actual.is_file()
 resource=Path(subprocess.check_output(['clang','-print-resource-dir'],text=True,timeout=5).strip()).resolve();assert resource.is_relative_to(root.resolve()),'Unreviewed clang resource root'
 linker_name=subprocess.check_output(['clang','-print-prog-name=ld'],text=True,timeout=5).strip();linker=Path(linker_name if '/' in linker_name else shutil.which(linker_name)).resolve();assert linker.is_file()
 environment=dict(os.environ);environment['LD_LIBRARY_PATH']=str(root/'lib/aarch64-linux-gnu')+':'+str(root/'lib/llvm-14/lib')+(':'+environment['LD_LIBRARY_PATH'] if environment.get('LD_LIBRARY_PATH') else '')
 libraries={}
 for binary in (actual,linker):
  output=subprocess.check_output(['ldd',str(binary)],text=True,env=environment,timeout=5);assert 'not found' not in output,'Missing consumed dynamic library'
  for raw in re.findall(r'(?<!\S)(/[^\s()]+)',output):
   path=Path(raw).resolve();assert path.is_file();libraries[str(path)]=sha(path)
 local={str(path.resolve()):sha(path.resolve()) for path in root.rglob('*') if path.is_file()}
 return {'actualClang':{'path':str(actual),'sha256':sha(actual)},'resourceDirectory':str(resource),'localResourceAndLibrarySources':dict(sorted(local.items())),'resolvedDynamicLibraries':dict(sorted(libraries.items())),'linker':{'path':str(linker),'sha256':sha(linker)}}
def dependency_binding(cpu=9):
 tracked=subprocess.check_output(['git','ls-files'],cwd=ROOT,text=True).splitlines()
 prefixes=('experiments/s-integrate/','experiments/s-integrate-trace/','experiments/s-perf/candidate/','experiments/s-prep/fivehour-connected-gates/')
 sources={n:sha(ROOT/n) for n in tracked if n.startswith(prefixes) and Path(n).suffix in {'.py','.bend','.mjs','.js','.ts'} and (ROOT/n).is_file()}
 for n in ('experiments/t05/run.py','experiments/s-perf/owned-index-core.bend','experiments/s-prep/owned-write-query-integration/controls-run.py','experiments/s-prep/owned-write-query-integration/prepare-evidence.json'):
  sources[n]=sha(ROOT/n)
 sources.update({str(f.relative_to(ROOT)):sha(f) for f in HERE.iterdir() if f.suffix in {'.py','.bend'}})
 for f in (ROOT/'docs/research/static-provider-dispatch/controls').glob('*.bend.txt'):sources[str(f.relative_to(ROOT))]=sha(f)
 sources['experiments/t01/bend-check']=sha(ROOT/'experiments/t01/bend-check')
 for name in ('final-js-e11-evidence.json','ts-oracle-node-bookend.json'):
  if (HERE/name).exists():sources[str((HERE/name).relative_to(ROOT))]=sha(HERE/name)
 tools={n:{'path':str(Path(shutil.which(n)).resolve()),'sha256':sha(Path(shutil.which(n)).resolve())} for n in ('bend','node','clang','python3','timeout')}
 base=Path.home()/'.bend/bend2/base.bend';tools['Base']={'path':str(base),'sha256':sha(base)}
 reference=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts')
 refnames=subprocess.check_output(['git','ls-files','packages/core/src'],cwd=reference,text=True).splitlines()
 refs={n:sha(reference/n) for n in refnames}
 for n in refnames:
  pinned=subprocess.check_output(['git','show','HEAD:'+n],cwd=reference)
  assert hashlib.sha256(pinned).hexdigest()==refs[n],'Reference tracked source drift'
 installed=Path.home()/'.bend/bend2';installed_sources={str(q.resolve()):sha(q) for q in [*installed.glob('*'),*(installed/'effs').glob('*')] if q.is_file()}
 return {'clangRuntime':clang_runtime_binding(),'installedBendRuntime':installed_sources,'gateAndProtectedSources':dict(sorted(sources.items())),'tools':tools,'referenceHEAD':subprocess.check_output(['git','rev-parse','HEAD'],cwd=reference,text=True).strip(),'referenceCoreSources':refs,'limits':{'checker':int(os.environ.get('BENDVY_CHECKER_SECONDS','5')),'runtime':5,'codegen':30,'clang':120},'cpu':cpu,'executionEnvironment':{name:os.environ.get(name) for name in ('NODE_OPTIONS','BEND_HOME','BEND_PATH','BEND_LIB','PYTHONPATH','LD_PRELOAD','LD_LIBRARY_PATH','HOME')}}
def main():
 p=argparse.ArgumentParser();p.add_argument('--js-overlay',type=Path,required=True);p.add_argument('--native-overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=9);p.add_argument('--reuse-receipt',type=Path);p.add_argument('--reuse-receipt-sha256');a=p.parse_args();a.output.mkdir(exist_ok=False)
 result={'status':'INCOMPLETE','schemaVersion':1,'scope':'Fresh exact candidate semantic/capability gates; no metric or product acceptance','roles':{},'gateSources':{f.name:sha(f) for f in HERE.glob('*.py')}}
 try:
  result['dependencyBinding']=dependency_binding(a.cpu)
  if a.reuse_receipt:
   assert a.reuse_receipt_sha256 and sha(a.reuse_receipt)==a.reuse_receipt_sha256,'Canonical receipt digest missing or mismatched'
   prior=json.loads(a.reuse_receipt.read_text());assert prior['status']=='FRESH_TWO_ROLE_CONNECTED_GATES_PASS','Only complete fresh receipt can authorize reuse'
   assert prior['dependencyBinding']==result['dependencyBinding'],'Gate/tool/reference dependencies changed'
   for role,overlay in [('JS',a.js_overlay),('Native',a.native_overlay)]:
    old=prior['roles'][role];assert old['status']=='PASS','Incomplete role gates';validate_gates(old['gates'])
    binding=source_binding(overlay);assert binding['runtimeSources']==old['binding']['runtimeSources'] and binding['runtimeClosureSHA256']==old['binding']['runtimeClosureSHA256'],'Runtime candidate source changed; run full gates'
    controls=a.output/(role+'-reuse-controls');command=[sys.executable,str(HERE/'materialize-controls.py'),'--overlay',str(overlay),'--output',str(controls),'--raw-snapshots','--slice-host-fixtures'];available=remaining();assert available>0,'Per-packet gate budget reached';code,_=supervisor.execute(command,min(120,available));assert code==0,'Reuse control derivation failed'
    derived=json.loads((controls/'overlay.json').read_text())['sources'];assert derived==old['controlSources'],'Derived actual gate source changed; run full gates'
    for gate in old['gates']:
     if 'receipt' in gate:assert sha(Path(gate['receipt']))==gate['receiptSHA256'],'Dependency receipt drift'
     if gate['name']=='tx-baseline':validate_suppressed_owner(gate['receipt'],overlay)
     if gate['name']=='access':validate_static_access(gate['receipt'],overlay,derived)
    result['roles'][role]={'status':'REUSED','binding':binding,'controlSources':derived,'gates':old['gates']}
   assert dependency_binding(a.cpu)==result['dependencyBinding'],'Dependencies changed during reuse'
   result.update(status='EXACT_UNCHANGED_TWO_ROLE_GATES_REUSED',reused=True,sourceReceiptSHA256=sha(a.reuse_receipt))
   return
  assert not a.reuse_receipt_sha256,'Digest requires reuse receipt'
  for role,overlay in [('JS',a.js_overlay),('Native',a.native_overlay)]:
   binding=source_binding(overlay);folder=a.output/role;folder.mkdir();entry={'status':'INCOMPLETE','input':str(overlay.resolve()),'binding':binding,'gates':[]};result['roles'][role]=entry
   def run(label,args,receipt,statuses,env=None):
    assert remaining()>0,'Per-packet gate budget reached'
    command=[sys.executable,*map(str,args)];out=folder/(label+'.log');
    try:code,text=supervisor.execute(command,min(1200,remaining()),env)
    except Exception as error:out.write_text(str(error));raise
    out.write_text(text);gate={'name':label,'command':command,'exit':code,'logSHA256':sha(out)};entry['gates'].append(gate)
    assert code==0,label+' failed: '+text[-2000:]
    if receipt:
     evidence=json.loads(receipt.read_text());assert evidence['status'] in statuses,label+' receipt not passing';gate.update(status=evidence['status'],receipt=str(receipt),receiptSHA256=sha(receipt))
   controls=folder/'control-overlay'
   run('materialize-controls',[HERE/'materialize-controls.py','--overlay',overlay,'--output',controls,'--raw-snapshots','--slice-host-fixtures'],None,None)
   entry['gates'][-1]['status']='PASS_DERIVED_CONTROL_SOURCE_MAP'
   entry['controlSources']=json.loads((controls/'overlay.json').read_text())['sources']
   host=folder/'host12';run('host12',[HERE/'host-mutations-run.py','--overlay',controls,'--output-dir',host,'--cpu',a.cpu],host/'protocol.json',{'PASS'})
   semantics=json.loads((host/'semantic-evidence.json').read_text());assert len(semantics['original'])==2 and all(x['fullSelectedChannelsEqual'] for x in semantics['original']);assert len(semantics['mutants'])==12 and all(len(x['observations'])==2 and all(o['compiling'] and o.get('differenceCount',1)>0 and o['witness'] for o in x['observations']) for x in semantics['mutants'])
   access=folder/'access.json';run('access',[HERE/'access-run.py',controls,'--evidence',access,'--cpu',a.cpu],None,None);data=json.loads(access.read_text());assert len(data['cases'])==9;static_boundary=data.get('staticProviderBoundary');assert (isinstance(static_boundary,dict) and static_boundary.get('status')=='FRESH_ACTUAL_STATIC_PROVIDER_BOUNDARY_PASS' and len(static_boundary.get('cases',[]))==8 and static_boundary.get('staticClientSHA256')==sha(controls/'experiments/s-integrate'/PC.STATIC_MODULE)) if PC.static_registration(controls/'experiments/s-integrate') else static_boundary is None;entry['gates'][-1].update(status='ACTUAL_ACCESS_9_PASS',receipt=str(access),receiptSHA256=sha(access))
   if PC.static_registration(controls/'experiments/s-integrate'):
    world=data['staticWorldBoundary'];assert world['status']=='FINITE_ACTUAL_STATIC_FOREIGN_WORLD_FIELDS_PASS' and sha(Path(world['receipt']))==world['receiptSHA256'],'Static world boundary receipt mismatch'
    actual_world=json.loads(Path(world['receipt']).read_text());assert actual_world['status']==world['status'] and len(actual_world['cases'])==16 and {(c['schema'],c['backend']) for c in actual_world['cases']}=={(s,b) for s in ('motion','health') for b in ('JS','Native')},'Static world coverage mismatch'
    assert actual_world['sourcePins']==json.loads((controls/'overlay.json').read_text())['sources'],'Static world input source mismatch'
   validate_static_access(access,overlay,entry['controlSources'])

   e11=folder/'e11.json';run('e11',[HERE/'e11-run.py',controls,'--evidence',e11,'--cpu',a.cpu],e11,{'BOUNDED_JOINED_PASS'})
   retention=json.loads(e11.read_text());assert len(retention['actual'])==20 and len(retention['publicReference'])==10 and retention['semanticMutants']['status']=='PASS'
   owned=folder/'owned';env=dict(os.environ,BENDVY_FINAL_OVERLAY=str(overlay.resolve()),BENDVY_OWNED_ARTIFACT=str(owned),BENDVY_CPU=str(a.cpu));run('owned-storage',[HERE/'owned-storage-run.py'],owned/'evidence.json',{'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS'},env)
   stage=folder/'staging';run('staging',[HERE/'staging-controls.py','--overlay',overlay,'--output',stage,'--cpu',a.cpu],stage/'evidence.json',{'PASS_BOUNDED_STAGING_TYPE_BOUNDARY'})
   for variant in [None,'stale-head','torn-tail','lost-mark','inverse-order']:
    target=folder/('tx-'+(variant or 'baseline'));args=[HERE/'tx-controls-run.py','--overlay',overlay,'--output',target,'--cpu',a.cpu]+(['--mutation',variant] if variant else [])+(['--split-schemas'] if role=='Native' else []);run(target.name,args,target/'evidence.json',{'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE'} if variant else {'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS'})
   validate_suppressed_owner(folder/'tx-baseline/evidence.json',overlay)
   assert source_binding(overlay)==binding,'Snapshot changed during checks';validate_gates(entry['gates']);entry['status']='PASS'
  assert dependency_binding(a.cpu)==result['dependencyBinding'],'Dependencies changed during fresh checks'
  result['status']='FRESH_TWO_ROLE_CONNECTED_GATES_PASS'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
