import Base
import ./scheduled.bend as Scheduled
import ./inspection.bend as Inspection
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as Family
import ./fixture-1.bend as F
import ./fixture-2.bend as Events
import ./fixture-3.bend as B
import ./fixture-6.bend as Common
import ./fixture-5.bend as Operations
import ./fixture-7.bend as Physical
import ./fixture-9.bend as Readers
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
import ./fixture-8.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/inspector-event-value.bend as Getter
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
type Metadata is Data:Metadata{factory:U32,handle:W.Handle<F.S>,activation:W.Status,queued:Maybe<&2,Relation.QueueStatus>}
type Inspection is Data:Inspection{first:Maybe<&2,List<&2,F.FirstEvent>>,second:Maybe<&2,List<&2,F.FirstEvent>>}
type Checkpoint is Data:Checkpoint{description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,physical:Physical.View,readers:Readers.View,args:String,inspected:Inspection}
type Report is Data:Report{metadata:Metadata,checkpoints:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>}
type State is Type:State{app:Common.Application(),args:Array<U32>,metadata:Metadata,checkpoints:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>}
def observed(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,physical:Events.Runtime() & Physical.View,readers:B.Owners4() & Readers.View,args:Array<U32> & String,inspected:Inspection) -> State:
  match physical readers args:
    case (runtime,physical),(owners,readers),(args,argsText):State{App.Application{schema,runtime,owners,recipe,debug},args,metadata,List.append(&2,Checkpoint,before,[Checkpoint{description,inventory,physical,readers,argsText,inspected}]),first,second,failures,schedules}
def inventoried(args:Array<U32>,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inspected:Inspection,result:Common.Application() & Maybe<&2,List<&2,String>>) -> State:
  match result:
    case (App.Application{schema,runtime,owners,recipe,debug},inventory):observed(schema,recipe,debug,metadata,before,first,second,failures,schedules,description,inventory,Physical.runtime(runtime),Readers.owners(owners),Owner.u32_array(args),inspected)
def described(args:Array<U32>,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,inspected:Inspection,result:Common.Application() & Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>) -> State:
  match result:
    case (app,description):inventoried(args,metadata,before,first,second,failures,schedules,description,inspected,Common.inventory(app))
def peek_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,base:Unit,slow:B.Owner2(),second:B.Owner3(),failure:B.Owner4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,declaration:Event.Declaration<F.S,F.FirstEvent>,registry:Sys.Registry<F.S,F.Store(),F.Resources(),F.Events(),Ev.Input<F.FirstEvent,Array<U32>>,Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),B.first_runner>,reader:Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>,returned:Events.Runtime() & Maybe<&2,List<&2,F.FirstEvent>>) -> Common.Application() & Maybe<&2,List<&2,F.FirstEvent>>:
  match returned:
    case (runtime,values):(App.Application{schema,runtime,((((base,Reader.Owner{declaration,reader,registry}),slow),second),failure),recipe,debug},values)
def peek(value:Common.Application()) -> Common.Application() & Maybe<&2,List<&2,F.FirstEvent>>:
  match value:
    case App.Application{schema,runtime,((((base,Reader.Owner{+declaration,reader,registry}),slow),second),failure),recipe,debug}:peek_returned(schema,base,slow,second,failure,recipe,debug,declaration,registry,reader,Cap.value_read(~Events.Runtime(),~Maybe<&2,List<&2,F.FirstEvent>>,~Inspection.first(Events.provision()),runtime))
def peeked(args:Array<U32>,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,+flag:Bool,prior:Maybe<&2,List<&2,F.FirstEvent>>,result:Common.Application() & Maybe<&2,List<&2,F.FirstEvent>>) -> State:
  match result:
    case (app,values):described(args,metadata,before,first,second,failures,schedules,Inspection{prior,values},Common.snapshot(Common.enabled(app,flag)))
def first_peek(args:Array<U32>,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,flag:Bool,result:Common.Application() & Maybe<&2,List<&2,F.FirstEvent>>) -> State:
  match result:
    case (app,values):peeked(args,metadata,before,first,second,failures,schedules,flag,values,peek(app))
def checkpoint(value:State,flag:Bool) -> State:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:first_peek(args,metadata,before,first,second,failures,schedules,flag,peek(app))
def finished(value:State) -> Maybe<&2,Report>:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:Some{Report{metadata,before,first,second,failures,schedules}}
def changed(action:Events.Runtime() -> Events.Runtime(),value:State) -> State:
  match value:
    case State{App.Application{schema,runtime,owners,recipe,debug},args,metadata,before,first,second,failures,schedules}:State{App.Application{schema,action(runtime),owners,recipe,debug},args,metadata,before,first,second,failures,schedules}
def frame_typed(runtime:Events.Runtime()) -> Events.Runtime():Mixed.frame(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.frame(),~Events.retain(),runtime)
def frame_failure(runtime:Events.Runtime()) -> Events.Runtime():Mixed.frame_failures(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,runtime)
def frames(value:State) -> Maybe<&2,Report>:finished(checkpoint(changed(frame_failure,checkpoint(changed(frame_failure,checkpoint(changed(frame_typed,checkpoint(changed(frame_typed,value),True{})),True{})),True{})),True{}))
def repeated(value:State) -> Maybe<&2,Report>:frames(checkpoint(checkpoint(value,True{}),False{}))
def synchronized(+tick:Nat,result:F.World() & Events.State()) -> Events.Runtime():
  match result:
    case (world,state):Route.Runtime{world,state,tick}
def publish_after(runtime:Events.Runtime()) -> Events.Runtime():
  match runtime:
    case Route.Runtime{world,state,+tick}:synchronized(1n+tick,Events.synchronize(Operations.pending(Operations.publish_after(world)),state,1n+tick))
def second_published(value:State) -> Maybe<&2,Report>:repeated(checkpoint(changed(publish_after,value),True{}))
def second_read(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Common.Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Array<U32>>) -> Maybe<&2,Report>:
  match result:
    case (app,Ev.Succeeded{(args,reading)}):second_published(checkpoint(State{app,args,metadata,before,first,List.append(&2,Ev.Reading<F.SecondEvent>,second,[reading]),failures,schedules},True{}))
    case _:None{}
def scheduled3(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Scheduled.Outcome<Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Array<U32>>>) -> Maybe<&2,Report>:
  match result:
    case Scheduled.Ran{app,completion,observations}:second_read(metadata,before,first,second,failures,List.append(&2,List<&2,Sch.Observation>,schedules,[observations]),(app,completion))
    case Scheduled.Refused{_,_,_}:None{}
def read_second(value:State) -> Maybe<&2,Report>:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:scheduled3(metadata,before,first,second,failures,schedules,Scheduled.run(~Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Array<U32>>,~Common.read3,2n,app,args))
def slow_read(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Common.Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>) -> Maybe<&2,Report>:
  match result:
    case (app,Ev.Succeeded{(args,reading)}):read_second(checkpoint(State{app,args,metadata,before,List.append(&2,Ev.Reading<F.FirstEvent>,first,[reading]),second,failures,schedules},True{}))
    case _:None{}
def scheduled2(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Scheduled.Outcome<Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>>) -> Maybe<&2,Report>:
  match result:
    case Scheduled.Ran{app,completion,observations}:slow_read(metadata,before,first,second,failures,List.append(&2,List<&2,Sch.Observation>,schedules,[observations]),(app,completion))
    case Scheduled.Refused{_,_,_}:None{}
def read_slow(value:State) -> Maybe<&2,Report>:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:scheduled2(metadata,before,first,second,failures,schedules,Scheduled.run(~Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>,~Common.read2,1n,app,args))
def first_read(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Common.Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>) -> Maybe<&2,Report>:
  match result:
    case (app,Ev.Succeeded{(args,reading)}):read_slow(checkpoint(State{app,args,metadata,before,List.append(&2,Ev.Reading<F.FirstEvent>,first,[reading]),second,failures,schedules},True{}))
    case _:None{}
def scheduled1(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Scheduled.Outcome<Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>>) -> Maybe<&2,Report>:
  match result:
    case Scheduled.Ran{app,completion,observations}:first_read(metadata,before,first,second,failures,List.append(&2,List<&2,Sch.Observation>,schedules,[observations]),(app,completion))
    case Scheduled.Refused{_,_,_}:None{}
def read_first(value:State) -> Maybe<&2,Report>:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:scheduled1(metadata,before,first,second,failures,schedules,Scheduled.run(~Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>,~Common.read1,0n,app,args))
def failure_read(metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:Common.Application() & K.Completion<Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Array<U32>>) -> Maybe<&2,Report>:
  match result:
    case (app,K.Succeeded{(args,reading)}):read_first(checkpoint(State{app,args,metadata,before,first,second,List.append(&2,List<&2,Read.KeyReading<F.S,F.Events()>>,failures,[reading]),schedules},True{}))
    case _:None{}
def read_failure(value:State) -> Maybe<&2,Report>:
  match value:
    case State{app,args,metadata,before,first,second,failures,schedules}:failure_read(metadata,before,first,second,failures,schedules,Common.read_failure(app,args))
def barrier_detached(detached:K.Runtime<F.S,F.Store(),F.Resources(),F.Events()> & (Family.State<Events.Events(),Events.Metadata(),Array<U32>> & Nat)) -> Events.Runtime():
  match detached:
    case (runtime,held):Mixed.failure_returned(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,held,K.barrier(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Operations.classify,runtime))
def barrier(runtime:Events.Runtime()) -> Events.Runtime():barrier_detached(Mixed.failure_runtime(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,runtime))
def queue_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,state:Events.State(),+tick:Nat,owners:B.Owners4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,args:Array<U32>,metadata:Metadata,before:List<&2,Checkpoint>,first:List<&2,Ev.Reading<F.FirstEvent>>,second:List<&2,Ev.Reading<F.SecondEvent>>,failures:List<&2,List<&2,Read.KeyReading<F.S,F.Events()>>>,schedules:List<&2,List<&2,Sch.Observation>>,result:F.World() & Relation.QueueStatus) -> Maybe<&2,Report>:
  match metadata result:
    case Metadata{factory,handle,activation,_},(world,status):read_failure(checkpoint(changed(barrier,checkpoint(State{App.Application{schema,synchronized(1n+tick,Events.synchronize(Operations.publish_before(world),state,1n+tick)),owners,recipe,debug},args,Metadata{factory,handle,activation,Some{status}},before,first,second,failures,schedules},True{})),True{}))
def handle(metadata:Metadata) -> W.Handle<F.S>:
  match metadata:
    case Metadata{_,handle,_,_}:handle
def queue(value:State) -> Maybe<&2,Report>:
  match value:
    case State{App.Application{schema,Route.Runtime{world,state,tick},owners,recipe,debug},args,+metadata,before,first,second,failures,schedules}:queue_returned(schema,state,tick,owners,recipe,debug,args,metadata,before,first,second,failures,schedules,Operations.queue_self(world,handle(metadata)))
def installed4(metadata:Metadata,app:B.App4()) -> Maybe<&2,Report>:queue(checkpoint(State{app,ANode{ALeaf{101},ALeaf{102}},metadata,[],[],[],[],[]},True{}))
def failed3(app:B.App3()) -> Maybe<&2,Report>:None{}
def installed3(metadata:Metadata,app:B.App3()) -> Maybe<&2,Report>:B.install4(~Maybe<&2,Report>,installed4(metadata),failed3,app)
def failed2(app:B.App2()) -> Maybe<&2,Report>:None{}
def installed2(metadata:Metadata,app:B.App2()) -> Maybe<&2,Report>:B.install3(~Maybe<&2,Report>,installed3(metadata),failed2,app)
def failed1(app:B.App1()) -> Maybe<&2,Report>:None{}
def installed1(metadata:Metadata,app:B.App1()) -> Maybe<&2,Report>:B.install2(~Maybe<&2,Report>,installed2(metadata),failed1,app)
def failed0(app:B.App0()) -> Maybe<&2,Report>:None{}
def activated(factory:U32,handle:W.Handle<F.S>,returned:F.World() & W.Status) -> Maybe<&2,Report>:
  match returned:
    case (world,activation):B.install1(~Maybe<&2,Report>,installed1(Metadata{factory,handle,activation,None{}}),failed0,B.initial(world))
def reserved(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,W.Reserved{+handle}):activated(factory,handle,W.activate(~F.S,~F.Store(),~F.Resources(),~F.Events(),world,handle))
    case _:None{}
def created(result:W.Creation<F.S,F.Store(),F.Resources(),F.Events()>) -> Maybe<&2,Report>:
  match result:
    case W.Created{W.Factory{factory},world}:reserved(factory,W.reserve_id(~F.S,~F.Store(),~F.Resources(),~F.Events(),world))
    case _:None{}
def run() -> Maybe<&2,Report>:created(W.create(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.empty,W.factory(),ANode{ALeaf{81},ALeaf{82}}))
