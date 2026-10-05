#!/usr/bin/env python3
"""Fresh modest actual Native workload matrix for the composed closure, semantic only."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,re,shutil,tempfile
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[2]
sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
sp=importlib.util.spec_from_file_location('B',ROOT/'experiments/s-integrate/measurement-bend-run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def blocks(s):return {m[2]:m[0].rstrip() for m in re.finditer(r'^(def|type) (\w+)[\s\S]*?(?=^(?:def|type|import) |\Z)',s,re.M)}
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=pathlib.Path);a=p.parse_args();assert a.overlay.is_absolute() and a.overlay.resolve()==a.overlay;manifest=json.loads((a.overlay/'overlay.json').read_text());assert all(sha(a.overlay/n)==v for n,v in manifest['sources'].items());base=a.overlay/'experiments/s-integrate';original=blocks((base/'measurement-bend.bend').read_text());inputs=H/'query-inputs';assert sha(inputs/'original-raw-observer.bend')=='5c52525ee9fad33d6697d71331e0aaf0b61ee528082c2a680ca390ac3a433572'
 e={'scope':'fresh actual64-step Dense/Sparse original callbacks/dispatcher/Host/query/Held/Tx; modest counts64/256 both schemas; no timing','runtimeClosureSHA256':manifest['cacheSpecialization']['runtimeClosureSHA256'],'overlaySha256':sha(a.overlay/'overlay.json'),'cpu':11,'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'subjects':{},'cases':{},'inputs':{p.name:sha(p) for p in inputs.glob('*.bend')},'freshTSReferenceAdapterSha256':sha(ROOT/'experiments/s-integrate/measurement-reference.mjs'),'environment':{'Bend':R.run(['bend','version'])[0].strip(),'Base':sha(pathlib.Path.home()/'.bend/bend2/base.bend')}}
 def save():(H/'query-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='native-static-query-') as td:
  root=pathlib.Path(td);core=root/'core';shutil.copytree(base,core);shutil.copy2(inputs/'original-raw-observer.bend',core/'original-raw-observer.bend')
  for schema in ['Motion','Health']:
   library=inputs/(schema.lower()+'-control-workload.bend');assert all(v==original[k] for k,v in blocks(library.read_text()).items());shutil.copy2(library,core/'control-workload.bend');entry=core/'query-workload.bend';shutil.copy2(inputs/(schema.lower()+'-query-workload.bend'),entry)
   try:
    assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','11','bend',entry,'--check-only']));c=root/(schema+'.c');R.run(['taskset','-c','11','bend',entry,'-o',c],30);bin=root/schema;R.run(['taskset','-c','11','clang','-O3',c,'-o',bin,'-pthread','-lm'],120);e['subjects'][schema]={'status':'SOURCE_CODEGEN_O3_PASS','generatedSha256':sha(c),'artifactSha256':sha(bin),'closure':R.closure(entry),'originalTypesAndExecutableBlocksExact':True};save()
   except Exception as exc:e['subjects'][schema]={'status':'BOUNDED_FAILURE','error':str(exc)};save();continue
   for sparse in [False,True]:
    for n in [64,256]:
     key=schema+('-Sparse' if sparse else '-Dense')+str(n);case={};e['cases'][key]=case
     try:
      ref=json.loads(R.run(['taskset','-c','11','node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'sparse' if sparse else 'dense',str(n)])[0]);assert ref['status']=='PASS';out=R.run(['taskset','-c','11',bin,'0' if schema=='Motion' else '1','1' if sparse else '0',str(n),'--threads','1','--gpu','off'])[0];actual=json.loads(out);expected=B.expected(schema,sparse,n);query=[{'handle':{'namespace':1,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in expected['world']['rows'] if r['main'] is not None];assert actual==dict(expected,query=query,afterQuery=expected['world']);normal=B.normalized(expected,schema);digest=hashlib.sha256(json.dumps(normal,separators=(',',':')).encode()).hexdigest();assert digest==ref['finalSha256'];(H/(key+'.json.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));case.update(status='ACTUAL_FULL_RAW_FIELDS_ORDER_OWNER_PASS',rows=n,queryRows=len(query),freshTSFinalSha256=digest,outputSha256=hashlib.sha256(out.encode()).hexdigest(),fullRawBeforeAfterOwnerWorldExact=True)
     except Exception as exc:case.update(status='BOUNDED_FAILURE',error=str(exc))
     save();print(key,case['status'],flush=True)
 e['status']='ACTUAL_COMPOSED_NATIVE_QUERY_PASS8' if len(e['cases'])==8 and all(c['status']=='ACTUAL_FULL_RAW_FIELDS_ORDER_OWNER_PASS' for c in e['cases'].values()) else 'EXPLICIT_PARTIAL_GATE';save();print(e['status'])
if __name__=='__main__':main()
