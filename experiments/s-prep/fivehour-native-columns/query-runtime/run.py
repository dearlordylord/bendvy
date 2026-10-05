#!/usr/bin/env python3
"""Fresh full-field actual Dense/Sparse query runtime gate, no timing metric."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,re,shutil,tempfile
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[3]
sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
sp=importlib.util.spec_from_file_location('B',ROOT/'experiments/s-integrate/measurement-bend-run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def defs(text):return {m[1]:m[0].rstrip() for m in re.finditer(r'^def (\w+)[\s\S]*?(?=^(?:def|type|import) |\Z)',text,re.M)}
def validate(actual,schema,sparse,count,reference):
 expected=B.expected(schema,sparse,count);query=[{'handle':{'namespace':1,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in expected['world']['rows'] if r['main'] is not None]
 assert actual==dict(expected,query=query,afterQuery=expected['world']),'FULL_FIELDS_ORDER_METADATA_OWNER_RESTORATION_DIFFERENCE'
 normalized=B.normalized(expected,schema);digest=hashlib.sha256(json.dumps(normalized,separators=(',',':')).encode()).hexdigest();assert digest==reference['finalSha256'];return {'fullRows':count,'orderedQueryRows':len(query),'normalizedFinalSha256':digest,'worksum':actual['readsum'],'calls':actual['calls'],'tick':actual['tick'],'frames':actual['frames'],'beforeAfterWorldExact':True}
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--prepared',type=pathlib.Path,required=True);parser.add_argument('--cpu',type=int,choices=[0,1,2,11],default=11);parser.add_argument('--retry-mutants',action='store_true');a=parser.parse_args();assert a.prepared.is_absolute() and a.prepared.resolve()==a.prepared;base=a.prepared/'experiments/s-integrate';pins=json.loads((H.parent/'source-bindings.json').read_text())['variant'];assert all(sha(base/n)==v for n,v in pins.items())
 raw=(H/'original-raw-observer.bend').read_bytes();assert hashlib.sha256(raw).hexdigest()=='5c52525ee9fad33d6697d71331e0aaf0b61ee528082c2a680ca390ac3a433572';original=R.run(['git','-C','/workspace/formal-proofs/bendvy','show','56b72f6:experiments/s-integrate/payload.bend'])[0].encode();assert raw==original
 callbacks=defs((H.parent/'control-callbacks.bend').read_text());measurement=defs((base/'measurement-bend.bend').read_text());assert all(v==measurement[k] for k,v in callbacks.items());driver=(H/'query-workload.bend').read_text();assert 'IO.now' not in driver and 'milliseconds' not in driver
 e={'scope':'fresh Native actual64-step Dense/Sparse dispatcher/Host/query/Held/Tx work with original protected raw observer; semantic only','limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':a.cpu,'iterations':64,'cases':{},'mutants':{},'originalProtectedRawBytesExact':True,'originalCallbackDefinitionsExact':True,'rawObserverSha256':sha(H/'original-raw-observer.bend'),'driverSha256':sha(H/'query-workload.bend'),'referenceAdapterSha256':sha(ROOT/'experiments/s-integrate/measurement-reference.mjs'),'fullFieldValidatorSha256':sha(ROOT/'experiments/s-integrate/measurement-bend-run.py'),'environment':{'bend':R.run(['bend','version'])[0].strip(),'Node':R.run(['node','--version'])[0].strip(),'BaseSha256':sha(pathlib.Path.home()/'.bend/bend2/base.bend')},'priorFreshCheckerFailures':['first-checker-timeout.json','second-checker-timeout.json'],'schemaSplit':'Motion and Health exact original setup/loop/callback blocks; every case and observation retained; CPU11 authorized for semantic checks','attempts':[{'stage':'initial driver checker','result':'REJECTED undefined JSON.render_motionmode; corrected to existing JSON.render_motion_mode without changing observations'}]}
 def save(): (H/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='native-columns-query-runtime-') as td:
  root=pathlib.Path(td);core=root/'core';shutil.copytree(base,core)
  for n in ['query-workload.bend','original-raw-observer.bend']:shutil.copy2(H/n,core/n)
  entry=core/'query-workload.bend';pristine={n:(core/n).read_text() for n in ['query.bend','uncached-payload.bend']}
  def build(name):
   check=''.join(R.run(['taskset','-c',str(a.cpu),'bend',entry,'--check-only']));assert 'ALL PROOFS CHECK' in check;c=root/(name+'.c');R.run(['taskset','-c',str(a.cpu),'bend',entry,'-o',c],30);bin=root/name;R.run(['taskset','-c',str(a.cpu),'clang','-O3',c,'-o',bin,'-pthread','-lm'],120);return bin,{'checker':'PASS5','generatedSha256':sha(c),'artifactSha256':sha(bin),'closure':R.closure(entry)}
  def execute(bin,schema,sparse,count):
   out=R.run(['taskset','-c',str(a.cpu),bin,'0' if schema=='Motion' else '1','1' if sparse else '0',str(count),'--threads','1','--gpu','off'])[0];return json.loads(out),out
  try:
   if a.retry_mutants:
    retained=json.loads((H/'first-workload-matrix.json').read_text());assert len(retained['cases'])==12 and all(v['status']=='ACTUAL_FULL_FIELDS_QUERY_ORDER_OWNER_PASS' for v in retained['cases'].values())
    for schema,subject in retained['subjects'].items():
     for old_path,digest in subject['closure'].items():
      name=pathlib.Path(old_path).name;current=H/(schema.lower()+'-control-workload.bend') if name=='control-workload.bend' else H/(schema.lower()+'-query-workload.bend') if name=='query-workload.bend' else core/name;assert sha(current)==digest,(schema,name,'retained subject source changed')
    e=retained;e['retryCPU']=a.cpu;e['priorMutantAttempts']=dict(e['mutants']);shutil.copy2(H/'health-control-workload.bend',core/'control-workload.bend');shutil.copy2(H/'health-query-workload.bend',entry)
   else:
    e['subjects']={}
    for schema in ['Motion','Health']:
     shutil.copy2(H/(schema.lower()+'-control-workload.bend'),core/'control-workload.bend');shutil.copy2(H/(schema.lower()+'-query-workload.bend'),entry)
     library=defs((core/'control-workload.bend').read_text());assert all(v==measurement[k] for k,v in library.items());bin,artifact=build('native-query-'+schema);e['subjects'][schema]=dict(artifact,originalDefinitionBlocksExact=True);save()
     for sparse in [False,True]:
      for count in [64,256,1024]:
       key=f'{schema}-'+('Sparse' if sparse else 'Dense')+str(count);case={};e['cases'][key]=case
       try:
        reference=json.loads(R.run(['taskset','-c',str(a.cpu),'node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'sparse' if sparse else 'dense',str(count)])[0]);assert reference['status']=='PASS';actual,out=execute(bin,schema,sparse,count);verified=validate(actual,schema,sparse,count,reference);(H/(key+'.json.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));case.update(verified,status='ACTUAL_FULL_FIELDS_QUERY_ORDER_OWNER_PASS',outputSha256=hashlib.sha256(out.encode()).hexdigest(),freshTSFinalSha256=reference['finalSha256'])
       except Exception as exc:case.update(status='BOUNDED_FAILURE',error=str(exc))
       save();print(key,case['status'],flush=True)
   # Mutations only copied helper/provider bodies. No callback/workload changes.
   variants=[('reverse-order','query.bend','List.reverse(&2,O,values))','values)'),('wrong-restoration-slot','query.bend','S.native_column_set(Maybe<M>,main,capacity,index,Some{m})','S.native_column_set(Maybe<M>,main,capacity,0,Some{m})'),('raw-tail-corruption','uncached-payload.bend','case (array,old): (T.Vitals{array,reserve,class},old)','case (array,old): (T.Vitals{Array.set(U32,array,3,0),reserve,class},old)')]
   for name,file,old,new in variants:
    if a.retry_mutants and name=='reverse-order':continue
    for n,text in pristine.items():(core/n).write_text(text)
    text=(core/file).read_text()
    if name=='reverse-order':
     begin=text.index('def native_struct_idx_finish');end=text.index('def native_struct_idx_go',begin);part=text[begin:end];assert old in part;text=text[:begin]+part.replace(old,new)+text[end:]
    else:assert old in text;text=text.replace(old,new)
    (core/file).write_text(text);entry_result={'mutatedSourceSha256':sha(core/file)};e['mutants'][name]=entry_result
    try:
     mutant,meta=build(name);entry_result.update(meta);actual,out=execute(mutant,'Health',False,256);expected=B.expected('Health',False,256)
     try:validate(actual,'Health',False,256,{'finalSha256':B.digest(json.dumps(B.normalized(expected,'Health'),separators=(',',':')).encode())});detected=False
     except AssertionError as exc:detected=True;entry_result['oracleError']=str(exc)
     assert detected,'MUTANT_SURVIVED';(H/(name+'.json.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));entry_result.update(status='COMPILING_ACTUAL_FULL_FIELD_MUTANT_DETECTED',outputSha256=hashlib.sha256(out.encode()).hexdigest())
    except Exception as exc:entry_result.update(status='BOUNDED_FAILURE',error=str(exc))
    save();print(name,entry_result['status'],flush=True)
   e['status']='ACTUAL_NATIVE_QUERY_RUNTIME_PASS' if all(x['status']=='ACTUAL_FULL_FIELDS_QUERY_ORDER_OWNER_PASS' for x in e['cases'].values()) and all(x['status']=='COMPILING_ACTUAL_FULL_FIELD_MUTANT_DETECTED' for x in e['mutants'].values()) else 'EXPLICIT_PARTIAL_GATE'
  except Exception as exc:e.update(status='BOUNDED_FAILURE',error=str(exc));save();raise
 save();print(e['status'])
if __name__=='__main__':main()
