"""Read/hash-only exact admitted whole IO Native A/B reconciliation; no clocks."""
import hashlib,importlib.util,json,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
ADMITTED={
 'A':('ledger-native-A-runtime-1791449142707045294','998eaf022d43aaa8d01ddbc0637e5fa076d7a5913b07bfde5b504089a17cb5a9'),
 'B':('ledger-native-B-runtime-1791449515094841909','b969a2e3fd6f1e252c67b46136326151249d18101647a7ae3b97dab3d5092190')}
RECEIPTS={'A':'dffdc05044bd971b0930a98070ec4dde28ed16a0406096a4aa95d76408c08187','B':'a20173b92edc1b8643970b566c445358374025845b6aefa45b741f17147500f0'}
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def load(p,name):
 spec=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def strict(raw):
 def pairs(items):
  out={}
  for key,value in items:
   assert key not in out,'duplicate JSON key';out[key]=value
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def canonical(v):return json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def qualify(schema):
 name,admitted=ADMITTED[schema];d=H/name;p=strict((d/'plan.json').read_bytes());r=strict((d/'receipt.json').read_bytes())
 assert sha(d/'plan.json')==admitted==r['planSHA256']
 assert sha(d/'receipt.json')==RECEIPTS[schema]
 assert p['schema']==schema and r['status']=='SCHEMA_'+schema+'_COMPLETE21_IO_LEDGER_NATIVE_CORRECTNESS_PASS_NO_FULL42_TIMING_CREDIT'
 assert [c['seconds'] for c in p['commands']]==[120,5] and len(r['commands'])==2
 assert [c['label'] for c in p['commands']]==['ledger-'+schema+'-clang','ledger-'+schema+'-run']
 assert all(c['exit']==0 and c['failure'] is None for c in r['commands']) and not r.get('guardFailures',[])
 assert inventory(Path(p['stage']))==p['inventory']
 for f,digest in p['pins'].items():assert sha(f)==digest,f
 assert sha(p['privateEnvironment'])==p['environmentSHA256']
 wrapper=H/('run-ledger-native-'+schema+'-runtime.py')
 definitions={'__file__':str(wrapper),'__name__':'ledger_reconciliation_config_'+schema}
 exec(compile(wrapper.read_text().split('parser=argparse.ArgumentParser()')[0],str(wrapper),'exec'),definitions)
 env=definitions['decode'](strict(Path(p['privateEnvironment']).read_bytes()))
 assert definitions['current_configs'](d,Path(p['stage']),p['tools'],env)==p['configurationStates']
 for f,digest in r['generated'].items():assert sha(f)==digest,f
 labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
 assert p['executionProbeLabels']==labels and r['probeCommandsExecuted']==25
 probe=d/'execution-probes';members={str(probe/(label+suffix)) for label in labels for suffix in ['.json','.stdout','.stderr']}
 assert set(r['probePins'])==members=={str(f) for f in probe.iterdir()}
 for f,digest in r['probePins'].items():assert sha(f)==digest,f
 for label in labels:
  tool=label.split('-ldd-',1)[1];meta=strict((probe/(label+'.json')).read_bytes())
  assert meta['argv']==['/usr/bin/taskset','-c','8','/usr/bin/ldd',p['tools']['tools'][tool]]
  assert meta['seconds']==5 and meta['exit']==0 and meta['failure'] is None and meta.get('exception') is None
  assert meta['runnerSHA256']==r['commands'][0]['runnerSHA256']==r['commands'][1]['runnerSHA256']
 lognames={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 assert set(r['logs'])==lognames
 for f,digest in r['logs'].items():assert sha(d/f)==digest,f
 assert all(not (d/(c['label']+'.stderr')).read_bytes() for c in p['commands'])
 assert not (d/('ledger-'+schema+'-clang.stdout')).read_bytes()
 assert {f.name for f in d.iterdir()}=={'plan.json','receipt.json','private-environment.json','stage','execution-probes',*[Path(f).name for f in r['generated']],*lognames}
 raw=(d/('ledger-'+schema+'-run.stdout')).read_bytes();strict(raw)
 validator=load(H/'ledger-native-source-v1/validate-schema.py','ledger_schema_'+schema)
 result=validator.validate(schema,raw)
 assert result['status']==r['independentValidationStatus']
 return result['physical'][schema],{'planSHA256':admitted,'receiptSHA256':sha(d/'receipt.json'),'stdoutSHA256':sha(d/('ledger-'+schema+'-run.stdout'))}
def main():
 observed={};joins={}
 for schema in ['A','B']:observed[schema],joins[schema]=qualify(schema)
 validator=load(H/'ledger-driver-source-v1/validate-correctness.py','ledger_full_union')
 raw=json.dumps(observed,ensure_ascii=False,separators=(',',':')).encode()
 result=validator.validate(raw)
 out=H/('ledger-native42-reconciliation-'+str(time.time_ns()));out.mkdir()
 (out/'full42.json').write_bytes(raw+b'\n')
 receipt={'status':'FULL42_SAME_OWNER_IO_LEDGER_NATIVE_CORRECTNESS_RECONCILED_NO_TIMING_CREDIT','qualifications':joins,'validation':result,'unionSHA256':sha(out/'full42.json'),'sourceSHA256':sha(Path(__file__)),'backendSubjectsExecuted':0,'scope':'Actual whole A/B owners, physical42/common42 only; IO.pure, no timing/population/proof/adoption credit.'}
 (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out);print(sha(out/'receipt.json'))
if __name__=='__main__':main()
