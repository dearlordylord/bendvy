#!/usr/bin/env python3
"""Finite correctness controls only; no timing/loop/performance claim."""
import hashlib,importlib.util,json,pathlib,tempfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('payload_runner',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 e={'scope':'actual nominal Type payloads; finite correctness only','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'environment':{},'sourceHashes':{p.name:sha(p) for p in HERE.glob('*.bend') if p.name!='active-payload.bend'},'cases':{},'mutants':{},'negative':{}}
 e['environment']={'bend':R.run(['bend','version'])[0].strip(),'node':R.run(['node','--version'])[0].strip(),'clang':R.run(['clang','--version'])[0].splitlines()[0],'Base':sha(pathlib.Path.home()/'.bend/bend2/base.bend')}
 with tempfile.TemporaryDirectory(prefix='fivehour-payload-') as directory:
  root=pathlib.Path(directory)
  for name in ['types.bend','fixture.bend']:(root/name).write_bytes((HERE/name).read_bytes())
  def build_run(name,source,backend):
   (root/'active-payload.bend').write_text(source);entry=root/'fixture.bend';checked=''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));assert 'ALL PROOFS CHECK' in checked
   generated=root/(name+('.c' if backend=='Native' else '.js'));R.run(['taskset','-c','8','bend',entry,'-o',generated],30);artifact=generated
   if backend=='Native':
    artifact=root/name;R.run(['taskset','-c','8','clang','-O3',generated,'-o',artifact,'-pthread','-lm'],120);cmd=[artifact,'--threads','1','--gpu','off']
   else:cmd=['node',artifact]
   output=R.run(['taskset','-c','8',*cmd])[0];return {'status':'PASS','sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'generatedSha256':sha(generated),'artifactSha256':sha(artifact),'output':output,'outputSha256':hashlib.sha256(output.encode()).hexdigest()}
  original=(HERE/'original-payload.bend').read_text();native=(HERE/'uncached-payload.bend').read_text();expected=None
  for backend in ['Native','JS']:
   baseline=build_run('original-'+backend,original,backend)
   if expected is None:expected=baseline['output'];(HERE/'expected.txt').write_text(expected)
   assert baseline['output']==expected
   subject=build_run('specialized-'+backend,native if backend=='Native' else original,backend);assert subject['output']==expected;e['cases'][backend]={'baseline':baseline,'subject':subject,'fullOutputEqual':True,'binding':'native direct Array intrinsics' if backend=='Native' else 'original flat Array intrinsic payload'};print(backend,'PASS',flush=True)
   source=native if backend=='Native' else original
   wrong=source.replace('Array.swap(U32,array,0,value)','Array.swap(U32,array,1,value)')
   lost=source.replace('case (array,old): (T.Position{array,frame},old)','case (array,old): (T.Position{Array.set(U32,array,1,0),frame},old)');assert lost!=source and wrong!=source
   for label,text in [('wrong-cell',wrong),('owner-cell-loss',lost)]:
    result=build_run(label+'-'+backend,text,backend);assert result['output']!=expected;result['status']='DETECTED';e['mutants'][label+'-'+backend]=result;print(label,backend,'DETECTED',flush=True)
  (root/'clone-negative.bend').write_text('import Base\nimport ./types.bend as T\ndef clone(owner: T.Position) -> T.Position & T.Position:\n  (owner,owner)\n');out=''.join(R.run(['taskset','-c','8','bend',root/'clone-negative.bend','--check-only'],ok=1));assert 'SOME PROOFS FAIL' in out and ('more than once' in out or 'consumed' in out);e['negative']={'affine-clone':{'status':'REJECTED','source':(root/'clone-negative.bend').read_text(),'output':out}}
 expected_manual=(HERE/'expected-oracle.txt').read_text();assert expected==expected_manual,'independent explicit full-output oracle differs'
 segment_spec=importlib.util.spec_from_file_location('payload_signatures',ROOT/'experiments/s-prep/segment-run.py');segment=importlib.util.module_from_spec(segment_spec);segment_spec.loader.exec_module(segment)
 before=segment.signatures(original);after=segment.signatures(native);assert before['imports']==after['imports'] and before['types']==after['types'] and all(h in after['definitions'] for h in before['definitions'])
 e['originalPublicHeadersPreserved']=True;e['explicitOracleSha256']=sha(HERE/'expected-oracle.txt');e['inputPayloadPath']='experiments/s-integrate/payload.bend';e['inputPayloadSha256']=sha(ROOT/e['inputPayloadPath']);e['worktreeInputCommit']=R.run(['git','-C',ROOT,'rev-parse','HEAD'])[0].strip()
 e['readOnlyReferenceCommits']={name:R.run(['git','-C','/workspace/formal-proofs/bendvy/.references/'+name,'rev-parse','HEAD'])[0].strip() for name in ['bevy-ts','bevy','bend2']}
 e['claimLimits']='Finite original nominal Type payload correctness and owner return gate only; no opaque-provider/ECS universal refinement, performance, or loop acceptance. JS binding remains original Array intrinsics.'
 e['status']='FINITE_CONTROLS_PASS';(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status'])
if __name__=='__main__':main()
