import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Family
import setup.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Composition
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import types.bend as Source

def World() -> Type:Setup.World()
def State() -> Type:Setup.State()
def Runtime() -> Type:Setup.Runtime()
type ReadError<E:Data> is Data:ReadError{reading:Ev.Reading<E>}
def read_runner(~E:Data,world:World(),input:Ev.Input<E,Bool>) -> Sys.Outcome<World(),ReadError<E>,Ev.Reading<E>>:
  match input:
    case Ev.Input{+values,+lagged,False{}}:Sys.Succeeded{world,Ev.Reading{values,lagged}}
    case Ev.Input{values,lagged,True{}}:Sys.Failed{world,ReadError{Ev.Reading{values,lagged}}}
def first_runner(world:World(),input:Ev.Input<Source.First,Bool>) -> Sys.Outcome<World(),ReadError<Source.First>,Ev.Reading<Source.First>>:read_runner(~Source.First,world,input)
def second_runner(world:World(),input:Ev.Input<Source.Second,Bool>) -> Sys.Outcome<World(),ReadError<Source.Second>,Ev.Reading<Source.Second>>:read_runner(~Source.Second,world,input)
def take_first(state:State()) -> State() & Leaf.Stream<Source.Schema,Source.First>:Setup.take_first(state)
def put_first(state:State(),stream:Leaf.Stream<Source.Schema,Source.First>) -> State():Setup.put_first(state,stream)
def take_second(state:State()) -> State() & Leaf.Stream<Source.Schema,Source.Second>:Setup.take_second(state)
def put_second(state:State(),stream:Leaf.Stream<Source.Schema,Source.Second>) -> State():Setup.put_second(state,stream)
def synchronize(world:World(),state:State(),tick:Nat) -> World() & State():Setup.synchronize(world,state,tick)
def FirstReader() -> Type:Route.Reader<Source.Schema,Source.First,State(),take_first,put_first>
def FirstRegistry() -> Type:Sys.Registry<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Ev.Input<Source.First,Bool>,ReadError<Source.First>,Ev.Reading<Source.First>,first_runner>
def FirstRegistration() -> Type:Route.Registration<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Source.First,State(),Bool,ReadError<Source.First>,Ev.Reading<Source.First>,take_first,put_first,first_runner>
def FirstRun() -> Type:Route.RunResult<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Source.First,State(),Bool,ReadError<Source.First>,Ev.Reading<Source.First>,take_first,put_first,first_runner>
def register_first(runtime:Runtime(),name:String) -> FirstRegistration():Route.register(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~Source.First,~State(),~Bool,~ReadError<Source.First>,~Ev.Reading<Source.First>,~take_first,~put_first,~first_runner,runtime,name)
def run_first(runtime:Runtime(),reader:FirstReader(),registry:FirstRegistry(),fail:Bool) -> FirstRun():Route.run(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~Source.First,~State(),~Bool,~ReadError<Source.First>,~Ev.Reading<Source.First>,~take_first,~put_first,~first_runner,~synchronize,runtime,reader,registry,fail)
def SecondReader() -> Type:Route.Reader<Source.Schema,Source.Second,State(),take_second,put_second>
def SecondRegistry() -> Type:Sys.Registry<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Ev.Input<Source.Second,Bool>,ReadError<Source.Second>,Ev.Reading<Source.Second>,second_runner>
def SecondRegistration() -> Type:Route.Registration<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Source.Second,State(),Bool,ReadError<Source.Second>,Ev.Reading<Source.Second>,take_second,put_second,second_runner>
def SecondRun() -> Type:Route.RunResult<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),Source.Second,State(),Bool,ReadError<Source.Second>,Ev.Reading<Source.Second>,take_second,put_second,second_runner>
def register_second(runtime:Runtime(),name:String) -> SecondRegistration():Route.register(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~Source.Second,~State(),~Bool,~ReadError<Source.Second>,~Ev.Reading<Source.Second>,~take_second,~put_second,~second_runner,runtime,name)
def run_second(runtime:Runtime(),reader:SecondReader(),registry:SecondRegistry(),fail:Bool) -> SecondRun():Route.run(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~Source.Second,~State(),~Bool,~ReadError<Source.Second>,~Ev.Reading<Source.Second>,~take_second,~put_second,~second_runner,~synchronize,runtime,reader,registry,fail)
type PublishRequest is Data:PublishRequest{domains:Setup.PairDomains(),fail:Bool}
def publish_outcome(fail:Bool) -> Tx.Outcome<Source.Error>:
  match fail:
    case False{}:Tx.Success{}
    case True{}:Tx.Failure{Source.Aborted{}}
def publish_finished(returned:Tx.Returned<World(),Source.Error>) -> Sys.Outcome<World(),Source.Error,Unit>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}:Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}:Sys.Failed{world,error}
def publisher_runner(world:World(),request:PublishRequest) -> Sys.Outcome<World(),Source.Error,Unit>:
  match request:
    case PublishRequest{domains,fail}:publish_finished(Tx.finish(~World(),~Setup.Events(),~Source.Error,~Setup.enqueue,~Setup.publish,Setup.staged_declared(world,domains),publish_outcome(fail)))
def PublisherRegistry() -> Type:Sys.Registry<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),PublishRequest,Source.Error,Unit,publisher_runner>
def PublisherRegistration() -> Type:Sys.RegistrationResult<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),PublishRequest,Source.Error,Unit,publisher_runner>
type Fixture is Type:
  Fixture{factory:W.Factory,publisher:PublisherRegistry(),runtime:Runtime(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry()}
  NoFirst{factory:W.Factory,publisher:PublisherRegistry(),runtime:Runtime()}
  NoSlow{factory:W.Factory,publisher:PublisherRegistry(),runtime:Runtime(),first:FirstReader(),firstRegistry:FirstRegistry()}
  NoSecond{factory:W.Factory,publisher:PublisherRegistry(),runtime:Runtime(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry()}
  NoPublisher{factory:W.Factory,world:World(),state:State()}
  NoWorld{factory:W.Factory,resource:Array<U32>,sibling:Array<U32>}
def third(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),registered:SecondRegistration()) -> Fixture:
  match registered:
    case Route.RegistrationFailed{runtime}:NoSecond{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry}
    case Route.Registered{runtime,second,secondRegistry}:Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}
def second(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),registered:FirstRegistration()) -> Fixture:
  match registered:
    case Route.RegistrationFailed{runtime}:NoSlow{factory,publisher,runtime,first,firstRegistry}
    case Route.Registered{runtime,slow,slowRegistry}:third(factory,publisher,first,firstRegistry,slow,slowRegistry,register_second(runtime,"second"))
def first(factory:W.Factory,publisher:PublisherRegistry(),registered:FirstRegistration()) -> Fixture:
  match registered:
    case Route.RegistrationFailed{runtime}:NoFirst{factory,publisher,runtime}
    case Route.Registered{runtime,reader,registry}:second(factory,publisher,reader,registry,register_first(runtime,"slow"))
def publisher_registered(factory:W.Factory,state:State(),registered:PublisherRegistration()) -> Fixture:
  match registered:
    case Sys.RegistrationFailed{world}:NoPublisher{factory,world,state}
    case Sys.Registered{world,publisher}:first(factory,publisher,register_first(Route.Runtime{world,state,0n},"first"))
def install_domains(factory:W.Factory,world:World(),returned:State() & Setup.PairDomains()) -> Fixture:
  match returned:
    case (state,domains):publisher_registered(factory,state,Sys.register(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~PublishRequest,~Source.Error,~Unit,~publisher_runner,world,"publisher",Setup.publisher_access(domains)))
def install_runtime(factory:W.Factory,runtime:Runtime()) -> Fixture:
  match runtime:
    case Route.Runtime{world,state,_}:install_domains(factory,world,Setup.publisher_domains(state))
def install(factory:W.Factory,world:World(),sibling:Array<U32>) -> Fixture:install_runtime(factory,Setup.setup(world,sibling))
def created(sibling:Array<U32>,creation:W.Creation<Source.Schema,Array<U32>,Array<U32>,Setup.Events()>) -> Fixture:
  match creation:
    case W.CreateRejected{factory,resource}:NoWorld{factory,resource,sibling}
    case W.Created{factory,world}:install(factory,world,sibling)
def setup() -> Fixture:created(ALeaf{61},W.create(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~Source.empty,W.factory(),ALeaf{51}))

type Observation is Data:
  FirstRead{reading:Ev.Reading<Source.First>,failed:Bool}
  SecondRead{reading:Ev.Reading<Source.Second>,failed:Bool}
  Published{failed:Bool}
  Rejected{}
  Framed{}
  SetupUnavailable{}
type Action is Data:
  Publish{fail:Bool}
  ReadFirst{slow:Bool,fail:Bool}
  ReadSecond{fail:Bool}
  Frame{}
def first_observation(completion:Ev.Completion<ReadError<Source.First>,Ev.Reading<Source.First>,Bool>) -> Observation:
  match completion:
    case Ev.Succeeded{reading}:FirstRead{reading,False{}}
    case Ev.Failed{ReadError{reading}}:FirstRead{reading,True{}}
    case Ev.Rejected{_}:Rejected{}
def second_observation(completion:Ev.Completion<ReadError<Source.Second>,Ev.Reading<Source.Second>,Bool>) -> Observation:
  match completion:
    case Ev.Succeeded{reading}:SecondRead{reading,False{}}
    case Ev.Failed{ReadError{reading}}:SecondRead{reading,True{}}
    case Ev.Rejected{_}:Rejected{}
def first_returned(factory:W.Factory,publisher:PublisherRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),returned:FirstRun()) -> Fixture & Observation:
  match returned:
    case Route.Ran{runtime,first,firstRegistry,completion}:(Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},first_observation(completion))
def slow_returned(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),returned:FirstRun()) -> Fixture & Observation:
  match returned:
    case Route.Ran{runtime,slow,slowRegistry,completion}:(Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},first_observation(completion))
def second_returned(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),returned:SecondRun()) -> Fixture & Observation:
  match returned:
    case Route.Ran{runtime,second,secondRegistry,completion}:(Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},second_observation(completion))
def read_selected(slowSelected:Bool,fail:Bool,factory:W.Factory,publisher:PublisherRegistry(),runtime:Runtime(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry()) -> Fixture & Observation:
  match slowSelected:
    case False{}:first_returned(factory,publisher,slow,slowRegistry,second,secondRegistry,run_first(runtime,first,firstRegistry,fail))
    case True{}:slow_returned(factory,publisher,first,firstRegistry,second,secondRegistry,run_first(runtime,slow,slowRegistry,fail))
def publisher_synced(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),tick:Nat,returned:World() & State()) -> Fixture & Observation:
  match returned:
    case (world,state):(Fixture{factory,publisher,Route.Runtime{world,state,tick},first,firstRegistry,slow,slowRegistry,second,secondRegistry},Published{False{}})
def publisher_outcome(factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),state:State(),+tick:Nat,outcome:Sys.Outcome<World(),Source.Error,Unit>) -> Fixture & Observation:
  match outcome:
    case Sys.Failed{world,_}:(Fixture{factory,publisher,Route.Runtime{world,state,1n+tick},first,firstRegistry,slow,slowRegistry,second,secondRegistry},Published{True{}})
    case Sys.Succeeded{world,Unit{}}:publisher_synced(factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,1n+tick,synchronize(world,state,1n+tick))
def publisher_returned(factory:W.Factory,first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),state:State(),tick:Nat,returned:Sys.RunResult<Source.Schema,Array<U32>,Array<U32>,Setup.Events(),PublishRequest,Source.Error,Unit,publisher_runner>) -> Fixture & Observation:
  match returned:
    case Sys.RegistrationRejected{publisher,world,_}:(Fixture{factory,publisher,Route.Runtime{world,state,tick},first,firstRegistry,slow,slowRegistry,second,secondRegistry},Rejected{})
    case Sys.Completed{publisher,outcome}:publisher_outcome(factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,state,tick,outcome)
def publish_domains(fail:Bool,factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),world:World(),tick:Nat,returned:State() & Setup.PairDomains()) -> Fixture & Observation:
  match returned:
    case (state,domains):publisher_returned(factory,first,firstRegistry,slow,slowRegistry,second,secondRegistry,state,tick,Sys.run(~Source.Schema,~Array<U32>,~Array<U32>,~Setup.Events(),~PublishRequest,~Source.Error,~Unit,~publisher_runner,publisher,world,PublishRequest{domains,fail}))
def publish_runtime(fail:Bool,factory:W.Factory,publisher:PublisherRegistry(),first:FirstReader(),firstRegistry:FirstRegistry(),slow:FirstReader(),slowRegistry:FirstRegistry(),second:SecondReader(),secondRegistry:SecondRegistry(),runtime:Runtime()) -> Fixture & Observation:
  match runtime:
    case Route.Runtime{world,state,tick}:publish_domains(fail,factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,world,tick,Setup.publisher_domains(state))
def step(action:Action,fixture:Fixture) -> Fixture & Observation:
  match action fixture:
    case Publish{fail} Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:publish_runtime(fail,factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,runtime)
    case ReadFirst{selected,fail} Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:read_selected(selected,fail,factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry)
    case ReadSecond{fail} Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:second_returned(factory,publisher,first,firstRegistry,slow,slowRegistry,run_second(runtime,second,secondRegistry,fail))
    case Frame{} Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:(Fixture{factory,publisher,Setup.next_frame(runtime),first,firstRegistry,slow,slowRegistry,second,secondRegistry},Framed{})
    case _ fixture:(fixture,SetupUnavailable{})
def sequence_returned(observation:Observation,returned:Fixture & List<&2,Observation>) -> Fixture & List<&2,Observation>:
  match returned:
    case (fixture,rest):(fixture,observation <> rest)
def sequence_join(rest:Fixture -> Fixture & List<&2,Observation>,returned:Fixture & Observation) -> Fixture & List<&2,Observation>:
  match returned:
    case (fixture,observation):sequence_returned(observation,rest(fixture))
def sequence(actions:List<&2,Action>,fixture:Fixture) -> Fixture & List<&2,Observation>:
  match actions:
    case []:(fixture,[])
    case action <> rest:sequence_join((fixture => sequence(rest,fixture)),step(action,fixture))
def scenario() -> Fixture & List<&2,Observation>:
  sequence([Publish{False{}},ReadFirst{False{},False{}},ReadSecond{False{}},Publish{True{}},ReadFirst{True{},True{}},ReadFirst{True{},False{}},Publish{False{}},Frame{},ReadFirst{False{},False{}},ReadSecond{False{}},Frame{},Frame{}],setup())
