import Base
import /workspace/formal-proofs/bendvy/src/ecs/query-contract.bend as Selection
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/decode-owned-journal.bend as Journal
import ./owner.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-resource.bend as ResourceConstruction
import /workspace/formal-proofs/bendvy/src/ecs/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-owned-component.bend as Write
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Lifecycle
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl

type Store<S:Data> is Type:Store{values:Col.Column<S,Input.Owner>,marker:Col.Column<S,U32>,returned:List<Request.Packet<Input.Owner>>,errors:List<&2,W.WorldError>}
def World(~S:Data) -> Type:W.World<S,Store<S>,Input.Owner,Unit>
def Rest(~S:Data) -> Type:Col.Column<S,U32> & (List<Request.Packet<Input.Owner>> & List<&2,W.WorldError>)
def take(~S:Data,value:Store<S>) -> Rest(~S) & Col.Column<S,Input.Owner>:
  match value:
    case Store{values,marker,returned,errors}:((marker,(returned,errors)),values)
def put(~S:Data,rest:Rest(~S),values:Col.Column<S,Input.Owner>) -> Store<S>:
  match rest:
    case (marker,(returned,errors)):Store{values,marker,returned,errors}
def family(~S:Data) -> Cmp.Family<S,Store<S>,Rest(~S),Input.Owner,D.Raw,Unit,take(~S),put(~S),Input.project>:Cmp.Family{"Value"}
def Frame(~S:Data) -> Type:F.Frame<S,Store<S>,Input.Owner,Unit,Input.Owner,Unit,Input.identity(~S),Input.project>
def factory(~S:Data,~codec:D.Codec) -> Constructor.Factory<S,Input.Input,Input.Owner,Input.identity(~S),Input.project,Input.incoming,Input.build>:
  Constructor.factory(~S,~Input.Input,~Input.Owner,~Input.identity(~S),~Input.project,~Input.incoming,~Input.build,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,codec))
def resource_factory(~S:Data,~codec:D.Codec) -> Constructor.Factory<S,Input.Input,Input.Owner,Input.resource_identity(~S),Input.project,Input.incoming,Input.build>:
  Constructor.factory(~S,~Input.Input,~Input.Owner,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Input.build,Decl.constructed(~S,~Input.Owner,~Input.resource_identity(~S),~Input.project,codec))
# Only this trusted schema provider knows Frame; the gameplay body sees H.
def inserted(~S:Data,+target:W.Handle<S>,+canonical:D.Raw,value:Frame(~S) & Write.Output<Input.Owner>) -> Frame(~S) & Request.Output<S,Input.Owner>:
  match value:
    case (frame,Write.Written{}):(frame,Request.Accepted{target,False{},canonical})
    case (frame,Write.Refused{owner,error}):(frame,Request.Refused{owner,Request.Entity{error}})
def projected(~S:Data,frame:Frame(~S),+target:W.Handle<S>,value:Input.Owner & D.Raw) -> Frame(~S) & Request.Output<S,Input.Owner>:
  match value:
    case (owner,raw):inserted(~S,target,raw,Write.set(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~Rest(~S),~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,~family(~S),frame,Query.Insert{target,owner}))
def lower(~S:Data,frame:Frame(~S),value:Request.Input<S,Input.Owner>) -> Frame(~S) & Request.Output<S,Input.Owner>:
  match value:
    case Request.Input{Commands.Spawn{},owner}:F.request(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,frame,Request.Input{Commands.Spawn{},owner})
    case Request.Input{Commands.Insert{target},owner}:projected(~S,frame,target,Input.project(owner))
def grants(~S:Data,~codec:D.Codec) -> Cap.OwnedRequest<Frame(~S),Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner>>:
  Constructed.grant(~S,~Input.Input,~Input.Owner,~Input.identity(~S),~Input.project,~Input.incoming,~Input.build,~factory(~S,~codec),~Frame(~S),~Cap.OwnedRequest{lower(~S)})
def resource_grants(~S:Data,~codec:D.Codec) -> Cap.OwnedRequest<Frame(~S),Input.Input,ResourceConstruction.Output<Input.Input,Input.Owner>>:
  ResourceConstruction.grant(~S,~Input.Input,~Input.Owner,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Input.build,~resource_factory(~S,~codec),~Frame(~S),~Resource.grant(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~Input.resource_identity(~S),~Input.project,~Decl.constructed(~S,~Input.Owner,~Input.resource_identity(~S),~Input.project,codec)))
type Mode is Data:Spawn{} Insert{} ResourceWrite{}
type Output<S:Data> is Type:Component{value:Constructed.Output<S,Input.Input,Input.Owner>} ResourceResult{value:ResourceConstruction.Output<Input.Input,Input.Owner>}
type Args<S:Data> is Type:Args{operation:Mode,target:W.Handle<S>,input:Input.Input}
def component_returned(~S:Data,~H:Type,value:H & Constructed.Output<S,Input.Input,Input.Owner>) -> H & Output<S>:
  match value:
    case (ctx,out):(ctx,Component{out})
def resource_returned(~S:Data,~H:Type,value:H & ResourceConstruction.Output<Input.Input,Input.Owner>) -> H & Output<S>:
  match value:
    case (ctx,out):(ctx,ResourceResult{out})
def body(~S:Data,~H:Type,~component:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner>>,~resource:Cap.OwnedRequest<H,Input.Input,ResourceConstruction.Output<Input.Input,Input.Owner>>,args:Args<S>,ctx:H) -> H & Output<S>:
  match args:
    case Args{Spawn{},_,input}:component_returned(~S,~H,Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Input.Owner>,~component,ctx,Constructed.Input{Commands.Spawn{},input}))
    case Args{Insert{},target,input}:component_returned(~S,~H,Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Input.Owner>,~component,ctx,Constructed.Input{Commands.Insert{target},input}))
    case Args{ResourceWrite{},_,input}:resource_returned(~S,~H,Cap.owned_request(~H,~Input.Input,~ResourceConstruction.Output<Input.Input,Input.Owner>,~resource,ctx,input))
type Ops<-S:Data,-H:Type> is Type:Ops{component:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner>>,resource:Cap.OwnedRequest<H,Input.Input,ResourceConstruction.Output<Input.Input,Input.Owner>>}
def component_cap(~S:Data,~H:Type,ops:Ops<S,H>) -> Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner>>:
  match ops:
    case Ops{cap,_}:cap
def resource_cap(~S:Data,~H:Type,ops:Ops<S,H>) -> Cap.OwnedRequest<H,Input.Input,ResourceConstruction.Output<Input.Input,Input.Owner>>:
  match ops:
    case Ops{_,cap}:cap
def gameplay(~S:Data,~H:Type,~ops:Ops<S,H>,args:Args<S>,ctx:H) -> H & Output<S>:
  body(~S,~H,~component_cap(~S,~H,ops),~resource_cap(~S,~H,ops),args,ctx)

def ops(~S:Data,~codec:D.Codec) -> Ops<S,Frame(~S)>:Ops{grants(~S,~codec),resource_grants(~S,~codec)}
def delivery_refused(~S:Data,world:World(~S),owner:Maybe<&1,Input.Owner>,error:W.WorldError,packet:Request.Packet<Input.Owner>) -> Delivery.Delivery<World(~S),Request.Packet<Input.Owner>>:
  match packet:
    case Request.Packet{_,original,canonical}:Delivery.Undelivered{world,Request.Packet{owner,original,canonical},error}
type MarkerView is Data:MarkerView{slots:List<&2,Maybe<&2,U32>>,stamps:List<&2,Lifecycle.Entry>} UnsupportedMarker{}
def delivered(~S:Data,packet:Request.Packet<Input.Owner>,result:Cmp.Replacement<World(~S),Input.Owner>) -> Delivery.Delivery<World(~S),Request.Packet<Input.Owner>>:
  match result:
    case Cmp.Replaced{world,previous}:Delivery.Delivered{world}
    case Cmp.ReplaceRejected{world,owner,error}:delivery_refused(~S,world,owner,error,packet)
def attempt(~S:Data,world:World(~S),target:W.Handle<S>,packet:Request.Packet<Input.Owner>) -> Delivery.Delivery<World(~S),Request.Packet<Input.Owner>>:
  match packet:
    case Request.Packet{owner,+original,+canonical}:delivered(~S,Request.Packet{None{},original,canonical},Cmp.replace(~S,~Store<S>,~Input.Owner,~Unit,~Rest(~S),~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,family(~S),world,target,owner))
# Deferred refusal recovery owns rejected packets in the Store, outside resource replacement.
def recovering(~S:Data,packet:Request.Packet<Input.Owner>,error:W.WorldError,store:Store<S>) -> Store<S> & Unit:
  match store:
    case Store{values,marker,returned,errors}:(Store{values,marker,packet <> returned,error <> errors},Unit{})
def recovered(~S:Data,value:World(~S) & Unit) -> World(~S):
  match value:
    case (world,_):world
def recover(~S:Data,world:World(~S),packet:Request.Packet<Input.Owner>,error:W.WorldError) -> World(~S):recovered(~S,W.with_store(~S,~Store<S>,~Input.Owner,~Unit,~Unit,recovering(~S,packet,error),world))
type Recovery<S:Data> is Type:Recovery{output:Output<S>,packets:List<Request.Packet<Input.Owner>>}
type State<S:Data> is Type:State{recoveries:List<Recovery<S>>,pending:List<Journal.Pending<Unit>>}
def retained(~S:Data,local:State<S>,output:Output<S>,packets:List<Request.Packet<Input.Owner>>) -> State<S>:
  match local:
    case State{previous,pending}:State{Recovery{output,packets} <> previous,pending}
def recover_abort(~S:Data,local:State<S>,output:Output<S>,packets:List<Request.Packet<Input.Owner>>,pending:List<Journal.Pending<Unit>>) -> State<S>:
  match local:
    case State{previous,old}:State{Recovery{output,packets} <> previous,List.append(&1,Journal.Pending<Unit>,old,pending)}
def finished(~S:Data,local:State<S>,value:Frame(~S) & Output<S>) -> Local.Outcome<World(~S),State<S>,Unit,Output<S>>:
  match value:
    case (F.Frame{owner,_,_,_,[],[]},output):Completion.finish_deferred(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~attempt(~S),~recover(~S),~State<S>,~Output<S>,~retained(~S),local,output,owner,T.Success{})
    case (frame,output):Completion.abort(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~State<S>,~Output<S>,~Unit,~Output<S>,~recover_abort(~S),Unit{},local,output,frame)
def runner(~S:Data,~codec:D.Codec,world:World(~S),local:State<S>,args:Args<S>) -> Local.Outcome<World(~S),State<S>,Unit,Output<S>>:
  finished(~S,local,Cap.invoke_owned(~(H => Ops<S,H>),~Args<S>,~Output<S>,~(H => ops => args => ctx => gameplay(~S,~H,~ops,args,ctx)),~Frame(~S),~ops(~S,~codec),args,Completion.begin_frame(~S,~Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,world,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,codec))))
def Instance(~S:Data,~codec:D.Codec) -> Type:Local.Instance<S,Store<S>,Input.Owner,Unit,State<S>,Args<S>,Unit,Output<S>,runner(~S,~codec)>
type PacketView is Data:PacketView{owner:Maybe<&2,Input.View>,original:D.Raw,canonical:D.Raw}
def packet_join(+original:D.Raw,+canonical:D.Raw,value:Maybe<&1,Input.Owner> & Maybe<&2,Input.View>) -> Request.Packet<Input.Owner> & PacketView:
  match value:
    case (owner,view):(Request.Packet{owner,original,canonical},PacketView{view,original,canonical})
def option_some(value:Input.Owner & Input.View) -> Maybe<&1,Input.Owner> & Maybe<&2,Input.View>:
  match value:
    case (owner,view):(Some{owner},Some{view})
def option(value:Maybe<&1,Input.Owner>) -> Maybe<&1,Input.Owner> & Maybe<&2,Input.View>:
  match value:
    case None{}:(None{},None{})
    case Some{owner}:option_some(Input.view(owner))
def packet(value:Request.Packet<Input.Owner>) -> Request.Packet<Input.Owner> & PacketView:
  match value:
    case Request.Packet{owner,original,canonical}:packet_join(original,canonical,option(owner))
def packet_join_list(head:Request.Packet<Input.Owner> & PacketView,tail:List<Request.Packet<Input.Owner>> & List<&2,PacketView>) -> List<Request.Packet<Input.Owner>> & List<&2,PacketView>:
  match head tail:
    case (owner,a),(tail,b):(owner <> tail,a <> b)
def packets(value:List<Request.Packet<Input.Owner>>) -> List<Request.Packet<Input.Owner>> & List<&2,PacketView>:
  match value:
    case []:([],[])
    case head <> tail:packet_join_list(packet(head),packets(tail))
def owners_join(head:Input.Owner & Input.View,tail:List<Input.Owner> & List<&2,Input.View>) -> List<Input.Owner> & List<&2,Input.View>:
  match head tail:
    case (owner,a),(tail,b):(owner <> tail,a <> b)
def owners(value:List<Input.Owner>) -> List<Input.Owner> & List<&2,Input.View>:
  match value:
    case []:([],[])
    case head <> tail:owners_join(Input.view(head),owners(tail))
def slots_join(left:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>,right:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,Maybe<&2,Input.View>,a,b))
def slots_leaf(value:Maybe<&1,Input.Owner> & Maybe<&2,Input.View>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>:
  match value:
    case (owner,view):(ALeaf{owner},[view])
def slots(value:Array<Maybe<&1,Input.Owner>>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>:
  match value:
    case ALeaf{owner}:slots_leaf(option(owner))
    case ANode{left,right}:slots_join(slots(left),slots(right))
type ColumnView is Data:ColumnView{supported:Bool,slots:List<&2,Maybe<&2,Input.View>>,stamps:List<&2,Lifecycle.Entry>}
def column_join(~S:Data,+stamps:List<&2,Lifecycle.Entry>,value:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,Input.View>>) -> Col.Column<S,Input.Owner> & ColumnView:
  match value:
    case (slots,values):(Col.Column{slots,stamps},ColumnView{True{},values,stamps})
def column(~S:Data,value:Col.Column<S,Input.Owner>) -> Col.Column<S,Input.Owner> & ColumnView:
  match value:
    case Col.Column{values,stamps}:column_join(~S,stamps,slots(values))
    case value:(value,ColumnView{False{},[],[]})


def marker_option(value:Maybe<&1,U32>) -> Maybe<&1,U32> & Maybe<&2,U32>:
  match value:
    case None{}:(None{},None{})
    case Some{+value}:(Some{value},Some{value})
def marker_slots_leaf(value:Maybe<&1,U32> & Maybe<&2,U32>) -> Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>:
  match value:
    case (owner,view):(ALeaf{owner},[view])
def marker_slots_join(left:Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>,right:Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>) -> Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,Maybe<&2,U32>,a,b))
def marker_slots(value:Array<Maybe<&1,U32>>) -> Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>:
  match value:
    case ALeaf{value}:marker_slots_leaf(marker_option(value))
    case ANode{left,right}:marker_slots_join(marker_slots(left),marker_slots(right))
def marker_join(~S:Data,+stamps:List<&2,Lifecycle.Entry>,value:Array<Maybe<&1,U32>> & List<&2,Maybe<&2,U32>>) -> Col.Column<S,U32> & MarkerView:
  match value:
    case (values,view):(Col.Column{values,stamps},MarkerView{view,stamps})
type StoreView is Data:StoreView{values:ColumnView,marker:MarkerView,returned:List<&2,PacketView>,errors:List<&2,W.WorldError>}
def marker_view(~S:Data,value:Col.Column<S,U32>) -> Col.Column<S,U32> & MarkerView:
  match value:
    case Col.Column{values,+stamps}:marker_join(~S,stamps,marker_slots(values))
    case value:(value,UnsupportedMarker{})

def store_join(~S:Data,+errors:List<&2,W.WorldError>,values:Col.Column<S,Input.Owner> & ColumnView,marker:Col.Column<S,U32> & MarkerView,returned:List<Request.Packet<Input.Owner>> & List<&2,PacketView>) -> Store<S> & StoreView:
  match values marker returned:
    case (values,a),(marker,b),(returned,c):(Store{values,marker,returned,errors},StoreView{a,b,c,errors})
def store_view(~S:Data,store:Store<S>) -> Store<S> & StoreView:
  match store:
    case Store{values,marker,returned,+errors}:store_join(~S,errors,column(~S,values),marker_view(~S,marker),packets(returned))
type Meta is Data:Meta{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Snapshot is Data:Snapshot{meta:Meta,live:List<&2,Bool>,store:StoreView,resource:Input.View,pending:U32}
def snapshot_live(~S:Data,resource:Input.View,store:StoreView,count:U32,+meta:Meta,owner:Store<S>,resource_owner:Input.Owner,pending:List<(World(~S) -> World(~S))>,value:Array<Bool> & List<&2,Bool>) -> World(~S) & Snapshot:
  match meta value:
    case Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},(live,view):(W.World{namespace,nextId,highWater,live,capacity,depth,owner,resource_owner,events,pending,registrations,nextSystemId,clock},Snapshot{meta,view,store,resource,count})
def snapshot_pending(~S:Data,resource:Input.View,store:StoreView,value:World(~S) & U32) -> World(~S) & Snapshot:
  match value:
    case (W.World{namespace,nextId,highWater,live,capacity,depth,owner,resource_owner,events,pending,registrations,nextSystemId,clock},count):snapshot_live(~S,resource,store,count,Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},owner,resource_owner,pending,Input.array(~Bool,live))
def snapshot_store(~S:Data,resource:Input.View,value:World(~S) & StoreView) -> World(~S) & Snapshot:
  match value:
    case (world,store):snapshot_pending(~S,resource,store,W.pending_count(~S,~Store<S>,~Input.Owner,~Unit,world))
def snapshot_resource(~S:Data,value:World(~S) & Input.View) -> World(~S) & Snapshot:
  match value:
    case (world,view):snapshot_store(~S,view,W.with_store(~S,~Store<S>,~Input.Owner,~Unit,~StoreView,store_view(~S),world))
def snapshot(~S:Data,world:World(~S)) -> World(~S) & Snapshot:snapshot_resource(~S,W.observe_resource(~S,~Store<S>,~Input.Owner,~Unit,~Input.View,~Input.view,world))
def Out(~S:Data) -> Type:Constructed.Output<S,Input.Input,Input.Owner>
type OperationView<S:Data> is Data:Accepted{target:W.Handle<S>,spawned:Bool,canonical:D.Raw,undoAvailable:Bool} Refused{owner:Maybe<&2,Input.InputView>,error:Request.Error}
def input_some(value:Input.Input & Input.InputView) -> Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>:
  match value:
    case (owner,view):(Some{owner},Some{view})
def input_option(value:Maybe<&1,Input.Input>) -> Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>:
  match value:
    case None{}:(None{},None{})
    case Some{owner}:input_some(Input.input_view(owner))
def operation_refused(~S:Data,+error:Request.Error,value:Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>) -> Out(~S) & OperationView<S>:
  match value:
    case (owner,view):(Constructed.Refused{owner,error},Refused{view,error})
def operation(~S:Data,value:Out(~S)) -> Out(~S) & OperationView<S>:
  match value:
    case Constructed.Accepted{+target,+spawned,+canonical,undo}:(Constructed.Accepted{target,spawned,canonical,undo},Accepted{target,spawned,canonical,True{}})
    case Constructed.Refused{owner,error}:operation_refused(~S,error,input_option(owner))
type ResourceView is Data:ResourceReplaced{canonical:D.Raw,undoAvailable:Bool} ResourceRefused{owner:Input.InputView,error:D.Error}
def resource_refused(error:D.Error,value:Input.Input & Input.InputView) -> ResourceView:
  match value:
    case (_,view):ResourceRefused{view,error}
def resource_result(value:ResourceConstruction.Output<Input.Input,Input.Owner>) -> ResourceView:
  match value:
    case ResourceConstruction.Replaced{canonical,undo}:ResourceReplaced{canonical,True{}}
    case ResourceConstruction.Refused{owner,error}:resource_refused(error,Input.input_view(owner))
type OutputView<S:Data> is Data:ComponentView{value:OperationView<S>} ResourceOutputView{value:ResourceView}
def component_view(~S:Data,value:Out(~S) & OperationView<S>) -> OutputView<S>:
  match value:
    case (_,view):ComponentView{view}
def output_view(~S:Data,value:Output<S>) -> OutputView<S>:
  match value:
    case Component{out}:component_view(~S,operation(~S,out))
    case ResourceResult{out}:ResourceOutputView{resource_result(out)}
type RecoveryView<S:Data> is Data:RecoveryView{output:OutputView<S>,packets:List<&2,PacketView>}
def recovery_join(~S:Data,output:OutputView<S>,value:List<Request.Packet<Input.Owner>> & List<&2,PacketView>) -> RecoveryView<S>:
  match value:
    case (_,values):RecoveryView{output,values}
def recovery_view(~S:Data,rec:Recovery<S>) -> RecoveryView<S>:
  match rec:
    case Recovery{output,values}:recovery_join(~S,output_view(~S,output),packets(values))
def recoveries(~S:Data,value:List<Recovery<S>>) -> List<&2,RecoveryView<S>>:
  match value:
    case []:[]
    case head <> tail:recovery_view(~S,head) <> recoveries(~S,tail)
type PendingView is Data:PendingView{owner:Unit,error:W.WorldError}
def pending_view(value:List<Journal.Pending<Unit>>) -> List<&2,PendingView>:
  match value:
    case []:[]
    case Journal.Pending{owner,error} <> rest:PendingView{owner,error} <> pending_view(rest)
type InstanceView<S:Data> is Data:InstanceView{namespace:U32,id:U32,name:String,access:List<&2,String>,recoveries:List<&2,RecoveryView<S>>,pending:List<&2,PendingView>}
def instance_view(~S:Data,~codec:D.Codec,value:Instance(~S,~codec)) -> InstanceView<S>:
  match value:
    case Local.Instance{namespace,id,name,access,State{values,pending}}:InstanceView{namespace,id,name,access,recoveries(~S,values),pending_view(pending)}
type ResultView<S:Data> is Data:Completed{output:OutputView<S>} Failed{error:Unit} InvocationRefused{input:Input.InputView,operation:Mode,target:W.Handle<S>}
def result_view(~S:Data,value:Result<&2,&1,Unit,Output<S>>) -> ResultView<S>:
  match value:
    case Done{out}:Completed{output_view(~S,out)}
    case Fail{error}:Failed{error}
type Report<S:Data> is Data:Report{original:Input.InputView,before:Snapshot,committed:Snapshot,barrier:Snapshot,instance:InstanceView<S>,result:ResultView<S>} SetupRefused{}
def reported(~S:Data,~codec:D.Codec,original:Input.InputView,before:Snapshot,committed:Snapshot,instance:Instance(~S,~codec),result:ResultView<S>,world:World(~S) & Snapshot) -> Report<S>:
  match world:
    case (_,barrier):Report{original,before,committed,barrier,instance_view(~S,~codec,instance),result}
def barrier(~S:Data,~codec:D.Codec,original:Input.InputView,before:Snapshot,instance:Instance(~S,~codec),result:ResultView<S>,world:World(~S) & Snapshot) -> Report<S>:
  match world:
    case (world,committed):reported(~S,~codec,original,before,committed,instance,result,snapshot(~S,W.barrier(~S,~Store<S>,~Input.Owner,~Unit,world)))
def invocation_refused_view(~S:Data,~codec:D.Codec,original:Input.InputView,before:Snapshot,world:World(~S),instance:Instance(~S,~codec),op:Mode,target:W.Handle<S>,input:Input.Input & Input.InputView) -> Report<S>:
  match input:
    case (_,view):barrier(~S,~codec,original,before,instance,InvocationRefused{view,op,target},snapshot(~S,world))
def invocation_refused(~S:Data,~codec:D.Codec,original:Input.InputView,before:Snapshot,world:World(~S),instance:Instance(~S,~codec),args:Args<S>) -> Report<S>:
  match args:
    case Args{op,target,owner}:invocation_refused_view(~S,~codec,original,before,world,instance,op,target,Input.input_view(owner))

def ran(~S:Data,~codec:D.Codec,original:Input.InputView,before:Snapshot,value:Local.Run<S,Store<S>,Input.Owner,Unit,State<S>,Args<S>,Unit,Output<S>,runner(~S,~codec)>) -> Report<S>:
  match value:
    case Local.Completed{world,instance,result}:barrier(~S,~codec,original,before,instance,result_view(~S,result),snapshot(~S,world))
    case Local.Refused{world,instance,args}:invocation_refused(~S,~codec,original,before,world,instance,args)
def started(~S:Data,~codec:D.Codec,op:Mode,target:W.Handle<S>,instance:Instance(~S,~codec),input:Input.Input & Input.InputView,world:World(~S) & Snapshot) -> Report<S>:
  match input world:
    case (input,original),(world,before):ran(~S,~codec,original,before,Local.run(~S,~Store<S>,~Input.Owner,~Unit,~State<S>,~Args<S>,~Unit,~Output<S>,~runner(~S,~codec),instance,world,Args{op,target,input}))
# The two selection passes match TS each().length then each()[0]; only the
# selected declared Value row supplies the immediate-write target.
def ScanOps(H:Type) -> Type:Unit
def scan_plan(~S:Data) -> Query.Plan<S,Store<S>,Input.Owner,Unit,ScanOps>:
  Query.Plan{Unit{},Query.family_match(~S,~Store<S>,~Input.Owner,~Unit,~Rest(~S),~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,~family(~S),~Query.Required{})}
def selected_again(~S:Data,~codec:D.Codec,raw:D.Raw,instance:Instance(~S,~codec),value:Selection.Scanned<S,Store<S>,Input.Owner,Unit>) -> Report<S>:
  match value:
    case Selection.Scanned{world,target <> []}:started(~S,~codec,Insert{},target,instance,Input.input_view(Input.input(raw)),snapshot(~S,world))
    case _:SetupRefused{}
def selected_once(~S:Data,~codec:D.Codec,raw:D.Raw,instance:Instance(~S,~codec),value:Selection.Scanned<S,Store<S>,Input.Owner,Unit>) -> Report<S>:
  match value:
    case Selection.Scanned{world,_ <> []}:selected_again(~S,~codec,raw,instance,Selection.scan(~S,~Store<S>,~Input.Owner,~Unit,~ScanOps,~scan_plan(~S),world,0))
    case _:SetupRefused{}
def ordinary_started(~S:Data,~codec:D.Codec,op:Mode,target:W.Handle<S>,raw:D.Raw,instance:Instance(~S,~codec),world:World(~S)) -> Report<S>:
  match op:
    case Insert{}:selected_once(~S,~codec,raw,instance,Selection.scan(~S,~Store<S>,~Input.Owner,~Unit,~ScanOps,~scan_plan(~S),world,0))
    case _:started(~S,~codec,op,target,instance,Input.input_view(Input.input(raw)),snapshot(~S,world))
def registered(~S:Data,~codec:D.Codec,op:Mode,target:W.Handle<S>,raw:D.Raw,value:Local.Registered<S,Store<S>,Input.Owner,Unit,State<S>,Args<S>,Unit,Output<S>,runner(~S,~codec)>) -> Report<S>:
  match value:
    case Local.Registered{world,instance}:ordinary_started(~S,~codec,op,target,raw,instance,world)
    case Local.RegistrationRejected{_,_}:SetupRefused{}
def marker_take(~S:Data,value:Store<S>) -> (Col.Column<S,Input.Owner> & (List<Request.Packet<Input.Owner>> & List<&2,W.WorldError>)) & Col.Column<S,U32>:
  match value:
    case Store{values,marker,returned,errors}:((values,(returned,errors)),marker)
def marker_put(~S:Data,rest:Col.Column<S,Input.Owner> & (List<Request.Packet<Input.Owner>> & List<&2,W.WorldError>),marker:Col.Column<S,U32>) -> Store<S>:
  match rest:
    case (values,(returned,errors)):Store{values,marker,returned,errors}
def marker_project_inner(value:Maybe<U32>) -> U32 & U32:
  match value:
    case Some{+value}:(value,value)
    case None{}:(0,0)
def marker_project(value:U32) -> U32 & U32:marker_project_inner(Some{value})
def marker_family(~S:Data) -> Cmp.Family<S,Store<S>,Col.Column<S,Input.Owner> & (List<Request.Packet<Input.Owner>> & List<&2,W.WorldError>),U32,U32,Unit,marker_take(~S),marker_put(~S),marker_project>:Cmp.Family{"Marker"}
def marker_done(~S:Data,value:Cmp.Replacement<World(~S),U32>) -> World(~S):
  match value:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:world
def marker_apply(~S:Data,world:World(~S),target:W.Handle<S>) -> World(~S):marker_done(~S,Cmp.replace(~S,~Store<S>,~Input.Owner,~Unit,~(Col.Column<S,Input.Owner> & (List<Request.Packet<Input.Owner>> & List<&2,W.WorldError>)),~U32,~U32,~Unit,~marker_take(~S),~marker_put(~S),~marker_project,marker_family(~S),world,target,Some{1}))
def seeded(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,+target:W.Handle<S>,value:Cmp.Replacement<World(~S),Input.Owner>) -> Report<S>:
  match value:
    case Cmp.ReplaceRejected{_,_,_}:SetupRefused{}
    case Cmp.Replaced{world,_}:registered(~S,~codec,op,target,raw,Completion.registered(~S,~Store<S>,~Input.Owner,~Unit,~State<S>,~Args<S>,~Unit,~Output<S>,~runner(~S,~codec),W.enqueue(~S,~Store<S>,~Input.Owner,~Unit,world,w => marker_apply(~S,w,target)),"application32",["Value","Resource","Marker"],State{[],[]}))
def active(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,+target:W.Handle<S>,value:World(~S) & W.Status) -> Report<S>:
  match value:
    case (_,W.Rejected{_}):SetupRefused{}
    case (world,W.Accepted{}):seeded(~S,~codec,op,raw,target,Cmp.replace(~S,~Store<S>,~Input.Owner,~Unit,~Rest(~S),~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,family(~S),world,target,Some{Input.owned(D.Number{9},333,444)}))
def reserved(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,value:World(~S) & W.Reservation<S>) -> Report<S>:
  match value:
    case (_,W.ReservationRejected{_}):SetupRefused{}
    case (world,W.Reserved{+target}):active(~S,~codec,op,raw,target,W.activate(~S,~Store<S>,~Input.Owner,~Unit,world,target))
def empty(~S:Data,u:Unit) -> Store<S>:Store{Col.empty(~S,~Input.Owner),Col.empty(~S,~U32),[],[]}
def created(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,value:W.Creation<S,Store<S>,Input.Owner,Unit>) -> Report<S>:
  match value:
    case W.CreateRejected{_,_}:SetupRefused{}
    case W.Created{_,world}:reserved(~S,~codec,op,raw,W.reserve_id(~S,~Store<S>,~Input.Owner,~Unit,world))
def resource_seeded(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,value:Build.Construction<Input.Input,Input.Owner,D.Error>) -> Report<S>:
  match value:
    case Build.Invalid{_,_}:SetupRefused{}
    case Build.Constructed{owner,_}:created(~S,~codec,op,raw,W.create(~S,~Store<S>,~Input.Owner,~Unit,~empty(~S),W.factory(),owner))
def run(~S:Data,~codec:D.Codec,op:Mode,raw:D.Raw,seed:D.Raw) -> Report<S>:resource_seeded(~S,~codec,op,raw,Constructor.construct(~S,~Input.Input,~Input.Owner,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Input.build,resource_factory(~S,~codec),Input.Input{seed,ANode{ALeaf{555},ALeaf{666}},ANode{ALeaf{False{}},ALeaf{True{}}}}))
