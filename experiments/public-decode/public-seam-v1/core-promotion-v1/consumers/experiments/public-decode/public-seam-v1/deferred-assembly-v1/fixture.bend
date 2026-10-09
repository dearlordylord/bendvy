import ../../../../../library/decode-local.bend as Completion
import Base
import ./assembly.bend as A
import ../../../../../library/decode-requests.bend as Request
import ../generic-assembly-v1/second-owner.bend as P
import ../generic-assembly-v1/observation.bend as O
import ../generic-assembly-v1/recovery-fixture.bend as Values
import ../../complete-v1/controls.bend as R
import ../../adoption-v1/observation.bend as RO
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import ../../../../../dependencies/snapshot/ordinary-declaration.bend as Identity
import ../../../../../dependencies/snapshot/decode-data.bend as D
import ../../../../../dependencies/snapshot/persistence-declaration.bend as Decl

def World() -> Type:W.World<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit>
def Owner() -> Type:Request.Owner<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit,P.Owner,P.identity(),P.project>
def Ops(~H:Type) -> Type:A.Ops<Unit,P.Owner,R.Owner,H>
def resource_identity() -> Identity.Declaration<Unit,R.Owner>:Identity.component(~Unit,~R.Owner,"decoded-resource")
def normalize(raw:D.Raw,owner:Maybe<&1,P.Owner>) -> Maybe<&1,P.Owner>:
  match owner:
    case None{}:None{}
    case Some{P.Owner{_,words,flags}}:Some{P.Owner{raw,words,flags}}
def attempt(world:World(),target:W.Handle<Unit>,packet:Request.Packet<P.Owner>) -> Delivery.Delivery<World(),Request.Packet<P.Owner>>:
  A.attempt(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~Unit,~Unit,~P.take,~P.put,~P.project,~P.family(),~normalize,~normalize,world,target,packet)
def recover(world:World(),packet:Request.Packet<P.Owner>,error:W.WorldError) -> World():A.recover(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,world,packet,error)

type Args is Type:Args{operation:Commands.Operation<Unit>,first:P.Owner,second:P.Owner,fail:Bool}
type Recovery is Type:Recovery{outputs:List<Request.Output<Unit,P.Owner>>,packets:List<Request.Packet<P.Owner>>}
type State is Type:State{codec:Decl.Constructed<Unit,P.Owner,P.identity(),P.project>,recoveries:List<Recovery>}
def decode_field(~H:Type,ops:Ops(~H)) -> Cap.OwnedRequest<H,Request.Input<Unit,P.Owner>,Request.Output<Unit,P.Owner>>:
  match ops:
    case A.Ops{decode,_}:decode
def resource_field(~H:Type,ops:Ops(~H)) -> Cap.OwnedRequest<H,R.Owner,Unit>:
  match ops:
    case A.Ops{_,resource}:resource
def decode(~H:Type,~ops:Ops(~H),ctx:H,operation:Commands.Operation<Unit>,owner:P.Owner) -> H & Request.Output<Unit,P.Owner>:
  Cap.owned_request(~H,~Request.Input<Unit,P.Owner>,~Request.Output<Unit,P.Owner>,~decode_field(~H,ops),ctx,Request.Input{operation,owner})
def resource(~H:Type,~ops:Ops(~H),ctx:H,value:R.Owner) -> H & Unit:Cap.owned_request(~H,~R.Owner,~Unit,~resource_field(~H,ops),ctx,value)
def done(~H:Type,outputs:List<Request.Output<Unit,P.Owner>>,+fail:Bool,result:H & Unit) -> H & (List<Request.Output<Unit,P.Owner>> & Bool):
  match result:
    case (ctx,_):(ctx,(outputs,fail))
def second_done(~H:Type,~ops:Ops(~H),first:Request.Output<Unit,P.Owner>,+fail:Bool,result:H & Request.Output<Unit,P.Owner>) -> H & (List<Request.Output<Unit,P.Owner>> & Bool):
  match result:
    case (ctx,second):done(~H,[first,second],fail,resource(~H,~ops,ctx,Values.first(300)))
def first_done(~H:Type,~ops:Ops(~H),+operation:Commands.Operation<Unit>,second:P.Owner,+fail:Bool,result:H & Request.Output<Unit,P.Owner>) -> H & (List<Request.Output<Unit,P.Owner>> & Bool):
  match result:
    case (ctx,first):second_done(~H,~ops,first,fail,decode(~H,~ops,ctx,operation,second))
def before_done(~H:Type,~ops:Ops(~H),+operation:Commands.Operation<Unit>,first:P.Owner,second:P.Owner,+fail:Bool,result:H & Unit) -> H & (List<Request.Output<Unit,P.Owner>> & Bool):
  match result:
    case (ctx,_):first_done(~H,~ops,operation,second,fail,decode(~H,~ops,ctx,operation,first))
def body(~H:Type,~ops:Ops(~H),args:Args,ctx:H) -> H & (List<Request.Output<Unit,P.Owner>> & Bool):
  match args:
    case Args{operation,first,second,fail}:before_done(~H,~ops,operation,first,second,fail,resource(~H,~ops,ctx,Values.first(200)))
def outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def retained(local:State,outputs:List<Request.Output<Unit,P.Owner>>,packets:List<Request.Packet<P.Owner>>) -> State:
  match local:
    case State{codec,previous}:State{codec,Recovery{outputs,packets} <> previous}
def invoked(codec:Decl.Constructed<Unit,P.Owner,P.identity(),P.project>,previous:List<Recovery>,result:Owner() & (List<Request.Output<Unit,P.Owner>> & Bool)) -> Local.Outcome<World(),State,Unit,List<Request.Output<Unit,P.Owner>>>:
  match result:
    case (owner,(outputs,fail)):Completion.finish_deferred(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~P.Owner,~Unit,~P.identity(),~P.project,~attempt,~recover,~State,~List<Request.Output<Unit,P.Owner>>,~retained,State{codec,previous},outputs,owner,outcome(fail))
def runner(world:World(),state:State,args:Args) -> Local.Outcome<World(),State,Unit,List<Request.Output<Unit,P.Owner>>>:
  match state:
    case State{+codec,previous}:invoked(codec,previous,A.invoke(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~P.identity(),~P.project,~Args,~(List<Request.Output<Unit,P.Owner>> & Bool),~(H => ops => args => ctx => body(~H,~ops,args,ctx)),Completion.begin_owner(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~P.Owner,~P.identity(),~P.project,world,codec),args))
def Instance() -> Type:Local.Instance<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit,State,Args,Unit,List<Request.Output<Unit,P.Owner>>,runner>
def define(world:World()) -> Local.Registered<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit,State,Args,Unit,List<Request.Output<Unit,P.Owner>>,runner>:
  Completion.registered(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~State,~Args,~Unit,~List<Request.Output<Unit,P.Owner>>,~runner,world,"declared-deferred-owned",A.access(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~Unit,~Unit,~P.identity(),~resource_identity(),~P.project,~P.take,~P.put),State{Decl.constructed(~Unit,~P.Owner,~P.identity(),~P.project,D.Integer{}),[]})

type PacketView is Data:PacketView{owner:Maybe<&2,O.PayloadView>,original:D.Raw,canonical:D.Raw}
def packet_join(+original:D.Raw,+canonical:D.Raw,result:Maybe<&1,P.Owner> & Maybe<&2,O.PayloadView>) -> Request.Packet<P.Owner> & PacketView:
  match result:
    case (owner,view):(Request.Packet{owner,original,canonical},PacketView{view,original,canonical})
def packet(value:Request.Packet<P.Owner>) -> Request.Packet<P.Owner> & PacketView:
  match value:
    case Request.Packet{owner,original,canonical}:packet_join(original,canonical,O.option(owner))
def packets_join(head:Request.Packet<P.Owner> & PacketView,tail:List<Request.Packet<P.Owner>> & List<&2,PacketView>) -> List<Request.Packet<P.Owner>> & List<&2,PacketView>:
  match head tail:
    case (head,a),(tail,b):(head <> tail,a <> b)
def packets(values:List<Request.Packet<P.Owner>>) -> List<Request.Packet<P.Owner>> & List<&2,PacketView>:
  match values:
    case []:([],[])
    case head <> tail:packets_join(packet(head),packets(tail))
def payloads_join(head:P.Owner & O.PayloadView,tail:List<P.Owner> & List<&2,O.PayloadView>) -> List<P.Owner> & List<&2,O.PayloadView>:
  match head tail:
    case (head,a),(tail,b):(head <> tail,a <> b)
def payloads(values:List<P.Owner>) -> List<P.Owner> & List<&2,O.PayloadView>:
  match values:
    case []:([],[])
    case head <> tail:payloads_join(O.payload(head),payloads(tail))
type MailView is Data:MailView{value:RO.PayloadView,retired:List<&2,O.PayloadView>,returned:List<&2,PacketView>,errors:List<&2,W.WorldError>}
def mail_join(+errors:List<&2,W.WorldError>,value:R.Owner & RO.PayloadView,retired:List<P.Owner> & List<&2,O.PayloadView>,returned:List<Request.Packet<P.Owner>> & List<&2,PacketView>) -> A.Mail<R.Owner,P.Owner> & MailView:
  match value retired returned:
    case (value,a),(retired,b),(returned,c):(A.Mail{value,retired,returned,errors},MailView{a,b,c,errors})
def mail(value:A.Mail<R.Owner,P.Owner>) -> A.Mail<R.Owner,P.Owner> & MailView:
  match value:
    case A.Mail{value,retired,returned,errors}:mail_join(errors,RO.payload(value),payloads(retired),packets(returned))
type Snapshot is Data:Snapshot{meta:O.Meta,live:List<&2,Bool>,column:O.ColumnView,mail:MailView,pending:U32}
def snapshot_join(+meta:O.Meta,live:Array<Bool> & List<&2,Bool>,column:P.Store() & O.ColumnView,mail:A.Mail<R.Owner,P.Owner> & MailView,pending:List<(World() -> World())> & U32) -> World() & Snapshot:
  match meta live column mail pending:
    case O.Meta{ns,next,high,capacity,depth,events,registrations,system,clock},(live,a),(column,b),(mail,c),(pending,d):(W.World{ns,next,high,live,capacity,depth,column,mail,events,pending,registrations,system,clock},Snapshot{meta,a,b,c,d})
def snapshot(world:World()) -> World() & Snapshot:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock}:snapshot_join(O.Meta{ns,next,high,capacity,depth,events,registrations,system,clock},O.bools(live),O.column(~Unit,store),mail(resource),W.pending_length(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,pending))
type OperationView is Data:AcceptedView{target:W.Handle<Unit>,spawned:Bool,canonical:D.Raw} RefusedView{owner:Maybe<&2,O.PayloadView>,error:Request.Error}
def refused_join(+error:Request.Error,result:Maybe<&1,P.Owner> & Maybe<&2,O.PayloadView>) -> Request.Output<Unit,P.Owner> & OperationView:
  match result:
    case (owner,view):(Request.Refused{owner,error},RefusedView{view,error})
def operation(value:Request.Output<Unit,P.Owner>) -> Request.Output<Unit,P.Owner> & OperationView:
  match value:
    case Request.Accepted{+target,+spawned,+canonical}:(Request.Accepted{target,spawned,canonical},AcceptedView{target,spawned,canonical})
    case Request.Refused{owner,error}:refused_join(error,O.option(owner))
def operations_join(head:Request.Output<Unit,P.Owner> & OperationView,tail:List<Request.Output<Unit,P.Owner>> & List<&2,OperationView>) -> List<Request.Output<Unit,P.Owner>> & List<&2,OperationView>:
  match head tail:
    case (head,a),(tail,b):(head <> tail,a <> b)
def operations(values:List<Request.Output<Unit,P.Owner>>) -> List<Request.Output<Unit,P.Owner>> & List<&2,OperationView>:
  match values:
    case []:([],[])
    case head <> tail:operations_join(operation(head),operations(tail))
type RecoveryView is Data:RecoveryView{outputs:List<&2,OperationView>,packets:List<&2,PacketView>}
def recovery_join(outputs:List<Request.Output<Unit,P.Owner>> & List<&2,OperationView>,packets:List<Request.Packet<P.Owner>> & List<&2,PacketView>) -> Recovery & RecoveryView:
  match outputs packets:
    case (outputs,a),(packets,b):(Recovery{outputs,packets},RecoveryView{a,b})
def recovery(value:Recovery) -> Recovery & RecoveryView:
  match value:
    case Recovery{outputs,payloads}:recovery_join(operations(outputs),packets(payloads))
def recoveries_join(head:Recovery & RecoveryView,tail:List<Recovery> & List<&2,RecoveryView>) -> List<Recovery> & List<&2,RecoveryView>:
  match head tail:
    case (head,a),(tail,b):(head <> tail,a <> b)
def recoveries(values:List<Recovery>) -> List<Recovery> & List<&2,RecoveryView>:
  match values:
    case []:([],[])
    case head <> tail:recoveries_join(recovery(head),recoveries(tail))
type InstanceView is Data:InstanceView{namespace:U32,id:U32,name:String,access:List<&2,String>,codec:D.Codec,recoveries:List<&2,RecoveryView>}
def instance_join(+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+codec:Decl.Constructed<Unit,P.Owner,P.identity(),P.project>,result:List<Recovery> & List<&2,RecoveryView>) -> Instance() & InstanceView:
  match result:
    case (recoveries,views):(Local.Instance{ns,id,name,access,State{codec,recoveries}},InstanceView{ns,id,name,access,Decl.codec(~Unit,~P.Owner,~P.identity(),~P.project,codec),views})
def instance(value:Instance()) -> Instance() & InstanceView:
  match value:
    case Local.Instance{ns,id,name,access,State{codec,entries}}:instance_join(ns,id,name,access,codec,recoveries(entries))
type ArgsView is Data:ArgsView{operation:Commands.Operation<Unit>,first:O.PayloadView,second:O.PayloadView,fail:Bool}
def args_join(+operation:Commands.Operation<Unit>,+fail:Bool,first:P.Owner & O.PayloadView,second:P.Owner & O.PayloadView) -> Args & ArgsView:
  match first second:
    case (first,a),(second,b):(Args{operation,first,second,fail},ArgsView{operation,a,b,fail})
def args_view(args:Args) -> Args & ArgsView:
  match args:
    case Args{operation,first,second,fail}:args_join(operation,fail,O.payload(first),O.payload(second))
type ResultView is Data:Completed{outputs:List<&2,OperationView>} Failed{} Refused{} InvocationRefused{args:ArgsView}
type Report is Data:FactoryRefused{mail:MailView} Report{before:Snapshot,committed:Snapshot,barrier:Snapshot,instance:Maybe<&2,InstanceView>,result:ResultView}
def barrier_report(+before:Snapshot,+committed:Snapshot,+instance:InstanceView,+result:ResultView,observed:World() & Snapshot) -> Report:
  match observed:
    case (world,barrier):Report{before,committed,barrier,Some{instance},result}
def report(+before:Snapshot,+instance:InstanceView,+result:ResultView,observed:World() & Snapshot) -> Report:
  match observed:
    case (world,+committed):barrier_report(before,committed,instance,result,snapshot(W.barrier(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world)))
def completed(+before:Snapshot,world:World(),instance:Instance() & InstanceView,outputs:List<Request.Output<Unit,P.Owner>> & List<&2,OperationView>) -> Report:
  match instance outputs:
    case (instance,view),(outputs,views):report(before,view,Completed{views},snapshot(world))
def failed(+before:Snapshot,world:World(),instance:Instance() & InstanceView) -> Report:
  match instance:
    case (instance,view):report(before,view,Failed{},snapshot(world))
def invocation_refused(+before:Snapshot,world:World(),local:Instance() & InstanceView,args:Args & ArgsView) -> Report:
  match local args:
    case (local,view),(args,argView):report(before,view,InvocationRefused{argView},snapshot(world))
def ran(+before:Snapshot,result:Local.Run<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit,State,Args,Unit,List<Request.Output<Unit,P.Owner>>,runner>) -> Report:
  match result:
    case Local.Completed{world,local,Done{outputs}}:completed(before,world,instance(local),operations(outputs))
    case Local.Completed{world,local,Fail{_}}:failed(before,world,instance(local))
    case Local.Refused{world,local,args}:invocation_refused(before,world,instance(local),args_view(args))
def incoming(+value:U32,invalid:Bool) -> P.Owner:
  match invalid:
    case False{}:Values.second(value)
    case True{}:P.Owner{D.Text{"invalid-integer"},ANode{ALeaf{value},ALeaf{U32.add(value,10)}},ANode{ALeaf{True{}},ALeaf{False{}}}}
def observed(operation:Commands.Operation<Unit>,fail:Bool,+invalid:Bool,world:World() & Snapshot,local:Instance()) -> Report:
  match world:
    case (world,+before):ran(before,Local.run(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~State,~Args,~Unit,~List<Request.Output<Unit,P.Owner>>,~runner,local,world,Args{operation,incoming(11,invalid),incoming(22,invalid),fail}))
def refused_report(result:World() & Snapshot) -> Report:
  match result:
    case (world,+view):Report{view,view,view,None{},Refused{}}
def factory_refused(result:A.Mail<R.Owner,P.Owner> & MailView) -> Report:
  match result:
    case (mail,view):FactoryRefused{view}
def registered(operation:Commands.Operation<Unit>,fail:Bool,invalid:Bool,result:Local.Registered<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit,State,Args,Unit,List<Request.Output<Unit,P.Owner>>,runner>) -> Report:
  match result:
    case Local.Registered{world,local}:observed(operation,fail,invalid,snapshot(world),local)
    case Local.RegistrationRejected{world,state}:refused_report(snapshot(world))
def marked(world:World()) -> World():W.event_publish(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world,[Unit{}])
def prepared(operation:Commands.Operation<Unit>,fail:Bool,invalid:Bool,world:World()) -> Report:registered(operation,fail,invalid,define(W.enqueue(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,marked(world),marked)))
def seeded(operation:Commands.Operation<Unit>,fail:Bool,invalid:Bool,result:C.Replacement<World(),P.Owner>) -> Report:
  match result:
    case C.Replaced{world,old}:prepared(operation,fail,invalid,world)
    case C.ReplaceRejected{world,incoming,error}:refused_report(snapshot(world))
type Mode is Data:Spawns{} Inserts{} Invalid{} LateMissing{} ForeignTarget{target:W.Handle<Unit>}
def selected(mode:Mode,+target:W.Handle<Unit>) -> Commands.Operation<Unit>:
  match mode:
    case Spawns{}:Commands.Spawn{}
    case Invalid{}:Commands.Spawn{}
    case Inserts{}:Commands.Insert{target}
    case LateMissing{}:Commands.Insert{target}
    case ForeignTarget{foreign}:Commands.Insert{foreign}
def dead(result:World() & W.Status) -> World():
  match result:
    case (world,status):world
def kill(+target:W.Handle<Unit>,world:World()) -> World():dead(W.deactivate(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world,target))
def late(mode:Mode,+target:W.Handle<Unit>,world:World()) -> World():
  match mode:
    case LateMissing{}:W.enqueue(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world,world => kill(target,world))
    case mode:world
def is_invalid(mode:Mode) -> Bool:
  match mode:
    case Invalid{}:True{}
    case mode:False{}
def activated(+mode:Mode,fail:Bool,+target:W.Handle<Unit>,result:World() & W.Status) -> Report:
  match result:
    case (world,W.Accepted{}):seeded(selected(mode,target),fail,is_invalid(mode),C.replace(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~Unit,~P.Owner,~D.Raw,~Unit,~P.take,~P.put,~P.project,P.family(),late(mode,target,world),target,Some{Values.second(10)}))
    case (world,W.Rejected{_}):refused_report(snapshot(world))
def reserved(mode:Mode,fail:Bool,result:World() & W.Reservation<Unit>) -> Report:
  match result:
    case (world,W.Reserved{+target}):activated(mode,fail,target,W.activate(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world,target))
    case (world,W.ReservationRejected{_}):refused_report(snapshot(world))
def created(mode:Mode,fail:Bool,result:W.Creation<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit>) -> Report:
  match result:
    case W.Created{factory,world}:reserved(mode,fail,W.reserve_id(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world))
    case W.CreateRejected{factory,resource}:factory_refused(mail(resource))
def run(mode:Mode,fail:Bool) -> Report:created(mode,fail,W.create(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~P.empty,W.factory(),A.Mail{Values.first(100),[],[],[]}))
# The rejected handle is allocated by a different real factory-created world.
def foreign_reserved(factory:W.Factory,result:World() & W.Reservation<Unit>) -> Report:
  match result:
    case (world,W.Reserved{+target}):created(ForeignTarget{target},False{},W.create(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~P.empty,factory,A.Mail{Values.first(100),[],[],[]}))
    case (world,W.ReservationRejected{_}):refused_report(snapshot(world))
def foreign_created(result:W.Creation<Unit,P.Store(),A.Mail<R.Owner,P.Owner>,Unit>) -> Report:
  match result:
    case W.Created{factory,world}:foreign_reserved(factory,W.reserve_id(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,world))
    case W.CreateRejected{factory,resource}:factory_refused(mail(resource))
def foreign() -> Report:foreign_created(W.create(~Unit,~P.Store(),~A.Mail<R.Owner,P.Owner>,~Unit,~P.empty,W.factory(),A.Mail{Values.first(100),[],[],[]}))
type Candidate is Data:Candidate{spawn:Report,insert:Report,failure:Report,foreign:Report,lateMissing:Report,invalid:Report,failedInsert:Report,failedInvalid:Report}
def main() -> Candidate:Candidate{run(Spawns{},False{}),run(Inserts{},False{}),run(Spawns{},True{}),foreign(),run(LateMissing{},False{}),run(Invalid{},False{}),run(Inserts{},True{}),run(Invalid{},True{})}
