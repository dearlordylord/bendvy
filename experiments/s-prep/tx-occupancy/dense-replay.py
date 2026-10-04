#!/usr/bin/env python3
from replay import ROOT,HERE,R,P,metrics,check,load
import pathlib,tempfile,json,hashlib,gzip
D=load('dense_prepare',HERE/'prepare-dense.py');C=load('chunks',HERE/'prepare-chunks.py');V=load('dense_validate',ROOT/'experiments/s-integrate/measurement-bend-run.py')
def main():
 e={'scope':'actual Dense/Sparse Tx diagnostic transport; no timing claim','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'cases':[],'sources':{},'generated':{}}
 with tempfile.TemporaryDirectory(prefix='prep22-dense-') as directory:
  root=pathlib.Path(directory);dest=R.materialize(root);original={p.name:p.read_bytes() for p in dest.glob('*.bend')};P.prepare(dest);D.prepare(dest);C.prepare(dest);entry=dest/'measurement-bend.bend'
  def build(name):
   assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));e['sources'][name]={str(pathlib.Path(p).relative_to(root)):h for p,h in R.closure(entry).items()};c=root/(name+'.c');js=root/(name+'.js');native=root/name
   R.run(['taskset','-c','8','bend',entry,'-o',c],30);R.run(['taskset','-c','8','bend',entry,'-o',js],30);R.run(['taskset','-c','8','clang','-O3',c,'-o',native,'-pthread','-lm'],120);e['generated'][name]={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [c,js,native]}
   import shutil
   retained=pathlib.Path('/tmp/prep22-dense-built');retained.mkdir(exist_ok=True)
   for p in [c,js,native]:shutil.copy2(p,retained/p.name)
   return {'Native':[native,'--threads','1','--gpu','off'],'JS':['node',js]}
  try:
   diagnostic=build('dense-diagnostic')
   for n,b in original.items():(dest/n).write_bytes(b)
   baseline=build('dense-original')
  except Exception as exc:e.update(status='BUILD_FAILURE',error=str(exc));(HERE/'dense-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(str(exc));return
  cases=[('Health',False,256)]+[(s,sp,n) for s in ['Motion','Health'] for sp in [False,True] for n in [64,256,1024] if (s,sp,n)!=('Health',False,256)]
  for schema,sparse,count in cases:
   workload='sparse' if sparse else 'dense';case={'schema':schema,'workload':workload,'count':count,'backends':{}};e['cases'].append(case)
   try:ref=json.loads(R.run(['taskset','-c','8','node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,workload,str(count)])[0])
   except Exception as exc:case['referenceFailure']=str(exc);continue
   for backend,cmd in diagnostic.items():
    try:
     args=[str(['Motion','Health'].index(schema)),str(int(sparse)),str(count)];text=R.run(['taskset','-c','8',*cmd,*args])[0];public='\n'.join(l for l in text.splitlines() if not l.startswith('txdiag:'));plain=R.run(['taskset','-c','8',*baseline[backend],*args])[0]
     a=json.loads(public);b=json.loads(plain);a.pop('milliseconds');b.pop('milliseconds');assert a==b,'complete public fields changed'
     validation=V.validate(public,schema,sparse,count,ref);validation.pop('milliseconds');records=metrics(text)
     # These actual transactions stage no commands/events; generic append/drain oracle still checks every physical sample.
     result=check(records,'dense');result.update(status='PASS',fullPublicMatch=True,freshTSValidation=validation,publicSha256=hashlib.sha256(json.dumps(a,separators=(',',':')).encode()).hexdigest());raw=gzip.compress(('\n'.join(json.dumps(t,separators=(',',':')) for t in records)+'\n').encode(),mtime=0);name=f'{workload}-{schema.lower()}-{count}-{backend.lower()}.jsonl.gz';(HERE/name).write_bytes(raw);result.update(rawRecords=name,rawSha256=hashlib.sha256(raw).hexdigest());case['backends'][backend]=result
    except Exception as exc:case['backends'][backend]={'status':'UNAVAILABLE','error':str(exc)}
   print(schema,workload,count,{b:r['status'] for b,r in case['backends'].items()},flush=True);(HERE/'dense-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 e['status']='PASS' if len(e['cases'])==12 and all(len(c['backends'])==2 and all(r['status']=='PASS' for r in c['backends'].values()) for c in e['cases']) else 'BOUNDED_FAILURE';(HERE/'dense-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
if __name__=='__main__':main()
