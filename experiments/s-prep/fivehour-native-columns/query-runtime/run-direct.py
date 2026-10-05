#!/usr/bin/env python3
"""Separate direct complete-query owner controls for the same candidate-body mutants."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,shutil,tempfile
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[3]
sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def four(n):return dict(zip('abcd',range(n,n+4)))
def expected(schema):
 motion=schema=='Motion';rows=[]
 for i,(old,head,aux) in enumerate([(10,17,110),(900,901,190)],1):
  cells=four(old);cells['a']=head;main={'coordinates':cells,'frame':7} if motion else {'levels':cells,'reserve':9,'class':2};a={'rates':four(aux),'moving':True} if motion else {'layers':four(aux),'grade':3};rows.append({'id':i,'main':main,'aux':a,'flag':{'group':8} if i==1 else None,'added':3 if i==1 else 5,'changed':4 if i==1 else 6})
 world={'namespace':7,'next':3,'rows':rows,'pending':[],'ledger':{'totals':four(100),'epoch':4},'mode':schema+'On'};query=[{'handle':{'namespace':7,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in rows];return {'schema':schema,'old0':[10,900],'world':world,'query':query,'afterQuery':world}
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--prepared',type=pathlib.Path,required=True);a=parser.parse_args();assert a.prepared.is_absolute() and a.prepared.resolve()==a.prepared;base=a.prepared/'experiments/s-integrate';pins=json.loads((H.parent/'source-bindings.json').read_text())['variant'];assert all(sha(base/n)==v for n,v in pins.items());assert sha(H/'original-raw-observer.bend')=='5c52525ee9fad33d6697d71331e0aaf0b61ee528082c2a680ca390ac3a433572'
 e={'scope':'direct finite complete nominal Main/Aux/Ledger raw-observer query/owner controls; distinct from passed actual workload matrix','cpu':11,'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cases':{},'mutants':{},'expected':[expected('Motion'),expected('Health')],'driverSha256':sha(H/'direct-query.bend'),'rawObserverSha256':sha(H/'original-raw-observer.bend'),'initialAttempt':'tuple multi-scrutinee pattern rejected; changed to single pair-of-pairs; no field or observation removed'}
 def save(): (H/'direct-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='native-columns-direct-query-') as td:
  root=pathlib.Path(td);core=root/'core';shutil.copytree(base,core)
  for n in ['direct-query.bend','original-raw-observer.bend']:shutil.copy2(H/n,core/n)
  entry=core/'direct-query.bend';pristine={n:(core/n).read_text() for n in ['query.bend','uncached-payload.bend']}
  def run(name):
   checked=''.join(R.run(['taskset','-c','11','bend',entry,'--check-only']));assert 'ALL PROOFS CHECK' in checked;c=root/(name+'.c');R.run(['taskset','-c','11','bend',entry,'-o',c],30);binary=root/name;R.run(['taskset','-c','11','clang','-O3',c,'-o',binary,'-pthread','-lm'],120);out=R.run(['taskset','-c','11',binary,'--threads','1','--gpu','off'])[0];actual=[json.loads(v) for v in out.splitlines()];assert len(actual)==2;(H/(name+'.jsonl.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));return actual,{'checker':'PASS5','generatedSha256':sha(c),'artifactSha256':sha(binary),'outputSha256':hashlib.sha256(out.encode()).hexdigest(),'closure':R.closure(entry)}
  try:
   actual,result=run('direct-subject');assert actual==e['expected'];e['cases']['Native']=dict(result,status='BOTH_SCHEMA_COMPLETE_QUERY_OWNER_PASS');save()
   for name,file,old,new in [('wrong-restoration-slot','query.bend','S.native_column_set(Maybe<M>,main,capacity,index,Some{m})','S.native_column_set(Maybe<M>,main,capacity,0,Some{m})'),('raw-tail-corruption','uncached-payload.bend','case (array,old): (T.Vitals{array,reserve,class},old)','case (array,old): (T.Vitals{Array.set(U32,array,3,0),reserve,class},old)')]:
    for n,text in pristine.items():(core/n).write_text(text)
    p=core/file;text=p.read_text();assert old in text;p.write_text(text.replace(old,new));actual,result=run('direct-'+name);assert actual!=e['expected'];witness={'actual':actual[1],'expected':e['expected'][1]};assert witness['actual']!=witness['expected'];e['mutants'][name]=dict(result,status='COMPILING_COMPLETE_RAW_QUERY_OWNER_MUTANT_DETECTED',witness=witness);save();print(name,e['mutants'][name]['status'],flush=True)
   e['status']='DIRECT_FULL_QUERY_OWNER_MUTANTS_PASS'
  except Exception as exc:e.update(status='BOUNDED_FAILURE',error=str(exc));save();raise
 save();print(e['status'])
if __name__=='__main__':main()
