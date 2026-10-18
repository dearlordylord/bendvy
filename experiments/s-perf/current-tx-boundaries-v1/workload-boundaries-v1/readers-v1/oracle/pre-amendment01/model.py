"""Source-derived277finish reports over unchanged qualified Readers model."""
from pathlib import Path
import copy,json,gzip,hashlib
import operation_model as O
P=Path(__file__).parent;sha=lambda v:hashlib.sha256(v).hexdigest()
DELTAS={'commands.spawn_reserved':[0,1,0],'commands.track_pending':[1,0,0],'component.tx_written':[1,0,0],'transaction.emit':[0,0,1],'structural.queue_checked':[0,1,0],'commands.despawn_checked_with':[0,1,0]}
def witness(w):return {'namespace':w.namespace,'tick':w.clock,'pending':len(w.pending),'events':len(w.events)}
def report(kind,w,begin,sites):
 current=[0,0,0];boundaries=[]
 for site in sites:
  delta=DELTAS[site];current=[x+y for x,y in zip(current,delta)]
  boundaries.append({'site':site,'delta':list(delta),'current':list(current),'peak':list(current)})
 return {'kind':kind,'namespace':w.namespace,'beginTick':begin,'endTick':w.clock,'appendTick':None,'boundaries':boundaries,'terminal':current,'consistent':True,'returnedWorld':witness(w)}
def sample(group,kind,iteration,phase,who,ordinal,w,begin,sites):return {'group':group,'kind':kind,'iteration':iteration,'phase':phase,'who':who,'cursor':None,'ordinal':ordinal,'committed':True,'tx':report(kind,w,begin,sites)}
WorldOriginal=O.World
class World(WorldOriginal):
 def barrier(self):
  if not hasattr(self,'seed_finish_world'):self.seed_finish_world=copy.deepcopy(self)
  super().barrier()
ProgramOriginal=O.Program
class Observer(ProgramOriginal):
 def __init__(self,*a):super().__init__(*a);self.domain=[];self.reader=[]
 def prime(self):
  seed=self.world.seed_finish_world
  assert seed.clock==0 and len(seed.pending)==self.frame.count
  self.domain.append(sample('domain','Seed',0,None,None,0,seed,0,['commands.spawn_reserved','commands.track_pending']*len(seed.pending)))
  super().prime()
 def mutation(self,operation):
  begin=self.world.clock;super().mutation(operation)
  kind=['Spawn','Update','Dispose'][operation];sites=[['commands.spawn_reserved','commands.track_pending'],['component.tx_written','transaction.emit'],['structural.queue_checked','commands.despawn_checked_with']][operation]
  self.domain.append(sample('domain',kind,self.frame.iteration,self.phase,None,len(self.domain),self.world,begin,sites))
 def read(self,provider):
  original_before=self.runtime.before;running=[]
  def before():
   original_before();running.append(copy.deepcopy(self.world))
  self.runtime.before=before
  try:super().read(provider)
  finally:self.runtime.before=original_before
  assert len(running)==1
  w=running[0]
  # Callback only returns prepared data. Original stream.advance/ingest below
  # updates provider/runtime metadata, not World. Never infer this report from
  # a post-sync timestamp or invented provider registry cursor.
  assert w.wire()==self.world.wire()
  a=self.audit[-1];assert a['tick']==w.clock
  self.reader.append(sample('reader','Reader',a['iteration'],a['phase'],provider.stream_id-1,len(self.reader),w,w.clock,[]))
def generate():
 b=json.loads((P/'SOURCE-BASIS.json').read_text())
 for pin in b['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
 assert sha((P/'operation_model.py').read_bytes())=='6ecaf75517608a5366f69e182139f9b47b2a09826aa6c1f9f092b14cd5e26050'
 q=b['qualifiedCanonical'];packed=(P/q['copy']).read_bytes();assert sha(packed)==q['gzipSHA256'];qualified=gzip.decompress(packed)
 control,_=O.report(64,64);assert control==qualified and(len(control),sha(control))==(q['bytes'],q['sha256'])
 (P/'canonical-control.stdout.gz').write_bytes(gzip.compress(control,mtime=0))
 O.World=World;O.Program=Observer
 try:observed,p=O.report(64,64)
 finally:O.World=WorldOriginal;O.Program=ProgramOriginal
 assert observed==control # additive observer has changed no original wire byte
 assert len(p.domain)==193 and len(p.reader)==84 and len(p.locals)==192 and len(p.logs)==194 and len(p.reads)==84
 assert p.world.clock==577 and p.world.events==[]and p.world.pending==[]
 assert [x['kind']for x in p.domain]==['Seed']+['Spawn','Update','Dispose']*64
 assert all(x['phase']==1 for x in p.domain[1:])
 assert [x['iteration']for x in p.reader[:2]]==[0,0]and [x['iteration']for x in p.reader[-2:]]==[64,64]
 assert [x['who']for x in p.reader[:2]]==[0,1]and [x['who']for x in p.reader[-2:]]==[0,1]
 assert all(x['tx']['terminal']==[0,0,0]and x['tx']['boundaries']==[]and x['tx']['beginTick']==x['tx']['endTick']for x in p.reader)
 assert all(x['cursor']is None for x in p.domain+p.reader)
 values=p.domain+p.reader;raw=(json.dumps(values,separators=(',',':'))+'\n').encode();(P/'expected.boundaries.json').write_bytes(raw);packed=gzip.compress(raw,mtime=0);(P/'expected.stdout.gz').write_bytes(packed)
 receipt={'status':'PASS','origin':'Independent unchanged indexedReaders operationmodel and actual source boundary semantics; no candidate/backend output input','modelSHA256':sha(Path(__file__).read_bytes()),'sourceBasisSHA256':sha((P/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':{'bytes':len(control),'sha256':sha(control),'observedCanonicalIdentical':observed==control},'samples':len(values),'domain':len(p.domain),'reader':len(p.reader),'rawDiscardSamples':0,'originalTxFacts':193,'originalLocalCalls':len(p.locals),'originalReadCalls':len(p.reads),'bytes':len(raw),'sha256':sha(raw),'gzipBytes':len(packed),'gzipSHA256':sha(packed),'allConsistent':all(x['tx']['consistent']for x in values)}
 (P/'GENERATION-RECEIPT.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt,sort_keys=True))
if __name__=='__main__':generate()
