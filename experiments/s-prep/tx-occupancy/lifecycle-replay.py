#!/usr/bin/env python3
from replay import ROOT,HERE,R,P,load
import tempfile,pathlib,json,hashlib,gzip
L=load('life_prepare',HERE/'prepare-lifecycle.py');V=load('life_validate',ROOT/'experiments/s-integrate/measurement-lifecycle-run.py')
e={'scope':'actual Lifecycle direct-world owner boundaries; no active Tx fixture substitution','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'cases':[],'sources':{},'generated':{}}
with tempfile.TemporaryDirectory(prefix='prep22-lifecycle-') as directory:
 root=pathlib.Path(directory);dest=R.materialize(root);original={p.name:p.read_bytes() for p in dest.glob('*.bend')};P.prepare(dest);L.prepare(dest);entry=dest/'measurement-lifecycle.bend'
 def build(name):
  assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));e['sources'][name]={str(pathlib.Path(p).relative_to(root)):h for p,h in R.closure(entry).items()};c=root/(name+'.c');js=root/(name+'.js');native=root/name;R.run(['taskset','-c','8','bend',entry,'-o',c],30);R.run(['taskset','-c','8','bend',entry,'-o',js],30);R.run(['taskset','-c','8','clang','-O3',c,'-o',native,'-pthread','-lm'],120);e['generated'][name]={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [c,js,native]};return {'Native':[native,'--threads','1','--gpu','off'],'JS':['node',js]}
 try:
  programs=build('lifecycle-diagnostic')
  for n,b in original.items():(dest/n).write_bytes(b)
  plain=build('lifecycle-original')
 except Exception as exc:e.update(status='BUILD_FAILURE',error=str(exc));(HERE/'lifecycle-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(str(exc));raise SystemExit(1)
 for schema in ['Motion','Health']:
  for count in [64,256,1024]:
   case={'schema':schema,'count':count,'backends':{}};e['cases'].append(case)
   try:ref=json.loads(R.run(['taskset','-c','8','node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'lifecycle',str(count)])[0])
   except Exception as exc:case['referenceFailure']=str(exc);continue
   for backend,cmd in programs.items():
    try:
     args=[str(['Motion','Health'].index(schema)),str(count)];text=R.run(['taskset','-c','8',*cmd,*args])[0];public='\n'.join(l for l in text.splitlines() if not l.startswith(('lifediag:','txdiag:')))+'\n';base=R.run(['taskset','-c','8',*plain[backend],*args])[0];assert public==base,'complete original public output changed';validation=V.validate(public,schema,count,ref);assert not any(l.startswith('txdiag:') for l in text.splitlines()),'unexpected active Tx transport';records=[]
     for line in text.splitlines():
      if not line.startswith('lifediag:'):continue
      _,sc,n,i,phase,kind,payload=line.split(':',6);assert sc==schema and int(n)==count and kind=='owner=World';values=list(map(int,payload.split(':')));assert len(values)==9;records.append({'schema':sc,'count':int(n),'iteration':int(i),'phase':phase,'ownerKind':'World','world':dict(zip(['namespace','next','live','pending','highWater','capacity','mainCapacity','auxCapacity','metadataCapacity'],values))})
     assert len(records)==514,(len(records),records[:2]);assert records[0]['world']['pending']==count;assert max(r['world']['pending'] for r in records if r['phase']=='after-system')==2;assert all(r['world']['namespace']==1 for r in records);name=f'lifecycle-{schema.lower()}-{count}-{backend.lower()}.jsonl.gz';raw=gzip.compress(('\n'.join(json.dumps(r,separators=(',',':')) for r in records)+'\n').encode(),mtime=0);(HERE/name).write_bytes(raw);case['backends'][backend]={'status':'PASS','fullPublicMatch':True,'freshTSValidation':validation,'worldPendingPeak':max(r['world']['pending'] for r in records),'systemPendingPeak':max(r['world']['pending'] for r in records if r['phase']=='after-system'),'actualOwnerKind':'World','activeTx':'not applicable to observed direct-world operations','checkpoints':len(records),'rawRecords':name,'rawSha256':hashlib.sha256(raw).hexdigest(),'publicSha256':hashlib.sha256(public.encode()).hexdigest()}
    except Exception as exc:case['backends'][backend]={'status':'UNAVAILABLE','error':str(exc)}
   print(schema,count,{b:v['status'] for b,v in case['backends'].items()},flush=True);(HERE/'lifecycle-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 e['status']='PASS' if all(len(c['backends'])==2 and all(v['status']=='PASS' for v in c['backends'].values()) for c in e['cases']) else 'BOUNDED_FAILURE';(HERE/'lifecycle-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
