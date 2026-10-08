"""Read/hash-only exact admitted whole aligned IO Native A/B reconciliation; no clocks."""
import hashlib,importlib.util,json,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
ADMITTED={
 'A':('aligned-native-A-runtime-1791454622703869356','3e709322c39d5b7cc664ae5ac2919ecaef7edb0113fd63c5e70cbd1365e98a76'),
 'B':('aligned-native-B-runtime-1791454794933261423','519cda2f27deb848f4968d4ba4c65a3ca6d54aa6573bb845226386db5e900739')}
RECEIPTS={'A':'49c934ac96a957cac57c01d08fae7afe5c5820fe4e86a81b7548e75ab1402d94','B':'a02c0fd8e91097f3d90a551b4973fbea966eabcd49a8c1ac27e58bce72ceccc0'}
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
 assert p['schema']==schema and r['status']=='SCHEMA_'+schema+'_COMPLETE58_AND21_ALIGNED_IO_NATIVE_CORRECTNESS_PASS_NO_FULL116_TIMING_CREDIT'
 assert [c['seconds'] for c in p['commands']]==[120,5] and len(r['commands'])==2
 assert [c['label'] for c in p['commands']]==['aligned-native-clang','aligned-native-run']
 assert all(c['exit']==0 and c['failure'] is None for c in r['commands']) and not r.get('guardFailures',[])
 assert inventory(Path(p['stage']))==p['inventory']
 for f,digest in p['pins'].items():assert sha(f)==digest,f
 assert sha(p['privateEnvironment'])==p['environmentSHA256']
 wrapper=H/('run-aligned-native-'+schema+'-runtime.py')
 definitions={'__file__':str(wrapper),'__name__':'ledger_reconciliation_config_'+schema}
 exec(compile(wrapper.read_text().split('parser=argparse.ArgumentParser()')[0],str(wrapper),'exec'),definitions)
 env=definitions['decode'](strict(Path(p['privateEnvironment']).read_bytes()))
 assert definitions['current_configs'](d,Path(p['stage']),p['tools'],env)==p['configurationStates']
 binary=d/('aligned-ledger-'+schema)
 assert r['generated']=={str(binary):sha(binary)}
 prefix=[p['tools']['taskset'],'-c','8'];cfile=p['commands'][0]['argv'][5]
 assert sha(cfile)==p['pins'][cfile]
 assert p['commands']==[{'label':'aligned-native-clang','argv':prefix+[p['tools']['tools']['clang-wrapper'],'-O3',cfile,'-pthread','-lm','-o',str(binary)],'seconds':120,'expected':0,'generated':str(binary)}, {'label':'aligned-native-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'expected':0,'oracle':True}]
 labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
 assert p['executionProbeLabels']==labels and r['probeCommandsExecuted']==25
 probe=d/'execution-probes';members={str(probe/(label+suffix)) for label in labels for suffix in ['.json','.stdout','.stderr']}
 assert set(r['probePins'])==members=={str(f) for f in probe.iterdir()}
 for f,digest in r['probePins'].items():assert sha(f)==digest,f
 for label in labels:
  tool=label.split('-ldd-',1)[1];meta=strict((probe/(label+'.json')).read_bytes())
  assert meta['argv']==['/usr/bin/taskset','-c','8','/usr/bin/ldd',p['tools']['tools'][tool]]
  assert meta['seconds']==5 and meta['exit']==0 and meta['failure'] is None and meta.get('exception') is None
  assert meta['runnerSHA256']==p['pins'][str(H.parents[4]/'scripts/task_runner.py')]==r['commands'][0]['runnerSHA256']==r['commands'][1]['runnerSHA256']
 lognames={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 assert set(r['logs'])==lognames
 for f,digest in r['logs'].items():assert sha(d/f)==digest,f
 assert all(not (d/(c['label']+'.stderr')).read_bytes() for c in p['commands'])
 assert not (d/'aligned-native-clang.stdout').read_bytes()
 assert {f.name for f in d.iterdir()}=={'plan.json','receipt.json','private-environment.json','stage','execution-probes',*[Path(f).name for f in r['generated']],*lognames}
 raw=(d/'aligned-native-run.stdout').read_bytes();strict(raw)
 validator=load(H/'capture-alignment-source-v1/validate-schema.py','ledger_schema_'+schema)
 result=validator.validate(schema,raw)
 assert result['status']==r['independentValidationStatus']
 return strict(raw)[schema],{'planSHA256':admitted,'receiptSHA256':sha(d/'receipt.json'),'stdoutSHA256':sha(d/'aligned-native-run.stdout')}
def main():
 observed={};joins={}
 for schema in ['A','B']:observed[schema],joins[schema]=qualify(schema)
 validator=load(H/'capture-alignment-source-v1/validate-correctness.py','ledger_full_union')
 raw=json.dumps(observed,ensure_ascii=False,separators=(',',':')).encode()
 result=validator.validate(raw)
 out=H/('aligned-native116-reconciliation-'+str(time.time_ns()));out.mkdir()
 (out/'full116.json').write_bytes(raw+b'\n')
 receipt={'status':'FULL116_ALIGNED_CAPTURES_AND_UNCHANGED42_NATIVE_CORRECTNESS_RECONCILED_NO_TIMING_CREDIT','qualifications':joins,'validation':result,'unionSHA256':sha(out/'full116.json'),'sourceSHA256':sha(Path(__file__)),'backendSubjectsExecuted':0,'scope':'Actual whole A/B owners, physical116/common116 and unchanged42; IO.pure, no timing/population/proof/adoption credit.'}
 (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out);print(sha(out/'receipt.json'))
if __name__=='__main__':main()
