import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-resource.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def Frame(~S:Data) -> Type:F.Frame<S,Unit,Business.Owner,Unit,Business.Owner,Unit,Business.identity(~S),Business.project>
def factory(~S:Data) -> Constructor.FallibleFactory<S,Input.Input,Business.Owner,Business.Error,Business.resource_identity(~S),Business.project,Input.incoming,Business.build>:
  Constructor.fallible_factory_with_input_codec(~S,~Input.Input,~Business.Owner,~Business.Error,~Business.resource_identity(~S),~Business.project,~Input.incoming,~Business.build,Decl.constructed(~S,~Business.Owner,~Business.resource_identity(~S),~Business.project,Business.codec()),D.StringValue{})
def lower(~S:Data) -> Cap.OwnedRequest<Frame(~S),Business.Owner,Resource.Output<Business.Owner>>:
  Resource.grant(~S,~Unit,~Business.Owner,~Unit,~Business.Owner,~Unit,~Business.identity(~S),~Business.project,~Business.resource_identity(~S),~Business.project,~Decl.constructed(~S,~Business.Owner,~Business.resource_identity(~S),~Business.project,Business.codec()))
def grants(~S:Data) -> Cap.OwnedRequest<Frame(~S),Input.Input,Constructed.Output<Input.Input,Business.Owner,Business.Error>>:
  Constructed.grant(~S,~Input.Input,~Business.Owner,~Business.Error,~Business.resource_identity(~S),~Business.project,~Input.incoming,~Business.build,~factory(~S),~Frame(~S),~lower(~S))
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input.Input,Constructed.Output<Input.Input,Business.Owner,Business.Error>>,input:Input.Input,ctx:H) -> H & Constructed.Output<Input.Input,Business.Owner,Business.Error>:
  Cap.owned_request(~H,~Input.Input,~Constructed.Output<Input.Input,Business.Owner,Business.Error>,~cap,ctx,input)
type ResultView is Data:Replaced{canonical:D.Raw,undoAvailable:Bool} Refused{owner:Input.InputView,error:Constructed.Error<Business.Error>}
def refused(error:Constructed.Error<Business.Error>,input:Input.Input & Input.InputView) -> ResultView:
  match input:
    case (_,view):Refused{view,error}
def result(value:Constructed.Output<Input.Input,Business.Owner,Business.Error>) -> ResultView:
  match value:
    case Constructed.Replaced{canonical,undo}:Replaced{canonical,True{}}
    case Constructed.Refused{owner,error}:refused(error,Input.input_view(owner))
type Snapshot is Data:Snapshot{meta:Input.Meta,live:List<&2,Bool>,store:Unit,resource:Business.View,pending:U32}
def snapshot_pending(~S:Data,meta:Input.Meta,view:Business.View,live:List<&2,Bool>,value:W.World<S,Unit,Business.Owner,Unit> & U32) -> W.World<S,Unit,Business.Owner,Unit> & Snapshot:
  match value:
    case (world,pending):(world,Snapshot{meta,live,Unit{},view,pending})
def snapshot_live(~S:Data,+meta:Input.Meta,store:Unit,resource:Business.Owner,pending:List<(W.World<S,Unit,Business.Owner,Unit> -> W.World<S,Unit,Business.Owner,Unit>)>,view:Business.View,live:Array<Bool> & List<&2,Bool>) -> W.World<S,Unit,Business.Owner,Unit> & Snapshot:
  match meta live:
    case Input.Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},(live,values):snapshot_pending(~S,Input.Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},view,values,W.pending_count(~S,~Unit,~Business.Owner,~Unit,W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}))
def snapshot_resource(~S:Data,value:W.World<S,Unit,Business.Owner,Unit> & Business.View) -> W.World<S,Unit,Business.Owner,Unit> & Snapshot:
  match value:
    case (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},view):snapshot_live(~S,Input.Meta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},store,resource,pending,view,Input.array(~Bool,live))
def snapshot(~S:Data,world:W.World<S,Unit,Business.Owner,Unit>) -> W.World<S,Unit,Business.Owner,Unit> & Snapshot:
  snapshot_resource(~S,W.observe_resource(~S,~Unit,~Business.Owner,~Unit,~Business.View,~Business.view,world))

type Report is Data:Report{before:Snapshot,after:Snapshot,result:ResultView,completion:T.Outcome<Unit>} CreateRefused{}
def report(~S:Data,before:Snapshot,result:ResultView,completion:T.Outcome<Unit>,value:W.World<S,Unit,Business.Owner,Unit> & Snapshot) -> Report:
  match value:
    case (_,after):Report{before,after,result,completion}
def completed(~S:Data,before:Snapshot,result:ResultView,value:T.Returned<W.World<S,Unit,Business.Owner,Unit>,Unit>) -> Report:
  match value:
    case T.Returned{world,outcome}:report(~S,before,result,outcome,snapshot(~S,world))
def invoked(~S:Data,before:Snapshot,fail:Bool,value:Frame(~S) & Constructed.Output<Input.Input,Business.Owner,Business.Error>) -> Report:
  match value:
    case (F.Frame{Request.Owner{Batch.Batch{tx,[]},_},_,_,_,[],[]},output):completed(~S,before,result(output),Commands.tx_finish(~S,~Unit,~Business.Owner,~Unit,~Unit,tx,Input.outcome(fail)))
    case (_,output):CreateRefused{}
def observed(~S:Data,input:Input.Input,fail:Bool,value:W.World<S,Unit,Business.Owner,Unit> & Snapshot) -> Report:
  match value:
    case (world,before):invoked(~S,before,fail,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input.Input,Constructed.Output<Input.Input,Business.Owner,Business.Error>>),~Input.Input,~Constructed.Output<Input.Input,Business.Owner,Business.Error>,~(H => cap => input => ctx => body(~H,~cap,input,ctx)),~Frame(~S),~grants(~S),input,Completion.begin_frame(~S,~Unit,~Business.Owner,~Unit,~Business.Owner,~Unit,~Business.identity(~S),~Business.project,world,Decl.constructed(~S,~Business.Owner,~Business.identity(~S),~Business.project,Business.codec()))))
def created(~S:Data,raw:D.Raw,fail:Bool,value:W.Creation<S,Unit,Business.Owner,Unit>) -> Report:
  match value:
    case W.CreateRejected{_,_}:CreateRefused{}
    case W.Created{_,world}:observed(~S,Input.input(raw),fail,snapshot(~S,world))
def run(~S:Data,raw:D.Raw,fail:Bool) -> Report:created(~S,raw,fail,W.create(~S,~Unit,~Business.Owner,~Unit,~(u => Unit{}),W.factory(),Business.owned(7,100)))
