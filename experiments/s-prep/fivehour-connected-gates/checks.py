#!/usr/bin/env python3
"""Fresh authoritative semantic gates for the exact immutable two-role snapshot."""
import argparse,datetime,hashlib,json,os,re,signal,subprocess,sys
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
 return {'overlayManifestSHA256':sha(overlay/'overlay.json'),'runtimeSources':dict(sorted(seen.items())),'runtimeClosureSHA256':hashlib.sha256(json.dumps(dict(sorted(seen.items())),separators=(',',':')).encode()).hexdigest()}
def main():
 p=argparse.ArgumentParser();p.add_argument('--js-overlay',type=Path,required=True);p.add_argument('--native-overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=9);a=p.parse_args();a.output.mkdir(exist_ok=False)
 result={'status':'INCOMPLETE','schemaVersion':1,'scope':'Fresh exact candidate semantic/capability gates; no metric or product acceptance','roles':{},'gateSources':{f.name:sha(f) for f in HERE.glob('*.py')}}
 try:
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
   host=folder/'host12';run('host12',[HERE/'host-mutations-run.py','--overlay',controls,'--output-dir',host,'--cpu',a.cpu],host/'protocol.json',{'PASS'})
   semantics=json.loads((host/'semantic-evidence.json').read_text());assert len(semantics['original'])==2 and all(x['fullSelectedChannelsEqual'] for x in semantics['original']);assert len(semantics['mutants'])==12 and all(len(x['observations'])==2 and all(o['compiling'] for o in x['observations']) for x in semantics['mutants'])
   access=folder/'access.json';run('access',[HERE/'access-run.py',controls,'--evidence',access],None,None);data=json.loads(access.read_text());assert len(data['cases'])==9;entry['gates'][-1].update(status='ACTUAL_ACCESS_9_PASS',receipt=str(access),receiptSHA256=sha(access))
   e11=folder/'e11.json';run('e11',[HERE/'e11-run.py',controls,'--evidence',e11],e11,{'BOUNDED_JOINED_PASS'})
   retention=json.loads(e11.read_text());assert len(retention['actual'])==20 and len(retention['publicReference'])==10 and retention['semanticMutants']['status']=='PASS'
   owned=folder/'owned';env=dict(os.environ,BENDVY_FINAL_OVERLAY=str(overlay.resolve()),BENDVY_OWNED_ARTIFACT=str(owned),BENDVY_CPU=str(a.cpu));run('owned-storage',[HERE/'owned-storage-run.py'],owned/'evidence.json',{'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS'},env)
   stage=folder/'staging';run('staging',[HERE/'staging-controls.py','--overlay',overlay,'--output',stage,'--cpu',a.cpu],stage/'evidence.json',{'PASS_BOUNDED_STAGING_TYPE_BOUNDARY'})
   for variant in [None,'torn-tail','lost-mark','inverse-order']:
    target=folder/('tx-'+(variant or 'baseline'));args=[HERE/'tx-controls-run.py','--overlay',overlay,'--output',target,'--cpu',a.cpu]+(['--mutation',variant] if variant else []);run(target.name,args,target/'evidence.json',{'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE'} if variant else {'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS'})
   assert source_binding(overlay)==binding,'Snapshot changed during checks';entry['status']='PASS'
  result['status']='FRESH_TWO_ROLE_CONNECTED_GATES_PASS'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
