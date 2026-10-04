#!/usr/bin/env python3
"""Actual Readers diagnostic replay, unchanged public trace and fresh TS validation."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,sys,tempfile,time,subprocess,io,tarfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value
R=module('occupancy_runner',HERE/'occupancy-run.py');P=module('occupancy_prepare',HERE/'occupancy-readers-prepare.py')
V=module('reader_validation',ROOT/'experiments/s-integrate/measurement-readers-run.py')

def parse_records(text):
 records=[]
 def boolean(s):assert s in ['True','False'];return s=='True'
 def reader(raw):
  x=raw.split(':');assert len(x)==13
  return dict(zip(['key','registeredAt','lastRun','streamLastRun','messageHolder','removedHolder','despawnHolder','unreadMessages','unreadRemoved','unreadDespawned','messageLag','removedLag','despawnedLag'],[int(v) if i in [0,1,2,3,7,8,9] else boolean(v) for i,v in enumerate(x)]))
 for line in text.splitlines():
  if not line.startswith('occupancy:'):continue
  import re
  _,schema,count,iteration,phase,tick,frame,payload=line.split(':',7)
  data=dict(x.split('=',1) for x in re.split(r'\|(?=[a-zA-Z][a-zA-Z-]*=)',payload))
  rec={'schema':schema,'count':int(count),'iteration':int(iteration),'phase':phase,'tick':int(tick),'frame':int(frame)}
  w=list(map(int,data['world'].split(':')));assert len(w)==9
  rec['world']=dict(zip(['namespace','next','live','pending','highWater','capacity','mainCapacity','auxCapacity','metadataCapacity'],w));assert w[5]==w[6]==w[7]==w[8]
  rec['logs']={}
  for kind in ['ping','removed','despawned']:
   x=data[kind].split(':');assert len(x)==9
   value=dict(zip(['capacity','cachedSize','droppedThrough','frontBatches','rearBatches','physicalValues','declaredValues','consistentSize','consistentBatches'],[int(v) if i<7 else boolean(v) for i,v in enumerate(x)]))
   assert value['consistentSize'] and value['consistentBatches'];assert value['physicalValues']==value['declaredValues']==value['cachedSize']
   rec['logs'][kind]=value
  if data['readers'].startswith('unavailable'):
   rec['readers']=None;rec['holders']=None;rec['availability']={'storedReaders':'unavailable in state-only hook','holders':'unavailable in state-only hook'}
  else:
   rec['readers']=[reader(s) for s in data['readers'].split(';') if s!='end'];keys=[r['key'] for r in rec['readers']];assert len(keys)==len(set(keys))
   holds=[]
   for raw in data['holders'].split('|'):
    n,values=raw.split(':',1);values=[int(v) for v in values.strip('[]').split(',') if v!='end'];assert int(n)==len(values);holds.append(values)
   rec['holders']=dict(zip(['messages','removed','despawned'],holds))
   for i,(holder,pos) in enumerate([('messageHolder','streamLastRun'),('removedHolder','lastRun'),('despawnHolder','lastRun')]):assert holds[i]==[r[pos] for r in rec['readers'] if r[holder]]
   bases=[]
   for raw in data['bases'].split(';'):
    if raw=='end':continue
    name,key,value=raw.split(':',2);value=None if value=='null' else reader(value);assert value is None or value['key']==int(key);bases.append({'name':name,'key':int(key),'state':value})
   rec['registeredReaderBases']=bases
  if 'running' in data:
   raw=data['running'];rec['running']=None
   if raw!='null':
    x=raw.split(':');assert len(x)==11
    rec['running']=dict(zip(['key','registeredAt','since','streamSince','thisRun','unreadMessages','unreadRemoved','unreadDespawned','messageLag','removedLag','despawnedLag'],[int(v) if i<8 else boolean(v) for i,v in enumerate(x)]))
  records.append(rec)
 return records

def checkpoint_maxima(records):
 maxima={}
 def maximum(name,value,checkpoint):
  if name not in maxima or value>maxima[name]['value']:maxima[name]={'value':value,'checkpoint':checkpoint}
 for index,r in enumerate(records):
  point={'record':index,'iteration':r['iteration'],'phase':r['phase'],'tick':r['tick'],'frame':r['frame']}
  maximum('live',r['world']['live'],point);maximum('pending',r['world']['pending'],point)
  for kind,log in r['logs'].items():maximum(kind+'Values',log['physicalValues'],point);maximum(kind+'Batches',log['frontBatches']+log['rearBatches'],point)
  if r['holders'] is not None:
   for kind,values in r['holders'].items():maximum(kind+'Holders',len(values),point)
  for reader in r['readers'] or []:
   for key in ['unreadMessages','unreadRemoved','unreadDespawned']:
    maximum('stored'+key[0].upper()+key[1:],reader[key],point);maximum(key,reader[key],point)
  if r.get('running') is not None:
   for key in ['unreadMessages','unreadRemoved','unreadDespawned']:
    maximum('running'+key[0].upper()+key[1:],r['running'][key],point);maximum(key,r['running'][key],point)
 return maxima

def validate_records(records,public,schema,count):
 assert len(records)==1196,len(records)
 assert all(r['schema']==schema and r['count']==count and r['world']['namespace']==1 for r in records)
 phases={r['phase'] for r in records}
 for phase in ['before-tick-before-frame','after-tick-before-next-frame','before-barrier','after-barrier','before-system=Update','after-system=Update','before-system=Fast','after-system=Fast','before-system=Slow','after-system=Slow']:assert phase in phases
 assert records[0]['world']['live']==count
 assert all(b['state'] is None for b in records[0]['registeredReaderBases'])
 reads=[json.loads(line) for line in public.splitlines() if json.loads(line).get('kind')=='Read']
 running=[r for r in records if r['phase'].startswith('before-system=') and r.get('running') is not None];assert len(reads)==len(running)==84
 for metric,read in zip(running,reads):
  actual=metric['running'];assert metric['phase']=='before-system='+read['system']
  assert {k:actual[k] for k in ['since','streamSince','thisRun']}==read['boundary']
  assert actual['unreadMessages']==len(read['messages']) and actual['unreadRemoved']==len(read['removed']) and actual['unreadDespawned']==len(read['despawned'])
  for name in ['messageLag','removedLag','despawnedLag']:assert actual[name]==read[name]
 maxima=checkpoint_maxima(records)
 final=records[-1];assert all(x['unreadMessages']==x['unreadRemoved']==x['unreadDespawned']==0 for x in final['readers'])
 assert final['logs']['removed']['physicalValues']>0 and final['logs']['despawned']['physicalValues']>0
 return {'status':'PASS','physicalCheckpoints':len(records),'runningDeliveryCrossChecks':len(running),'observedCheckpointMaxima':maxima,'final':final,'unavailable':{'activeTransactionStaging':'No active Tx owner reaches these runtime/state hooks; no workload staging/inverse/mark peak inferred from finite fixtures.','stateHookStoredReaders':'Available at tick hooks, unavailable inside invocation/barrier owner-only hooks.','setupAppendPeaks':'Bulk setup append peaks before the first diagnostic checkpoint are not inspected.','RSS':'Separate clean-launcher replay required.'}}

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--candidate',type=pathlib.Path,default=HERE/'candidate');parser.add_argument('--counts',nargs='*',type=int,default=[64,256,1024]);parser.add_argument('--schemas',nargs='*',default=['Motion','Health']);args=parser.parse_args()
 environment={'compiler':''.join(R.run(['bend','version'])).strip(),'node':R.run(['node','--version'])[0].strip(),'clang':R.run(['clang','--version'])[0].splitlines()[0],'baseSha256':hashlib.sha256((pathlib.Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest()}
 assert environment['baseSha256']=='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
 pins=json.loads((ROOT/'.references/sources.json').read_text())['sources'];environment['referencePins']={}
 for name in ['bevy-ts','bevy','bend2']:
  actual=R.run(['git','-C',pathlib.Path('/workspace/formal-proofs/bendvy/.references')/name,'rev-parse','HEAD'])[0].strip();assert actual==pins[name]['commit'];environment['referencePins'][name]=actual
 evidence={'environment':environment,'scope':'Actual unchanged Readers64 operation sequence, separately instrumented diagnostic replay; no timing acceptance','cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'candidate':str(args.candidate.resolve())}
 with tempfile.TemporaryDirectory(prefix='occupancy-readers-') as directory:
  root=pathlib.Path(directory);dest=R.materialize(root)
  for p in args.candidate.glob('*.bend'):
   if not p.name.startswith('owned-storage-'):(dest/p.name).write_bytes(p.read_bytes())
  entry=dest/'measurement-readers.bend';plain=entry.read_text();P.prepare(entry)
  evidence['sources']={str(pathlib.Path(p).relative_to(root)):value for p,value in R.closure(entry).items()}
  evidence['generated']={}
  def build(name):
   assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']))
   c=root/(name+'.c');js=root/(name+'.js');binary=root/name
   R.run(['taskset','-c','8','bend',entry,'-o',c],30);R.run(['taskset','-c','8','bend',entry,'-o',js],30);R.run(['taskset','-c','8','clang','-O3',c,'-o',binary,'-pthread','-lm'],120)
   evidence['generated'][name]={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [c,js,binary]}
   return {'Native':[binary,'--threads','1','--gpu','off'],'JS':['node',js]}
  try:
   programs=build('diagnostic');entry.write_text(plain);original=build('uninstrumented')
  except Exception as exc:
   evidence['status']='BOUNDED_BUILD_FAILURE';evidence['buildFailure']=str(exc);evidence['cases']=[{'schema':schema,'count':count,'backends':{backend:{'status':'UNAVAILABLE','reason':'Build prerequisite failed'} for backend in ['Native','JS']}} for schema in args.schemas for count in args.counts];(HERE/'occupancy-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');return 1
  for schema in args.schemas:
   number=['Motion','Health'].index(schema)
   for count in args.counts:
    case={'schema':schema,'count':count,'backends':{}};evidence['cases'].append(case)
    try:
     reference=json.loads(R.run(['taskset','-c','8','node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'readers',str(count)])[0]);case['freshTS']=reference['status']
    except Exception as exc:case['referenceFailure']=str(exc);continue
    for backend,command in programs.items():
     try:
      text=R.run(['taskset','-c','8',*command,str(number),str(count)])[0];public='\n'.join(x for x in text.splitlines() if not x.startswith('occupancy:'))+'\n'
      baseline=R.run(['taskset','-c','8',*original[backend],str(number),str(count)])[0];assert public==baseline,'instrumentation changed complete original public trace'
      semantic=V.validate(public,schema,count,reference);records=parse_records(text);result=validate_records(records,public,schema,count)
      result['publicTraceMatch']=True;result['freshTSValidation']=semantic;result['publicSha256']=hashlib.sha256(public.encode()).hexdigest()
      path=HERE/f'occupancy-readers-{schema.lower()}-{count}-{backend.lower()}.jsonl.gz';data='\n'.join(json.dumps(r,separators=(',',':')) for r in records)+'\n';path.write_bytes(gzip.compress(data.encode(),mtime=0));result['rawRecords']=path.name;result['rawRecordsSha256']=hashlib.sha256(path.read_bytes()).hexdigest();case['backends'][backend]=result
     except Exception as exc:case['backends'][backend]={'status':'FAILED','error':str(exc)}
     (HERE/'occupancy-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print(schema,count,{k:v['status'] for k,v in case['backends'].items()},flush=True)
 evidence['status']='PASS' if all(c.get('freshTS') and len(c['backends'])==2 and all(x['status']=='PASS' for x in c['backends'].values()) for c in evidence['cases']) else 'BOUNDED_FAILURE'
 (HERE/'occupancy-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(evidence['status']);return int(evidence['status']!='PASS')
if __name__=='__main__':sys.exit(main())
