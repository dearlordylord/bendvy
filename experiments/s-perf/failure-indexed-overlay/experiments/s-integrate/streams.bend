import Base
import ./readers.bend as R
import ./types.bend as T

# Generic Data observations retain nominal Ping/Handle types. Affine log owners
# stay behind trusted declared views. Setup bounds counts and additions to U32.
type Batch<-V: Data> is Data:
  Batch{tick: U32, count: U32, values: List<&2,V>}
type Buffer<-V: Data> is Type:
  Buffer{capacity: U32, size: U32, dropped: U32, front: List<&2,Batch<V>>, rear: List<&2,Batch<V>>}
type PingLog<-P: Data> is Type:
  PingLog{buffer: Buffer<P>}
type LifeLog<-H: Data> is Type:
  LifeLog{buffer: Buffer<H>}
type Cut<-V: Data> is Data:
  Cut{front: List<&2,Batch<V>>, size: U32, dropped: U32}
type Values<-V: Data> is Type:
  Values{buffer: Buffer<V>, values: List<&2,V>, lagged: Bool}
type PingRead<-P: Data> is Type:
  PingRead{log: PingLog<P>, run: R.Run, values: List<&2,P>, lagged: Bool}
type LifeRead<-H: Data> is Type:
  LifeRead{log: LifeLog<H>, run: R.Run, values: List<&2,H>}
type Inspection<-V: Data> is Data:
  Inspection{capacity: U32, size: U32, dropped: U32, batches: List<&2,Batch<V>>}

def initial(-P: Data,capacity: U32) -> PingLog<P>: PingLog{Buffer{capacity,0,0,[],[]}}
def life_initial(-H: Data,capacity: U32) -> LifeLog<H>: LifeLog{Buffer{capacity,0,0,[],[]}}
def count(-V: Data,values: List<&2,V>,acc: U32) -> U32:
  match values:
    case Nil{}: acc
    case Con{_,tail}: count(V,tail,U32.add(acc,1))
def append_buffer(-V: Data,buffer: Buffer<V>,tick: U32,values: List<&2,V>) -> Buffer<V>:
  match buffer values:
    case Buffer{capacity,size,dropped,front,rear} Nil{}: Buffer{capacity,size,dropped,front,rear}
    case Buffer{capacity,size,dropped,front,rear} Con{+v,+vs}:
      +n = count(V,v <> vs,0)
      Buffer{capacity,U32.add(size,n),dropped,front,Batch{tick,n,v <> vs} <> rear}
def append(-P: Data,log: PingLog<P>,tick: U32,values: List<&2,P>) -> PingLog<P>:
  match log:
    case PingLog{buffer}: PingLog{append_buffer(P,buffer,tick,values)}
def append_units(-H: Data,values: List<&2,H>,+tick: U32,buffer: Buffer<H>) -> Buffer<H>:
  match values:
    case Nil{}: buffer
    case Con{value,tail}: append_units(H,tail,tick,append_buffer(H,buffer,tick,[value]))
def append_lifecycle(-H: Data,log: LifeLog<H>,tick: U32,handles: List<&2,H>) -> LifeLog<H>:
  match log:
    case LifeLog{buffer}: LifeLog{append_units(H,handles,tick,buffer)}
def choose_min(smaller: Bool,a: U32,b: U32) -> U32:
  match smaller:
    case True{}: a
    case False{}: b
def minimum(+a: U32,+b: U32) -> U32: choose_min(U32.is_lt(a,b),a,b)
def maximum(+a: U32,+b: U32) -> U32: choose_min(U32.is_lt(a,b),b,a)
def boundary(holders: List<&2,U32>,window: U32) -> U32:
  match holders:
    case Nil{}: window
    case Con{head,tail}: boundary(tail,minimum(window,head))
def trim_decision(-V: Data,drop: Bool,+head: Batch<V>,tail: List<&2,Batch<V>>,+size: U32,+dropped: U32,
  ih: U32 -> U32 -> Cut<V>) -> Cut<V>:
  match drop head:
    case False{} kept: Cut{kept <> tail,size,dropped}
    case True{} Batch{tick,n,_}: ih(U32.sub(size,n),maximum(dropped,tick))
def trim_front(-V: Data,front: List<&2,Batch<V>>,+capacity: U32,+window: U32,+size: U32,+dropped: U32) -> Cut<V>:
  match front:
    case Nil{}: Cut{[],size,dropped}
    case Con{Batch{+tick,+n,+values},+tail}:
      trim_decision(V,Bool.or(U32.is_le(tick,window),U32.is_gt(size,capacity)),Batch{tick,n,values},tail,size,dropped,
        remaining => lost => trim_front(V,tail,capacity,window,remaining,lost))
def finish_cut(-V: Data,capacity: U32,cut: Cut<V>) -> Buffer<V>:
  match cut:
    case Cut{front,size,dropped}: Buffer{capacity,size,dropped,front,[]}
def trim_second(-V: Data,+capacity: U32,+window: U32,rear: List<&2,Batch<V>>,cut: Cut<V>) -> Buffer<V>:
  match cut:
    case Cut{Nil{},size,dropped}: finish_cut(V,capacity,trim_front(V,List.reverse(&2,Batch<V>,rear),capacity,window,size,dropped))
    case Cut{Con{head,tail},size,dropped}: Buffer{capacity,size,dropped,head <> tail,rear}
def trim_buffer(-V: Data,buffer: Buffer<V>,window: U32,holders: List<&2,U32>) -> Buffer<V>:
  match buffer:
    case Buffer{+capacity,size,dropped,front,rear}:
      +oldest = boundary(holders,window)
      trim_second(V,capacity,oldest,rear,trim_front(V,front,capacity,oldest,size,dropped))
def trim(-P: Data,log: PingLog<P>,window: U32,holders: List<&2,U32>) -> PingLog<P>:
  match log:
    case PingLog{buffer}: PingLog{trim_buffer(P,buffer,window,holders)}
def trim_lifecycle(-H: Data,log: LifeLog<H>,window: U32,holders: List<&2,U32>) -> LifeLog<H>:
  match log:
    case LifeLog{buffer}: LifeLog{trim_buffer(H,buffer,window,holders)}
def push_values(-V: Data,values: List<&2,V>,acc: List<&2,V>) -> List<&2,V>:
  match values:
    case Nil{}: acc
    case Con{head,tail}: push_values(V,tail,head <> acc)
def read_choose(-V: Data,include: Bool,values: List<&2,V>,acc: List<&2,V>) -> List<&2,V>:
  match include:
    case True{}: push_values(V,values,acc)
    case False{}: acc
def read_batches(-V: Data,batches: List<&2,Batch<V>>,+since: U32,acc: List<&2,V>) -> List<&2,V>:
  match batches:
    case Nil{}: acc
    case Con{Batch{tick,_,values},tail}: read_batches(V,tail,since,read_choose(V,U32.is_gt(tick,since),values,acc))
def read_buffer(-V: Data,buffer: Buffer<V>,+since: U32,registered: U32) -> Values<V>:
  match buffer:
    case Buffer{capacity,size,+dropped,+front,+rear}:
      Values{Buffer{capacity,size,dropped,front,rear},List.reverse(&2,V,read_batches(V,List.reverse(&2,Batch<V>,rear),since,read_batches(V,front,since,[]))),U32.is_gt(dropped,maximum(since,registered))}
def ping_result(-P: Data,run: R.Run,result: Values<P>) -> PingRead<P>:
  match result:
    case Values{buffer,values,lagged}: PingRead{PingLog{buffer},run,values,lagged}
def ping_info(-P: Data,log: PingLog<P>,info: R.RunInfo) -> PingRead<P>:
  match log info:
    case PingLog{buffer} R.RunInfo{run,T.ReaderState{registered,_,_},T.ReadBoundary{_,since,_}}:
      ping_result(P,run,read_buffer(P,buffer,since,registered))
def read_ping(-P: Data,log: PingLog<P>,run: R.Run) -> PingRead<P>:
  ping_info(P,log,R.project(run))
def life_result(-H: Data,run: R.Run,result: Values<H>) -> LifeRead<H>:
  match result:
    case Values{buffer,values,_}: LifeRead{LifeLog{buffer},run,values}
def life_info(-H: Data,log: LifeLog<H>,info: R.RunInfo) -> LifeRead<H>:
  match log info:
    case LifeLog{buffer} R.RunInfo{run,T.ReaderState{registered,_,_},T.ReadBoundary{since,_,_}}:
      life_result(H,run,read_buffer(H,buffer,since,registered))
def read_lifecycle(-H: Data,log: LifeLog<H>,run: R.Run) -> LifeRead<H>:
  life_info(H,log,R.project(run))
def missed_info(-H: Data,log: LifeLog<H>,info: R.RunInfo) -> LifeLog<H> & (R.Run & Bool):
  match log info:
    case LifeLog{Buffer{capacity,size,+dropped,front,rear}} R.RunInfo{run,T.ReaderState{registered,_,_},T.ReadBoundary{since,_,_}}:
      (LifeLog{Buffer{capacity,size,dropped,front,rear}},(run,U32.is_gt(dropped,maximum(since,registered))))
def missed(-H: Data,log: LifeLog<H>,run: R.Run) -> LifeLog<H> & (R.Run & Bool):
  missed_info(H,log,R.project(run))
def observe_buffer(-V: Data,buffer: Buffer<V>) -> Buffer<V> & Inspection<V>:
  match buffer:
    case Buffer{+capacity,+size,+dropped,+front,+rear}:
      (Buffer{capacity,size,dropped,front,rear},Inspection{capacity,size,dropped,List.append(&2,Batch<V>,front,List.reverse(&2,Batch<V>,rear))})
