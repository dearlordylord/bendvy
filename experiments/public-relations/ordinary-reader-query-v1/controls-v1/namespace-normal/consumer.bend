import Base
import fixture.bend as F
import operations.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def failure_runner(~S:Data,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,input:K.Input<S,A.Notice<S,U32>,Array<U32>>) -> Sy.Outcome<W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>)>:
  match input:
    case K.Input{readings,args}:Sy.Succeeded{world,(args,readings)}
def classify(~S:Data,notice:A.Notice<S,U32>) -> Maybe<Domains.DescriptorKey<S>>:
  match notice:
    case A.RelationFailed{G.Failure{G.Descriptor{id,_,_,_},_,_,_,_}}:Some{Domains.DeclaredKey{id}}
    case _:None{}
type RegistryView is Data: RegistryView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type Snapshot<S:Data> is Data:
  Snapshot{world:String,events:List<&2,A.Notice<S,U32>>,domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,positions:List<&2,Ev.Position>,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,writer:RegistryView,inverse:RegistryView,failure:RegistryView,args:List<&2,U32>}
type State<S:Data> is Type: State{runtime:K.Runtime<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>}
type Report<S:Data> is Data: Report{snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>}
def writer_view(~S:Data,owner:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & RegistryView:
  match owner:
    case Sy.Registry{+ns,+id,+name,+access,+cursor}:(Sy.Registry{ns,id,name,access,cursor},RegistryView{ns,id,name,access,cursor})
def inverse_view(~S:Data,owner:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & RegistryView:
  match owner:
    case Sy.Registry{+ns,+id,+name,+access,+cursor}:(Sy.Registry{ns,id,name,access,cursor},RegistryView{ns,id,name,access,cursor})
def failure_view(~S:Data,owner:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>) -> K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)> & RegistryView:
  match owner:
    case K.Reader{Sy.Registry{+ns,+id,+name,+access,+cursor},+keys}:(K.Reader{Sy.Registry{ns,id,name,access,cursor},keys},RegistryView{ns,id,name,access,cursor})
def failure_registered(~S:Data,result:K.Registered<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> Maybe<State<S>>:
  match result:
    case K.Registered{runtime,failure}:Some{State{runtime,writer,inverse,failure,ANode{ALeaf{101},ALeaf{102}},[],[],[],[]}}
    case _:None{}
def inverse_registered(~S:Data,result:Sy.RegistrationResult<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> Maybe<State<S>>:
  match result:
    case Sy.Registered{world,inverse}:failure_registered(~S,D.register(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),~failure_runner(~S),K.start(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,world),[D.relation(~S,F.parent(~S))],"ParentFailures"),writer,inverse)
    case _:None{}
def writer_registered(~S:Data,result:Sy.RegistrationResult<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> Maybe<State<S>>:
  match result:
    case Sy.Registered{world,writer}:inverse_registered(~S,Sy.register(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~W.Handle<S>,~Unit,~Maybe<&2,List<&2,W.Handle<S>>>,~O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),world,"ParentInverse",["Parent:read"]),writer)
    case _:None{}
def start(~S:Data) -> Maybe<State<S>>:
  writer_registered(~S,Sy.register(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~P.Targets<S>,~Unit,~A.QueueStatus,~O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),F.fixture(~S,1),"ParentWriter",["Parent:write"]))
def cells(values:Array<U32>) -> List<&2,U32>:
  match values:
    case ALeaf{value}:[value]
    case ANode{left,right}:List.append(&2,U32,cells(left),cells(right))
def snapshot_clone(~S:Data,+events:List<&2,A.Notice<S,U32>>,+domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,text:String,wv:RegistryView,iv:RegistryView,fv:RegistryView,observed:Array<U32> & Array<U32>) -> State<S>:
  (args,argcopy)=observed
  State{K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},writer,inverse,failure,args,Snapshot{text,events,domains,positions,tick,frameStart,boundary,capacity,wv,iv,fv,cells(argcopy)} <> snapshots,writes,queries,deliveries}
def snapshot_failure(~S:Data,+events:List<&2,A.Notice<S,U32>>,+domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,text:String,wv:RegistryView,iv:RegistryView,observed:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)> & RegistryView) -> State<S>:
  (failure,fv)=observed
  snapshot_clone(~S,events,domains,positions,tick,frameStart,boundary,capacity,writer,inverse,failure,snapshots,writes,queries,deliveries,world,text,wv,iv,fv,Array.clone(U32,args))
def snapshot_inverse(~S:Data,+events:List<&2,A.Notice<S,U32>>,+domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,text:String,wv:RegistryView,observed:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & RegistryView) -> State<S>:
  (inverse,iv)=observed
  snapshot_failure(~S,events,domains,positions,tick,frameStart,boundary,capacity,writer,inverse,args,snapshots,writes,queries,deliveries,world,text,wv,iv,failure_view(~S,failure))
def snapshot_writer(~S:Data,+events:List<&2,A.Notice<S,U32>>,+domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>,world:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>>,text:String,observed:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & RegistryView) -> State<S>:
  (writer,wv)=observed
  snapshot_inverse(~S,events,domains,positions,tick,frameStart,boundary,capacity,writer,failure,args,snapshots,writes,queries,deliveries,world,text,wv,inverse_view(~S,inverse))
def snapshot_world(~S:Data,+events:List<&2,A.Notice<S,U32>>,+domains:List<&2,Domains.Domain<S,A.Notice<S,U32>>>,+positions:List<&2,Ev.Position>,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>,observed:W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & String) -> State<S>:
  (world,text)=observed
  snapshot_writer(~S,events,domains,positions,tick,frameStart,boundary,capacity,inverse,failure,args,snapshots,writes,queries,deliveries,world,text,writer_view(~S,writer))
def snapshot(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{K.Runtime{W.World{ns,next,high,live,cap,depth,store,resource,+events,pending,regs,nextSystem,clock},+domains,+positions,+tick,+frameStart,+boundary,+capacity},writer,inverse,failure,args,snapshots,writes,queries,deliveries}:snapshot_world(~S,events,domains,positions,tick,frameStart,boundary,capacity,writer,inverse,failure,args,snapshots,writes,queries,deliveries,F.observe(~S,W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,nextSystem,clock}))
def write_result(~S:Data,result:Sy.RunResult<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & A.QueueStatus)>:
  match result:
    case Sy.Completed{registry,Sy.Succeeded{world,output}}:(world,Some{(registry,output)})
    case Sy.Completed{_,Sy.Failed{world,_}}:(world,None{})
    case Sy.RegistrationRejected{_,world,_}:(world,None{})
def write_complete(~S:Data,observed:K.Runtime<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & A.QueueStatus)>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>) -> Maybe<State<S>>:
  match observed:
    case (runtime,Some{(writer,output)}):Some{State{runtime,writer,inverse,failure,args,snapshots,output <> writes,queries,deliveries}}
    case _:None{}
def write(~S:Data,state:State<S>,input:P.Targets<S>) -> Maybe<State<S>>:
  match state:
    case State{runtime,writer,inverse,failure,args,snapshots,writes,queries,deliveries}:write_complete(~S,K.with_world(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & A.QueueStatus)>,~classify(~S),w => write_result(~S,Sy.run_tracked(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~P.Targets<S>,~Unit,~A.QueueStatus,~O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),writer,w,input)),runtime),inverse,failure,args,snapshots,writes,queries,deliveries)
def query_result(~S:Data,result:Sy.RunResult<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>) -> W.World<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & Maybe<&2,List<&2,W.Handle<S>>>)>:
  match result:
    case Sy.Completed{registry,Sy.Succeeded{world,output}}:(world,Some{(registry,output)})
    case Sy.Completed{_,Sy.Failed{world,_}}:(world,None{})
    case Sy.RegistrationRejected{_,world,_}:(world,None{})
def query_complete(~S:Data,observed:K.Runtime<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>> & Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & Maybe<&2,List<&2,W.Handle<S>>>)>,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,failure:K.Reader<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,args:Array<U32>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>) -> Maybe<State<S>>:
  match observed:
    case (runtime,Some{(inverse,output)}):Some{State{runtime,writer,inverse,failure,args,snapshots,writes,output <> queries,deliveries}}
    case _:None{}
def query(~S:Data,state:State<S>,input:W.Handle<S>) -> Maybe<State<S>>:
  match state:
    case State{runtime,writer,inverse,failure,args,snapshots,writes,queries,deliveries}:query_complete(~S,K.with_world(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~Maybe<(Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))> & Maybe<&2,List<&2,W.Handle<S>>>)>,~classify(~S),w => query_result(~S,Sy.run_tracked(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~W.Handle<S>,~Unit,~Maybe<&2,List<&2,W.Handle<S>>>,~O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S)),inverse,w,input)),runtime),writer,failure,args,snapshots,writes,queries,deliveries)
def barrier(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{runtime,writer,inverse,failure,args,snapshots,writes,queries,deliveries}:State{K.barrier(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~classify(~S),runtime),writer,inverse,failure,args,snapshots,writes,queries,deliveries}
def delivered(~S:Data,result:K.RunResult<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),failure_runner(~S)>,writer:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,P.Targets<S>,Unit,A.QueueStatus,O.writer(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,inverse:Sy.Registry<S,A.Store<S,F.Components>,Array<U32>,A.Notice<S,U32>,W.Handle<S>,Unit,Maybe<&2,List<&2,W.Handle<S>>>,O.reader(~S,~F.Components,~Array<U32>,~U32,~F.parent(~S))>,snapshots:List<&2,Snapshot<S>>,writes:List<&2,A.QueueStatus>,queries:List<&2,Maybe<&2,List<&2,W.Handle<S>>>>,deliveries:List<&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>>) -> Maybe<State<S>>:
  match result:
    case K.Ran{runtime,failure,K.Succeeded{(args,+values)}}:Some{State{runtime,writer,inverse,failure,args,snapshots,writes,queries,values <> deliveries}}
    case _:None{}
def deliver(~S:Data,state:State<S>) -> Maybe<State<S>>:
  match state:
    case State{runtime,writer,inverse,failure,args,snapshots,writes,queries,deliveries}:delivered(~S,K.run(~S,~A.Store<S,F.Components>,~Array<U32>,~A.Notice<S,U32>,~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<S,A.Notice<S,U32>>>),~failure_runner(~S),~classify(~S),runtime,failure,args),writer,inverse,snapshots,writes,queries,deliveries)
def finish(~S:Data,state:State<S>) -> Report<S>:
  match state:
    case State{_,_,_,_,_,snapshots,writes,queries,deliveries}:Report{List.reverse(&2,Snapshot<S>,snapshots),List.reverse(&2,A.QueueStatus,writes),List.reverse(&2,Maybe<&2,List<&2,W.Handle<S>>>,queries),List.reverse(&2,List<&2,Read.KeyReading<S,A.Notice<S,U32>>>,deliveries)}
def after9(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:Some{finish(~S,snapshot(~S,state))}
def stage9(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after9(~S,deliver(~S,state))
def after8(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage9(~S,Some{snapshot(~S,state)})
def stage8(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after8(~S,deliver(~S,state))
def stage7(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage8(~S,Some{snapshot(~S,barrier(~S,state))})
def after6(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage7(~S,Some{snapshot(~S,state)})
def stage6(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after6(~S,write(~S,state,P.Targets{W.Handle{1,2},W.Handle{1,99}}))
def after5(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage6(~S,Some{snapshot(~S,state)})
def stage5(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after5(~S,write(~S,state,P.Targets{W.Handle{1,3},W.Handle{1,3}}))
def after4(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage5(~S,Some{snapshot(~S,state)})
def stage4(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after4(~S,write(~S,state,P.Targets{W.Handle{1,1},W.Handle{1,2}}))
def after3(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage4(~S,Some{snapshot(~S,state)})
def stage3(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after3(~S,query(~S,state,W.Handle{1,1}))
def stage2(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage3(~S,Some{snapshot(~S,barrier(~S,state))})
def after1(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage2(~S,Some{snapshot(~S,state)})
def stage1(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after1(~S,query(~S,state,W.Handle{1,1}))
def after0(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:stage1(~S,Some{snapshot(~S,state)})
def stage0(~S:Data,observed:Maybe<State<S>>) -> Maybe<Report<S>>:
  match observed:
    case None{}:None{}
    case Some{state}:after0(~S,write(~S,state,P.Targets{W.Handle{1,2},W.Handle{1,1}}))
def started(~S:Data,result:Maybe<State<S>>) -> Maybe<Report<S>>:
  match result:
    case None{}:None{}
    case Some{state}:stage0(~S,Some{snapshot(~S,state)})
def run(~S:Data) -> Maybe<Report<S>>: started(~S,start(~S))
