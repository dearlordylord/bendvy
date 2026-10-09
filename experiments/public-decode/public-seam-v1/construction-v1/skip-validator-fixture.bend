import Base
import ./skip-validator/constructor.bend as Constructor
import ./resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as ExistingResource

type First is Data:First{}
type Second is Data:Second{}
type Input is Type:Input{raw:D.Raw,words:Array<U32>,flags:Array<Bool>}
type Owner is Type:Owner{raw:D.Raw,original:D.Raw,words:Array<U32>,flags:Array<Bool>}
type View is Data:View{raw:D.Raw,original:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
type InputView is Data:InputView{raw:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
def input(raw:D.Raw) -> Input:Input{raw,ANode{ALeaf{71},ALeaf{72}},ANode{ALeaf{True{}},ALeaf{False{}}}}
def incoming(value:Input) -> Input & D.Raw:
  match value:
    case Input{+raw,words,flags}:(Input{raw,words,flags},raw)
def project(value:Owner) -> Owner & D.Raw:
  match value:
    case Owner{+raw,original,words,flags}:(Owner{raw,original,words,flags},raw)
def undo(value:Owner) -> Input:
  match value:
    case Owner{_,original,words,flags}:Input{original,words,flags}
def build(value:Input,canonical:D.Raw) -> Build.Construction<Input,Owner,D.Error>:
  match value:
    case Input{original,words,flags}:Build.Constructed{Owner{canonical,original,words,flags},undo}
def identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"constructed-raw-owner")
def resource_identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"constructed-raw-resource")
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input,Build.Construction<Input,Owner,D.Error>>,value:Input,ctx:H) -> H & Build.Construction<Input,Owner,D.Error>:
  Cap.owned_request(~H,~Input,~Build.Construction<Input,Owner,D.Error>,~cap,ctx,value)
def joined(~V:Data,left:Array<V> & List<&2,V>,right:Array<V> & List<&2,V>) -> Array<V> & List<&2,V>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,V,a,b))
def array(~V:Data,owner:Array<V>) -> Array<V> & List<&2,V>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:joined(~V,array(~V,left),array(~V,right))
def flagged(+raw:D.Raw,+original:D.Raw,words:Array<U32>,list:List<&2,U32>,value:Array<Bool> & List<&2,Bool>) -> Owner & View:
  match value:
    case (flags,values):(Owner{raw,original,words,flags},View{raw,original,list,values})
def words(+raw:D.Raw,+original:D.Raw,flags:Array<Bool>,value:Array<U32> & List<&2,U32>) -> Owner & View:
  match value:
    case (words,list):flagged(raw,original,words,list,array(~Bool,flags))
def view(value:Owner) -> Owner & View:
  match value:
    case Owner{raw,original,values,flags}:words(raw,original,flags,array(~U32,values))
def input_flagged(+raw:D.Raw,words:Array<U32>,list:List<&2,U32>,value:Array<Bool> & List<&2,Bool>) -> Input & InputView:
  match value:
    case (flags,values):(Input{raw,words,flags},InputView{raw,list,values})
def input_words(+raw:D.Raw,flags:Array<Bool>,value:Array<U32> & List<&2,U32>) -> Input & InputView:
  match value:
    case (words,list):input_flagged(raw,words,list,array(~Bool,flags))
def input_view(value:Input) -> Input & InputView:
  match value:
    case Input{raw,words,flags}:input_words(raw,flags,array(~U32,words))
type ConstructedView is Data:Constructed{owner:View,recovered:InputView} Rejected{input:InputView,error:D.Error}
def rejected(error:D.Error,value:Input & InputView) -> ConstructedView:
  match value:
    case (_,view):Rejected{view,error}
def restored(owner:View,value:Input & InputView) -> ConstructedView:
  match value:
    case (_,input):Constructed{owner,input}
def constructed(reverse:Owner -> Input,value:Owner & View) -> ConstructedView:
  match value:
    case (owner,view):restored(view,input_view(reverse(owner)))
def observe(result:Build.Construction<Input,Owner,D.Error>) -> ConstructedView:
  match result:
    case Build.Invalid{raw,error}:rejected(error,input_view(raw))
    case Build.Constructed{cooked,reverse}:constructed(reverse,view(cooked))
def invoked(~S:Data,result:Constructor.Factory<S,Input,Owner,identity(~S),project,incoming,build> & Build.Construction<Input,Owner,D.Error>) -> ConstructedView:
  match result:
    case (_,result):observe(result)
def construct(~S:Data,codec:D.Codec,raw:D.Raw) -> ConstructedView:
  invoked(~S,Constructor.invoke(~S,~Input,~Owner,~identity(~S),~project,~incoming,~build,~Input,~Build.Construction<Input,Owner,D.Error>,~(H => cap => input => ctx => body(~H,~cap,input,ctx)),Constructor.factory(~S,~Input,~Owner,~identity(~S),~project,~incoming,~build,Decl.constructed(~S,~Owner,~identity(~S),~project,codec)),input(raw)))

# Actual validated resource mutation via abstract H on the real core frame.
def resource_body(~H:Type,~cap:Cap.OwnedRequest<H,Owner,Resource.Output<Owner>>,replacement:Owner,ctx:H) -> H & Resource.Output<Owner>:
  Cap.owned_request(~H,~Owner,~Resource.Output<Owner>,~cap,ctx,replacement)
def grants(~S:Data,~codec:D.Codec) -> Cap.OwnedRequest<F.Frame<S,Unit,Owner,Unit,Owner,Unit,identity(~S),project>,Owner,Resource.Output<Owner>>:
  Resource.grant(~S,~Unit,~Owner,~Unit,~Owner,~Unit,~identity(~S),~project,~resource_identity(~S),~project,~Decl.constructed(~S,~Owner,~resource_identity(~S),~project,codec))
type ResourceResult is Data:Replaced{canonical:D.Raw} Refused{owner:View,error:D.Error}
def refused_resource(error:D.Error,value:Owner & View) -> ResourceResult:
  match value:
    case (_,view):Refused{view,error}
def resource_result(value:Resource.Output<Owner>) -> ResourceResult:
  match value:
    case Resource.Replaced{raw}:Replaced{raw}
    case Resource.Refused{owner,error}:refused_resource(error,view(owner))
type Meta is Data:Meta{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Snapshot is Data:Snapshot{meta:Meta,live:List<&2,Bool>,store:Unit,resource:View,pending:U32}
def snapshot_pending(~S:Data,meta:Meta,view:View,live:List<&2,Bool>,value:W.World<S,Unit,Owner,Unit> & U32) -> W.World<S,Unit,Owner,Unit> & Snapshot:
  match value:
    case (world,pending):(world,Snapshot{meta,live,Unit{},view,pending})
def snapshot_live(~S:Data,+meta:Meta,store:Unit,resource:Owner,pending:List<(W.World<S,Unit,Owner,Unit> -> W.World<S,Unit,Owner,Unit>)>,view:View,live:Array<Bool> & List<&2,Bool>) -> W.World<S,Unit,Owner,Unit> & Snapshot:
  match meta live:
    case Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},(live,values):snapshot_pending(~S,Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},view,values,W.pending_count(~S,~Unit,~Owner,~Unit,W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}))
def snapshot_resource(~S:Data,value:W.World<S,Unit,Owner,Unit> & View) -> W.World<S,Unit,Owner,Unit> & Snapshot:
  match value:
    case (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},view):snapshot_live(~S,Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},store,resource,pending,view,array(~Bool,live))
def snapshot(~S:Data,world:W.World<S,Unit,Owner,Unit>) -> W.World<S,Unit,Owner,Unit> & Snapshot:
  snapshot_resource(~S,W.observe_resource(~S,~Unit,~Owner,~Unit,~View,~view,world))
type ResourceReport is Data:ResourceReport{before:Snapshot,after:Snapshot,result:ResourceResult,outcome:T.Outcome<Unit>,pending:U32,undoCount:Nat} CreateRefused{}
def report(~S:Data,before:Snapshot,result:ResourceResult,outcome:T.Outcome<Unit>,pending:U32,count:Nat,value:W.World<S,Unit,Owner,Unit> & Snapshot) -> ResourceReport:
  match value:
    case (_,after):ResourceReport{before,after,result,outcome,pending,count}
def completed(~S:Data,before:Snapshot,result:ResourceResult,pending:U32,count:Nat,value:T.Returned<W.World<S,Unit,Owner,Unit>,Unit>) -> ResourceReport:
  match value:
    case T.Returned{world,outcome}:report(~S,before,result,outcome,pending,count,snapshot(~S,world))
def outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def counted(~S:Data,before:Snapshot,fail:Bool,world:W.World<S,Unit,Owner,Unit>,commands:List<(W.World<S,Unit,Owner,Unit> -> W.World<S,Unit,Owner,Unit>)>,events:List<&2,Unit>,pending:U32,output:Resource.Output<Owner>,result:List<(W.World<S,Unit,Owner,Unit> -> W.World<S,Unit,Owner,Unit>)> & Nat) -> ResourceReport:
  match result:
    case (undo,count):completed(~S,before,resource_result(output),pending,count,Commands.tx_finish(~S,~Unit,~Owner,~Unit,~Unit,T.Tx{world,undo,commands,events},outcome(fail)))
def returned(~S:Data,before:Snapshot,fail:Bool,result:F.Frame<S,Unit,Owner,Unit,Owner,Unit,identity(~S),project> & Resource.Output<Owner>) -> ResourceReport:
  match result:
    case (F.Frame{Request.Owner{Batch.Batch{T.Tx{world,undo,commands,events},prepared},_},_,_,_,_,_},output):counted(~S,before,fail,world,commands,events,U32.from_nat(List.length(&1,Batch.Prepared<S,Request.Packet<Owner>>,prepared)),output,Batch.count_commands(~W.World<S,Unit,Owner,Unit>,undo))
def before(~S:Data,~codec:D.Codec,replacement:Owner,fail:Bool,result:W.World<S,Unit,Owner,Unit> & Snapshot) -> ResourceReport:
  match result:
    case (world,before):returned(~S,before,fail,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Owner,Resource.Output<Owner>>),~Owner,~Resource.Output<Owner>,~(H => cap => replacement => ctx => resource_body(~H,~cap,replacement,ctx)),~F.Frame<S,Unit,Owner,Unit,Owner,Unit,identity(~S),project>,~grants(~S,~codec),replacement,Completion.begin_frame(~S,~Unit,~Owner,~Unit,~Owner,~Unit,~identity(~S),~project,world,Decl.constructed(~S,~Owner,~identity(~S),~project,D.Integer{}))))
def created(~S:Data,~codec:D.Codec,replacement:Owner,fail:Bool,value:W.Creation<S,Unit,Owner,Unit>) -> ResourceReport:
  match value:
    case W.CreateRejected{_,_}:CreateRefused{}
    case W.Created{_,world}:before(~S,~codec,replacement,fail,snapshot(~S,world))
def owned(+raw:D.Raw) -> Owner:Owner{raw,raw,ANode{ALeaf{81},ALeaf{82}},ANode{ALeaf{False{}},ALeaf{True{}}}}
def resource(~S:Data,~codec:D.Codec,raw:D.Raw,fail:Bool) -> ResourceReport:
  created(~S,~codec,owned(raw),fail,W.create(~S,~Unit,~Owner,~Unit,~(u => Unit{}),W.factory(),owned(D.Number{100})))
def nested() -> D.Codec:D.Struct{[D.NamedCodec{"items",D.ArrayValue{D.Nullable{D.Literal{D.Number{7}}}}}]}
def valid() -> D.Raw:D.Object{[D.Field{"items",D.Array{[D.Number{7},D.Null{}]}},D.Field{"extra",D.Text{"discarded"}}]}
def invalid() -> D.Raw:D.Object{[D.Field{"items",D.Array{[D.Number{7},D.Text{"wrong"}]}}]}
type Cases is Data:Cases{constructed:ConstructedView,rejected:ConstructedView,handle:ConstructedView,foreign:ConstructedView,resource:ResourceReport,invalidResource:ResourceReport,abortedResource:ResourceReport}
def cases(~S:Data) -> Cases:
  Cases{construct(~S,nested(),valid()),construct(~S,nested(),invalid()),construct(~S,D.HandleValue{1},D.Handle{1,4}),construct(~S,D.HandleValue{1},D.Handle{2,4}),resource(~S,~D.Integer{},D.Number{200},False{}),resource(~S,~nested(),invalid(),False{}),resource(~S,~D.Integer{},D.Number{300},True{})}
type Candidate is Data:Candidate{first:Cases,second:Cases}
def main() -> Candidate:Candidate{cases(~First),cases(~Second)}
