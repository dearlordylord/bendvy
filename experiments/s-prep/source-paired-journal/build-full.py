#!/usr/bin/env python3
"""Bounded exact-source full64 builds and fresh65 fields; no clocks accepted."""
import json,pathlib,argparse,hashlib,os,sys,importlib.util
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates');import supervisor
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();os.sched_setaffinity(0,{8});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.load(open(a.overlay/'overlay.json'));r={'status':'INCOMPLETE','overlay':str(a.overlay),'runtimeSources':m['sources'],'schema':a.schema,'commands':[],'scope':'Finite fresh65 complete fields on actual full64 source; no clocks/performance/proof acceptance'}
def save():
 a.output.mkdir(exist_ok=True);(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap):
 argv=list(map(str,argv));code,out=supervisor.execute(argv,cap);n=len(r['commands']);a.output.mkdir(exist_ok=True);(a.output/f'command-{n}.txt').write_text(out);r['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});save();assert code==0,out[-2000:];return out
try:
 assert len(m['sources'])==29
 for f,h in m['sources'].items():assert sha(a.overlay/f)==h
 assert m['cacheSpecialization']==json.load(open(a.overlay/'cache-specialization.json'));assert m['cacheSpecialization']['runtimeClosure']==m['sources']
 run(['python3','/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-measurement/prepare-bend.py','--core',a.overlay/'experiments/s-integrate','--output',a.output,'--schema',a.schema,'--batch','64'],5)
 entry=a.output/'batch.bend';run(['bend',entry,'--check-only'],15)
 for suffix in ['js','c']:run(['bend',entry,'-o',a.output/('batch.'+suffix)],30)
 run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'batch.c','-pthread','-lm','-o',a.output/'batch.native'],120)
 reference=pathlib.Path('/tmp/bendvy-flat-journal-'+a.schema.lower()+'-fields-v4/reference.mjs');world=json.loads(run(['node',reference],5));assert (world['schema'],world['count'],world['iterations'],world['batch'])==(a.schema,256,64,64)
 sp=importlib.util.spec_from_file_location('v','/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(sp);sp.loader.exec_module(v)
 r['lanes']={}
 for backend,argv in [('JS',['node',a.output/'batch.js']),('Native',[a.output/'batch.native','--threads','1','--gpu','off'])]:
  actual=run(argv,5);(a.output/(backend+'.raw.txt')).write_text(actual);records=[x for x in actual.splitlines() if x.startswith('{')];assert len(records)==65
  for row,expected in zip(records,[world['warmup'],*world['samples']]):v.validate(row,a.schema,False,256,expected);assert v.normalized(json.loads(row),a.schema)==expected['final']
  r['lanes'][backend]={'fullWorlds':65,'allFullFieldsEqual':True}
 r['artifacts']={n:sha(a.output/n) for n in ['batch.bend','batch.c','batch.js','batch.native']};r['referenceSHA256']=sha(reference);r['status']='PAIRED_ACTUAL_SOURCE_BOTH_BACKEND_FRESH65_PASS'
except Exception as e:r['status']='FAIL';r['error']=repr(e)
save();print(json.dumps(r));sys.exit(r['status']=='FAIL')
