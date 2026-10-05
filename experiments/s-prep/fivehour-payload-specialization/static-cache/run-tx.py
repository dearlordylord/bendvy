#!/usr/bin/env python3
"""Fresh actual final-core Tx journal gate with byte-identical control callbacks."""
import hashlib,importlib.util,json,pathlib,re,shutil,tempfile,gzip
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
spec=importlib.util.spec_from_file_location('tx_static_controls',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def defs(text):return {m[1]:m[0].rstrip() for m in re.finditer(r'^def ([A-Za-z0-9_]+)[\s\S]*?(?=^(?:def|type|import) |\Z)',text,re.M)}
def main():
 base=pathlib.Path('/tmp/bendvy-fivehour-final-js/experiments/s-integrate');expected=(HERE/'expected.jsonl').read_text();assert hashlib.sha256(expected.encode()).hexdigest()=='86470371004f767f76a13c0103f2b83d8a70b64ecc1b2eb80535c8782e21c3c4'
 extracted=defs((HERE/'control-callbacks.bend').read_text());full=defs((base/'measurement-bend.bend').read_text());assert len(extracted)==8 and all(v==full[k] for k,v in extracted.items())
 e={'scope':'actual final-core Tx all144 records; control-only exact8callback extraction; no timing','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'cases':{},'mutants':{},'sourceHashes':{p.name:sha(p) for p in HERE.glob('*.bend')},'callbackDefinitionsByteEqual':True,'expectedSha256':sha(HERE/'expected.jsonl'),'environment':{'bend':R.run(['bend','version'])[0].strip(),'Base':sha(pathlib.Path.home()/'.bend/bend2/base.bend')}}
 with tempfile.TemporaryDirectory(prefix='fivehour-static-cache-tx-') as directory:
  root=pathlib.Path(directory);core=root/'core';shutil.copytree(base,core);e['inputClosureSources']={p.name:sha(p) for p in core.glob('*.bend')};shutil.copy2(HERE/'control-callbacks.bend',core/'control-callbacks.bend');raw_fixture=(HERE/'fixture.bend').read_text().replace('import ./measurement-bend.bend as M','import ./control-callbacks.bend as M');cached_fixture=raw_fixture
  for payload in ['position','vitals','motion_ledger','health_ledger']:cached_fixture=cached_fixture.replace('P.'+payload+'_uncached','P.'+payload+'_get')
  originals={n:(core/n).read_bytes() for n in ['cache.bend','cached-payload.bend','uncached-payload.bend']}
  def save(): (HERE/'tx-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
  def build_run(name,backend):
   entry=core/'fixture.bend';assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));generated=root/(name+('.c' if backend=='Native' else '.js'));R.run(['taskset','-c','8','bend',entry,'-o',generated],30);artifact=generated
   if backend=='Native':artifact=root/name;R.run(['taskset','-c','8','clang','-O3',generated,'-o',artifact,'-pthread','-lm'],120);cmd=[artifact,'--threads','1','--gpu','off']
   else:cmd=['node',artifact]
   out=R.run(['taskset','-c','8',*cmd])[0];assert len(out.splitlines())==144;result={'closure':{str(pathlib.Path(p).relative_to(core)):h for p,h in R.closure(entry).items()},'generatedSha256':sha(generated),'artifactSha256':sha(artifact),'outputSha256':hashlib.sha256(out.encode()).hexdigest(),'records':144};return out,result
  try:
   for backend in ['Native','JS']:
    for n,b in originals.items():(core/n).write_bytes(b)
    (core/'fixture.bend').write_text(raw_fixture);out,baseline=build_run('baseline-'+backend,backend);assert out==expected
    for n in ['cache.bend','cached-payload.bend']:shutil.copy2(HERE/n,core/n)
    for observer,text in [('raw',raw_fixture),('cached',cached_fixture)]:
     (core/'fixture.bend').write_text(text);out,result=build_run('static-'+observer+'-'+backend,backend);assert out==expected;e['cases'][observer+'-'+backend]={'status':'ACTUAL_FULL_FIELDS_JOURNAL_PASS','baseline':baseline,'subject':result};(HERE/('tx-'+observer+'-'+backend+'.jsonl.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));save();print(observer,backend,'PASS144',flush=True)
    pristine={n:(core/n).read_bytes() for n in originals}
    for name in ['wrong-cache-cell','raw-tail-corruption']:
     for n,b in pristine.items():(core/n).write_bytes(b)
     if name=='wrong-cache-cell':
      (core/'fixture.bend').write_text(cached_fixture);p=core/'cached-payload.bend';old='T.VitalsView{T.Four{value,b,c,d},reserve,class}';new='T.VitalsView{T.Four{value,b,0,d},reserve,class}'
     else:
      (core/'fixture.bend').write_text(raw_fixture);p=core/'uncached-payload.bend';old='case (array,old): (T.Vitals{array,reserve,class},old)';new='case (array,old): (T.Vitals{Array.set(U32,array,3,0),reserve,class},old)'
     text=p.read_text();assert old in text;p.write_text(text.replace(old,new));out,result=build_run(name+'-'+backend,backend);assert out!=expected;e['mutants'][name+'-'+backend]=dict(result,status='DETECTED');(HERE/('tx-'+name+'-'+backend+'.jsonl.gz')).write_bytes(gzip.compress(out.encode(),mtime=0));save();print(name,backend,'DETECTED144',flush=True)
   e['status']='ACTUAL_STATIC_CACHE_TX144_PASS'
  except Exception as exc:e.update(status='BOUNDED_FAILURE',error=str(exc));save();raise
  save();print(e['status'])
if __name__=='__main__':main()
