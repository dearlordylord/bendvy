"""Portable finite current-root variant Native48 joins, with no backend children."""
import argparse,hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;sha=lambda raw:hashlib.sha256(raw).hexdigest();sys.dont_write_bytecode=True
ADMITTED={'wrong-exit-selector':('bundle-relocated-mutant-Native-wrong-exit-selector-1791440178680683267','2fea3cdafa8cb6fc3f0d83d28d93de73d66ac7ea50776fdb7664b6fb605d020a'),'reverse-phase-order':('bundle-relocated-mutant-Native-reverse-phase-order-1791440180819389852','73d4e86c4aba0bba4714924b461e8e1ca2bbd4902465cffa766b819c97a8c7a0'),'omit-inactive-requirement':('bundle-relocated-mutant-Native-omit-inactive-requirement-1791440182748969378','b72ca2ab66c199b677193b0363b91b28de5d21c87323d6f374ce0fc083526e3b')}
def strict(raw):
 def pairs(items):
  out={}
  for k,v in items:
   assert k not in out,'duplicate key';out[k]=v
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def equal(a,b):return json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
def main(variant):
 D=H/'delivery-relocated-mutants-native-v1'/variant;m=strict((D/'manifest.json').read_bytes())
 assert sha((H/'delivery-relocated-mutants-js-v1/manifest.json').read_bytes())==m['currentJSMutantsManifestSHA256']
 for n,d in m['source'].items():assert sha((H/n).read_bytes())==d,n
 assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256'] and sha((D/m['archive']['name']).read_bytes())==m['archive']['sha256']
 with tarfile.open(D/m['archive']['name'],'r:gz') as t:
  members=t.getmembers();assert all(f.isfile() for f in members) and len(members)==len({f.name for f in members});data={f.name:t.extractfile(f).read() for f in members}
 assert set(data)==set(m['archive']['members'])
 for n,v in m['archive']['members'].items():assert sha(data[n])==v['sha256'] and len(data[n])==v['bytes']
 run,admitted=ADMITTED[variant];p=strict(data[run+'/plan.json']);r=strict(data[run+'/receipt.json'])
 assert sha(data[run+'/plan.json'])==admitted==r['planSHA256'] and r['status']=='BUNDLE_'+variant+'_NATIVE_COMPLETE48_REACHED_VARIANT_PASS'
 assert p['variant']==variant and [c['seconds'] for c in p['commands']]==[5,30,120,5]*2 and len(r['commands'])==8 and all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])==85
 stage={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stage==p['inventory']
 modelRecord=strict((H/'relocated-mutations-v1/manifest.json').read_bytes())['variants'][variant]
 assert stage[modelRecord['changedFile']]==modelRecord['relocatedVariantSHA256']
 for n,digest in strict((H/'adoption-stage-review-manifest.json').read_bytes())['closure'].items():
  if n!=modelRecord['changedFile']:assert stage[n]==digest
 fixture='experiments/public-machine-handlers/candidate-v1/bundle-v1/';assert stage[fixture+'expected.json']==modelRecord['expectedSHA256']
 root=Path(p['stage']).parent;probe=root/'execution-probes';pins={str(probe/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']};assert set(r['probePins'])==pins
 assert {n[len(run+'/execution-probes/'):] for n in data if n.startswith(run+'/execution-probes/')}=={Path(n).name for n in pins}
 for absolute,d in r['probePins'].items():assert sha(data[run+'/'+str(Path(absolute).relative_to(root))])==d
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 for n,d in r['logs'].items():assert sha(data[run+'/'+n])==d
 assert all(not data[run+'/'+c['label']+'.stderr'] for c in p['commands'])
 for c in p['commands']:
  if c['label'].endswith('-source'):assert data[run+'/'+c['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
 for absolute,d in r['generated'].items():
  if Path(absolute).suffix=='.c':assert sha(data[run+'/'+Path(absolute).name])==d
 directory=H/'relocated-mutations-v1'/variant;expected=strict((directory/'expected.json').read_bytes())['rows'];normal=strict((H/'expected.json').read_bytes())['rows'];observed={}
 assert sha((directory/'oracle.py').read_bytes())==modelRecord['modelSHA256']
 spec=importlib.util.spec_from_file_location('independent_native_'+variant.replace('-','_'),directory/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
 assert equal(expected,{s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]})
 for schema in ['A','B']:
  values=strict(data[run+'/bundle-'+schema+'-run.stdout']);assert isinstance(values,list) and len(values)==24 and all(set(v)=={'name','value'} for v in values) and [v['name'] for v in values]==list(expected[schema]);observed[schema]={v['name']:v['value'] for v in values}
  assert equal(observed[schema],expected[schema]) and not equal(observed[schema][modelRecord['witness']],normal[schema][modelRecord['witness']])
 assert equal(observed,r['observations']) and equal(observed,expected)
 print('PORTABLE_CURRENT_ROOT_'+variant+'_NATIVE_FULL48_REACHED_PASS')
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--variant',required=True,choices=ADMITTED);main(parser.parse_args().variant)
