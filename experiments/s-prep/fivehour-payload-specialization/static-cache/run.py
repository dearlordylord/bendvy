#!/usr/bin/env python3
"""Finite direct Cache raw-owner/field and static-codegen gate; no timing claim."""
import hashlib,importlib.util,json,pathlib,re,shutil,tempfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
spec=importlib.util.spec_from_file_location('static_controls',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def functions(text):
 return [text[m.start():text.index('\n}\n',m.start())+3] for m in re.finditer(r'^function \$cached\$045payload\$058(?:position|vitals|motion_ledger|health_ledger)_swap[^\n]*',text,re.M)]
def main():
 expected=(HERE/'payload-expected.txt').read_text();e={'scope':'direct nominal Type Cache field/owner gate only; actual Tx144 integration remains unavailable','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'sources':{p.name:sha(p) for p in HERE.glob('*.bend')},'cases':{},'mutants':{},'codegen':{},'environment':{'Bend':R.run(['bend','version'])[0].strip(),'Base':sha(pathlib.Path.home()/'.bend/bend2/base.bend')}}
 with tempfile.TemporaryDirectory(prefix='fivehour-static-cache-small-') as directory:
  root=pathlib.Path(directory)
  for name in ['types.bend','uncached-payload.bend']:(root/name).write_bytes((HERE/name).read_bytes())
  (root/'fixture.bend').write_bytes((HERE/'payload-fixture.bend').read_bytes())
  def build_run(name,backend):
   entry=root/'fixture.bend';assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));generated=root/(name+('.c' if backend=='Native' else '.js'));R.run(['taskset','-c','8','bend',entry,'-o',generated],30);artifact=generated
   if backend=='Native':artifact=root/name;R.run(['taskset','-c','8','clang','-O3',generated,'-o',artifact,'-pthread','-lm'],120);cmd=[artifact,'--threads','1','--gpu','off']
   else:cmd=['node',artifact]
   out=R.run(['taskset','-c','8',*cmd])[0];result={'closure':{pathlib.Path(p).name:h for p,h in R.closure(entry).items()},'generatedSha256':sha(generated),'artifactSha256':sha(artifact),'outputSha256':hashlib.sha256(out.encode()).hexdigest(),'output':out};return out,result,generated.read_text()
  for backend in ['Native','JS']:
   (root/'uncached-payload.bend').write_bytes((HERE/'uncached-payload.bend').read_bytes())
   for n in ['cache.bend','cached-payload.bend']:(root/n).write_bytes((HERE/('baseline-'+n)).read_bytes())
   out,baseline,baseline_code=build_run('baseline-'+backend,backend);assert out==expected
   for n in ['cache.bend','cached-payload.bend']:(root/n).write_bytes((HERE/n).read_bytes())
   out,subject,code=build_run('static-'+backend,backend);assert out==expected;e['cases'][backend]={'status':'ALL_RAW_CACHE_FIELDS_OWNER_RESTORE_PASS','baseline':baseline,'subject':subject}
   if backend=='JS':
    before=functions(baseline_code);after=functions(code);assert len(before)==len(after)==4;assert all('run_clo' in x for x in before) and all('run_clo' not in x for x in after);e['codegen'][backend]={'status':'FIXED_WRITE_PATCH_WRAPPERS_REMOVED','baselineFunctionExcerpts':before,'staticFunctionExcerpts':after}
   else:
    assert 'FID_CACHE_SWAP' in baseline_code and 'FID_CACHE_SWAP' not in code
    at=code.index('u32 _cached_0 =');e['codegen'][backend]={'status':'REACHABLE_GENERIC_CACHE_SWAP_REMOVED','baselineGenericSwapOccurrences':baseline_code.count('FID_CACHE_SWAP'),'staticGenericSwapOccurrences':code.count('FID_CACHE_SWAP'),'directCachedFieldExcerpt':code[max(0,at-90):at+1500]}
   print(backend,'PASS static codegen',flush=True)
   for name in ['wrong-cache-cell','raw-tail-corruption']:
    for n in ['cache.bend','cached-payload.bend','uncached-payload.bend']:(root/n).write_bytes((HERE/n).read_bytes())
    if name=='wrong-cache-cell':p=root/'cached-payload.bend';old='T.VitalsView{T.Four{value,b,c,d},reserve,class}';new='T.VitalsView{T.Four{value,b,0,d},reserve,class}'
    else:p=root/'uncached-payload.bend';old='case (array,old): (T.Vitals{array,reserve,class},old)';new='case (array,old): (T.Vitals{Array.set(U32,array,3,0),reserve,class},old)'
    s=p.read_text();assert old in s;p.write_text(s.replace(old,new));out,result,_=build_run(name+'-'+backend,backend);assert out!=expected;e['mutants'][name+'-'+backend]=dict(result,status='DETECTED');print(name,backend,'DETECTED',flush=True)
  negative=root/'clone.bend';negative.write_text('import Base\nimport ./types.bend as T\nimport ./cache.bend as C\ndef clone(owner:C.Cache<T.Vitals,T.VitalsView>) -> C.Cache<T.Vitals,T.VitalsView> & C.Cache<T.Vitals,T.VitalsView>:\n  (owner,owner)\n');out=''.join(R.run(['taskset','-c','8','bend',negative,'--check-only'],ok=1));assert 'consumed more than once' in out;e['affineNegative']={'source':negative.read_text(),'output':out,'status':'REJECTED'}
 e['status']='FINITE_STATIC_CACHE_OWNER_CODEGEN_PASS';e['actualTxJournalStatus']='Separate run-tx.py must freshly execute full144field/journal gate; current completed result retained in tx-evidence.json, historical deadlines not erased';(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status'])
if __name__=='__main__':main()
