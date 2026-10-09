import Base
import ./second-owner.bend as B
import ./observation.bend as O
import ./immediate.bend as Immediate
import ./owned-journal.bend as Journal
import ../full-assembly-v1/request.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity

def Receipt() -> Type:Journal.Receipt<B.World(),Request.Packet<B.Owner>,B.Recovery()>
def Tx() -> Type:T.Tx<B.World(),Unit>
def Spawned() -> Type:Tx() & (Result<&2,&2,W.WorldError,W.Handle<Unit>> & (Maybe<&1,Request.Packet<B.Owner>> & (Maybe<&1,Receipt()> & Maybe<&1,Journal.Pending<B.Recovery()>>)))
type PacketView is Data:PacketView{owner:Maybe<&2,O.PayloadView>,original:D.Raw,canonical:D.Raw}
type State is Type:State{owners:List<Request.Packet<B.Owner>>,pending:List<Journal.Pending<B.Recovery()>>,during:Maybe<&2,O.Snapshot>}
type StateView is Data:StateView{owners:List<&2,PacketView>,pending:Nat,during:Maybe<&2,O.Snapshot>}
type Report is Data:CreationRejected{} Report{before:O.Snapshot,after:O.Snapshot,local:StateView,result:Result<&2,&2,Unit,Unit>}
def first(+value:U32) -> First.Owner:First.Owner{D.Number{value},ANode{ALeaf{value},ALeaf{U32.add(value,1)}}}
def second(+value:U32) -> B.Owner:B.Owner{D.Number{value},ANode{ALeaf{value},ALeaf{U32.add(value,10)}},ANode{ALeaf{True{}},ALeaf{False{}}}}
def packet(+value:U32) -> Request.Packet<B.Owner>:Request.Packet{Some{second(value)},D.Number{value},D.Number{value}}
def packet_view_done(+original:D.Raw,+canonical:D.Raw,result:Maybe<&1,B.Owner> & Maybe<&2,O.PayloadView>) -> Request.Packet<B.Owner> & PacketView:
  match result:
    case (owner,view):(Request.Packet{owner,original,canonical},PacketView{view,original,canonical})
def packet_view(value:Request.Packet<B.Owner>) -> Request.Packet<B.Owner> & PacketView:
  match value:
    case Request.Packet{owner,original,canonical}:packet_view_done(original,canonical,O.option(owner))
def packet_views_join(head:Request.Packet<B.Owner> & PacketView,tail:List<Request.Packet<B.Owner>> & List<&2,PacketView>) -> List<Request.Packet<B.Owner>> & List<&2,PacketView>:
  match head tail:
    case (owner,a),(rest,b):(owner <> rest,a <> b)
def packet_views(values:List<Request.Packet<B.Owner>>) -> List<Request.Packet<B.Owner>> & List<&2,PacketView>:
  match values:
    case []:([],[])
    case head <> rest:packet_views_join(packet_view(head),packet_views(rest))
def pending_join(head:Journal.Pending<B.Recovery()>,result:List<Journal.Pending<B.Recovery()>> & Nat) -> List<Journal.Pending<B.Recovery()>> & Nat:
  match result:
    case (rest,count):(head <> rest,1n+count)
def pending_count(values:List<Journal.Pending<B.Recovery()>>) -> List<Journal.Pending<B.Recovery()>> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_join(head,pending_count(rest))
def state_join(+during:Maybe<&2,O.Snapshot>,owners:List<Request.Packet<B.Owner>> & List<&2,PacketView>,pending:List<Journal.Pending<B.Recovery()>> & Nat) -> State & StateView:
  match owners pending:
    case (owners,views),(pending,count):(State{owners,pending,during},StateView{views,count,during})
def state_view(state:State) -> State & StateView:
  match state:
    case State{owners,pending,+during}:state_join(during,packet_views(owners),pending_count(pending))
def aborted(+during:O.Snapshot,result:Journal.Returned<B.World(),Request.Packet<B.Owner>,B.Recovery()>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case Journal.Returned{world,owners,pending}:Local.Failed{world,State{owners,pending,Some{during}},Unit{}}
def snap_abort(receipts:List<Receipt()>,undo:List<(B.World() -> B.World())>,commands:List<(B.World() -> B.World())>,events:List<&2,Unit>,result:B.World() & O.Snapshot) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (world,during):aborted(during,Journal.abort(~B.World(),~Unit,~Request.Packet<B.Owner>,~B.Recovery(),receipts,T.Tx{world,undo,commands,events}))
def finish(receipts:List<Receipt()>,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match tx:
    case T.Tx{world,undo,commands,events}:snap_abort(receipts,undo,commands,events,O.snapshot(world))
def rejected_owner(packet:Maybe<&1,Request.Packet<B.Owner>>,pending:Maybe<&1,Journal.Pending<B.Recovery()>>,result:Local.Outcome<B.World(),State,Unit,Unit>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match packet pending result:
    case None{} None{} result:result
    case Some{owner} None{} Local.Failed{world,State{owners,pending,during},error}:Local.Failed{world,State{owner <> owners,pending,during},error}
    case None{} Some{owner} Local.Failed{world,State{owners,pending,during},error}:Local.Failed{world,State{owners,owner <> pending,during},error}
    case Some{owner} Some{recovery} Local.Failed{world,State{owners,pending,during},error}:Local.Failed{world,State{owner <> owners,recovery <> pending,during},error}
    case Some{owner} None{} Local.Succeeded{world,State{owners,pending,during},output}:Local.Succeeded{world,State{owner <> owners,pending,during},output}
    case None{} Some{owner} Local.Succeeded{world,State{owners,pending,during},output}:Local.Succeeded{world,State{owners,owner <> pending,during},output}
    case Some{owner} Some{recovery} Local.Succeeded{world,State{owners,pending,during},output}:Local.Succeeded{world,State{owner <> owners,recovery <> pending,during},output}
def rejected_spawn(receipts:List<Receipt()>,result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(_,(owner,(None{},pending)))):rejected_owner(owner,pending,finish(receipts,tx))
    case (tx,(_,(owner,(Some{receipt},pending)))):rejected_owner(owner,pending,finish(receipt <> receipts,tx))
def second_spawn(receipts:List<Receipt()>,result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(Done{_},(None{},(Some{receipt},None{})))):finish(receipt <> receipts,Resource.tx_replace(~Unit,~B.Store(),~First.Owner,~Unit,tx,first(300)))
    case result:rejected_spawn(receipts,result)
def written(receipts:List<Receipt()>,result:C.SetResult<Tx(),B.Owner>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case C.Written{tx}:second_spawn(receipts,Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,tx,packet(22)))
    case C.WriteRejected{tx,_,_}:finish(receipts,tx)
    case C.WriteFailure{tx,_}:finish(receipts,tx)
def first_spawn(result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(Done{+target},(None{},(Some{receipt},None{})))):written([receipt],C.tx_set(~Unit,~B.Store(),~First.Owner,~Unit,~Unit,~B.Owner,~D.Raw,~Unit,~B.take,~B.put,~B.project,B.family(),tx,target,second(99)))
    case result:rejected_spawn([],result)
def runner(world:B.World(),state:State,args:Unit) -> Local.Outcome<B.World(),State,Unit,Unit>:
  first_spawn(Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,Resource.tx_replace(~Unit,~B.Store(),~First.Owner,~Unit,T.begin(~B.World(),~Unit,world),first(200)),packet(11)))
def Instance() -> Type:Local.Instance<Unit,B.Store(),First.Owner,Unit,State,Unit,Unit,Unit,runner>
def report(+before:O.Snapshot,+result:Result<&2,&2,Unit,Unit>,observed:B.World() & O.Snapshot,local:Instance() & StateView) -> Report:
  match observed local:
    case (_,after),(_,view):Report{before,after,view,result}
def status(result:Result<&2,&1,Unit,Unit>) -> Result<&2,&2,Unit,Unit>:
  match result:
    case Done{value}:Done{value}
    case Fail{error}:Fail{error}
def ran(+before:O.Snapshot,result:Local.Run<Unit,B.Store(),First.Owner,Unit,State,Unit,Unit,Unit,runner>) -> Report:
  match result:
    case Local.Completed{world,instance,result}:report(before,status(result),O.snapshot(world),Local.observe(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Unit,~Unit,~Unit,~runner,~StateView,~state_view,instance))
    case Local.Refused{world,instance,_}:report(before,Fail{Unit{}},O.snapshot(world),Local.observe(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Unit,~Unit,~Unit,~runner,~StateView,~state_view,instance))
def before(instance:Instance(),result:B.World() & O.Snapshot) -> Report:
  match result:
    case (world,+view):ran(view,Local.run(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Unit,~Unit,~Unit,~runner,instance,world,Unit{}))
def rejected(result:B.World() & O.Snapshot) -> Report:
  match result:
    case (_,+view):Report{view,view,StateView{[],0n,None{}},Fail{Unit{}}}
def registered(result:Local.Registered<Unit,B.Store(),First.Owner,Unit,State,Unit,Unit,Unit,runner>) -> Report:
  match result:
    case Local.Registered{world,instance}:before(instance,O.snapshot(world))
    case Local.RegistrationRejected{world,_}:rejected(O.snapshot(world))
def created(result:W.Creation<Unit,B.Store(),First.Owner,Unit>) -> Report:
  match result:
    case W.Created{_,world}:registered(Local.register(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Unit,~Unit,~Unit,~runner,world,"immediate-recovery",[Identity.key(~Unit,~B.Owner,B.identity()),Identity.key(~Unit,~First.Owner,Identity.component(~Unit,~First.Owner,"decoded-resource"))],State{[],[],None{}}))
    case W.CreateRejected{_,_}:CreationRejected{}
def main() -> Report:created(W.create(~Unit,~B.Store(),~First.Owner,~Unit,~B.empty,W.factory(),first(100)))
