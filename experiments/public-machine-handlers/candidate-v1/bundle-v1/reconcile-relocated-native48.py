"""Read/hash-only reconciliation of exact independently admitted A/B Native24 receipts."""
import hashlib,importlib.util,json,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[3];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
sys.dont_write_bytecode=True
ADMITTED={'A':('bundle-relocated-native-A-1791439666073142944','f967adcff109ed3b324d59690955c2e1c46148baaa2cd454d59887c1b4cd84fd'),'B':('bundle-relocated-native-B-1791439667093325179','ce80a2d83523005757ee83dc4b7f5d2ad3e322a4f8bbc9b1209173db8c08ac0d')}
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def strict_json(raw):
 def pairs(items):
  out={}
  for k,v in items:
   assert k not in out,'duplicate key';out[k]=v
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda v:(_ for _ in ()).throw(ValueError(v)))
def equal(a,b):return json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
def qualify(schema):
 name,admitted=ADMITTED[schema];d=H/name;p=json.loads((d/'plan.json').read_text());r=json.loads((d/'receipt.json').read_text())
 assert sha(d/'plan.json')==admitted==r['planSHA256'];assert r['status']=='BUNDLE_SCHEMA_'+schema+'_TWENTY_FOUR_NATIVE_OBSERVATIONS_PASS'
 assert p['schema']==schema and [c['seconds'] for c in p['commands']]==[120,5] and len(r['commands'])==2
 assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])==25
 assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert inventory(Path(p['stage']))==p['inventory']
 for f,digest in p['pins'].items():assert sha(Path(f))==digest,f
 assert sha(Path(p['privateEnvironment']))==p['environmentSHA256']
 for f,digest in p['configurationStates'].items():assert (sha(Path(f)) if Path(f).is_file() else None)==digest,f
 for f,digest in r['generated'].items():assert sha(Path(f))==digest,f
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 for f,digest in r['logs'].items():assert sha(d/f)==digest,f
 assert all(not (d/(c['label']+'.stderr')).read_bytes() for c in p['commands'])
 probe=d/'execution-probes';expected={str(probe/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 assert set(r['probePins'])==expected and {str(f) for f in probe.iterdir()}==expected
 for f,digest in r['probePins'].items():assert sha(Path(f))==digest,f
 assert {f.name for f in d.iterdir()}=={'plan.json','receipt.json','private-environment.json','stage','execution-probes',*[Path(f).name for f in r['generated']],*r['logs']}
 raw=(d/('bundle-'+schema+'-run.stdout')).read_bytes();values=strict_json(raw);expected=strict_json((H/'expected.json').read_bytes())['rows'][schema]
 assert isinstance(values,list) and len(values)==len(expected)==24
 assert [v['name'] for v in values]==list(expected) and all(set(v)=={'name','value'} for v in values)
 rows={v['name']:v['value'] for v in values};assert equal(rows,expected) and equal(r['observations'],rows)
 return rows,{'planSHA256':admitted,'receiptSHA256':sha(d/'receipt.json'),'stdoutSHA256':sha(d/('bundle-'+schema+'-run.stdout'))}
def main():
 observed={};joins={}
 for schema in ['A','B']:observed[schema],joins[schema]=qualify(schema)
 expected=strict_json((H/'expected.json').read_bytes())['rows'];assert equal(observed,expected)
 spec=importlib.util.spec_from_file_location('bundle_independent_native_model',H/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
 assert equal(observed,{s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]})
 out=H/('bundle-relocated-native48-reconciliation-'+str(time.time_ns()));out.mkdir();raw=out/'full48.json';raw.write_text(json.dumps(observed,indent=2)+'\n')
 receipt={'status':'FULL_FORTY_EIGHT_ACTUAL_NATIVE_OBSERVATIONS_RECONCILED','qualifications':joins,'unionSHA256':sha(raw),'oracleSHA256':sha(H/'expected.json'),'modelSHA256':sha(H/'oracle.py'),'sourceSHA256':sha(Path(__file__)),'backendSubjectsExecuted':0,'scope':'Exact Native A24/B24 complete JSON plus independent full48 model only. No replay/performance/adoption/proof/full49 credit.'}
 (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out);print(sha(out/'receipt.json'))
if __name__=='__main__':main()
