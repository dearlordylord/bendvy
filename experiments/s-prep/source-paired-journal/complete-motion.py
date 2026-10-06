#!/usr/bin/env python3
"""Complete JS and fresh ordinary-binary fields on existing immutable Motion build."""
import pathlib,json,hashlib,sys,os,importlib.util
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates');import supervisor
root=pathlib.Path('/tmp/bendvy-paired-journal-motion-v1');r=json.load(open(root/'build.json'));assert not (root/'build-full.json').exists();os.sched_setaffinity(0,{8});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();assert sha(root/'batch.c')==r['sourceSHA256'];assert sha(root/'batch.native')==r['binarySHA256'];r['upstreamBuildSHA256']=sha(root/'build.json');r['scope']='Completed actual paired Motion Native/JS fresh65 complete fields; no clocks/proof acceptance'
def run(argv,cap):
 argv=list(map(str,argv));code,out=supervisor.execute(argv,cap);r['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});assert code==0,out[-2000:];return out
run(['bend',root/'batch.bend','-o',root/'batch.js'],30);observed=json.loads(run(['node','/tmp/bendvy-flat-journal-motion-fields-v4/reference.mjs'],5));sp=importlib.util.spec_from_file_location('v','/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(sp);sp.loader.exec_module(v);r['lanes']={}
for backend,argv in [('JS',['node',root/'batch.js']),('Native',[root/'batch.native','--threads','1','--gpu','off'])]:
 actual=run(argv,5);(root/(backend+'.raw.txt')).write_text(actual);records=[x for x in actual.splitlines() if x.startswith('{')];assert len(records)==65
 for row,expected in zip(records,[observed['warmup'],*observed['samples']]):v.validate(row,'Motion',False,256,expected);assert v.normalized(json.loads(row),'Motion')==expected['final']
 r['lanes'][backend]={'fullWorlds':65,'allFullFieldsEqual':True}
r['status']='PAIRED_ACTUAL_SOURCE_BOTH_BACKEND_FRESH65_PASS';r['artifacts']={n:sha(root/n) for n in ['batch.bend','batch.c','batch.js','batch.native']};assert r['artifacts']['batch.c']==r['sourceSHA256'];(root/'build-full.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
