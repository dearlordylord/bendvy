import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Deferred
import /workspace/formal-proofs/bendvy/src/ecs/query-contract.bend as Selection
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/decode-owned-journal.bend as Journal
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/owner.bend as Input
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

def instance_view(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,value:Local.Instance<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>) -> App.InstanceView<S>:
  match value:
    case Local.Instance{namespace,id,name,access,App.State{values,pending}}:App.InstanceView{(namespace+1:U32),id,name,access,App.recoveries(~S,values),App.pending_view(pending)}
def reported(~S:Data,original:Input.InputView,before:App.Snapshot,committed:App.Snapshot,instance:App.InstanceView<S>,result:App.ResultView<S>,world:App.World(~S) & App.Snapshot) -> App.Report<S>:
  match world:
    case (_,barrier):App.Report{original,before,committed,barrier,instance,result}
def barrier(~S:Data,original:Input.InputView,before:App.Snapshot,instance:App.InstanceView<S>,result:App.ResultView<S>,world:App.World(~S) & App.Snapshot) -> App.Report<S>:
  match world:
    case (world,committed):reported(~S,original,before,committed,instance,result,App.snapshot(~S,App.observed_barrier(~S,world)))
def invocation_refused_view(~S:Data,original:Input.InputView,before:App.Snapshot,world:App.World(~S),instance:App.InstanceView<S>,op:App.Mode,target:W.Handle<S>,input:Input.Input & Input.InputView) -> App.Report<S>:
  match input:
    case (_,view):barrier(~S,original,before,instance,App.InvocationRefused{view,op,target},App.snapshot(~S,world))
def invocation_refused(~S:Data,original:Input.InputView,before:App.Snapshot,world:App.World(~S),instance:App.InstanceView<S>,args:App.Args<S>) -> App.Report<S>:
  match args:
    case App.Args{op,target,owner}:invocation_refused_view(~S,original,before,world,instance,op,target,Input.input_view(owner))

def published_main(~S:Data,original:Input.InputView,before:App.Snapshot,instance:App.InstanceView<S>,value:App.World(~S) & App.ResultView<S>) -> App.Report<S>:
  match value:
    case (world,result):barrier(~S,original,before,instance,result,App.snapshot(~S,world))
def ran(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,original:Input.InputView,before:App.Snapshot,value:Local.Run<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>) -> App.Report<S>:
  match value:
    case Local.Completed{world,instance,result}:published_main(~S,original,before,instance_view(~S,~run,instance),App.published_result(~S,world,App.result_view(~S,result)))
    case Local.Refused{world,instance,args}:invocation_refused(~S,original,before,world,instance_view(~S,~run,instance),args)
def started(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,op:App.Mode,target:W.Handle<S>,instance:Local.Instance<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>,input:Input.Input & Input.InputView,world:App.World(~S) & App.Snapshot) -> App.Report<S>:
  match input world:
    case (input,original),(world,before):ran(~S,~run,original,before,Local.run(~S,~App.Store<S>,~Input.Owner,~Unit,~App.State<S>,~App.Args<S>,~Unit,~App.Output<S>,~run,instance,world,App.Args{op,target,input}))
# The two selection passes match TS each().length then each()[0]; only the
# selected declared Value row supplies the immediate-write target.
def selected_again(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,raw:D.Raw,instance:Local.Instance<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>,value:Selection.Scanned<S,App.Store<S>,Input.Owner,Unit>) -> App.Report<S>:
  match value:
    case Selection.Scanned{world,target <> []}:started(~S,~run,App.Insert{},target,instance,Input.input_view(Input.input(raw)),App.snapshot(~S,world))
    case _:App.SetupRefused{}
def selected_once(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,raw:D.Raw,instance:Local.Instance<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>,value:Selection.Scanned<S,App.Store<S>,Input.Owner,Unit>) -> App.Report<S>:
  match value:
    case Selection.Scanned{world,_ <> []}:selected_again(~S,~run,raw,instance,Selection.scan(~S,~App.Store<S>,~Input.Owner,~Unit,~App.ScanOps,~App.scan_plan(~S),world,0))
    case _:App.SetupRefused{}
def ordinary_started(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,op:App.Mode,target:W.Handle<S>,raw:D.Raw,instance:Local.Instance<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>,world:App.World(~S)) -> App.Report<S>:
  match op:
    case App.Insert{}:selected_once(~S,~run,raw,instance,Selection.scan(~S,~App.Store<S>,~Input.Owner,~Unit,~App.ScanOps,~App.scan_plan(~S),world,0))
    case _:started(~S,~run,op,target,instance,Input.input_view(Input.input(raw)),App.snapshot(~S,world))
def registered(~S:Data,~run:App.World(~S) -> App.State<S> -> App.Args<S> -> Local.Outcome<App.World(~S),App.State<S>,Unit,App.Output<S>>,op:App.Mode,target:W.Handle<S>,raw:D.Raw,value:Local.Registered<S,App.Store<S>,Input.Owner,Unit,App.State<S>,App.Args<S>,Unit,App.Output<S>,run>) -> App.Report<S>:
  match value:
    case Local.Registered{world,instance}:ordinary_started(~S,~run,op,target,raw,instance,world)
    case Local.RegistrationRejected{_,_}:App.SetupRefused{}
def seeded(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,+target:W.Handle<S>,value:Cmp.Replacement<App.World(~S),Input.Owner>) -> App.Report<S>:
  match value:
    case Cmp.ReplaceRejected{_,_,_}:App.SetupRefused{}
    case Cmp.Replaced{world,_}:registered(~S,~App.runner(~S,~codec),op,target,raw,Completion.registered(~S,~App.Store<S>,~Input.Owner,~Unit,~App.State<S>,~App.Args<S>,~Unit,~App.Output<S>,~App.runner(~S,~codec),W.enqueue(~S,~App.Store<S>,~Input.Owner,~Unit,world,w => App.marker_apply(~S,w,target)),"application32",["Value","Resource","Marker"],App.State{[],[]}))
def active(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,+target:W.Handle<S>,value:App.World(~S) & W.Status) -> App.Report<S>:
  match value:
    case (_,W.Rejected{_}):App.SetupRefused{}
    case (world,W.Accepted{}):seeded(~S,~codec,op,raw,target,Cmp.replace(~S,~App.Store<S>,~Input.Owner,~Unit,~App.Rest(~S),~Input.Owner,~D.Raw,~Unit,~App.take(~S),~App.put(~S),~Input.project,App.family(~S),world,target,Some{Input.owned(D.Number{9},333,444)}))
def reserved(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:App.World(~S) & W.Reservation<S>) -> App.Report<S>:
  match value:
    case (_,W.ReservationRejected{_}):App.SetupRefused{}
    case (world,W.Reserved{+target}):active(~S,~codec,op,raw,target,W.activate(~S,~App.Store<S>,~Input.Owner,~Unit,world,target))
def created(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:W.Creation<S,App.Store<S>,Input.Owner,Unit>) -> App.Report<S>:
  match value:
    case W.CreateRejected{_,_}:App.SetupRefused{}
    case W.Created{_,world}:reserved(~S,~codec,op,raw,W.reserve_id(~S,~App.Store<S>,~Input.Owner,~Unit,world))
def resource_seeded(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:Build.Construction<Input.Input,Input.Owner,D.Error>) -> App.Report<S>:
  match value:
    case Build.Invalid{_,_}:App.SetupRefused{}
    case Build.Constructed{owner,_}:created(~S,~codec,op,raw,W.create(~S,~App.Store<S>,~Input.Owner,~Unit,~App.empty(~S),W.factory(),owner))
# Ordinary registered trusted typed setup; gameplay receives only its grant.
def queue_ran(~S:Data,~codec:D.Codec,op:App.Mode,+target:W.Handle<S>,raw:D.Raw,value:Sys.RunResult<S,App.Store<S>,Input.Owner,Unit,W.Handle<S>,Unit,Unit,App.queue_runner(~S)>) -> App.Report<S>:
  match value:
    case Sys.Completed{_,Sys.Succeeded{world,_}}:registered(~S,~App.runner(~S,~codec),op,target,raw,Completion.registered(~S,~App.Store<S>,~Input.Owner,~Unit,~App.State<S>,~App.Args<S>,~Unit,~App.Output<S>,~App.runner(~S,~codec),world,"application32",["Value","Resource","Marker"],App.State{[],[]}))
    case _:App.SetupRefused{}
def queue_registered(~S:Data,~codec:D.Codec,op:App.Mode,+target:W.Handle<S>,raw:D.Raw,value:Sys.RegistrationResult<S,App.Store<S>,Input.Owner,Unit,W.Handle<S>,Unit,Unit,App.queue_runner(~S)>) -> App.Report<S>:
  match value:
    case Sys.Registered{world,registry}:queue_ran(~S,~codec,op,target,raw,Sys.run(~S,~App.Store<S>,~Input.Owner,~Unit,~W.Handle<S>,~Unit,~Unit,~App.queue_runner(~S),registry,world,target))
    case _:App.SetupRefused{}
def seed_ran(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:Sys.RunResult<S,App.Store<S>,Input.Owner,Unit,Input.Owner,Unit,App.SeedOut<S>,App.seed_runner(~S)>) -> App.Report<S>:
  match value:
    case Sys.Completed{_,Sys.Succeeded{world,App.SeedAccepted{target,_}}}:queue_registered(~S,~codec,op,target,raw,Sys.register(~S,~App.Store<S>,~Input.Owner,~Unit,~W.Handle<S>,~Unit,~Unit,~App.queue_runner(~S),App.observed_barrier(~S,world),"queue",["Marker"]))
    case _:App.SetupRefused{}
def seed_registered(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:Sys.RegistrationResult<S,App.Store<S>,Input.Owner,Unit,Input.Owner,Unit,App.SeedOut<S>,App.seed_runner(~S)>) -> App.Report<S>:
  match value:
    case Sys.Registered{world,registry}:seed_ran(~S,~codec,op,raw,Sys.run(~S,~App.Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~App.SeedOut<S>,~App.seed_runner(~S),registry,world,Input.owned(D.Number{9},333,444)))
    case _:App.SetupRefused{}
def ordinary_created(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:W.Creation<S,App.Store<S>,Input.Owner,Unit>) -> App.Report<S>:
  match value:
    case W.Created{_,world}:seed_registered(~S,~codec,op,raw,Sys.register(~S,~App.Store<S>,~Input.Owner,~Unit,~Input.Owner,~Unit,~App.SeedOut<S>,~App.seed_runner(~S),world,"seed",["Value"]))
    case _:App.SetupRefused{}
def ordinary_resource_seeded(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,value:Build.Construction<Input.Input,Input.Owner,D.Error>) -> App.Report<S>:
  match value:
    case Build.Constructed{owner,_}:ordinary_created(~S,~codec,op,raw,W.create(~S,~App.Store<S>,~Input.Owner,~Unit,~App.empty(~S),W.factory(),owner))
    case _:App.SetupRefused{}
def run(~S:Data,~codec:D.Codec,op:App.Mode,raw:D.Raw,seed:D.Raw) -> App.Report<S>:ordinary_resource_seeded(~S,~codec,op,raw,Constructor.construct(~S,~Input.Input,~Input.Owner,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Input.build,App.resource_factory(~S,~codec),Input.Input{seed,ANode{ALeaf{555},ALeaf{666}},ANode{ALeaf{False{}},ALeaf{True{}}}}))
