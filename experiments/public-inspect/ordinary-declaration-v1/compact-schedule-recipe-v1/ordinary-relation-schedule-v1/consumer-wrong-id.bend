import Base
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as PublicRelation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-system.bend as Registered
import ./state.bend as State
import ./dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def declaration(~S:Data) -> Ord.Declaration<S>:
  Ord.relation(~S,G.Descriptor{7,"Link","LinkedBy",G.Ordinary{}})
def Application(~S:Data) -> Type:
  Relation.Application(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2})
def condition(~S:Data,world:State.World(~S),id:U32) -> State.World(~S) & Bool:
  (world,U32.is_eq(id,1))
def provision(~S:Data,world:State.World(~S)) -> State.World(~S) & List<&2,SP.Requirement<S>>:
  (world,[])
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,_}:U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ U32.show(cursor) ++ ":" ++ slot
def view(~S:Data,value:Maybe<&2,Scheduled.Description<S,PublicRelation.View<S>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{Scheduled.Description{App.Description{_,DTO.Product{bindings,DTO.Observation{_,text}}},ns,name,steps}}:"Debug{bindings=" ++ List.show(&2,DTO.Binding<S>,binding(~S),bindings) ++ "|relations=" ++ List.show(&2,String,x=>x,text) ++ "|schedule=" ++ name ++ "|steps=" ++ Nat.show(List.length(&2,Scheduled.PlannedStep<S>,steps)) ++ "}"
def physical_done(~S:Data,text:String,schema:Schema.Schema<S,A.Store<S,Unit>,State.Resources<S>>,owners:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2}),recipe:Relation.Recipe(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2}),debug:Bool,plan:SP.Plan<S>,ns:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:State.World(~S) & String) -> Application(~S) & String:
  match result:
    case (world,physical):(Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,ns,name,steps,needs},text ++ "|" ++ physical)
def physical(~S:Data,text:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,ns,name,steps,needs}:physical_done(~S,text,schema,owners,recipe,debug,plan,ns,name,steps,needs,Dump.world(~S,world))
def shown(~S:Data,result:Application(~S) & Maybe<&2,Scheduled.Description<S,PublicRelation.View<S>>>) -> Application(~S) & String:
  match result:
    case (app,value):physical(~S,view(~S,value),app)
def snapshot(~S:Data,flag:Bool,app:Application(~S)) -> Application(~S) & String:
  shown(~S,Relation.snapshot(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2},app,flag))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def ran(~S:Data,result:Scheduled.RunResult<Application(~S),S,Maybe<&2,Unit>>) -> Application(~S) & String:
  match result:
    case Scheduled.Finished{app,observations}:physical(~S,"Finished:" ++ List.show(&2,Sch.Observation,observation,observations),app)
    case Scheduled.Failed{app,_,observations}:physical(~S,"Failed:" ++ List.show(&2,Sch.Observation,observation,observations),app)
    case Scheduled.Rejected{app}:physical(~S,"Rejected",app)
    case Scheduled.Missing{app,_}:physical(~S,"Missing",app)
def run(~S:Data,app:Application(~S)) -> Application(~S) & String:
  ran(~S,Relation.run(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2},~condition(~S),~provision(~S),app))
def joined(~Value:Type,next:Value -> String -> String,result:Value & String) -> String:
  match result:
    case (value,text):next(value,text)
def sequence(~Value:Type,actions:List<(Value -> Value & String)>,prefix:String,value:Value) -> String:
  match actions:
    case []:prefix
    case first <> rest:joined(~Value,next=>text=>sequence(~Value,rest,prefix ++ text ++ "\n",next),first(value))
def attached(~S:Data,result:Scheduled.Attachment<App.Application<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2}),PublicRelation.View<S>,PublicRelation.observe(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~PublicRelation.builtin_row(~S)),Registered.empty_fold(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2})>,Application(~S)>) -> String:
  match result:
    case Scheduled.Invalid{_}:"Invalid"
    case Scheduled.Attached{app}:sequence(~Application(~S),[snapshot(~S,True{}),snapshot(~S,True{}),snapshot(~S,False{}),run(~S),snapshot(~S,True{}),run(~S),snapshot(~S,True{}),snapshot(~S,False{})],"",app)
def second_registered(~S:Data,first:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2}),result:Sys.RegistrationResult<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Unit,Unit,Unit,Registered.reader(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2})>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"RegistrationFailed"
    case Sys.Registered{world,_}:attached(~S,Relation.attach(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2},Schema.resource_schema(~S,~State.Resources<S>,Schema.resource(~S,~State.Resources<S>,"Counter")),first,world,"Update",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{2,1},[]},SP.Entry{Sch.Barrier{},[]}}}))
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Unit,Unit,Unit,Registered.reader(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2})>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"RegistrationFailed"
    case Sys.Registered{world,first}:second_registered(~S,first,Registered.register(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2},world,"OtherReadLinks"))
def pending(~S:Data,world:State.World(~S)) -> State.World(~S):
  W.event_publish(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,world,[A.Original{99}])
def activated(~S:Data,result:State.World(~S) & W.Status) -> State.World(~S):
  match result:
    case (world,_):world
def reserved(~S:Data,result:State.World(~S) & W.Reservation<S>) -> State.World(~S):
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,world,handle))
    case (world,W.ReservationRejected{_}):world
def add_entity(~S:Data,world:State.World(~S)) -> State.World(~S):
  reserved(~S,W.reserve_id(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,world))
def entities(~S:Data,world:State.World(~S)) -> State.World(~S):
  add_entity(~S,add_entity(~S,add_entity(~S,world)))
def empty_store(~S:Data,value:Unit) -> A.Store<S,Unit>:
  A.Store{Unit{},G.Graph{[],[]}}
def seed_finished(~S:Data,result:T.Returned<State.World(~S),Unit>) -> State.World(~S):
  match result:
    case T.Returned{world,_}:W.barrier(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,world)
def seed_queued(~S:Data,result:T.Tx<State.World(~S),A.Notice<S,U32>> & A.QueueStatus) -> State.World(~S):
  match result:
    case (frame,_):seed_finished(~S,Cmd.tx_finish(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,frame,T.Success{}))
def seeded(~S:Data,world:State.World(~S)) -> State.World(~S):
  seed_queued(~S,A.queue_relate(~S,~Unit,~State.Resources<S>,~U32,T.begin(~State.World(~S),~A.Notice<S,U32>,entities(~S,world)),PublicRelation.descriptor(~S,declaration(~S)),W.Handle{1,1},W.Handle{1,2}))
def created(~S:Data,result:W.Creation<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:registered(~S,Registered.register(~S,~Unit,~State.Resources<S>,~U32,~declaration(~S),~W.Handle{1,2},W.enqueue(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,W.event_publish(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,seeded(~S,world),[A.Original{91},A.Original{92}]),pending(~S)),"ReadLinks"))
    case _:"CREATE_REJECTED"
def scenario(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~empty_store(~S),W.factory(),State.Resources{ANode{ALeaf{61},ALeaf{62}}}))
