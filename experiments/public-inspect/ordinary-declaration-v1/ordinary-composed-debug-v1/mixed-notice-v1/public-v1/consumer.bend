import Base
import ./state.bend as F
import ./event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import ./operations.bend as Operations
import ./physical.bend as Physical
import ./common.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as Owner

type ReaderView is Data:ReaderView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,keys:List<&2,Domains.DescriptorKey<F.S>>}
type Checkpoint is Data:Checkpoint{description:Maybe<&2,SchemaApp.Description<F.S,Common.Rows()>>,inventory:Maybe<&2,List<&2,String>>,physical:Physical.View,reader:ReaderView,args:String}
type Report is Data:Report{factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,checkpoints:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>}
type State is Type:State{runtime:Events.Runtime(),reader:Operations.Reader(),args:Array<U32>,checkpoints:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>}
def reader_view(value:Operations.Reader()) -> Operations.Reader() & ReaderView:
  match value:
    case K.Reader{Sys.Registry{+ns,+id,+name,+access,+cursor},+keys}:(K.Reader{Sys.Registry{ns,id,name,access,cursor},keys},ReaderView{ns,id,name,access,cursor,keys})
def observed(description:Maybe<&2,SchemaApp.Description<F.S,Common.Rows()>>,inventory:Maybe<&2,List<&2,String>>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,runtime:Events.Runtime() & Physical.View,reader:Operations.Reader() & ReaderView,args:Array<U32> & String) -> State:
  match runtime reader args:
    case (runtime,physical),(reader,readerView),(args,argsText):State{runtime,reader,args,List.append(&2,Checkpoint,before,[Checkpoint{description,inventory,physical,readerView,argsText}]),deliveries}
def inventoried(description:Maybe<&2,SchemaApp.Description<F.S,Common.Rows()>>,reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,result:Common.Application() & Maybe<&2,List<&2,String>>) -> State:
  match result:
    case (app,inventory):observed(description,inventory,before,deliveries,Physical.runtime(Common.detach(app)),reader_view(reader),Owner.u32_array(args))
def described(reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,result:Common.Application() & Maybe<&2,SchemaApp.Description<F.S,Common.Rows()>>) -> State:
  match result:
    case (app,description):inventoried(description,reader,args,before,deliveries,Common.inventory(app))
def checkpoint(state:State,flag:Bool) -> State:
  match state:
    case State{runtime,reader,args,before,deliveries}:described(reader,args,before,deliveries,Common.snapshot(Common.enabled(Common.attach(runtime),flag)))
def framed(state:State) -> State:
  match state:
    case State{runtime,reader,args,before,deliveries}:State{Mixed.frame(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.frame(),~Events.retain(),runtime),reader,args,before,deliveries}
def failure_framed(state:State) -> State:
  match state:
    case State{runtime,reader,args,before,deliveries}:State{Mixed.frame_failures(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,runtime),reader,args,before,deliveries}
def finish(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,state:State) -> Report:
  match state:
    case State{_,_,_,checkpoints,deliveries}:Report{factory,handle,activation,queued,checkpoints,deliveries}
def final_frames(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,state:State) -> Report:
  finish(factory,handle,activation,queued,checkpoint(failure_framed(checkpoint(failure_framed(checkpoint(framed(checkpoint(framed(checkpoint(checkpoint(state,True{}),False{})),True{})),True{})),True{})),True{}))
def synchronized_after(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,+tick:Nat,returned:F.World() & Events.State()) -> Report:
  match returned:
    case (world,state):final_frames(factory,handle,activation,queued,checkpoint(State{Route.Runtime{world,state,tick},reader,args,before,deliveries},True{}))
def publish_after(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,state:State) -> Report:
  match state:
    case State{Route.Runtime{world,family,_},reader,args,before,deliveries}:synchronized_after(factory,handle,activation,queued,reader,args,before,deliveries,2n,Events.synchronize(Operations.pending(Operations.publish_after(world)),family,2n))
def read_completed(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,held:Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,result:K.RunResult<F.S,F.Store(),F.Resources(),F.Events(),Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Operations.runner>) -> Maybe<&2,Report>:
  match result:
    case K.Ran{runtime,reader,K.Succeeded{(args,readings)}}:Some{publish_after(factory,handle,activation,queued,checkpoint(State{Mixed.failure_returned(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,held,runtime),reader,args,before,List.append(&2,List<&2,Read.KeyReading<F.S,F.Events()>>,deliveries,[readings])},True{}))}
    case _:None{}
def read_detached(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,detached:K.Runtime<F.S,F.Store(),F.Resources(),F.Events()> & (Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat)) -> Maybe<&2,Report>:
  match detached:
    case (runtime,held):read_completed(factory,handle,activation,queued,held,before,deliveries,K.run(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,~Operations.classify,runtime,reader,args))
def read_failures(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,state:State) -> Maybe<&2,Report>:
  match state:
    case State{runtime,reader,args,before,deliveries}:read_detached(factory,handle,activation,queued,reader,args,before,deliveries,Mixed.failure_runtime(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,runtime))
def barrier_detached(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,detached:K.Runtime<F.S,F.Store(),F.Resources(),F.Events()> & (Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat)) -> Maybe<&2,Report>:
  match detached:
    case (runtime,held):read_failures(factory,handle,activation,queued,checkpoint(State{Mixed.failure_returned(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,held,K.barrier(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Operations.classify,runtime)),reader,args,before,deliveries},True{}))
def barrier(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,state:State) -> Maybe<&2,Report>:
  match state:
    case State{runtime,reader,args,before,deliveries}:barrier_detached(factory,handle,activation,queued,reader,args,before,deliveries,Mixed.failure_runtime(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,runtime))
def synchronized_before(factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Relation.QueueStatus,reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,returned:F.World() & Events.State()) -> Maybe<&2,Report>:
  match returned:
    case (world,state):barrier(factory,handle,activation,queued,checkpoint(State{Route.Runtime{world,state,1n},reader,args,before,deliveries},True{}))
def queued_before(factory:U32,handle:W.Handle<F.S>,activation:W.Status,family:Events.State(),reader:Operations.Reader(),args:Array<U32>,before:List<&2,Checkpoint>,deliveries:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,returned:F.World() & Relation.QueueStatus) -> Maybe<&2,Report>:
  match returned:
    case (world,queued):synchronized_before(factory,handle,activation,queued,reader,args,before,deliveries,Events.synchronize(Operations.publish_before(world),family,1n))
def queue_before(factory:U32,+handle:W.Handle<F.S>,activation:W.Status,state:State) -> Maybe<&2,Report>:
  match state:
    case State{Route.Runtime{world,family,_},reader,args,before,deliveries}:queued_before(factory,handle,activation,family,reader,args,before,deliveries,Operations.queue_self(world,handle))
def registered(factory:U32,handle:W.Handle<F.S>,activation:W.Status,held:Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat,result:K.Registered<F.S,F.Store(),F.Resources(),F.Events(),Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Operations.runner>) -> Maybe<&2,Report>:
  match result:
    case K.Registered{runtime,reader}:queue_before(factory,handle,activation,checkpoint(State{Mixed.failure_returned(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,held,runtime),reader,ANode{ALeaf{101},ALeaf{102}},[],[]},True{}))
    case _:None{}
def register_detached(factory:U32,handle:W.Handle<F.S>,activation:W.Status,detached:K.Runtime<F.S,F.Store(),F.Resources(),F.Events()> & (Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat)) -> Maybe<&2,Report>:
  match detached:
    case (runtime,held):registered(factory,handle,activation,held,Decl.register(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,runtime,[F.parent()],"ParentFailures"))
def activated(factory:U32,handle:W.Handle<F.S>,returned:F.World() & W.Status) -> Maybe<&2,Report>:
  match returned:
    case (world,activation):register_detached(factory,handle,activation,Mixed.failure_runtime(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,Events.setup(world,ANode{ALeaf{31},ALeaf{32}})))
def reserved(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,W.Reserved{+handle}):activated(factory,handle,W.activate(~F.S,~F.Store(),~F.Resources(),~F.Events(),world,handle))
    case _:None{}
def created(result:W.Creation<F.S,F.Store(),F.Resources(),F.Events()>) -> Maybe<&2,Report>:
  match result:
    case W.Created{W.Factory{factory},world}:reserved(factory,W.reserve_id(~F.S,~F.Store(),~F.Resources(),~F.Events(),world))
    case _:None{}
def run() -> Maybe<&2,Report>:created(W.create(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.empty,W.factory(),ANode{ALeaf{81},ALeaf{82}}))
