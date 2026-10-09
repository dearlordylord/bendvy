import ../../../../../library/decode-local.bend as Completion
import Base
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import ../../../../../library/decode-frame.bend as F
import ../../../../../library/decode-traversal.bend as Traversal
import ../../../../../library/decode-declaration.bend as Declared
import ../../../../../library/decode-owned-component.bend as Write
import ../../../../../library/decode-owned-journal.bend as Journal
import ../../../../../library/decode-requests.bend as Request
import ./second-owner.bend as B
import ./observation.bend as O
import ./recovery-fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import ../../complete-v1/controls.bend as First
import ../../../../../dependencies/snapshot/decode-data.bend as D
import ../../../../../dependencies/snapshot/persistence-declaration.bend as Codec
import ../../../../../dependencies/snapshot/ordinary-declaration.bend as Identity
import ../../../../../dependencies/query/ordinary-query-declaration.bend as Clause

def Frame() -> Type:F.Frame<Unit,B.Store(),First.Owner,Unit,B.Owner,B.Recovery(),B.identity(),B.project>
def Ops(~H:Type) -> Type:Declared.Ops<Unit,B.Owner,First.Owner,D.Raw,H>
def query() -> Clause.Declaration<Unit,Query.Frame<Unit,B.Store(),First.Owner,Unit>,Cap.Write<Query.Frame<Unit,B.Store(),First.Owner,Unit>,B.Owner,D.Raw>>:
  Declared.query(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install)
def grants() -> Ops(Frame()):Declared.grants(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install)
def selector(frame:Frame()) -> Frame() & Bool:F.select(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.identity(),~B.project,~Clause.selector(~Unit,~Query.Frame<Unit,B.Store(),First.Owner,Unit>,~Cap.Write<Query.Frame<Unit,B.Store(),First.Owner,Unit>,B.Owner,D.Raw>,query()),frame)
type IncomingPair is Type:IncomingPair{first:B.Owner,second:B.Owner}
type Args is Type:Args{incoming:Maybe<&1,IncomingPair>,operations:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,fail:Bool}
type Recovery is Type:Recovery{args:Args,owners:List<Request.Packet<B.Owner>>,pending:List<Journal.Pending<B.Recovery()>>}
type State is Type:State{codec:Codec.Constructed<Unit,B.Owner,B.identity(),B.project>,recovery:List<Recovery>}
def resource_field(~H:Type,ops:Ops(~H)) -> Cap.OwnedRequest<H,First.Owner,Unit>:
  match ops:
    case Declared.Ops{_,_,_,_,cap}:cap
def spawn_field(~H:Type,ops:Ops(~H)) -> Cap.OwnedRequest<H,B.Owner,Request.Output<Unit,B.Owner>>:
  match ops:
    case Declared.Ops{_,_,cap,_,_}:cap
def write_field(~H:Type,ops:Ops(~H)) -> Cap.OwnedRequest<H,Query.Insert<Unit,B.Owner>,Write.Output<B.Owner>>:
  match ops:
    case Declared.Ops{_,cap,_,_,_}:cap
def read_field(~H:Type,ops:Ops(~H)) -> Cap.Read<H,D.Raw>:
  match ops:
    case Declared.Ops{cap,_,_,_,_}:cap
def resource(~H:Type,~ops:Ops(~H),ctx:H,value:First.Owner) -> H & Unit:Cap.owned_request(~H,~First.Owner,~Unit,~resource_field(~H,ops),ctx,value)
def spawn(~H:Type,~ops:Ops(~H),ctx:H,value:B.Owner) -> H & Request.Output<Unit,B.Owner>:Cap.owned_request(~H,~B.Owner,~Request.Output<Unit,B.Owner>,~spawn_field(~H,ops),ctx,value)
def write(~H:Type,~ops:Ops(~H),ctx:H,target:W.Handle<Unit>,value:B.Owner) -> H & Write.Output<B.Owner>:Cap.owned_request(~H,~Query.Insert<Unit,B.Owner>,~Write.Output<B.Owner>,~write_field(~H,ops),ctx,Query.Insert{target,value})
def read(~H:Type,~ops:Ops(~H),ctx:H) -> H & Cmp.Access<D.Raw>:Cap.read(~H,~D.Raw,~read_field(~H,ops),ctx)
def user_outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def write_added(written:Maybe<&1,Write.Output<B.Owner>>,previous:List<Write.Output<B.Owner>>) -> List<Write.Output<B.Owner>>:
  match written:
    case None{}:previous
    case Some{written}:written <> previous
def resource_after(~H:Type,first:Request.Output<Unit,B.Owner>,second:Request.Output<Unit,B.Owner>,written:Maybe<&1,Write.Output<B.Owner>>,previous:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,+fail:Bool,view:Cmp.Access<D.Raw>,result:H & Unit) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match result:
    case (ctx,_):(ctx,(Args{None{},second <> first <> previous,write_added(written,writes),fail},(user_outcome(fail),view)))
def spawned_second(~H:Type,~ops:Ops(~H),first:Request.Output<Unit,B.Owner>,written:Maybe<&1,Write.Output<B.Owner>>,previous:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,+fail:Bool,view:Cmp.Access<D.Raw>,result:H & Request.Output<Unit,B.Owner>) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match result:
    case (ctx,second):resource_after(~H,first,second,written,previous,writes,fail,view,resource(~H,~ops,ctx,Input.first(300)))
def written_first(~H:Type,~ops:Ops(~H),first:Request.Output<Unit,B.Owner>,second:B.Owner,previous:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,+fail:Bool,view:Cmp.Access<D.Raw>,result:H & Write.Output<B.Owner>) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match result:
    case (ctx,written):spawned_second(~H,~ops,first,Some{written},previous,writes,fail,view,spawn(~H,~ops,ctx,second))
def spawned_first(~H:Type,~ops:Ops(~H),second:B.Owner,previous:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,+fail:Bool,view:Cmp.Access<D.Raw>,result:H & Request.Output<Unit,B.Owner>) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match result:
    case (ctx,Request.Accepted{+target,+spawned,+canonical}):written_first(~H,~ops,Request.Accepted{target,spawned,canonical},second,previous,writes,fail,view,write(~H,~ops,ctx,target,Input.second(99)))
    case (ctx,first):spawned_second(~H,~ops,first,None{},previous,writes,fail,view,spawn(~H,~ops,ctx,second))
def resource_before(~H:Type,~ops:Ops(~H),first:B.Owner,second:B.Owner,previous:List<Request.Output<Unit,B.Owner>>,writes:List<Write.Output<B.Owner>>,+fail:Bool,view:Cmp.Access<D.Raw>,result:H & Unit) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match result:
    case (ctx,_):spawned_first(~H,~ops,second,previous,writes,fail,view,spawn(~H,~ops,ctx,first))
def read_before(~H:Type,~ops:Ops(~H),args:Args,result:H & Cmp.Access<D.Raw>) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  match args result:
    case Args{None{},operations,writes,fail}, (ctx,view):(ctx,(Args{None{},operations,writes,fail},(T.Success{},view)))
    case Args{Some{IncomingPair{first,second}},operations,writes,fail}, (ctx,view):resource_before(~H,~ops,first,second,operations,writes,fail,view,resource(~H,~ops,ctx,Input.first(200)))
def body(~H:Type,~ops:Ops(~H),args:Args,ctx:H) -> H & (Args & (T.Outcome<Unit> & Cmp.Access<D.Raw>)):
  read_before(~H,~ops,args,read(~H,~ops,ctx))

# The fixed consuming body above has no deferred command invocation. Its
# defensive prepared-packet branch retains every packet as app Local recovery;
# it is not a general deferred delivery implementation or acceptance claim.

def retained(local:State,args:Args,owners:List<Request.Packet<B.Owner>>,pending:List<Journal.Pending<B.Recovery()>>) -> State:
  match local:
    case State{codec,previous}:State{codec,Recovery{args,owners,pending} <> previous}
def committed_state(local:State,args:Args,rows:List<&2,Cmp.Access<D.Raw>>) -> State & (Args & List<&2,Cmp.Access<D.Raw>>):
  (local,(args,rows))
def rejected_state(local:State,args:Args) -> State:retained(local,args,[],[])
def traversed(codec:Codec.Constructed<Unit,B.Owner,B.identity(),B.project>,previous:List<Recovery>,result:Frame() & (Args & (T.Outcome<Query.Error<Unit>> & List<&2,Cmp.Access<D.Raw>>))) -> Local.Outcome<B.World(),State,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>>:
  Completion.traversal(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.identity(),~B.project,~State,~Args,~List<&2,Cmp.Access<D.Raw>>,~Query.Error<Unit>,~(Args & List<&2,Cmp.Access<D.Raw>>),~committed_state,~rejected_state,~retained,Query.UserError{Unit{}},State{codec,previous},result)
def handles(+codec:Codec.Constructed<Unit,B.Owner,B.identity(),B.project>,previous:List<Recovery>,args:Args,result:B.World() & List<&2,W.Handle<Unit>>) -> Local.Outcome<B.World(),State,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>>:
  match result:
    case (world,handles):traversed(codec,previous,Traversal.run_rows(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~Args,~Unit,~Cmp.Access<D.Raw>,~(H => Ops(~H)),~B.identity(),~B.project,~selector,~grants(),~(H => ops => args => ctx => body(~H,~ops,args,ctx)),handles,0,Completion.begin_frame(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~B.identity(),~B.project,world,codec),args,[]))
def runner(world:B.World(),state:State,args:Args) -> Local.Outcome<B.World(),State,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>>:
  match state:
    case State{codec,previous}:handles(codec,previous,args,W.handles(~Unit,~B.Store(),~First.Owner,~Unit,world))
def Instance() -> Type:Local.Instance<Unit,B.Store(),First.Owner,Unit,State,Args,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>,runner>
def define(world:B.World()) -> Local.Registered<Unit,B.Store(),First.Owner,Unit,State,Args,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>,runner>:
  Completion.registered(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Args,~Query.Error<Unit>,~(Args & List<&2,Cmp.Access<D.Raw>>),~runner,world,"declared-owned-system",Declared.access(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~Identity.component(~Unit,~First.Owner,"decoded-resource")),State{Codec.constructed(~Unit,~B.Owner,~B.identity(),~B.project,D.Integer{}),[]})

type IncomingView is Data:IncomingView{first:O.PayloadView,second:O.PayloadView}
type OperationView is Data:AcceptedView{target:W.Handle<Unit>,spawned:Bool,canonical:D.Raw} RefusedView{owner:Maybe<&2,O.PayloadView>,error:Request.Error}
type WriteView is Data:WrittenView{} WriteRefusedView{owner:Maybe<&2,O.PayloadView>,error:W.WorldError}
type ArgsView is Data:ArgsView{incoming:Maybe<&2,IncomingView>,operations:List<&2,OperationView>,writes:List<&2,WriteView>,fail:Bool}
type RecoveryView is Data:RecoveryView{args:ArgsView,owners:List<&2,Input.PacketView>,pending:List<&2,Input.PendingView>}
type StateView is Data:StateView{codec:D.Codec,recovery:List<&2,RecoveryView>}
type InstanceView is Data:InstanceView{namespace:U32,id:U32,name:String,access:List<&2,String>,state:StateView}
type ResultView is Data:CompletedView{args:ArgsView,rows:List<&2,Cmp.Access<D.Raw>>} FailedView{error:Query.Error<Unit>} RegistrationRefusedView{} FactoryRefusedView{} InvocationRefusedView{args:ArgsView} SkippedView{args:ArgsView}
type Report is Data:Report{before:O.Snapshot,after:O.Snapshot,instance:InstanceView,result:ResultView} Unavailable{result:ResultView}
type Candidate is Data:Candidate{success:Report,failure:Report,noMatch:Report,skip:Report}
def incoming_join(left:B.Owner & O.PayloadView,right:B.Owner & O.PayloadView) -> Maybe<&1,IncomingPair> & Maybe<&2,IncomingView>:
  match left right:
    case (left,a),(right,b):(Some{IncomingPair{left,right}},Some{IncomingView{a,b}})
def incoming_view(value:Maybe<&1,IncomingPair>) -> Maybe<&1,IncomingPair> & Maybe<&2,IncomingView>:
  match value:
    case None{}:(None{},None{})
    case Some{IncomingPair{first,second}}:incoming_join(O.payload(first),O.payload(second))
def operation_refused(+error:Request.Error,result:Maybe<&1,B.Owner> & Maybe<&2,O.PayloadView>) -> Request.Output<Unit,B.Owner> & OperationView:
  match result:
    case (owner,view):(Request.Refused{owner,error},RefusedView{view,error})
def operation_view(value:Request.Output<Unit,B.Owner>) -> Request.Output<Unit,B.Owner> & OperationView:
  match value:
    case Request.Accepted{+target,+spawned,+canonical}:(Request.Accepted{target,spawned,canonical},AcceptedView{target,spawned,canonical})
    case Request.Refused{owner,error}:operation_refused(error,O.option(owner))
def operations_join(head:Request.Output<Unit,B.Owner> & OperationView,tail:List<Request.Output<Unit,B.Owner>> & List<&2,OperationView>) -> List<Request.Output<Unit,B.Owner>> & List<&2,OperationView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def operations_view(values:List<Request.Output<Unit,B.Owner>>) -> List<Request.Output<Unit,B.Owner>> & List<&2,OperationView>:
  match values:
    case []:([],[])
    case head <> rest:operations_join(operation_view(head),operations_view(rest))
def write_refused(+error:W.WorldError,result:Maybe<&1,B.Owner> & Maybe<&2,O.PayloadView>) -> Write.Output<B.Owner> & WriteView:
  match result:
    case (owner,view):(Write.Refused{owner,error},WriteRefusedView{view,error})
def write_view(value:Write.Output<B.Owner>) -> Write.Output<B.Owner> & WriteView:
  match value:
    case Write.Written{}:(Write.Written{},WrittenView{})
    case Write.Refused{owner,error}:write_refused(error,O.option(owner))
def writes_join(head:Write.Output<B.Owner> & WriteView,tail:List<Write.Output<B.Owner>> & List<&2,WriteView>) -> List<Write.Output<B.Owner>> & List<&2,WriteView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def writes_view(values:List<Write.Output<B.Owner>>) -> List<Write.Output<B.Owner>> & List<&2,WriteView>:
  match values:
    case []:([],[])
    case head <> rest:writes_join(write_view(head),writes_view(rest))
def args_join(+fail:Bool,incoming:Maybe<&1,IncomingPair> & Maybe<&2,IncomingView>,operations:List<Request.Output<Unit,B.Owner>> & List<&2,OperationView>,writes:List<Write.Output<B.Owner>> & List<&2,WriteView>) -> Args & ArgsView:
  match incoming operations writes:
    case (incoming,a),(operations,b),(writes,c):(Args{incoming,operations,writes,fail},ArgsView{a,b,c,fail})
def args_view(value:Args) -> Args & ArgsView:
  match value:
    case Args{incoming,operations,writes,fail}:args_join(fail,incoming_view(incoming),operations_view(operations),writes_view(writes))
def recovery_join(args:Args & ArgsView,owners:List<Request.Packet<B.Owner>> & List<&2,Input.PacketView>,pending:List<Journal.Pending<B.Recovery()>> & List<&2,Input.PendingView>) -> Recovery & RecoveryView:
  match args owners pending:
    case (args,a),(owners,b),(pending,c):(Recovery{args,owners,pending},RecoveryView{a,b,c})
def recovery_view(value:Recovery) -> Recovery & RecoveryView:
  match value:
    case Recovery{args,owners,pending}:recovery_join(args_view(args),Input.packet_views(owners),Input.pending_views(pending))
def recoveries_join(head:Recovery & RecoveryView,tail:List<Recovery> & List<&2,RecoveryView>) -> List<Recovery> & List<&2,RecoveryView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def recoveries_view(values:List<Recovery>) -> List<Recovery> & List<&2,RecoveryView>:
  match values:
    case []:([],[])
    case head <> rest:recoveries_join(recovery_view(head),recoveries_view(rest))
def state_join(+codec:Codec.Constructed<Unit,B.Owner,B.identity(),B.project>,result:List<Recovery> & List<&2,RecoveryView>) -> State & StateView:
  match result:
    case (recovery,views):(State{codec,recovery},StateView{Codec.codec(~Unit,~B.Owner,~B.identity(),~B.project,codec),views})
def state_view(value:State) -> State & StateView:
  match value:
    case State{codec,recovery}:state_join(codec,recoveries_view(recovery))
def instance_join(+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,result:State & StateView) -> Instance() & InstanceView:
  match result:
    case (state,view):(Local.Instance{namespace,id,name,access,state},InstanceView{namespace,id,name,access,view})
def instance_view(value:Instance()) -> Instance() & InstanceView:
  match value:
    case Local.Instance{namespace,id,name,access,state}:instance_join(namespace,id,name,access,state_view(state))
def completed_view(rows:List<&2,Cmp.Access<D.Raw>>,result:Args & ArgsView) -> ResultView:
  match result:
    case (_,view):CompletedView{view,rows}
def result_view(value:Result<&2,&1,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>>) -> ResultView:
  match value:
    case Fail{error}:FailedView{error}
    case Done{(args,rows)}:completed_view(rows,args_view(args))
def report(+before:O.Snapshot,result:ResultView,world:B.World() & O.Snapshot,instance:Instance() & InstanceView) -> Report:
  match world instance:
    case (_,after),(_,view):Report{before,after,view,result}
def refused_view(result:Args & ArgsView) -> ResultView:
  match result:
    case (_,view):InvocationRefusedView{view}
def ran(+before:O.Snapshot,value:Local.Run<Unit,B.Store(),First.Owner,Unit,State,Args,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>,runner>) -> Report:
  match value:
    case Local.Completed{world,instance,result}:report(before,result_view(result),O.snapshot(world),instance_view(instance))
    case Local.Refused{world,instance,args}:report(before,refused_view(args_view(args)),O.snapshot(world),instance_view(instance))
def started(fail:Bool,instance:Instance(),value:B.World() & O.Snapshot) -> Report:
  match value:
    case (world,+before):ran(before,Local.run(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Args,~Query.Error<Unit>,~(Args & List<&2,Cmp.Access<D.Raw>>),~runner,instance,world,Args{Some{IncomingPair{Input.second(11),Input.second(22)}},[],[],fail}))
def registered(fail:Bool,value:Local.Registered<Unit,B.Store(),First.Owner,Unit,State,Args,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>,runner>) -> Report:
  match value:
    case Local.Registered{world,instance}:started(fail,instance,O.snapshot(world))
    case Local.RegistrationRejected{_,_}:Unavailable{RegistrationRefusedView{}}
def seeded(fail:Bool,result:Install.Attempt<B.World(),Request.Packet<B.Owner>,B.Recovery()>) -> Report:
  match result:
    case Install.Installed{world,_}:registered(fail,define(world))
    case _:Unavailable{FactoryRefusedView{}}
def activated(fail:Bool,+target:W.Handle<Unit>,result:B.World() & W.Status) -> Report:
  match result:
    case (world,W.Accepted{}):seeded(fail,B.install(world,target,Input.packet(10)))
    case _:Unavailable{FactoryRefusedView{}}
def reserved(fail:Bool,result:B.World() & W.Reservation<Unit>) -> Report:
  match result:
    case (world,W.Reserved{+target}):activated(fail,target,W.activate(~Unit,~B.Store(),~First.Owner,~Unit,world,target))
    case _:Unavailable{FactoryRefusedView{}}
def created(fail:Bool,seed:Bool,result:W.Creation<Unit,B.Store(),First.Owner,Unit>) -> Report:
  match seed result:
    case False{} W.Created{_,world}:registered(fail,define(world))
    case True{} W.Created{_,world}:reserved(fail,W.reserve_id(~Unit,~B.Store(),~First.Owner,~Unit,world))
    case _ _:Unavailable{FactoryRefusedView{}}
def run(fail:Bool,seed:Bool) -> Report:created(fail,seed,W.create(~Unit,~B.Store(),~First.Owner,~Unit,~B.empty,W.factory(),Input.first(100)))
def skipped_args(+before:O.Snapshot,world:B.World() & O.Snapshot,instance:Instance() & InstanceView,args:Args & ArgsView) -> Report:
  match args:
    case (_,view):report(before,SkippedView{view},world,instance)
def skipped_before(instance:Instance(),result:B.World() & O.Snapshot) -> Report:
  match result:
    case (world,+before):skipped_args(before,O.snapshot(world),instance_view(Local.skip(~Unit,~B.Store(),~First.Owner,~Unit,~State,~Args,~Query.Error<Unit>,~(Args & List<&2,Cmp.Access<D.Raw>>),~runner,instance)),args_view(Args{Some{IncomingPair{Input.second(11),Input.second(22)}},[],[],False{}}))
def registered_skip(result:Local.Registered<Unit,B.Store(),First.Owner,Unit,State,Args,Query.Error<Unit>,Args & List<&2,Cmp.Access<D.Raw>>,runner>) -> Report:
  match result:
    case Local.Registered{world,instance}:skipped_before(instance,O.snapshot(world))
    case Local.RegistrationRejected{_,_}:Unavailable{RegistrationRefusedView{}}
def created_skip(result:W.Creation<Unit,B.Store(),First.Owner,Unit>) -> Report:
  match result:
    case W.Created{_,world}:registered_skip(define(world))
    case W.CreateRejected{_,_}:Unavailable{FactoryRefusedView{}}
def run_skip() -> Report:created_skip(W.create(~Unit,~B.Store(),~First.Owner,~Unit,~B.empty,W.factory(),Input.first(100)))
def main() -> Candidate:Candidate{run(False{},True{}),run(True{},True{}),run(False{},False{}),run_skip()}
