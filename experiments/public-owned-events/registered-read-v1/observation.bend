import Base
import fixture.bend as F
import log.bend as Log
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

type PayloadView is Data: PayloadView{cells:List<&2,U32>,sentinel:List<&2,U32>}
type RowView is Data: RowView{key:U32,payload:PayloadView}
type LogView is Data: LogView{seen:List<&2,U32>,rows:List<&2,RowView>}
type ReaderView is Data: ReaderView{namespace:U32,id:U32,registryId:U32,registryNamespace:U32,actualRegistryId:U32,name:String,access:List<&2,String>,cursor:U32}
type RuntimeView is Data: RuntimeView{namespace:U32,statuses:List<&2,Ev.ReaderStatus>,world:F.WorldMeta,batches:List<&2,Ev.Batch<U32>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,droppedThrough:Nat,log:LogView}
type Snapshot is Data: Snapshot{label:String,runtime:RuntimeView,fast:ReaderView,slow:ReaderView,reads:List<&2,F.View>,retired:List<&2,RowView>,refused:List<&2,RowView>,errors:List<&2,Log.Refusal>,ok:Bool}
def array_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,U32,a,b))
def array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: array_join(array(left),array(right))
def payload_done(cells:Array<U32> & List<&2,U32>,sentinel:Array<U32> & List<&2,U32>) -> P.Payload & PayloadView:
  match cells sentinel:
    case (cells,a), (sentinel,b): (P.Payload{cells,sentinel},PayloadView{a,b})
def payload(owner:P.Payload) -> P.Payload & PayloadView:
  match owner:
    case P.Payload{cells,sentinel}: payload_done(array(cells),array(sentinel))
def row_done(+key:U32,observed:P.Payload & PayloadView) -> Log.Row<P.Payload> & RowView:
  match observed:
    case (owner,view): (Log.Row{key,owner},RowView{key,view})
def row(owner:Log.Row<P.Payload>) -> Log.Row<P.Payload> & RowView:
  match owner:
    case Log.Row{key,p}: row_done(key,payload(p))
def rows_join(head:Log.Row<P.Payload> & RowView,tail:List<Log.Row<P.Payload>> & List<&2,RowView>) -> List<Log.Row<P.Payload>> & List<&2,RowView>:
  match head tail:
    case (head,a), (tail,b): (head <> tail,a <> b)
def rows_view(owners:List<Log.Row<P.Payload>>) -> List<Log.Row<P.Payload>> & List<&2,RowView>:
  match owners:
    case []: ([],[])
    case head <> tail: rows_join(row(head),rows_view(tail))
def log_done(+seen:List<&2,U32>,observed:List<Log.Row<P.Payload>> & List<&2,RowView>) -> Log.Log<P.Payload> & LogView:
  match observed:
    case (rows,view): (Log.Log{seen,rows},LogView{seen,view})
def log_view(owner:Log.Log<P.Payload>) -> Log.Log<P.Payload> & LogView:
  match owner:
    case Log.Log{seen,rows}: log_done(seen,rows_view(rows))
def world_done(+meta:F.WorldMeta,live:Array<Bool>,store:Unit,pending:List<(W.World<F.Schema,Unit,Log.Log<P.Payload>,U32> -> W.World<F.Schema,Unit,Log.Log<P.Payload>,U32>)>,observed:Log.Log<P.Payload> & LogView) -> W.World<F.Schema,Unit,Log.Log<P.Payload>,U32> & (F.WorldMeta & LogView):
  match observed:
    case (log,view): (F.rebuild(meta,live,store,log,pending),(meta,view))
def world_view(owner:W.World<F.Schema,Unit,Log.Log<P.Payload>,U32>) -> W.World<F.Schema,Unit,Log.Log<P.Payload>,U32> & (F.WorldMeta & LogView):
  match owner:
    case W.World{namespace,next,high,live,capacity,depth,store,log,events,pending,registrations,nextSystem,clock}: world_done(F.WorldMeta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},live,store,pending,log_view(log))
def runtime_done(+namespace:U32,+batches:List<&2,Ev.Batch<U32>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,observed:W.World<F.Schema,Unit,Log.Log<P.Payload>,U32> & (F.WorldMeta & LogView)) -> Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32> & RuntimeView:
  match observed:
    case (world,(meta,log)): (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},RuntimeView{namespace,Ev.reader_statuses(~U32,positions,batches,dropped),meta,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,log})
def runtime_view(owner:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>) -> Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32> & RuntimeView:
  match owner:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}: runtime_done(namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,world_view(world))
def reader(reader:Ev.Reader<F.Schema>,registry:Sy.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>) -> (Ev.Reader<F.Schema> & Sy.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>) & ReaderView:
  match reader registry:
    case Ev.Reader{+namespace,+id,+expected}, Sy.Registry{+actual,+registryId,+name,+access,+cursor}: ((Ev.Reader{namespace,id,expected},Sy.Registry{actual,registryId,name,access,cursor}),ReaderView{namespace,id,expected,actual,registryId,name,access,cursor})
def assembled(label:String,rt:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32> & RuntimeView,fast:(Ev.Reader<F.Schema> & Sy.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>) & ReaderView,slow:(Ev.Reader<F.Schema> & Sy.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>) & ReaderView,+reads:List<&2,F.View>,retired:List<Log.Row<P.Payload>> & List<&2,RowView>,refused:List<Log.Row<P.Payload>> & List<&2,RowView>,+errors:List<&2,Log.Refusal>,+ok:Bool) -> F.Host & Snapshot:
  match rt fast slow retired refused:
    case (runtime,a), ((fast,fastReg),b), ((slow,slowReg),c), (retired,d), (refused,e): (F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok},Snapshot{label,a,b,c,reads,d,e,errors,ok})
def snapshot(label:String,owner:F.Host) -> F.Host & Snapshot:
  match owner:
    case F.Host{rt,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}: assembled(label,runtime_view(rt),reader(fast,fastReg),reader(slow,slowReg),reads,rows_view(retired),rows_view(refused),errors,ok)
