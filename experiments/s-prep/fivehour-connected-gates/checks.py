#!/usr/bin/env python3
"""Fresh authoritative semantic gates for the exact immutable two-role snapshot."""
import argparse,datetime,hashlib,json,os,re,signal,subprocess,sys,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
DEADLINE=datetime.datetime.fromisoformat('2026-10-05T07:34:51+00:00')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
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
  for name in re.findall(r'^import (\./\S+\.bend)',source.read_text(),re.M):visit(source.parent/name)
 visit(overlay/'experiments/s-integrate/measurement-bend.bend')
 return {'manifestSources':dict(sorted(manifest['sources'].items())),'overlayManifestSHA256':sha(overlay/'overlay.json'),'runtimeSources':dict(sorted(seen.items())),'runtimeClosureSHA256':hashlib.sha256(json.dumps(dict(sorted(seen.items())),separators=(',',':')).encode()).hexdigest()}
def dependency_binding():
 tracked=subprocess.check_output(['git','ls-files'],cwd=ROOT,text=True).splitlines()
 prefixes=('experiments/s-integrate/','experiments/s-integrate-trace/','experiments/s-perf/candidate/','experiments/s-prep/fivehour-connected-gates/')
 sources={n:sha(ROOT/n) for n in tracked if n.startswith(prefixes) and Path(n).suffix in {'.py','.bend','.mjs','.js','.ts'} and (ROOT/n).is_file()}
 for n in ('experiments/t05/run.py','experiments/s-perf/owned-index-core.bend','experiments/s-prep/owned-write-query-integration/controls-run.py','experiments/s-prep/owned-write-query-integration/prepare-evidence.json'):
  sources[n]=sha(ROOT/n)
 sources.update({str(f.relative_to(ROOT)):sha(f) for f in HERE.iterdir() if f.suffix in {'.py','.bend'}})
 sources['experiments/t01/bend-check']=sha(ROOT/'experiments/t01/bend-check')
 tools={n:{'path':str(Path(shutil.which(n)).resolve()),'sha256':sha(Path(shutil.which(n)).resolve())} for n in ('bend','node','clang','python3','timeout')}
 base=Path.home()/'.bend/bend2/base.bend';tools['Base']={'path':str(base),'sha256':sha(base)}
 reference=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts')
 refnames=subprocess.check_output(['git','ls-files','packages/core/src'],cwd=reference,text=True).splitlines()
 refs={n:sha(reference/n) for n in refnames}
 for n in refnames:
  pinned=subprocess.check_output(['git','show','HEAD:'+n],cwd=reference)
  assert hashlib.sha256(pinned).hexdigest()==refs[n],'Reference tracked source drift'
 return {'gateAndProtectedSources':dict(sorted(sources.items())),'tools':tools,'referenceHEAD':subprocess.check_output(['git','rev-parse','HEAD'],cwd=reference,text=True).strip(),'referenceCoreSources':refs,'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':9}
def main():
 p=argparse.ArgumentParser();p.add_argument('--js-overlay',type=Path,required=True);p.add_argument('--native-overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=9);p.add_argument('--reuse-receipt',type=Path);p.add_argument('--reuse-receipt-sha256');a=p.parse_args();a.output.mkdir(exist_ok=False)
 result={'status':'INCOMPLETE','schemaVersion':1,'scope':'Fresh exact candidate semantic/capability gates; no metric or product acceptance','roles':{},'gateSources':{f.name:sha(f) for f in HERE.glob('*.py')}}
 try:
  result['dependencyBinding']=dependency_binding()
  if a.reuse_receipt:
   assert a.reuse_receipt_sha256 and sha(a.reuse_receipt)==a.reuse_receipt_sha256,'Canonical receipt digest missing or mismatched'
   prior=json.loads(a.reuse_receipt.read_text());assert prior['status']=='FRESH_TWO_ROLE_CONNECTED_GATES_PASS','Only complete fresh receipt can authorize reuse'
   assert prior['dependencyBinding']==result['dependencyBinding'],'Gate/tool/reference dependencies changed'
   for role,overlay in [('JS',a.js_overlay),('Native',a.native_overlay)]:
    old=prior['roles'][role];assert old['status']=='PASS' and len(old['gates'])==11,'Incomplete role gates'
    binding=source_binding(overlay);assert binding['runtimeSources']==old['binding']['runtimeSources'] and binding['runtimeClosureSHA256']==old['binding']['runtimeClosureSHA256'],'Runtime candidate source changed; run full gates'
    controls=a.output/(role+'-reuse-controls');command=[sys.executable,str(HERE/'materialize-controls.py'),'--overlay',str(overlay),'--output',str(controls),'--raw-snapshots','--slice-host-fixtures'];subprocess.run(command,stdout=subprocess.DEVNULL,check=True,timeout=120)
    derived=json.loads((controls/'overlay.json').read_text())['sources'];assert derived==old['controlSources'],'Derived actual gate source changed; run full gates'
    for gate in old['gates']:
     if 'receipt' in gate:assert sha(Path(gate['receipt']))==gate['receiptSHA256'],'Dependency receipt drift'
    result['roles'][role]={'status':'REUSED','binding':binding,'controlSources':derived,'gates':old['gates']}
   result.update(status='EXACT_UNCHANGED_TWO_ROLE_GATES_REUSED',reused=True,sourceReceiptSHA256=sha(a.reuse_receipt))
   return
  assert not a.reuse_receipt_sha256,'Digest requires reuse receipt'
  for role,overlay in [('JS',a.js_overlay),('Native',a.native_overlay)]:
   binding=source_binding(overlay);folder=a.output/role;folder.mkdir();entry={'status':'INCOMPLETE','input':str(overlay.resolve()),'binding':binding,'gates':[]};result['roles'][role]=entry
   def run(label,args,receipt,statuses,env=None):
    assert datetime.datetime.now(datetime.timezone.utc)<DEADLINE,'Global work deadline reached'
    command=[sys.executable,*map(str,args)];out=folder/(label+'.log');process=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
    try:text,_=process.communicate(timeout=min(1200,(DEADLINE-datetime.datetime.now(datetime.timezone.utc)).total_seconds()))
    except subprocess.TimeoutExpired:os.killpg(process.pid,signal.SIGKILL);text,_=process.communicate();out.write_text(text);raise RuntimeError(label+' gate deadline')
    out.write_text(text);gate={'name':label,'command':command,'exit':process.returncode,'logSHA256':sha(out)};entry['gates'].append(gate)
    assert process.returncode==0,label+' failed: '+text[-2000:]
    if receipt:
     evidence=json.loads(receipt.read_text());assert evidence['status'] in statuses,label+' receipt not passing';gate.update(status=evidence['status'],receipt=str(receipt),receiptSHA256=sha(receipt))
   controls=folder/'control-overlay'
   run('materialize-controls',[HERE/'materialize-controls.py','--overlay',overlay,'--output',controls,'--raw-snapshots','--slice-host-fixtures'],None,None)
   entry['controlSources']=json.loads((controls/'overlay.json').read_text())['sources']
   host=folder/'host12';run('host12',[HERE/'host-mutations-run.py','--overlay',controls,'--output-dir',host,'--cpu',a.cpu],host/'protocol.json',{'PASS'})
   semantics=json.loads((host/'semantic-evidence.json').read_text());assert len(semantics['original'])==2 and all(x['fullSelectedChannelsEqual'] for x in semantics['original']);assert len(semantics['mutants'])==12 and all(len(x['observations'])==2 and all(o['compiling'] for o in x['observations']) for x in semantics['mutants'])
   access=folder/'access.json';run('access',[HERE/'access-run.py',controls,'--evidence',access],None,None);data=json.loads(access.read_text());assert len(data['cases'])==9;entry['gates'][-1].update(status='ACTUAL_ACCESS_9_PASS',receipt=str(access),receiptSHA256=sha(access))
   e11=folder/'e11.json';run('e11',[HERE/'e11-run.py',controls,'--evidence',e11],e11,{'BOUNDED_JOINED_PASS'})
   retention=json.loads(e11.read_text());assert len(retention['actual'])==20 and len(retention['publicReference'])==10 and retention['semanticMutants']['status']=='PASS'
   owned=folder/'owned';env=dict(os.environ,BENDVY_FINAL_OVERLAY=str(overlay.resolve()),BENDVY_OWNED_ARTIFACT=str(owned),BENDVY_CPU=str(a.cpu));run('owned-storage',[HERE/'owned-storage-run.py'],owned/'evidence.json',{'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS'},env)
   stage=folder/'staging';run('staging',[HERE/'staging-controls.py','--overlay',overlay,'--output',stage,'--cpu',a.cpu],stage/'evidence.json',{'PASS_BOUNDED_STAGING_TYPE_BOUNDARY'})
   for variant in [None,'stale-head','torn-tail','lost-mark','inverse-order']:
    target=folder/('tx-'+(variant or 'baseline'));args=[HERE/'tx-controls-run.py','--overlay',overlay,'--output',target,'--cpu',a.cpu]+(['--mutation',variant] if variant else []);run(target.name,args,target/'evidence.json',{'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE'} if variant else {'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS'})
   assert source_binding(overlay)==binding,'Snapshot changed during checks';entry['status']='PASS'
  result['status']='FRESH_TWO_ROLE_CONNECTED_GATES_PASS'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
