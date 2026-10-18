"""Independent finite Tx-boundary observer over the unchanged qualified operation model.
No Bend subject output or generated backend is loaded or executed.
"""
from pathlib import Path
import json,gzip,hashlib,copy,io
import operation_model as O
HERE=Path(__file__).parent
SHA=lambda b:hashlib.sha256(b).hexdigest()
COMP='component.tx_written';RESOURCE='resource-field.journaled';SPAWN='commands.spawn_reserved';PENDING='commands.track_pending';EMIT='transaction.emit';DISPOSE='commands.despawn_checked_with'
DELTAS={COMP:[1,0,0],RESOURCE:[1,0,0],SPAWN:[0,1,0],PENDING:[1,0,0],EMIT:[0,0,1],DISPOSE:[0,1,0]}
def report(kind,namespace,begin,end,sites,terminal,returned):
 current=[0,0,0];peak=[0,0,0];rows=[]
 for site in sites:
  delta=DELTAS[site];current=[x+y for x,y in zip(current,delta)];peak=[max(x,y)for x,y in zip(peak,current)]
  rows.append({'site':site,'delta':list(delta),'current':list(current),'peak':list(peak)})
 assert current==terminal
 return {'kind':kind,'namespace':namespace,'beginTick':begin,'endTick':end,'appendTick':None,'boundaries':rows,'terminal':list(terminal),'consistent':True,'returnedWorld':returned}
def witness(world,pending=None,events=None):
 return {'namespace':world.ns,'tick':world.clock,'pending':len(world.pending)if pending is None else pending,'events':len(world.events)if events is None else events}
def sample(samples,kind,iteration,phase,committed,value):
 samples.append({'kind':kind,'iteration':iteration,'phase':phase,'ordinal':len(samples),'committed':committed,'tx':value})
class Observer(O.Model):
 def do_a(self,iteration):
  self.begin=self.world.clock;super().do_a(iteration)
 def _reader_attempt(self,*a,**kw):
  result=super()._reader_attempt(*a,**kw);self.begin=self.world.clock;return result
 def callback_text(self,**kw):
  kind=kw['who'];prime=kw.get('prime',False);ok=kw['outcome_success'];i=kw['iteration'];phase=0 if prime else 1 if kind=='A'or not ok else 3
  sites=[]if prime else [COMP]+([]if kind=='A'else[COMP])+[RESOURCE,SPAWN,PENDING,EMIT]
  terminal=[0,0,0]if prime else[3 if kind=='A'else 4,1,1]
  # At Cmd.tx_finish, before Reader.commit/after-success synchronization. Those
  # later operations update provider metadata, not this World witness.
  returned=witness(self.world,len(self.world.pending)+(int(ok)if not prime else 0),len(self.world.events)+(int(ok)if not prime else 0))
  value=report(kind,self.world.ns,self.begin,self.world.clock,sites,terminal,returned)
  sample(self.samples,kind,i,phase,ok,value)
  return super().callback_text(**kw)
 def do_publication(self,phase,iteration,prime=False):
  # Prepare advances the actual World clock before Tx.begin. This callback has
  # Unit capabilities and cannot append to its fresh empty transaction.
  before=self.world.clock;super().do_publication(phase,iteration,prime)
  assert self.world.clock==before+1
  sample(self.samples,'Publications',iteration,phase,True,report('Publications',self.world.ns,self.world.clock,self.world.clock,[],[0,0,0],witness(self.world)))
 def do_dispose(self):
  # O.do_dispose combines staging/commit and the authored barrier. Its report is
  # taken after commit but BEFORE that barrier drains the two staged commands.
  tick=self.world.clock;returned=witness(self.world,len(self.world.pending)+2)
  sample(self.samples,'Dispose',self.frame.iteration,6,True,report('Dispose',self.world.ns,tick,tick,[DISPOSE,DISPOSE],[0,2,0],returned));super().do_dispose()
 def append_boundary(self,phase_name):pass
 def schedule(self,*args,**kwargs):pass

def world(namespace):
 w=O.seed_pending_world(namespace,64)
 samples=[];sample(samples,'seed',None,None,True,report('seed',namespace,0,0,[SPAWN,PENDING]*64,[64,64,0],witness(w)))
 w,reservations,base=O.setup_model(namespace,64)
 # Health:64Vitals +22Armor +21Tracked writes; resource metadata is unchanged.
 assert w.clock==64+22+21==107
 assert w.main.values[0]==([0,1,2,3],9,2) and w.aux.values[0]==([1,2,3,4],3)
 base.__class__=Observer;base.samples=samples
 O.schedule0(base);assert w.clock==109
 for i in range(64):O.do_iteration(base,i)
 assert len(samples)==387 and w.clock==813 and len(w.pending)==0 and len(w.events)==128
 assert [s['kind']for s in samples[:3]]==['seed','B','Publications']
 for i in range(64):
  rows=samples[3+6*i:9+6*i];assert [s['kind']for s in rows]==['A','B','Publications','B','Publications','Dispose'];assert [s['committed']for s in rows]==[True,False,True,True,True,True]
  start=109+11*i;assert [(s['tx']['beginTick'],s['tx']['endTick'])for s in rows]==[(start,start+1),(start+2,start+4),(start+5,start+5),(start+6,start+8),(start+9,start+9),(start+11,start+11)]
  assert [(s['tx']['returnedWorld']['pending'],s['tx']['returnedWorld']['events'])for s in rows]==[(1,2*i+1),(1,2*i+1),(1,2*i+1),(2,2*i+2),(2,2*i+2),(2,2*i+2)]
 return samples

def generate():
 basis=json.loads((HERE/'SOURCE-BASIS.json').read_text())
 for row in basis['sourcePins']:assert SHA((HERE/row['copy']).read_bytes())==row['sha256']
 assert SHA((HERE/'operation_model.py').read_bytes())=='62dce81d79630514c5c44eef915b5eb6b39240acd0b5e6894eb775f74a41b134'
 # Reproduce the exact qualified canonical stream independently. All original
 # model functions are unchanged; only its temporary spool paths are isolated.
 original=O.Path;spool=HERE/'canonical-control';spool.mkdir(exist_ok=True)
 O.Path=lambda x:spool/original(x).name if str(x).startswith('/tmp/failedtxn-oracle-ns-')else original(x)
 control=O.generate(spool,64,64);assert(control['bytes'],control['sha256'])==(38400832,'a20f7dccdf2efd66b44cb4dde507b0f7256ea493c1d3d5935d12f97db0ef5a95')
 worlds=[{'run':label,'reports':world(ns)}for label,ns in [('warmup',1),('measured',2)]]
 result={'scope':'ordinary-workload-tx-boundaries','workload':'FailedTxn','schema':'Health','workloadCount':64,'iterations':64,'worlds':worlds}
 raw=(json.dumps(result,separators=(',',':'))+'\n').encode();(HERE/'expected.stdout').write_bytes(raw);(HERE/'expected.boundaries.json').write_bytes(raw);packed=gzip.compress(raw,mtime=0);(HERE/'expected.stdout.gz').write_bytes(packed)
 assert gzip.decompress(packed)==raw
 checks={'status':'PASS','origin':'Unchanged independent operation model plus source-derived diagnostic observer; no subject/backend outputs','modelSHA256':SHA(Path(__file__).read_bytes()),'operationModelSHA256':SHA((HERE/'operation_model.py').read_bytes()),'sourceBasisSHA256':SHA((HERE/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':control,'worldReports':[len(x['reports'])for x in worlds],'bytes':len(raw),'sha256':SHA(raw),'gzipBytes':len(packed),'gzipSHA256':SHA(packed),'allConsistent':all(s['tx']['consistent']for x in worlds for s in x['reports'])}
 (HERE/'GENERATION-RECEIPT.json').write_text(json.dumps(checks,indent=2)+'\n');print(json.dumps(checks,sort_keys=True))
if __name__=='__main__':generate()
