"""Independent additive observer over qualified Lifecycle Health operation/LC2 models."""
from pathlib import Path
import sys,importlib.util,json,gzip,hashlib
P=Path(__file__).parent
sys.path[:0]=[str(P/'source/operation/lc1-v1/health-v1'),str(P/'source/operation')]
import capture,records
import health_program as program
sys.path.insert(0,str(P/'source/operation/lc2-v1/health-v1'))
spec=importlib.util.spec_from_file_location('lc2_model_codec',P/'source/operation/lc2-v1/health-v1/codec.py');LC2=importlib.util.module_from_spec(spec);spec.loader.exec_module(LC2)
sha=lambda b:hashlib.sha256(b).hexdigest()
DELTAS={'commands.spawn_reserved':[0,1,0],'commands.track_pending':[1,0,0],'structural.queue_checked':[0,1,0],'commands.despawn_checked_with':[0,1,0]}
def witness(w):return {'namespace':w.namespace,'tick':w.clock,'pending':len(w.pending),'events':0}
def report(kind,w,begin,sites):
 current=[0,0,0];boundaries=[]
 for site in sites:
  delta=DELTAS[site];current=[x+y for x,y in zip(current,delta)]
  boundaries.append({'site':site,'delta':list(delta),'current':list(current),'peak':list(current)})
 return {'kind':kind,'namespace':w.namespace,'beginTick':begin,'endTick':w.clock,'appendTick':None,'boundaries':boundaries,'terminal':current,'consistent':True,'returnedWorld':witness(w)}
def sample(kind,iteration,phase,call,ordinal,action,committed,w,begin,sites,handle=None,cursor=None):
 return {'kind':kind,'iteration':iteration,'phase':phase,'call':call,'ordinal':ordinal,'action':action,'committed':committed,'observation':{'handle':None if handle is None else {'namespace':handle.namespace,'index':handle.key.index,'generation':handle.key.generation},'cursor':cursor,'tx':report(kind,w,begin,sites)}}
Original=capture.Program
class Observer(Original):
 def __init__(self,*a):
  super().__init__(*a);self.metric_groups=[[],[],[],[]]
 def invoke(self,index):
  begin=self.world.clock;iteration=self.frame.iteration;phase=self.frame.phase;call=self.counts[index]+1
  if index==0:
   # query-contract.scan obtains W.handles before selecting; it unselects every
   # attempted handle, not only the selected target. All current live entities
   # have Main in this authored workload, verified against actual model query.
   handles=[program.Handle(self.world.namespace,k)for k in self.world.allocator.visible()]
   assert handles==self.world.main_handles()
   for h in handles:
    group=self.metric_groups[0];group.append(sample('Select',iteration,phase,call,len(group),'unselect',None,self.world,begin,[],h,0))
  super().invoke(index)
  if index in [1,2]:
   kind='Reserve'if index==1 else 'Dispose';sites=['commands.spawn_reserved','commands.track_pending']if index==1 else ['structural.queue_checked','commands.despawn_checked_with'];group=self.metric_groups[index]
   # Operation model asserts actual accepted target/removal/despawn status;
   # its typed call records actual modeled succeeded completion.
   assert self.typed_calls[-1]['status']==0
   group.append(sample(kind,iteration,phase,call,len(group),'finish',True,self.world,begin,sites))
def generate():
 basis=json.loads((P/'SOURCE-BASIS.json').read_text())
 for pin in basis['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
 # First exact independent original canonical reconstruction, without observer.
 raw=LC2.encode_report(records.report(64,64));q=basis['qualifiedCanonical'];qualified=gzip.decompress((P/q['copy']).read_bytes());assert raw==qualified and(len(raw),sha(raw))==(q['bytes'],q['sha256'])
 (P/'canonical-control.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
 capture.Program=Observer
 try:v=capture.run(64,64)
 finally:capture.Program=Original
 p=v['final'];assert [len(g)for g in p.metric_groups]==[4096,64,64,0]
 seeds=[sample('main-seed',None,None,None,0,'finish',True,v['seed_pending'],0,['commands.spawn_reserved','commands.track_pending']*64),sample('foreign-seed',None,None,None,1,'finish',True,v['foreign_pending'],0,['commands.spawn_reserved','commands.track_pending'])]
 values=seeds+[x for g in p.metric_groups for x in g];assert len(values)==4226
 assert p.counts==[64,64,64,192] and p.world.clock==235 and not p.world.pending
 for i in range(64):
  ss=p.metric_groups[0][i*64:(i+1)*64];r=p.metric_groups[1][i];d=p.metric_groups[2][i]
  assert all(s['call']==i+1 and s['iteration']==i and s['phase']==0 and s['observation']['cursor']==0 and s['committed']is None for s in ss)
  assert all(s['observation']['tx']['terminal']==[0,0,0]and s['observation']['tx']['beginTick']==107+2*i and s['observation']['tx']['returnedWorld']['pending']==0 for s in ss)
  assert r['observation']['tx']['terminal']==[1,1,0]and r['observation']['tx']['beginTick']==107+2*i and r['observation']['tx']['returnedWorld']['pending']==1
  assert d['observation']['tx']['terminal']==[0,2,0]and d['observation']['tx']['beginTick']==108+2*i and d['observation']['tx']['returnedWorld']['pending']==2 and d['phase']==1
 out=(json.dumps(values,separators=(',',':'))+'\n').encode();(P/'expected.boundaries.json').write_bytes(out);packed=gzip.compress(out,mtime=0);(P/'expected.stdout.gz').write_bytes(packed)
 receipt={'status':'PASS','origin':'Independent qualified operation+LC2 models and source-derived observer; no subject/backend output input','modelSHA256':sha(Path(__file__).read_bytes()),'sourceBasisSHA256':sha((P/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':{'bytes':len(raw),'sha256':sha(raw)},'samples':len(values),'groups':{'main-seed':1,'foreign-seed':1,'Select':4096,'Reserve':64,'Dispose':64,'Observe':0},'bytes':len(out),'sha256':sha(out),'gzipBytes':len(packed),'gzipSHA256':sha(packed),'allConsistent':all(s['observation']['tx']['consistent']for s in values)}
 (P/'GENERATION-RECEIPT.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt,sort_keys=True))
if __name__=='__main__':generate()
