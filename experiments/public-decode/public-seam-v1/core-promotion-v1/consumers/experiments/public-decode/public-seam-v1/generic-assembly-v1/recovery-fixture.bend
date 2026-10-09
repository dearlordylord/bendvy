import Base
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import ../../typed.bend as OldD
import ./second-owner.bend as B
import ./observation.bend as O
import ../../../../../library/decode-immediate.bend as Immediate
import ../../../../../library/decode-owned-journal.bend as Journal
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as ComponentInstall
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Lifecycle
import ../../../../../library/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import ../../../../../dependencies/snapshot/decode-data.bend as D
import ../../complete-v1/controls.bend as First
import ../../../../../dependencies/snapshot/ordinary-declaration.bend as Identity

type Mode is Data:Interleaved{} EqualPosition{} PendingControl{} Success{} ReserveRefused{} InstallRefused{} ActivationRefused{}
type Candidate is Data:Candidate{interleaved:Report,equalPosition:Report,pending:Report,success:Report,reserveRefused:Report,installRefused:Report,activationRefused:Report}
def Receipt() -> Type:Journal.Receipt<B.World(),Request.Packet<B.Owner>,B.Recovery()>
def Tx() -> Type:T.Tx<B.World(),Unit>
def Spawned() -> Type:Tx() & (Result<&2,&2,W.WorldError,W.Handle<Unit>> & (Maybe<&1,Request.Packet<B.Owner>> & (Maybe<&1,Receipt()> & Maybe<&1,Journal.Pending<B.Recovery()>>)))
type PacketView is Data:PacketView{owner:Maybe<&2,O.PayloadView>,original:D.Raw,canonical:D.Raw}
type State is Type:State{owners:List<Request.Packet<B.Owner>>,pending:List<Journal.Pending<B.Recovery()>>,during:Maybe<&2,O.Snapshot>,errors:List<&2,W.WorldError>}
type PendingView is Data:PendingView{target:W.Handle<Unit>,owner:Maybe<&2,O.PayloadView>,stamp:Lifecycle.Stamp,error:W.WorldError}
type StateView is Data:StateView{owners:List<&2,PacketView>,pending:List<&2,PendingView>,during:Maybe<&2,O.Snapshot>,errors:List<&2,W.WorldError>}
type Report is Data:CreationRejected{} Report{before:O.Snapshot,after:O.Snapshot,local:StateView,result:Result<&2,&2,Unit,Unit>}
def first(+value:U32) -> First.Owner:First.Owner{OldD.Number{value},ANode{ALeaf{value},ALeaf{U32.add(value,1)}}}
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
def pending_view_join(+target:W.Handle<Unit>,+stamp:Lifecycle.Stamp,+error:W.WorldError,result:Maybe<&1,B.Owner> & Maybe<&2,O.PayloadView>) -> Journal.Pending<B.Recovery()> & PendingView:
  match result:
    case (owner,view):(Journal.Pending{ComponentInstall.Recovery{ComponentInstall.Entry{target,owner},stamp},error},PendingView{target,view,stamp,error})
def pending_view(value:Journal.Pending<B.Recovery()>) -> Journal.Pending<B.Recovery()> & PendingView:
  match value:
    case Journal.Pending{ComponentInstall.Recovery{ComponentInstall.Entry{target,owner},stamp},error}:pending_view_join(target,stamp,error,O.option(owner))
def pending_join(head:Journal.Pending<B.Recovery()> & PendingView,tail:List<Journal.Pending<B.Recovery()>> & List<&2,PendingView>) -> List<Journal.Pending<B.Recovery()>> & List<&2,PendingView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def pending_views(values:List<Journal.Pending<B.Recovery()>>) -> List<Journal.Pending<B.Recovery()>> & List<&2,PendingView>:
  match values:
    case []:([],[])
    case head <> rest:pending_join(pending_view(head),pending_views(rest))
def state_join(+during:Maybe<&2,O.Snapshot>,+errors:List<&2,W.WorldError>,owners:List<Request.Packet<B.Owner>> & List<&2,PacketView>,pending:List<Journal.Pending<B.Recovery()>> & List<&2,PendingView>) -> State & StateView:
  match owners pending:
    case (owners,views),(pending,recoveries):(State{owners,pending,during,errors},StateView{views,recoveries,during,errors})
def state_view(state:State) -> State & StateView:
  match state:
    case State{owners,pending,+during,+errors}:state_join(during,errors,packet_views(owners),pending_views(pending))
def aborted(+during:O.Snapshot,result:Journal.Returned<B.World(),Request.Packet<B.Owner>,B.Recovery()>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case Journal.Returned{world,owners,pending}:Local.Failed{world,State{owners,pending,Some{during},[]},Unit{}}
def commit_result(during:O.Snapshot,result:T.Returned<B.World(),Unit>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case T.Returned{world,T.Success{}}:Local.Succeeded{world,State{[],[],Some{during},[]},Unit{}}
    case T.Returned{world,T.Failure{error}}:Local.Failed{world,State{[],[],Some{during},[]},error}
def snap_finished(mode:Mode,during:O.Snapshot,receipts:List<Receipt()>,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match mode:
    case Success{}:commit_result(during,Commands.tx_finish(~Unit,~B.Store(),~First.Owner,~Unit,~Unit,tx,T.Success{}))
    case _:aborted(during,Journal.abort(~B.World(),~Unit,~Request.Packet<B.Owner>,~B.Recovery(),receipts,tx))
def snap_abort(+mode:Mode,receipts:List<Receipt()>,undo:List<(B.World() -> B.World())>,commands:List<(B.World() -> B.World())>,events:List<&2,Unit>,result:B.World() & O.Snapshot) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (world,during):snap_finished(mode,during,receipts,T.Tx{world,undo,commands,events})

def finish(+mode:Mode,receipts:List<Receipt()>,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match tx:
    case T.Tx{world,undo,commands,events}:snap_abort(mode,receipts,undo,commands,events,O.snapshot(world))
def rejected_owner(packet:Maybe<&1,Request.Packet<B.Owner>>,pending:Maybe<&1,Journal.Pending<B.Recovery()>>,result:Local.Outcome<B.World(),State,Unit,Unit>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match packet pending result:
    case None{} None{} result:result
    case Some{owner} None{} Local.Failed{world,State{owners,pending,during,errors},error}:Local.Failed{world,State{owner <> owners,pending,during,errors},error}
    case None{} Some{owner} Local.Failed{world,State{owners,pending,during,errors},error}:Local.Failed{world,State{owners,owner <> pending,during,errors},error}
    case Some{owner} Some{recovery} Local.Failed{world,State{owners,pending,during,errors},error}:Local.Failed{world,State{owner <> owners,recovery <> pending,during,errors},error}
    case Some{owner} None{} Local.Succeeded{world,State{owners,pending,during,errors},output}:Local.Succeeded{world,State{owner <> owners,pending,during,errors},output}
    case None{} Some{owner} Local.Succeeded{world,State{owners,pending,during,errors},output}:Local.Succeeded{world,State{owners,owner <> pending,during,errors},output}
    case Some{owner} Some{recovery} Local.Succeeded{world,State{owners,pending,during,errors},output}:Local.Succeeded{world,State{owner <> owners,recovery <> pending,during,errors},output}
def rejected_error(error:W.WorldError,result:Local.Outcome<B.World(),State,Unit,Unit>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case Local.Failed{world,State{owners,pending,during,errors},failed}:Local.Failed{world,State{owners,pending,during,error <> errors},failed}
    case Local.Succeeded{world,State{owners,pending,during,errors},output}:Local.Succeeded{world,State{owners,pending,during,error <> errors},output}
def rejected_status(status:Result<&2,&2,W.WorldError,W.Handle<Unit>>,result:Local.Outcome<B.World(),State,Unit,Unit>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match status:
    case Done{_}:result
    case Fail{error}:rejected_error(error,result)
def rejected_spawn(+mode:Mode,receipts:List<Receipt()>,result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(status,(owner,(None{},pending)))):rejected_status(status,rejected_owner(owner,pending,finish(mode,receipts,tx)))
    case (tx,(status,(owner,(Some{receipt},pending)))):rejected_status(status,rejected_owner(owner,pending,finish(mode,receipt <> receipts,tx)))
def inactive(mode:Mode,receipts:List<Receipt()>,undo:List<(B.World() -> B.World())>,commands:List<(B.World() -> B.World())>,events:List<&2,Unit>,result:B.World() & W.Status) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (world,_):finish(mode,receipts,T.Tx{world,undo,commands,events})
def after_second(+mode:Mode,+target:W.Handle<Unit>,receipts:List<Receipt()>,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match mode tx:
    case PendingControl{} T.Tx{world,undo,commands,events}:inactive(mode,receipts,undo,commands,events,W.deactivate(~Unit,~B.Store(),~First.Owner,~Unit,world,target))
    case _ tx:finish(mode,receipts,tx)
def second_spawn(+mode:Mode,receipts:List<Receipt()>,result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(Done{target},(None{},(Some{receipt},None{})))):after_second(mode,target,receipt <> receipts,Resource.tx_replace(~Unit,~B.Store(),~First.Owner,~Unit,tx,first(300)))
    case result:rejected_spawn(mode,receipts,result)
def written_refused(+mode:Mode,receipts:List<Receipt()>,tx:Tx(),error:W.WorldError,result:B.Owner & D.Raw) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (owner,+raw):rejected_error(error,rejected_owner(Some{Request.Packet{Some{owner},raw,raw}},None{},finish(mode,receipts,tx)))
def written(+mode:Mode,receipts:List<Receipt()>,result:C.SetResult<Tx(),B.Owner>) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case C.Written{tx}:second_spawn(mode,receipts,Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,tx,packet(22)))
    case C.WriteRejected{tx,owner,error}:written_refused(mode,receipts,tx,error,B.project(owner))
    case C.WriteFailure{tx,error}:rejected_error(error,finish(mode,receipts,tx))
def first_accepted(+mode:Mode,receipt:Receipt(),target:W.Handle<Unit>,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match mode:
    case EqualPosition{}:second_spawn(mode,[receipt],Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,tx,packet(22)))
    case _:written(mode,[receipt],C.tx_set(~Unit,~B.Store(),~First.Owner,~Unit,~Unit,~B.Owner,~D.Raw,~Unit,~B.take,~B.put,~B.project,B.family(),tx,target,second(99)))
def first_spawn(+mode:Mode,result:Spawned()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match result:
    case (tx,(Done{+target},(None{},(Some{receipt},None{})))):first_accepted(mode,receipt,target,tx)
    case result:rejected_spawn(mode,[],result)

def reject_install(world:B.World(),target:W.Handle<Unit>,packet:Request.Packet<B.Owner>) -> Install.Attempt<B.World(),Request.Packet<B.Owner>,B.Recovery()>:
  Install.Refused{world,packet,W.MissingEntity{}}
def exhausted(world:B.World()) -> B.World():
  match world:
    case W.World{namespace,_,high,live,capacity,depth,store,resource,events,commands,registrations,system,clock}:W.World{namespace,131073,high,live,capacity,depth,store,resource,events,commands,registrations,system,clock}
def activation_refused(tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match tx:
    case T.Tx{world,undo,commands,events}:rejected_spawn(ActivationRefused{},[],Immediate.activated(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,W.Handle{0,1},packet(11),undo,commands,events,W.activate(~Unit,~B.Store(),~First.Owner,~Unit,world,W.Handle{0,1})))
def start(+mode:Mode,tx:Tx()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match mode:
    case InstallRefused{}:first_spawn(mode,Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~reject_install,tx,packet(11)))
    case ActivationRefused{}:activation_refused(tx)
    case _:first_spawn(mode,Immediate.spawn(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.install,tx,packet(11)))
def selected_world(+mode:Mode,world:B.World()) -> Local.Outcome<B.World(),State,Unit,Unit>:
  match mode:
    case ReserveRefused{}:start(mode,Resource.tx_replace(~Unit,~B.Store(),~First.Owner,~Unit,T.begin(~B.World(),~Unit,world),first(200)))
    case _:start(mode,Resource.tx_replace(~Unit,~B.Store(),~First.Owner,~Unit,T.begin(~B.World(),~Unit,world),first(200)))
def runner(world:B.World(),state:State,args:Mode) -> Local.Outcome<B.World(),State,Unit,Unit>:
  selected_world(args,world)
def Instance() -> Type:Local.Instance<Unit,B.Store(),First.Owner,Unit,State,Mode,Unit,Unit,runner>
def report(+before:O.Snapshot,+result:Result<&2,&2,Unit,Unit>,observed:B.World() & O.Snapshot,local:Instance() & StateView) -> Report:
  match observed local:
    case (_,after),(_,view):Report{before,after,view,result}
def status(result:Result<&2,&1,Unit,Unit>) -> Result<&2,&2,Unit,Unit>:
  match result:
    case Done{value}:Done{value}
    case Fail{error}:Fail{error}
def ran(+before:O.Snapshot,result:Local.Run<Unit,B.Store(),First.Owner,Unit,State,Mode,Unit,Unit,runner>) -> Report:
  match result:
    case Local.Completed{world,instance,result}:report(before,status(result),O.snapshot(world),Local.observe(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Mode,~Unit,~Unit,~runner,~StateView,~state_view,instance))
    case Local.Refused{world,instance,_}:report(before,Fail{Unit{}},O.snapshot(world),Local.observe(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Mode,~Unit,~Unit,~runner,~StateView,~state_view,instance))
def before(mode:Mode,instance:Instance(),result:B.World() & O.Snapshot) -> Report:
  match result:
    case (world,+view):ran(view,Local.run(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Mode,~Unit,~Unit,~runner,instance,world,mode))
def rejected(result:B.World() & O.Snapshot) -> Report:
  match result:
    case (_,+view):Report{view,view,StateView{[],[],None{},[]},Fail{Unit{}}}
def registered(mode:Mode,result:Local.Registered<Unit,B.Store(),First.Owner,Unit,State,Mode,Unit,Unit,runner>) -> Report:
  match result:
    case Local.Registered{world,instance}:before(mode,instance,O.snapshot(world))
    case Local.RegistrationRejected{world,_}:rejected(O.snapshot(world))
def provisioned(mode:Mode,world:B.World()) -> Report:
  registered(mode,Local.register(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Mode,~Unit,~Unit,~runner,world,"immediate-recovery",[Identity.key(~Unit,~B.Owner,B.identity()),Identity.key(~Unit,~First.Owner,Identity.component(~Unit,~First.Owner,"decoded-resource"))],State{[],[],None{},[]}))
def setup(+mode:Mode,world:B.World()) -> Report:
  match mode:
    case ReserveRefused{}:provisioned(mode,exhausted(world))
    case _:provisioned(mode,world)
def created(mode:Mode,result:W.Creation<Unit,B.Store(),First.Owner,Unit>) -> Report:
  match result:
    case W.Created{_,world}:setup(mode,world)
    case W.CreateRejected{_,_}:CreationRejected{}
def run(mode:Mode) -> Report:created(mode,W.create(~Unit,~B.Store(),~First.Owner,~Unit,~B.empty,W.factory(),first(100)))

def main() -> Candidate:Candidate{run(Interleaved{}),run(EqualPosition{}),run(PendingControl{}),run(Success{}),run(ReserveRefused{}),run(InstallRefused{}),run(ActivationRefused{})}
