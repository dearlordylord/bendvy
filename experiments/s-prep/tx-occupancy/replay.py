#!/usr/bin/env python3
"""One-shot actual owner-preserving transaction diagnostic replay."""
import pathlib,importlib.util,tempfile,json,hashlib,gzip,sys
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);v=importlib.util.module_from_spec(s);s.loader.exec_module(v);return v
R=load('runner',ROOT/'experiments/s-perf/occupancy-run.py');P=load('prepare',HERE/'prepare.py');VR=load('readers',ROOT/'experiments/s-integrate/measurement-readers-run.py');VF=load('failure',ROOT/'experiments/s-integrate/measurement-failure-oracle.py')
def metrics(text):
 result=[]
 for line in text.splitlines():
  if not line.startswith('txdiag:'):continue
  points=[]
  for item in line[7:].split(';'):
   if not item:continue
   parts=item.split(':');points.append({'phase':parts[0],'counts':list(map(int,parts[1:]))})
  result.append(points)
 return result

def check(records,kind):
 assert records,'no actual transaction transport'
 peaks=[0]*4;phases=set();locations={}
 for tx_index,tx in enumerate(records):
  previous=[0]*4;drains={}
  for point_index,p in enumerate(tx):
   phase=p['phase'];v=p['counts'];phases.add(phase)
   if len(v)==4:
    if phase=='tx_begin':assert v==[0]*4
    elif phase=='tx_stage_command':assert v==[previous[0]+1,*previous[1:]]
    elif phase=='tx_stage_ping':assert v==[previous[0],previous[1]+1,*previous[2:]]
    elif phase=='record_main':assert v in [previous,[previous[0],previous[1],previous[2]+1,previous[3]+1]]
    elif phase=='record_ledger':assert v in [previous,[previous[0],previous[1],previous[2]+1,previous[3]]]
    else:assert v==previous,(phase,v,previous)
    previous=v
    for field,(a,b) in enumerate(zip(peaks,v)):
     if field not in locations or b>a:locations[field]={'transaction':tx_index,'point':point_index,'phase':phase,'value':b}
    peaks=[max(a,b) for a,b in zip(peaks,v)]
   elif phase in ['unwind','mark-drain']:
    assert len(v)==1 and v[0]>=0
    start=previous[2 if phase=='unwind' else 3]
    expected=max(0,drains.get(phase,start)-1)
    assert v[0]==expected,(phase,v,expected)
    drains[phase]=v[0]
  assert tx[-1]['phase'] in ['commit','rollback']
 assert 'tx_stage_ping' in phases and 'mark-drain' in phases
 if kind=='failure':assert 'tx_stage_command' in phases
 if kind=='failure':assert 'unwind' in phases and 'rollback' in phases
 return {'transactions':len(records),'physicalPeaks':dict(zip(['commands','events','inverse','marks'],peaks)),'peakLocations':dict(zip(['commands','events','inverse','marks'],[locations[i] for i in range(4)])),'phases':sorted(phases)}

def main():
 e={'environment':{'compiler':R.run(['bend','version'])[0].strip(),'node':R.run(['node','--version'])[0].strip(),'clang':R.run(['clang','--version'])[0].splitlines()[0],'Base':hashlib.sha256((pathlib.Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest()},'sourceCommit':R.run(['git','-C',ROOT,'rev-parse','HEAD'])[0].strip(),'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'cases':[],'sources':{},'generated':{},'attempts':[]}
 with tempfile.TemporaryDirectory(prefix='prep22-tx-') as directory:
  root=pathlib.Path(directory);dest=R.materialize(root)
  original={p.name:p.read_bytes() for p in dest.glob('*.bend')};P.prepare(dest)
  diagnostic={p.name:p.read_bytes() for p in dest.glob('*.bend')}
  frozen=HERE/'overlay';frozen.mkdir(exist_ok=True)
  for n,b in diagnostic.items():
   if b!=original[n]:(frozen/n).write_bytes(b)
  e['modifiedSources']={n:hashlib.sha256(b).hexdigest() for n,b in diagnostic.items() if b!=original[n]}
  def build(kind,name):
   entry=dest/('measurement-readers.bend' if kind=='readers' else 'measurement-failure-driver.bend')
   assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']))
   e['sources'][name]={str(pathlib.Path(p).relative_to(root)):h for p,h in R.closure(entry).items()}
   c=root/(name+'.c');js=root/(name+'.js');native=root/name
   R.run(['taskset','-c','8','bend',entry,'-o',c],30);R.run(['taskset','-c','8','bend',entry,'-o',js],30);R.run(['taskset','-c','8','clang','-O3',c,'-o',native,'-pthread','-lm'],120)
   e['generated'][name]={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [c,js,native]}
   import shutil
   retained=pathlib.Path('/tmp/prep22-tx-built');retained.mkdir(exist_ok=True)
   for p in [c,js,native]:shutil.copy2(p,retained/p.name)
   return {'Native':[native,'--threads','1','--gpu','off'],'JS':['node',js]}
  for kind in ['readers','failure']:
   for n,b in diagnostic.items():(dest/n).write_bytes(b)
   try:program=build(kind,kind+'-diagnostic')
   except Exception as exc:
    e['attempts'].append({'kind':kind,'buildFailure':str(exc)});print(kind,'BUILD_FAILURE',str(exc),flush=True);(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');continue
   for n,b in original.items():(dest/n).write_bytes(b)
   plain=build(kind,kind+'-original')
   for schema in ['Motion','Health']:
    for count in [64,256,1024]:
     case={'workload':kind,'schema':schema,'count':count,'backends':{}};e['cases'].append(case)
     try:ref=json.loads(R.run(['taskset','-c','8','node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'readers' if kind=='readers' else 'failed-transaction',str(count)])[0])
     except Exception as exc:
      case['referenceFailure']=str(exc);print(kind,schema,count,'REFERENCE_FAILURE',str(exc),flush=True);(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');continue
     for backend,cmd in program.items():
      try:
       runtime_args=[str(['Motion','Health'].index(schema)),str(count)]+(['64'] if kind=='failure' else []);actual=R.run(['taskset','-c','8',*cmd,*runtime_args])[0];public='\n'.join(l for l in actual.splitlines() if not l.startswith('txdiag:'))+'\n';base=R.run(['taskset','-c','8',*plain[backend],*runtime_args])[0]
       # FailedTxn's existing clock value is transport metadata, never a public semantic field.
       semantic=lambda s:'\n'.join(l for l in s.splitlines() if not l.startswith('FAILURE-TIMING:'))
       assert semantic(public)==semantic(base),'public trace changed'
       validation=VR.validate(public,schema,count,ref) if kind=='readers' else VF.validate(public,ref)
       if kind=='failure':
        name=f'failure-validation-{schema.lower()}-{count}-{backend.lower()}.json.gz';packed=gzip.compress(json.dumps(validation,separators=(',',':')).encode(),mtime=0);(HERE/name).write_bytes(packed)
        validation={k:x for k,x in validation.items() if k not in ['audit','reservations','actual_reads','actual_effects']};validation.update(completeValidationFile=name,completeValidationSha256=hashlib.sha256(packed).hexdigest())
       records=metrics(actual);result=check(records,kind);result.update(status='PASS',publicTraceMatch=True,freshTSValidation=validation,publicSha256=hashlib.sha256(semantic(public).encode()).hexdigest())
       filename=f'{kind}-{schema.lower()}-{count}-{backend.lower()}.jsonl.gz';raw=gzip.compress(('\n'.join(json.dumps(x,separators=(',',':')) for x in records)+'\n').encode(),mtime=0);(HERE/filename).write_bytes(raw);result.update(rawRecords=filename,rawSha256=hashlib.sha256(raw).hexdigest());case['backends'][backend]=result
      except Exception as exc:case['backends'][backend]={'status':'FAILED','error':str(exc)}
     print(kind,schema,count,{b:r['status'] for b,r in case['backends'].items()},flush=True);(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 for case in e['cases']:
  values=list(case['backends'].values())
  if len(values)==2 and all(v['status']=='PASS' for v in values):
   assert gzip.decompress((HERE/values[0]['rawRecords']).read_bytes())==gzip.decompress((HERE/values[1]['rawRecords']).read_bytes()), 'Native/JS physical records differ'
   case['physicalBackendEquality']=True
 e['status']='PASS' if len(e['cases'])==12 and all(len(c['backends'])==2 and all(v['status']=='PASS' for v in c['backends'].values()) for c in e['cases']) else 'BOUNDED_FAILURE';(HERE/'evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status']);return e['status']!='PASS'
if __name__=='__main__':sys.exit(main())
