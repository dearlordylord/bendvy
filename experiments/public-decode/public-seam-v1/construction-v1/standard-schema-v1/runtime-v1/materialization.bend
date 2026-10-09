import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Structural
import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/materialization-v1/mail.bend as Mail
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Lifecycle
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def Store(~S:Data) -> Type:Col.Column<S,Business.Owner>
def Resource() -> Type:Mail.Mail<Business.Owner,Business.Owner>
def World(~S:Data) -> Type:W.World<S,Store(~S),Resource(),Unit>
def Owner(~S:Data) -> Type:Request.Owner<S,Store(~S),Resource(),Unit,Business.Owner,Business.identity(~S),Business.project>
def Out(~S:Data) -> Type:Constructed.Output<S,Input.Input,Business.Owner,Business.Error>
def take(~S:Data,value:Store(~S)) -> Unit & Col.Column<S,Business.Owner>:(Unit{},value)
def put(~S:Data,rest:Unit,value:Col.Column<S,Business.Owner>) -> Store(~S):value
def family(~S:Data) -> Cmp.Family<S,Store(~S),Unit,Business.Owner,D.Raw,Unit,take(~S),put(~S),Business.project>:Cmp.Family{"constructed-raw-owner"}
# The constructor already produced canonical P. Keep original input/sentinels.
def same(raw:D.Raw,value:Maybe<&1,Business.Owner>) -> Maybe<&1,Business.Owner>:value
def attempt(~S:Data,world:World(~S),target:W.Handle<S>,packet:Request.Packet<Business.Owner>) -> Delivery.Delivery<World(~S),Request.Packet<Business.Owner>>:
  Mail.attempt(~S,~Store(~S),~Business.Owner,~Unit,~Business.Owner,~Unit,~Unit,~take(~S),~put(~S),~Business.project,~family(~S),~same,~same,world,target,packet)
def recover(~S:Data,world:World(~S),packet:Request.Packet<Business.Owner>,error:W.WorldError) -> World(~S):Mail.recover(~S,~Store(~S),~Business.Owner,~Unit,~Business.Owner,world,packet,error)
def factory(~S:Data) -> Constructor.FallibleFactory<S,Input.Input,Business.Owner,Business.Error,Business.identity(~S),Business.project,Input.incoming,Business.build>:
  Constructor.fallible_factory_with_input_codec(~S,~Input.Input,~Business.Owner,~Business.Error,~Business.identity(~S),~Business.project,~Input.incoming,~Business.build,Decl.constructed(~S,~Business.Owner,~Business.identity(~S),~Business.project,Business.codec()),D.StringValue{})
def grants(~S:Data) -> Cap.OwnedRequest<Owner(~S),Constructed.Input<S,Input.Input>,Out(~S)>:
  Constructed.grant(~S,~Input.Input,~Business.Owner,~Business.Error,~Business.identity(~S),~Business.project,~Input.incoming,~Business.build,~factory(~S),~Owner(~S),~Request.grant(~S,~Store(~S),~Resource(),~Unit,~Business.Owner,~Business.identity(~S),~Business.project))
type Args<S:Data> is Type:Args{operation:Commands.Operation<S>,input:Input.Input,fail:Bool}
type Recovery<S:Data> is Type:Recovery{output:Out(~S),packets:List<Request.Packet<Business.Owner>>}
type State<S:Data> is Type:State{recoveries:List<Recovery<S>>}
def body_returned(~S:Data,~H:Type,fail:Bool,result:H & Out(~S)) -> H & (Out(~S) & Bool):
  match result:
    case (ctx,output):(ctx,(output,fail))
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Out(~S)>,args:Args<S>,ctx:H) -> H & (Out(~S) & Bool):
  match args:
    case Args{operation,input,fail}:body_returned(~S,~H,fail,Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Out(~S),~cap,ctx,Constructed.Input{operation,input}))
def retained(~S:Data,local:State<S>,output:Out(~S),packets:List<Request.Packet<Business.Owner>>) -> State<S>:
  match local:
    case State{previous}:State{Recovery{output,packets} <> previous}
def outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def invoked(~S:Data,local:State<S>,result:Owner(~S) & (Out(~S) & Bool)) -> Local.Outcome<World(~S),State<S>,Unit,Out(~S)>:
  match result:
    case (owner,(output,fail)):Completion.finish_deferred(~S,~Store(~S),~Resource(),~Unit,~Business.Owner,~Unit,~Business.identity(~S),~Business.project,~attempt(~S),~recover(~S),~State<S>,~Out(~S),~retained(~S),local,output,owner,outcome(fail))
def runner(~S:Data,world:World(~S),local:State<S>,args:Args<S>) -> Local.Outcome<World(~S),State<S>,Unit,Out(~S)>:
  invoked(~S,local,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Out(~S)>),~Args<S>,~(Out(~S) & Bool),~(H => cap => args => ctx => body(~S,~H,~cap,args,ctx)),~Owner(~S),~grants(~S),args,Completion.begin_owner(~S,~Store(~S),~Resource(),~Unit,~Business.Owner,~Business.identity(~S),~Business.project,world,Decl.constructed(~S,~Business.Owner,~Business.identity(~S),~Business.project,Business.codec()))))
def Instance(~S:Data) -> Type:Local.Instance<S,Store(~S),Resource(),Unit,State<S>,Args<S>,Unit,Out(~S),runner(~S)>
def define(~S:Data,world:World(~S)) -> Local.Registered<S,Store(~S),Resource(),Unit,State<S>,Args<S>,Unit,Out(~S),runner(~S)>:
  Completion.registered(~S,~Store(~S),~Resource(),~Unit,~State<S>,~Args<S>,~Unit,~Out(~S),~runner(~S),world,"constructed-materialization",Mail.access(~S,~Store(~S),~Business.Owner,~Unit,~Business.Owner,~Unit,~Unit,~Business.identity(~S),~Business.resource_identity(~S),~Business.project,~take(~S),~put(~S)),State{[]})

# All component slots/lifecycle stamps, mailbox owners and Local ownership.
type PacketView is Data:PacketView{owner:Maybe<&2,Business.View>,original:D.Raw,canonical:D.Raw}
def packet_join(+original:D.Raw,+canonical:D.Raw,value:Maybe<&1,Business.Owner> & Maybe<&2,Business.View>) -> Request.Packet<Business.Owner> & PacketView:
  match value:
    case (owner,view):(Request.Packet{owner,original,canonical},PacketView{view,original,canonical})
def option_some(value:Business.Owner & Business.View) -> Maybe<&1,Business.Owner> & Maybe<&2,Business.View>:
  match value:
    case (owner,view):(Some{owner},Some{view})
def option(value:Maybe<&1,Business.Owner>) -> Maybe<&1,Business.Owner> & Maybe<&2,Business.View>:
  match value:
    case None{}:(None{},None{})
    case Some{owner}:option_some(Business.view(owner))
def packet(value:Request.Packet<Business.Owner>) -> Request.Packet<Business.Owner> & PacketView:
  match value:
    case Request.Packet{owner,original,canonical}:packet_join(original,canonical,option(owner))
def packet_join_list(head:Request.Packet<Business.Owner> & PacketView,tail:List<Request.Packet<Business.Owner>> & List<&2,PacketView>) -> List<Request.Packet<Business.Owner>> & List<&2,PacketView>:
  match head tail:
    case (owner,a),(tail,b):(owner <> tail,a <> b)
def packets(value:List<Request.Packet<Business.Owner>>) -> List<Request.Packet<Business.Owner>> & List<&2,PacketView>:
  match value:
    case []:([],[])
    case head <> tail:packet_join_list(packet(head),packets(tail))
def owners_join(head:Business.Owner & Business.View,tail:List<Business.Owner> & List<&2,Business.View>) -> List<Business.Owner> & List<&2,Business.View>:
  match head tail:
    case (owner,a),(tail,b):(owner <> tail,a <> b)
def owners(value:List<Business.Owner>) -> List<Business.Owner> & List<&2,Business.View>:
  match value:
    case []:([],[])
    case head <> tail:owners_join(Business.view(head),owners(tail))
type MailView is Data:MailView{value:Business.View,retired:List<&2,Business.View>,returned:List<&2,PacketView>,errors:List<&2,W.WorldError>}
def mail_join(value:Business.Owner & Business.View,retired:List<Business.Owner> & List<&2,Business.View>,returned:List<Request.Packet<Business.Owner>> & List<&2,PacketView>,+errors:List<&2,W.WorldError>) -> Resource() & MailView:
  match value retired returned:
    case (value,a),(retired,b),(returned,c):(Mail.Mail{value,retired,returned,errors},MailView{a,b,c,errors})
def mail(value:Resource()) -> Resource() & MailView:
  match value:
    case Mail.Mail{value,retired,returned,+errors}:mail_join(Business.view(value),owners(retired),packets(returned),errors)
def slots_join(left:Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>,right:Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>) -> Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,Maybe<&2,Business.View>,a,b))
def slots_leaf(value:Maybe<&1,Business.Owner> & Maybe<&2,Business.View>) -> Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>:
  match value:
    case (owner,view):(ALeaf{owner},[view])
def slots(value:Array<Maybe<&1,Business.Owner>>) -> Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>:
  match value:
    case ALeaf{owner}:slots_leaf(option(owner))
    case ANode{left,right}:slots_join(slots(left),slots(right))
type ColumnView is Data:ColumnView{supported:Bool,slots:List<&2,Maybe<&2,Business.View>>,stamps:List<&2,Lifecycle.Entry>}
def column_join(~S:Data,+stamps:List<&2,Lifecycle.Entry>,value:Array<Maybe<&1,Business.Owner>> & List<&2,Maybe<&2,Business.View>>) -> Store(~S) & ColumnView:
  match value:
    case (slots,values):(Col.Column{slots,stamps},ColumnView{True{},values,stamps})
def column(~S:Data,value:Store(~S)) -> Store(~S) & ColumnView:
  match value:
    case Col.Column{values,stamps}:column_join(~S,stamps,slots(values))
    case value:(value,ColumnView{False{},[],[]})
type Snapshot is Data:Snapshot{meta:Input.Meta,live:List<&2,Bool>,column:ColumnView,mail:MailView,pending:U32}
def store_observed(~S:Data,value:Store(~S)) -> Store(~S) & ColumnView:column(~S,value)
def snapshot_store(~S:Data,view:MailView,world:World(~S) & ColumnView) -> World(~S) & (MailView & ColumnView):
  match world:
    case (world,column):(world,(view,column))
def snapshot_mail(~S:Data,value:World(~S) & MailView) -> World(~S) & (MailView & ColumnView):
  match value:
    case (world,view):snapshot_store(~S,view,W.with_store(~S,~Store(~S),~Resource(),~Unit,~ColumnView,store_observed(~S),world))
def snapshot_live(~S:Data,+meta:Input.Meta,store:Store(~S),resource:Resource(),pending:List<(World(~S) -> World(~S))>,view:MailView,column:ColumnView,count:U32,result:Array<Bool> & List<&2,Bool>) -> World(~S) & Snapshot:
  match meta result:
    case Input.Meta{ns,next,high,capacity,depth,events,registrations,system,clock},(live,values):(W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock},Snapshot{meta,values,column,view,count})
def snapshot_pending(~S:Data,view:MailView,column:ColumnView,result:World(~S) & U32) -> World(~S) & Snapshot:
  match result:
    case (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock},count):snapshot_live(~S,Input.Meta{ns,next,high,capacity,depth,events,registrations,system,clock},store,resource,pending,view,column,count,Input.array(~Bool,live))
def snapshot_observed(~S:Data,result:World(~S) & (MailView & ColumnView)) -> World(~S) & Snapshot:
  match result:
    case (world,(view,column)):snapshot_pending(~S,view,column,W.pending_count(~S,~Store(~S),~Resource(),~Unit,world))
def snapshot(~S:Data,world:World(~S)) -> World(~S) & Snapshot:
  snapshot_observed(~S,snapshot_mail(~S,W.observe_resource(~S,~Store(~S),~Resource(),~Unit,~MailView,~mail,world)))

type OperationView<S:Data> is Data:Accepted{target:W.Handle<S>,spawned:Bool,canonical:D.Raw,undoAvailable:Bool} Refused{owner:Maybe<&2,Input.InputView>,error:Constructed.Error<Business.Error>}
def input_some(value:Input.Input & Input.InputView) -> Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>:
  match value:
    case (owner,view):(Some{owner},Some{view})
def input_option(value:Maybe<&1,Input.Input>) -> Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>:
  match value:
    case None{}:(None{},None{})
    case Some{owner}:input_some(Input.input_view(owner))
def operation_refused(~S:Data,+error:Constructed.Error<Business.Error>,value:Maybe<&1,Input.Input> & Maybe<&2,Input.InputView>) -> Out(~S) & OperationView<S>:
  match value:
    case (owner,view):(Constructed.Refused{owner,error},Refused{view,error})
def operation(~S:Data,value:Out(~S)) -> Out(~S) & OperationView<S>:
  match value:
    case Constructed.Accepted{+target,+spawned,+canonical,undo}:(Constructed.Accepted{target,spawned,canonical,undo},Accepted{target,spawned,canonical,True{}})
    case Constructed.Refused{owner,error}:operation_refused(~S,error,input_option(owner))
type RecoveryView<S:Data> is Data:RecoveryView{output:OperationView<S>,packets:List<&2,PacketView>}
def recovery_join(~S:Data,output:Out(~S) & OperationView<S>,packets:List<Request.Packet<Business.Owner>> & List<&2,PacketView>) -> Recovery<S> & RecoveryView<S>:
  match output packets:
    case (output,a),(packets,b):(Recovery{output,packets},RecoveryView{a,b})
def recovery_view(~S:Data,value:Recovery<S>) -> Recovery<S> & RecoveryView<S>:
  match value:
    case Recovery{output,values}:recovery_join(~S,operation(~S,output),packets(values))
def recoveries_join(~S:Data,head:Recovery<S> & RecoveryView<S>,tail:List<Recovery<S>> & List<&2,RecoveryView<S>>) -> List<Recovery<S>> & List<&2,RecoveryView<S>>:
  match head tail:
    case (owner,a),(rest,b):(owner <> rest,a <> b)
def recoveries(~S:Data,value:List<Recovery<S>>) -> List<Recovery<S>> & List<&2,RecoveryView<S>>:
  match value:
    case []:([],[])
    case head <> tail:recoveries_join(~S,recovery_view(~S,head),recoveries(~S,tail))
type InstanceView<S:Data> is Data:InstanceView{namespace:U32,id:U32,name:String,access:List<&2,String>,recoveries:List<&2,RecoveryView<S>>}
def instance_join(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,value:List<Recovery<S>> & List<&2,RecoveryView<S>>) -> Instance(~S) & InstanceView<S>:
  match value:
    case (owner,view):(Local.Instance{namespace,id,name,access,State{owner}},InstanceView{namespace,id,name,access,view})
def instance_observe(~S:Data,value:Instance(~S)) -> Instance(~S) & InstanceView<S>:
  match value:
    case Local.Instance{namespace,id,name,access,State{values}}:instance_join(~S,namespace,id,name,access,recoveries(~S,values))
type ResultView<S:Data> is Data:Completed{output:OperationView<S>} Failed{error:Unit} Skipped{input:Input.InputView} RefusedInvocation{} Unavailable{}
def completed_view(~S:Data,value:Out(~S) & OperationView<S>) -> ResultView<S>:
  match value:
    case (_,output):Completed{output}
def result_view(~S:Data,value:Result<&2,&1,Unit,Out(~S)>) -> ResultView<S>:
  match value:
    case Fail{error}:Failed{error}
    case Done{output}:completed_view(~S,operation(~S,output))
type Report<S:Data> is Data:Report{before:Snapshot,committed:Snapshot,barrier:Snapshot,instance:InstanceView<S>,result:ResultView<S>} SetupRefused{}
def report(~S:Data,+before:Snapshot,+committed:Snapshot,result:ResultView<S>,world:World(~S) & Snapshot,value:Instance(~S) & InstanceView<S>) -> Report<S>:
  match world value:
    case (_,barrier),(_,instance):Report{before,committed,barrier,instance,result}
def barrier(~S:Data,before:Snapshot,result:ResultView<S>,instance:Instance(~S),value:World(~S) & Snapshot) -> Report<S>:
  match value:
    case (world,committed):report(~S,before,committed,result,snapshot(~S,W.barrier(~S,~Store(~S),~Resource(),~Unit,world)),instance_observe(~S,instance))
def ran(~S:Data,before:Snapshot,value:Local.Run<S,Store(~S),Resource(),Unit,State<S>,Args<S>,Unit,Out(~S),runner(~S)>) -> Report<S>:
  match value:
    case Local.Completed{world,instance,result}:barrier(~S,before,result_view(~S,result),instance,snapshot(~S,world))
    case Local.Refused{world,instance,args}:barrier(~S,before,RefusedInvocation{},instance,snapshot(~S,world))
type Mode is Data:Spawn{} Insert{} Failure{} FailedInsert{} Invalid{} LateMissing{} Skip{} ParseRejected{} WrongKind{} BadOutput{}
def fail(mode:Mode) -> Bool:
  match mode:
    case Failure{}:True{}
    case FailedInsert{}:True{}
    case _:False{}
def raw(mode:Mode) -> D.Raw:
  match mode:
    case ParseRejected{}:D.Text{"7;q"}
    case WrongKind{}:D.Number{7}
    case BadOutput{}:D.Text{"9,8"}
    case _:D.Text{"7,8"}
def action(~S:Data,mode:Mode,handle:W.Handle<S>) -> Commands.Operation<S>:
  match mode:
    case Insert{}:Commands.Insert{handle}
    case FailedInsert{}:Commands.Insert{handle}
    case _:Commands.Spawn{}
def skipped(~S:Data,before:Snapshot,instance:Instance(~S),world:World(~S),view:Input.Input & Input.InputView) -> Report<S>:
  match view:
    case (_,input):barrier(~S,before,Skipped{input},Local.skip(~S,~Store(~S),~Resource(),~Unit,~State<S>,~Args<S>,~Unit,~Out(~S),~runner(~S),instance),snapshot(~S,world))
def started(~S:Data,+incoming:D.Raw,+mode:Mode,handle:W.Handle<S>,instance:Instance(~S),value:World(~S) & Snapshot) -> Report<S>:
  match mode value:
    case Skip{},(world,before):skipped(~S,before,instance,world,Input.input_view(Input.input(incoming)))
    case mode,(world,before):ran(~S,before,Local.run(~S,~Store(~S),~Resource(),~Unit,~State<S>,~Args<S>,~Unit,~Out(~S),~runner(~S),instance,world,Args{action(~S,mode,handle),Input.input(incoming),fail(mode)}))
def registered(~S:Data,+incoming:D.Raw,mode:Mode,handle:W.Handle<S>,value:Local.Registered<S,Store(~S),Resource(),Unit,State<S>,Args<S>,Unit,Out(~S),runner(~S)>) -> Report<S>:
  match value:
    case Local.RegistrationRejected{_,_}:SetupRefused{}
    case Local.Registered{world,instance}:started(~S,incoming,mode,handle,instance,snapshot(~S,world))
def prepared(~S:Data,+incoming:D.Raw,mode:Mode,+target:W.Handle<S>,world:World(~S)) -> Report<S>:
  match mode:
    case LateMissing{}:registered(~S,incoming,mode,target,define(~S,W.enqueue(~S,~Store(~S),~Resource(),~Unit,world,w => Structural.despawn_apply(~S,~Store(~S),~Resource(),~Unit,w,target))))
    case _:registered(~S,incoming,mode,target,define(~S,world))
def seeded(~S:Data,+incoming:D.Raw,mode:Mode,target:W.Handle<S>,value:Cmp.Replacement<World(~S),Business.Owner>) -> Report<S>:
  match value:
    case Cmp.ReplaceRejected{_,_,_}:SetupRefused{}
    case Cmp.Replaced{world,previous}:prepared(~S,incoming,mode,target,Mail.retire(~S,~Store(~S),~Business.Owner,~Unit,~Business.Owner,previous,world))
def active(~S:Data,+incoming:D.Raw,mode:Mode,+target:W.Handle<S>,value:World(~S) & W.Status) -> Report<S>:
  match value:
    case (_,W.Rejected{_}):SetupRefused{}
    case (world,W.Accepted{}):seeded(~S,incoming,mode,target,Cmp.replace(~S,~Store(~S),~Resource(),~Unit,~Unit,~Business.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Business.project,family(~S),world,target,Some{Business.owned(7,99)}))
def reserved(~S:Data,+incoming:D.Raw,mode:Mode,value:World(~S) & W.Reservation<S>) -> Report<S>:
  match value:
    case (_,W.ReservationRejected{_}):SetupRefused{}
    case (world,W.Reserved{+target}):active(~S,incoming,mode,target,W.activate(~S,~Store(~S),~Resource(),~Unit,world,target))
def created(~S:Data,+incoming:D.Raw,mode:Mode,value:W.Creation<S,Store(~S),Resource(),Unit>) -> Report<S>:
  match value:
    case W.CreateRejected{_,_}:SetupRefused{}
    case W.Created{_,world}:reserved(~S,incoming,mode,W.reserve_id(~S,~Store(~S),~Resource(),~Unit,world))
def empty(~S:Data,u:Unit) -> Store(~S):Col.empty(~S,~Business.Owner)
def run(~S:Data,+incoming:D.Raw,mode:Mode) -> Report<S>:created(~S,incoming,mode,W.create(~S,~Store(~S),~Resource(),~Unit,~empty(~S),W.factory(),Mail.Mail{Business.owned(7,100),[],[],[]}))
