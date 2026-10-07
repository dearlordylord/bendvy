import Base
import trace-force.bend as Force
import trace-value.bend as J
import trace-rows.bend as Rows
import trace-public.bend as Public
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-providers.bend as P
import ../../../../src/ecs/relation-reorder.bend as R
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as X
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/capabilities.bend as Cap
import ../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../../../../src/ecs/relation-query.bend as RQ
import trace-query.bend as Q
import ../../promotion-stage/application/next-version/v1/cleanup-client.bend as C

# Authored clients have only their declared abstract capabilities.
def relate_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)

def unrelate_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  match caps args:
    case P.Writable{_,_,Cap.Request{remove}} P.Targets{source,_}: remove(owner,source)

def reorder_body(~S:Data,-H:Type,caps:R.Writable<H,S>,args:R.Args<S>,owner:H) -> H & A.QueueStatus:
  match caps:
    case R.Writable{Cap.Request{request}}: request(owner,args)

def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{3,"Parent","Children"}

def discard(~S:Data,observed:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = observed
  tx

def component_done(~S:Data,result:Cmp.SetResult<X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,O.Payload>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match result:
    case Cmp.Written{tx}: (tx,True{})
    case Cmp.WriteRejected{tx,_,_}: (tx,False{})
    case Cmp.WriteFailure{tx,_}: (tx,False{})

def component_body(-H:Type,caps:Cap.Request<H,O.Payload,Bool>,owner:H,incoming:O.Payload) -> H & Bool:
  match caps:
    case Cap.Request{set}: set(owner,incoming)

def component_join(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = result
  tx




def descriptors(~S:Data) -> List<&2,G.Descriptor<S>>:
  [Q.link(~S),Q.other(~S),R.descriptor(~S,hierarchy(~S))]

def relate(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,source:U32,target:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~descriptor,~A.QueueStatus,~relate_body(~S),P.Targets{W.Handle{1,source},W.Handle{1,target}},tx))

def unrelate(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,source:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~descriptor,~A.QueueStatus,~unrelate_body(~S),P.Targets{W.Handle{1,source},W.Handle{1,0}},tx))

def reorder(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,R.invoke(~S,~O.Components<S>,~U32,~U32,~hierarchy(~S),~A.QueueStatus,~reorder_body(~S),R.Args{W.Handle{1,1},[W.Handle{1,3},W.Handle{1,2}]},tx))

def component_server(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,incoming:O.Payload) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  component_done(~S,Cmp.tx_set(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.Rest<S>,~O.Payload,~List<&2,U32>,~Q.Token<S>,~Q.take(~S),~Q.put(~S),~O.project_payload,Q.family(~S),tx,W.Handle{1,3},incoming))




# Matched writer traverses actual component membership before/after the one mutation.
def scan_tail_join(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Cmp.Access<List<&2,U32>>,next:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match result:
    case (tx,Cmp.Found{_}):next(tx)
    case (tx,Cmp.ComponentAbsent{}):next(tx)
    case (tx,_):(tx,False{})
def scan_tail(~S:Data,handles:List<&2,W.Handle<S>>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match handles:
    case []:(tx,True{})
    case handle <> rest:scan_tail_join(~S,Cmp.tx_get(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.Rest<S>,~O.Payload,~List<&2,U32>,~Q.Token<S>,~Q.take(~S),~Q.put(~S),~O.project_payload,Q.family(~S),tx,handle),tx => scan_tail(~S,rest,tx))
def scan_written(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool,rest:List<&2,W.Handle<S>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match result:
    case (tx,True{}):scan_tail(~S,rest,tx)
    case (tx,False{}):(tx,False{})
def scan_found(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Cmp.Access<List<&2,U32>>,id:U32,incoming:O.Payload,rest:List<&2,W.Handle<S>>,next:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> -> O.Payload -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match result id:
    case (tx,Cmp.Found{_}) 3:scan_written(~S,component_server(~S,tx,incoming),rest)
    case (tx,Cmp.Found{_}) _:next(tx,incoming)
    case (tx,Cmp.ComponentAbsent{}) _:next(tx,incoming)
    case (tx,_) _:(tx,False{})
def scan_write(~S:Data,handles:List<&2,W.Handle<S>>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,incoming:O.Payload) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match handles:
    case []:(tx,False{})
    case W.Handle{+namespace,+id} <> +rest:scan_found(~S,Cmp.tx_get(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.Rest<S>,~O.Payload,~List<&2,U32>,~Q.Token<S>,~Q.take(~S),~Q.put(~S),~O.project_payload,Q.family(~S),tx,W.Handle{namespace,id}),id,incoming,rest,tx => incoming => scan_write(~S,rest,tx,incoming))
def scan_handles(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,W.Handle<S>>,undo:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,commands:List<(W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>)>,events:List<&2,A.Notice<S,U32>>,incoming:O.Payload) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  (world,handles) = result
  scan_write(~S,handles,X.Tx{world,undo,commands,events},incoming)
def component_matched(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,incoming:O.Payload) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match tx:
    case X.Tx{world,undo,commands,events}:scan_handles(~S,W.handles(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),undo,commands,events,incoming)

def component_write(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  component_join(~S,component_body(X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,Cap.Request{component_matched(~S)},tx,O.Payload{ANode{ANode{ALeaf{130},ALeaf{131}},ANode{ALeaf{132},ALeaf{133}}},3300}))


def spawned(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & W.Reservation<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match result:
    case (tx,W.Reserved{handle}): discard(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~Q.link(~S),~A.QueueStatus,~relate_body(~S),P.Targets{W.Handle{1,5},handle},tx))
    case (tx,W.ReservationRejected{_}): tx

def spawn_payload(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,_:W.Handle<S>,_:Unit) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  world

def future(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  spawned(~S,Cmd.tx_spawn(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~spawn_payload(~S),tx,Unit{}))

def operations(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,phase:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match phase:
    case 0: relate(~S,~R.descriptor(~S,hierarchy(~S)),relate(~S,~R.descriptor(~S,hierarchy(~S)),relate(~S,~R.descriptor(~S,hierarchy(~S)),tx,2,1),3,1),4,3)
    case 1: relate(~S,~Q.link(~S),unrelate(~S,~Q.other(~S),relate(~S,~Q.link(~S),component_write(~S,tx),3,2),4),2,2)
    case 2: reorder(~S,tx)
    case 6: future(~S,tx)
    case 3: discard(~S,C.invoked(~S,~descriptors(~S),tx,W.Handle{1,3}))
    case _: discard(~S,C.invoked(~S,~descriptors(~S),tx,W.Handle{1,1}))


def failure_operations(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  relate(~S,~Q.other(~S),component_join(~S,component_body(X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,Cap.Request{component_matched(~S)},tx,O.Payload{ANode{ANode{ALeaf{230},ALeaf{231}},ANode{ALeaf{232},ALeaf{233}}},9000})),5,1)

def write_runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,phase:U32) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  match phase:
    case 5: Sys.Failed{O.commit(~S,failure_operations(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world)),X.Failure{903}),903}
    case rest: Sys.Succeeded{O.commit(~S,operations(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),rest),X.Success{}),Unit{}}

def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,U32,U32,Unit,write_runner(~S)>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,_}}: (world,None{})
    case Sys.Completed{_,Sys.Failed{world,error}}: (world,Some{error})
    case Sys.RegistrationRejected{_,world,_}: (world,Some{999})

def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,U32,U32,Unit,write_runner(~S)>,phase:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  match result:
    case Sys.Registered{world,registry}: ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~U32,~U32,~Unit,~write_runner(~S),registry,world,phase))
    case Sys.RegistrationFailed{world}: (world,Some{999})

def write(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+phase:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~U32,~U32,~Unit,~write_runner(~S),world,"relation-write-" ++ U32.show(phase),["Link.write","OtherLink.write","Parent.write","Children.write","Payload.write"]),phase)








# No timer: qualify complete immutable public trace before adding a forcing boundary.
def record_notices(~S:Data,result:List<&2,J.Value> & (List<&2,J.Value> & List<&2,J.Value>),world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,root:String,name:String,rows:List<&2,J.Field>,graphs:List<&2,J.Value>,retained:J.Value,status:Maybe<&2,U32>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  (failures,(removed,despawned)) = result
  (world,J.Object{[J.Field{"root",J.Text{root}},J.Field{"phase",J.Text{name}},J.Field{"rows",J.Object{rows}},J.Field{"graphs",J.Items{graphs}},J.Field{"failures",J.Items{failures}},J.Field{"removed",J.Items{removed}},J.Field{"despawned",J.Items{despawned}},J.Field{"retained",retained},J.Field{"systemResult",Public.status(status)}]})
def record_events(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,A.Notice<S,U32>>,root:String,name:String,rows:List<&2,J.Field>,graphs:List<&2,J.Value>,retained:J.Value,status:Maybe<&2,U32>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  (world,events) = result
  record_notices(~S,Public.notices(~S,events),world,root,name,rows,graphs,retained,status)
def record_graphs(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,root:String,name:String,rows:List<&2,J.Field>,retained:J.Value,status:Maybe<&2,U32>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  (world,graphs) = result
  record_events(~S,W.events_view(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),root,name,rows,graphs,retained,status)
def record_rows(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Field>,root:String,name:String,retained:J.Value,status:Maybe<&2,U32>,count:Nat) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  (world,rows) = result
  record_graphs(~S,Public.graphs(~S,descriptors(~S),world,count),root,name,rows,retained,status)
def observed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,root:String,+name:String,retained:J.Value,status:Maybe<&2,U32>,count:Nat) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  record_rows(~S,Q.registered_world(~S,world,"query-" ++ name),root,name,retained,status,count)
def appended(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,record) = result
  (world,List.append(&2,J.Value,records,[record]))
def queued(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,+root:String,+phase:U32,+retained:J.Value,count:Nat,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,record) = result
  appended(~S,observed(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),root,"applied-" ++ U32.show(phase),retained,None{},count),List.append(&2,J.Value,records,[record]))
def written(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>,+root:String,+phase:U32,+retained:J.Value,+count:Nat,records:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,status) = result
  queued(~S,observed(~S,world,root,"queued-" ++ U32.show(phase),retained,status,count),root,phase,retained,count,records)
def step(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,root:String,+phase:U32,retained:J.Value,count:Nat) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,records) = result
  written(~S,write(~S,world,phase),root,phase,retained,count,records)
def finished(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,root:String) -> J.Value:
  (_,records) = result
  J.Object{[J.Field{"root",J.Text{root}},J.Field{"records",J.Items{records}}]}
def start(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+root:String,+retained:J.Value) -> J.Value:
  finished(~S,step(~S,step(~S,step(~S,step(~S,step(~S,step(~S,step(~S,appended(~S,observed(~S,world,root,"initial",retained,None{},5n),[]),root,0,retained,5n),root,1,retained,5n),root,2,retained,5n),root,5,retained,5n),root,6,retained,6n),root,3,retained,6n),root,4,retained,6n),root)
def captured(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,RQ.Row<S,List<&2,U32>>>,+root:String) -> J.Value:
  (world,rows) = result
  start(~S,world,root,J.Items{Rows.rows(~S,rows)})
def capture_rows(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,root:String) -> J.Value:
  captured(~S,RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~Q.spec_optional(~S),~Q.component_selected(~S),~Q.read_body(~S),world),root)
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,root:String) -> J.Value:
  match result:
    case W.Created{_,world}:capture_rows(~S,Q.seeded(~S,O.spawn(~S,5n,world)),root)
    case _:J.Text{"CREATE_REJECTED"}
def run(~S:Data,root:String) -> J.Value:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.empty(~S),W.factory(),77),root)
def trace() -> J.Value:
  J.Items{[run(~O.Workshop,"Workshop"),run(~O.Other,"Other")]}
def main() -> IO(Unit):
  IO.print(J.encode(trace()))
