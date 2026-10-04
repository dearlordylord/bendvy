import Base
import ./storage.bend as W
import ./streams.bend as S
import ./readers.bend as R
import ./reader-host.bend as H
import ./transaction.bend as X
import ./types.bend as T

# Diagnostic-only owner-return inspection. It invokes no reader/trim operation.
type BatchStats is Data:
  BatchStats{batches: U32, values: U32, declared: U32, consistent: Bool}
type BufferStats is Data:
  BufferStats{capacity: U32, cached: U32, dropped: U32, front: U32, rear: U32, physical: U32, declared: U32, consistentSize: Bool, consistentBatches: Bool}
type BufferView<-V: Data> is Data:
  BufferView{stats: BufferStats, front: List<&2,S.Batch<V>>, rear: List<&2,S.Batch<V>>}
type LogView<-Schema: Data,-P: Data> is Data:
  LogView{ping: BufferView<P>, removed: BufferView<W.Handle<Schema>>, despawned: BufferView<W.Handle<Schema>>}
type ReaderStats is Data:
  ReaderStats{key: U32, registeredAt: U32, lastRun: U32, streamLastRun: U32, messages: Bool, removed: Bool, despawned: Bool, unreadMessages: U32, unreadRemoved: U32, unreadDespawned: U32, messageLag: Bool, removedLag: Bool, despawnedLag: Bool}
type TxStats is Data:
  TxStats{commands: U32, pings: U32, inverse: U32, marks: U32}
type WorldStats is Data:
  WorldStats{namespace: U32, next: U32, live: U32, pending: U32, highWater: U32, capacity: U32, mainCapacity: U32, auxCapacity: U32, metadataCapacity: U32}
def length(-V: Data,values: List<&2,V>) -> U32:
  match values:
    case Nil{}: 0
    case Con{_,tail}: U32.add(1,length(V,tail))
def owned_cons(-V: Type,head: V,result: List<V> & U32) -> List<V> & U32:
  match result:
    case (tail,n): (head <> tail,U32.add(1,n))
def owned_length(-V: Type,values: List<V>) -> List<V> & U32:
  match values:
    case Nil{}: ([],0)
    case Con{head,tail}: owned_cons(V,head,owned_length(V,tail))
def batch_cons(+declared: U32,+actual: U32,tail: BatchStats) -> BatchStats:
  match tail:
    case BatchStats{n,v,c,yes}: BatchStats{U32.add(1,n),U32.add(actual,v),U32.add(declared,c),Bool.and(yes,U32.is_eq(declared,actual))}
def batches(-V: Data,values: List<&2,S.Batch<V>>) -> BatchStats:
  match values:
    case Nil{}: BatchStats{0,0,0,True{}}
    case Con{S.Batch{_,declared,data},tail}: batch_cons(declared,length(V,data),batches(V,tail))
def buffer_stats(capacity: U32,+cached: U32,dropped: U32,front: BatchStats,rear: BatchStats) -> BufferStats:
  match front rear:
    case BatchStats{fn,+fv,fc,fy} BatchStats{rn,+rv,rc,ry}: BufferStats{capacity,cached,dropped,fn,rn,U32.add(fv,rv),U32.add(fc,rc),U32.is_eq(cached,U32.add(fv,rv)),Bool.and(fy,ry)}
def inspect_buffer(-V: Data,buffer: S.Buffer<V>) -> S.Buffer<V> & BufferView<V>:
  match buffer:
    case S.Buffer{+capacity,+cached,+dropped,+front,+rear}: (S.Buffer{capacity,cached,dropped,front,rear},BufferView{buffer_stats(capacity,cached,dropped,batches(V,front),batches(V,rear)),front,rear})
def ping_done(-P: Data,result: S.Buffer<P> & BufferView<P>) -> S.PingLog<P> & BufferView<P>:
  match result:
    case (buffer,view): (S.PingLog{buffer},view)
def inspect_ping(-P: Data,log: S.PingLog<P>) -> S.PingLog<P> & BufferView<P>:
  match log:
    case S.PingLog{buffer}: ping_done(P,inspect_buffer(P,buffer))
def life_done(-V: Data,result: S.Buffer<V> & BufferView<V>) -> S.LifeLog<V> & BufferView<V>:
  match result:
    case (buffer,view): (S.LifeLog{buffer},view)
def inspect_life(-V: Data,log: S.LifeLog<V>) -> S.LifeLog<V> & BufferView<V>:
  match log:
    case S.LifeLog{buffer}: life_done(V,inspect_buffer(V,buffer))
def logs_done(-Schema: Data,-P: Data,result: (S.PingLog<P> & BufferView<P>) & ((S.LifeLog<W.Handle<Schema>> & BufferView<W.Handle<Schema>>) & (S.LifeLog<W.Handle<Schema>> & BufferView<W.Handle<Schema>>))) -> H.Logs<Schema,P> & LogView<Schema,P>:
  match result:
    case ((ping,pv),((removed,rv),(despawned,dv))): (H.Logs{ping,removed,despawned},LogView{pv,rv,dv})
def inspect_logs(-Schema: Data,-P: Data,logs: H.Logs<Schema,P>) -> H.Logs<Schema,P> & LogView<Schema,P>:
  match logs:
    case H.Logs{ping,removed,despawned}: logs_done(Schema,P,(inspect_ping(P,ping),(inspect_life(W.Handle<Schema>,removed),inspect_life(W.Handle<Schema>,despawned))))
def unread_case(include: Bool,n: U32,tail: U32) -> U32:
  match include:
    case False{}: tail
    case True{}: U32.add(n,tail)
def unread(-V: Data,+since: U32,values: List<&2,S.Batch<V>>) -> U32:
  match values:
    case Nil{}: 0
    case Con{S.Batch{tick,_,data},tail}: unread_case(U32.is_gt(tick,since),length(V,data),unread(V,since,tail))
def view_unread(-V: Data,+position: U32,view: BufferView<V>) -> U32:
  match view:
    case BufferView{_,front,rear}: U32.add(unread(V,position,front),unread(V,position,rear))
def view_lag(-V: Data,position: U32,registered: U32,view: BufferView<V>) -> Bool:
  match view:
    case BufferView{BufferStats{_,_,dropped,_,_,_,_,_,_},_,_}: U32.is_gt(dropped,U32.max(position,registered))
def reader_stats(-Schema: Data,-P: Data,key: U32,+interests: R.Interests,state: T.ReaderState,+logs: LogView<Schema,P>) -> ReaderStats:
  match state logs:
    case T.ReaderState{+registered,+last,+stream} LogView{+ping,+removed,+despawned}: ReaderStats{key,registered,last,stream,R.interested(R.Messages{},interests),R.interested(R.Removed{0},interests),R.interested(R.Despawned{},interests),view_unread(P,stream,ping),view_unread(W.Handle<Schema>,last,removed),view_unread(W.Handle<Schema>,last,despawned),view_lag(P,stream,registered,ping),view_lag(W.Handle<Schema>,last,registered,removed),view_lag(W.Handle<Schema>,last,registered,despawned)}
def reader_records(-Schema: Data,-P: Data,+logs: LogView<Schema,P>,slots: List<&2,R.Slot>) -> List<&2,ReaderStats>:
  match slots:
    case Nil{}: []
    case Con{R.Slot{key,interests,state},tail}: reader_stats(Schema,P,key,interests,state,logs) <> reader_records(Schema,P,logs,tail)
def inspect_readers(-Schema: Data,-P: Data,readers: R.Readers,logs: LogView<Schema,P>) -> R.Readers & List<&2,ReaderStats>:
  match readers:
    case R.Readers{+slots}: (R.Readers{slots},reader_records(Schema,P,logs,slots))
def tx_done(-W: Type,-Handle: Data,-C: Type,world: W,selected: Handle,+undo: List<&2,X.Inverse<Handle>>,+pings: List<&2,U32>,+marks: List<&2,Handle>,result: List<C> & U32) -> X.Tx<W,Handle,C> & TxStats:
  match result:
    case (commands,count): (X.Tx{world,selected,undo,commands,pings,marks},TxStats{count,length(U32,pings),length(X.Inverse<Handle>,undo),length(Handle,marks)})
def inspect_tx(-W: Type,-Handle: Data,-C: Type,tx: X.Tx<W,Handle,C>) -> X.Tx<W,Handle,C> & TxStats:
  match tx:
    case X.Tx{world,selected,undo,commands,pings,marks}: tx_done(W,Handle,C,world,selected,undo,pings,marks,owned_length(C,commands))
def live_value(-F: Data,meta: W.Metadata<F>) -> U32:
  match meta:
    case W.Metadata{True{},_,_,_}: 1
    case W.Metadata{False{},_,_,_}: 0
def metadata_join(-F: Data,result: (Array<W.Metadata<F>> & (U32 & U32)) & (Array<W.Metadata<F>> & (U32 & U32))) -> Array<W.Metadata<F>> & (U32 & U32):
  match result:
    case ((l,(ln,lc)),(r,(rn,rc))): (ANode{l,r},(U32.add(ln,rn),U32.add(lc,rc)))
def metadata_count(-F: Data,meta: Array<W.Metadata<F>>) -> Array<W.Metadata<F>> & (U32 & U32):
  match meta:
    case ALeaf{+entry}: (ALeaf{entry},(live_value(F,entry),1))
    case ANode{l,r}: metadata_join(F,(metadata_count(F,l),metadata_count(F,r)))
def world_done(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,+namespace: U32,+next: U32,+capacity: U32,depth: Nat,+high: U32,ledger: Maybe<L>,mode: Mode,result: (Array<Maybe<M>> & U32) & ((Array<Maybe<A>> & U32) & ((Array<W.Metadata<F>> & (U32 & U32)) & (List<W.Command<M,A,F>> & U32)))) -> W.World<Schema,M,A,F,L,Mode> & WorldStats:
  match result:
    case ((main,mc),((aux,ac),((metadata,(live,fc)),(pending,n)))): (W.World{namespace,next,W.Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode},WorldStats{namespace,next,live,n,high,capacity,mc,ac,fc})
def inspect_world(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,world: W.World<Schema,M,A,F,L,Mode>) -> W.World<Schema,M,A,F,L,Mode> & WorldStats:
  match world:
    case W.World{namespace,next,W.Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode}: world_done(Schema,M,A,F,L,Mode,namespace,next,capacity,depth,high,ledger,mode,(Array.size(Maybe<M>,main),(Array.size(Maybe<A>,aux),(metadata_count(F,metadata),owned_length(W.Command<M,A,F>,pending)))))
def format_buffer(stats: BufferStats) -> String:
  match stats:
    case BufferStats{capacity,cached,dropped,front,rear,physical,declared,sizeOK,batchesOK}: U32.show(capacity) ++ ":" ++ U32.show(cached) ++ ":" ++ U32.show(dropped) ++ ":" ++ U32.show(front) ++ ":" ++ U32.show(rear) ++ ":" ++ U32.show(physical) ++ ":" ++ U32.show(declared) ++ ":" ++ Bool.show(sizeOK) ++ ":" ++ Bool.show(batchesOK)
def format_view(-V: Data,view: BufferView<V>) -> String:
  match view:
    case BufferView{stats,_,_}: format_buffer(stats)
def format_logs(-Schema: Data,-P: Data,view: LogView<Schema,P>) -> String:
  match view:
    case LogView{ping,removed,despawned}: "ping=" ++ format_view(P,ping) ++ "|removed=" ++ format_view(W.Handle<Schema>,removed) ++ "|despawned=" ++ format_view(W.Handle<Schema>,despawned)
def format_reader(stats: ReaderStats) -> String:
  match stats:
    case ReaderStats{key,registered,last,stream,mh,rh,dh,mu,ru,du,ml,rl,dl}: U32.show(key) ++ ":" ++ U32.show(registered) ++ ":" ++ U32.show(last) ++ ":" ++ U32.show(stream) ++ ":" ++ Bool.show(mh) ++ ":" ++ Bool.show(rh) ++ ":" ++ Bool.show(dh) ++ ":" ++ U32.show(mu) ++ ":" ++ U32.show(ru) ++ ":" ++ U32.show(du) ++ ":" ++ Bool.show(ml) ++ ":" ++ Bool.show(rl) ++ ":" ++ Bool.show(dl)
def format_readers(records: List<&2,ReaderStats>) -> String:
  match records:
    case Nil{}: "end"
    case Con{head,tail}: format_reader(head) ++ ";" ++ format_readers(tail)
def format_tx(stats: TxStats) -> String:
  match stats:
    case TxStats{commands,pings,inverse,marks}: U32.show(commands) ++ ":" ++ U32.show(pings) ++ ":" ++ U32.show(inverse) ++ ":" ++ U32.show(marks)
def format_world(stats: WorldStats) -> String:
  match stats:
    case WorldStats{ns,next,live,pending,high,c,mc,ac,fc}: U32.show(ns) ++ ":" ++ U32.show(next) ++ ":" ++ U32.show(live) ++ ":" ++ U32.show(pending) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(c) ++ ":" ++ U32.show(mc) ++ ":" ++ U32.show(ac) ++ ":" ++ U32.show(fc)
type Holders is Data:
  Holders{messages: List<&2,U32>, removed: List<&2,U32>, despawned: List<&2,U32>}
def holders_despawned(messages: List<&2,U32>,removed: List<&2,U32>,result: R.Readers & List<&2,U32>) -> R.Readers & Holders:
  match result:
    case (readers,despawned): (readers,Holders{messages,removed,despawned})
def holders_removed(messages: List<&2,U32>,result: R.Readers & List<&2,U32>) -> R.Readers & Holders:
  match result:
    case (readers,removed): holders_despawned(messages,removed,R.holders(readers,R.Despawned{}))
def holders_messages(result: R.Readers & List<&2,U32>) -> R.Readers & Holders:
  match result:
    case (readers,messages): holders_removed(messages,R.holders(readers,R.Removed{0}))
def inspect_holders(readers: R.Readers) -> R.Readers & Holders:
  holders_messages(R.holders(readers,R.Messages{}))
def positions(values: List<&2,U32>) -> String:
  match values:
    case Nil{}: "end"
    case Con{head,tail}: U32.show(head) ++ "," ++ positions(tail)
def format_holders(holds: Holders) -> String:
  match holds:
    case Holders{+m,+r,+d}: U32.show(length(U32,m)) ++ ":[" ++ positions(m) ++ "]|" ++ U32.show(length(U32,r)) ++ ":[" ++ positions(r) ++ "]|" ++ U32.show(length(U32,d)) ++ ":[" ++ positions(d) ++ "]"
def reader_key(stats: ReaderStats) -> U32:
  match stats:
    case ReaderStats{key,_,_,_,_,_,_,_,_,_,_,_,_}: key
def reader_found(found: Bool,head: ReaderStats,tail: Maybe<&2,ReaderStats>) -> Maybe<&2,ReaderStats>:
  match found:
    case True{}: Some{head}
    case False{}: tail
def find_reader(+key: U32,records: List<&2,ReaderStats>) -> Maybe<&2,ReaderStats>:
  match records:
    case Nil{}: None{}
    case Con{+head,tail}: reader_found(U32.is_eq(key,reader_key(head)),head,find_reader(key,tail))
def format_optional_reader(record: Maybe<&2,ReaderStats>) -> String:
  match record:
    case None{}: "null"
    case Some{stats}: format_reader(stats)
