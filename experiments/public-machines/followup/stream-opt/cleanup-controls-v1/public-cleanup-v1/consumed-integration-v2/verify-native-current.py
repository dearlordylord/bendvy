"""Finite current-world Native normal/control evidence, no backend execution."""
from pathlib import Path
import hashlib,importlib.util,io,json,re,tarfile,tempfile
V=Path(__file__).resolve().parent;D=V/'native-current-v1/delivery-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
canonical=lambda x:json.dumps(x,sort_keys=True,separators=(',',':'))
def unpack(blob,members):
 with tarfile.open(fileobj=io.BytesIO(blob)) as t:
  es=t.getmembers();ns=[e.name for e in es];assert len(ns)==len(set(ns)) and set(ns)==set(members)
  assert all(e.isfile() and not Path(e.name).is_absolute() and '..' not in Path(e.name).parts for e in es)
  out={e.name:t.extractfile(e).read() for e in es}
 for n,e in members.items():assert sha(out[n])==e['sha256'] and len(out[n])==e['bytes']
 return out
m=json.loads((D/'manifest.json').read_text());assert sha((D/'cohort.tar.gz').read_bytes())==m['archive']['sha256'] and sha((D/'REPORT.md').read_bytes())==m['reportSHA256'];data=unpack((D/'cohort.tar.gz').read_bytes(),m['archive']['members'])
for n,h in m['sources'].items():assert sha((V/n).read_bytes())==sha(data['source/'+n])==h
ADMITTED={'post-normal': ('1175edf25840ba2e489d3d17420bafe158ff86f0c66778d5984c076e0632ce24', '719046f5514a2a7f8789490f4812fb2d9132974204730b14edc21026372a75c3'), 'failed-normal': ('15a11601ab8d353634bc866e85a49e16cb1f5e66c92d5ee0e72bb5536e61e9cb', 'a32ae02f52720daec1c95eb5b9749821380e7214cc73afbe29c2d5748a176fe0'), 'post-control': ('dc50cd36f3686cefba5f4ed989665c3f552f8510d027588c4b826f3aac25d862', '0d6ca691f495c860210e78aa46e2ec56ea0303100194513d4cb1595b0ebf23c7'), 'failed-control': ('394ae5c56997a2b48aee3c9539040b9b6c74ff9b9e9eb9fd9ccfb12506e3d75c', 'ab76df0dac234c9554288f89e4d057bf6f68ade473f658302aa6b0929bd9cf4b')}

assert set(m['runs'])==set(ADMITTED)
plans={};receipts={};private={};elf={};outputs={}
runner='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
notice='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
for label,(ps,rs) in ADMITTED.items():
 assert sha(data[label+'/plan.json'])==m['runs'][label]['planSHA256']==ps and sha(data[label+'/receipt.json'])==m['runs'][label]['receiptSHA256']==rs
 p=json.loads(data[label+'/plan.json']);r=json.loads(data[label+'/receipt.json']);plans[label]=p;receipts[label]=r
 incomplete=label=='failed-control'
 assert r['planSHA256']==ps and not r.get('guardFailures',[]) and len(p['commands'])==3 and len(r['commands'])==(2 if incomplete else 3)
 scenario='POST_CONSUMPTION' if label.startswith('post') else 'FAILED_BATCH'
 expected='ACTUAL_CURRENT_WORLD_ACCEPTED_CLOCK_MUTANT_'+scenario+'_FULL_NATIVE_VARIANT_ORACLE_AND_BOTH_SCHEMA_WITNESSES_PASS_NO_ADOPTION' if label.endswith('control') else 'ACTUAL_CURRENT_WORLD_CLEANUP_'+scenario+'_FULL_NATIVE_ORACLE_PASS_NO_ISSUE_CLOSURE'
 assert r['status']==('INCOMPLETE' if incomplete else expected) and [c['label'] for c in p['commands']]==['emit-c','clang','consumer'] and [c['seconds'] for c in p['commands']]==[30,120,5] and p['tools']['cpu']==8
 pref=label+'/stage/';inventory={n[len(pref):]:sha(b) for n,b in data.items() if n.startswith(pref)};assert inventory==p['inventory'] and len(inventory)==109
 private[p['environment']]=p['environmentSHA256']
 logs={c['label']+suffix for c in r['commands'] for suffix in ['.stdout','.stderr']};assert set(r['logs'])==logs
 assert {n[len(label)+1:] for n in data if n.startswith(label+'/') and '/' not in n[len(label)+1:] and n not in [label+'/plan.json',label+'/receipt.json']}==logs
 for n,h in r['logs'].items():assert sha(data[label+'/'+n])==h
 for c,a in zip(p['commands'],r['commands']):
  failed=incomplete and c['label']=='clang';assert all(a[k]==c[k] for k in ['argv','label','seconds']) and a['exit']==(None if failed else 0) and a['failure']==('child deadline' if failed else None) and a['runnerSHA256']==runner and a['capture']=='split' and a['status']==('FAILED' if failed else 'TERMINAL')
 c,cc,run=p['commands'];prefix=[p['tools']['taskset'],'-c','8'];assert c['argv'][:4]==prefix+[p['tools']['tools']['bend']] and c['argv'][5:]==['-o',c['generated']]
 rel=str(Path(c['argv'][4]).relative_to(Path(p['stage'])));assert rel in inventory and sha(data[pref+rel])==inventory[rel]
 assert cc['argv']==prefix+[p['tools']['tools']['clang_wrapper'],'-O3',c['generated'],'-o',cc['generated'],'-pthread','-lm'] and run['argv']==prefix+[cc['generated'],'--threads','1','--gpu','off']
 assert set(r['generated'])==set(m['generatedDispositions'][label])==({c['generated']} if incomplete else {c['generated'],cc['generated']})
 if not incomplete:elf[cc['generated']]=r['generated'][cc['generated']]
 assert {n for n in data if n.startswith(label+'/generated/')}=={e['member'] for e in m['generatedDispositions'][label].values() if e['kind']=='archive'}
 assert data[label+'/emit-c.stdout']==data[label+'/clang.stdout']==data[label+'/clang.stderr']==(b'' if incomplete else data[label+'/consumer.stderr'])==b'' and (data[label+'/emit-c.stderr']==b'' or sha(data[label+'/emit-c.stderr'])==notice)
 active=[k for k in p['tools']['tools'] if k not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(7) for k in active];assert p['executionProbeLabels']==labels and p['expectedProbeCount']==len(labels)==49 and r['probeCommandsExecuted']==(35 if incomplete else 49);labels=labels[:35] if incomplete else labels
 members={n+suffix for n in labels for suffix in ['.json','.stdout','.stderr']};pre=label+'/execution-probes/';orig=m['runs'][label]['originalDirectory']+'/execution-probes/'
 assert {n[len(pre):] for n in data if n.startswith(pre)}==members and set(r['probePins'])=={orig+n for n in members}
 for n in members:assert sha(data[pre+n])==r['probePins'][orig+n]
 for n in labels:
  q=json.loads(data[pre+n+'.json']);k=n.split('-ldd-',1)[1];assert q['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][k]] and q['seconds']==5 and q['exit']==0 and q['failure'] is None and q.get('exception') is None and q['runnerSHA256']==runner
 assert set(m['pinDispositions'][label])==set(p['pins'])
 for n,h in p['pins'].items():
  e=m['pinDispositions'][label][n];assert e['sha256']==h
  if e['kind']=='archive':
   assert sha(data[e['member']])==h
   if n.endswith('/plan.json'):
    old=json.loads(data[e['member']])
    for f in ['environment','privateEnvironment']:
     if f in old:private[old[f]]=old['environmentSHA256']
 if not incomplete:outputs[label]=data[label+'/consumer.stdout']
# Bind the literal prior packet and all its private-owner identities separately.
ps=m['priorJSManifestSHA256'];assert ps=='1b738f40d318f768f0fe554c98dc9d501060f5147b7a71355e26e38cf435a564';prior=json.loads(data['pin-bytes/'+ps]);private.update(prior['privateOwnerRoles']);assert private==m['privateOwnerRoles'] and elf==m['generatedELFOwnerRoles']
priorblob=data['pin-bytes/'+prior['archive']['sha256']];assert sha(priorblob)==prior['archive']['sha256'];olddata=unpack(priorblob,prior['archive']['members'])
for label,p in plans.items():
 for n,e in m['pinDispositions'][label].items():
  if e['kind']=='installedIdentityExcluded':assert p['tools']['pins'][n]==e['sha256']
  elif e['kind']=='privateEnvironmentIdentityExcluded':assert private[n]==e['sha256']
  elif e['kind']=='generatedELFIdentityExcluded':assert elf[n]==e['sha256']
  else:assert e['kind']=='archive'
 for n,h in receipts[label]['generated'].items():
  e=m['generatedDispositions'][label][n];assert e['sha256']==h
  if e['kind']=='archive':assert sha(data[e['member']])==h
  else:assert e['kind']=='generatedELFIdentityExcluded' and elf[n]==h
for n,h in m['sources'].items():assert any(p['pins'].get(m['originalSourceRoot']+'/'+n)==h for p in plans.values()),n
selection=json.loads(data['source/native-current-v1/proposal.json']);control=json.loads(data['source/native-current-v1/mutation-clock-v1/proposal.json']);core='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller-core.bend';adapter='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/adapter.bend'
for label,p in plans.items():
 pref=label+'/stage/';assert p['inventory']==(control['inventory'] if label.endswith('control') else selection['inventory'])
 assert sha(data[pref+core])=='584eb301a7e7041fb8b0a8c5d1faeac47e13c80593f542000225c054102400d7' and 'GC.cleanup' in data[pref+core].decode() and 'Ports.Two' in data[pref+core].decode()
 assert adapter in p['consumedImports'] and p['inventory'][adapter]==(control['mutantSHA256'] if label.endswith('control') else control['normalSHA256'])
 for n,e in selection['currentCore'].items():assert p['pins'][n]==p['inventory'][e['copy']]==sha(data[pref+e['copy']])==e['sha256']
for normal,variant in [('post-normal','post-control'),('failed-normal','failed-control')]:assert [n for n in plans[normal]['inventory'] if plans[normal]['inventory'][n]!=plans[variant]['inventory'][n]]==[adapter]
for e in selection['changedFiles']:
 old=olddata['post-JS/stage/'+e['path']];new=data['post-normal/stage/'+e['path']];assert sha(old)==e['oldSHA256'] and sha(new)==e['newSHA256'] and re.sub(rb'\bRead\b',b'WorldTailScanRead',re.sub(rb'\bReady\b',b'WorldTailScanReady',old))==new
with tempfile.TemporaryDirectory() as tmp:
 h=Path(tmp)/'public-cleanup-v1'
 for n,b in olddata.items():
  if n.startswith('source/'):
   f=h/n[7:];f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(b)
 for scenario,normal,variant in [('post-consumption','post-normal','post-control'),('failed-batch','failed-normal','failed-control')]:
  results=[]
  for path,label in [(h/'models'/scenario/'validate.py',normal),(h/'consumed-integration-v2/mutation-clock-v2/models'/scenario/'validate.py',variant)]:
   if label not in outputs:continue
   spec=importlib.util.spec_from_file_location('validator_'+label.replace('-','_'),path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);results.append(module.validate(outputs[label]))
  def differences(a,b,path=()):
   if isinstance(a,dict):assert set(a)==set(b);return sum((differences(a[k],b[k],path+(k,)) for k in a),[])
   if isinstance(a,list):assert len(a)==len(b);return sum((differences(x,y,path+(i,)) for i,(x,y) in enumerate(zip(a,b))),[])
   return [] if canonical(a)==canonical(b) else [(path,a,b)]
  if len(results)==1:assert scenario=='failed-batch';continue
  diffs=differences(*results);assert len(diffs)==6 and all(p[-1]=='componentClock' and int(b)-int(a) in [1,2] for p,a,b in diffs)
print('PORTABLE_CURRENT_CLEANUP_NATIVE_TWO_NORMALS_POST_REACHED_CONTROL_AND_FAILED_CONTROL_INCOMPLETE_PASS')
