import Base
import ./relation-app.bend as Relation
import ./state.bend as State
import ./dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Select
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def World(~S:Data) -> Type:
  State.World(~S)
def declaration(~S:Data) -> Ord.Declaration<S>:
  Ord.relation(~S,G.Descriptor{7,"Link","LinkedBy",G.Ordinary{}})
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def relation_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}:"Missing"
    case RQ.Target{target}:"Target:" ++ handle(~S,target)
    case RQ.Sources{targets}:"Sources:" ++ List.show(&2,W.Handle<S>,handle(~S),targets)
def end(value:RQ.End) -> String:
  match value:
    case RQ.Outgoing{}:"Outgoing"
    case RQ.Incoming{}:"Incoming"
def cell(~S:Data,value:RQ.Cell<S>) -> String:
  match value:
    case RQ.Cell{key,direction,value}:key ++ ":" ++ end(direction) ++ ":" ++ relation_value(~S,value)
def row(~S:Data,value:Relation.Row(~S)) -> String:
  match value:
    case IQ.ProjectedRow{entity,Select.Product{_,cells}}:handle(~S,entity) ++ ":" ++ List.show(&2,RQ.Cell<S>,cell(~S),cells)
def Application(~S:Data) -> Type:
  Relation.Application(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S))
def rows(~S:Data) -> Data:
  Relation.ObservedRows(~S,~Unit)
def completed(~S:Data,text:String,owners:Unit,recipe:Relation.Recipe(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S)),debug:Bool,result:World(~S) & String) -> Application(~S) & String:
  match result:
    case (world,physical):(Build.Registered{world,owners,recipe,debug},text ++ "|owners=Unit|" ++ physical)
def complete(~S:Data,text:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:completed(~S,text,owners,recipe,debug,Dump.world(~S,world))
def view(~S:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<rows(~S)>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{DTO.Product{bindings,DTO.Observation{_,text}}}:"Debug{bindings=" ++ Nat.show(List.length(&2,DTO.Binding<S>,bindings)) ++ "|relations=" ++ List.show(&2,String,x=>x,text) ++ "}"
def shown(~S:Data,result:Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<rows(~S)>>>) -> Application(~S) & String:
  match result:
    case (app,value):complete(~S,view(~S,value),app)
def snapshot(~S:Data,flag:Bool,app:Application(~S)) -> Application(~S) & String:
  shown(~S,Relation.snapshot_app(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),app,flag))
def outcome(value:T.Outcome<Unit>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{_}:"Failure:Unit"
def status(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def queued(~S:Data,result:Application(~S) & DTO.Product<A.QueueStatus,T.Outcome<Unit>>) -> Application(~S) & String:
  match result:
    case (app,DTO.Product{state,result}):complete(~S,status(state) ++ ":" ++ outcome(result),app)
def selected(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case True{}:T.Failure{Unit{}}
    case False{}:T.Success{}
def relate(~S:Data,source:U32,fail:Bool,app:Application(~S)) -> Application(~S) & String:
  queued(~S,Relation.relate_app(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Unit,app,P.Targets{W.Handle{1,source},W.Handle{1,2}},selected(fail)))
def read_shown(~S:Data,result:Application(~S) & Maybe<&2,List<&2,W.Handle<S>>>) -> Application(~S) & String:
  match result:
    case (app,None{}):complete(~S,"Inverse:None",app)
    case (app,Some{targets}):complete(~S,"Inverse:" ++ List.show(&2,W.Handle<S>,handle(~S),targets),app)
def read(~S:Data,app:Application(~S)) -> Application(~S) & String:
  read_shown(~S,Relation.inverse_app(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),app,W.Handle{1,2}))
def barrier(~S:Data,app:Application(~S)) -> Application(~S) & String:
  complete(~S,"Barrier",Relation.barrier_app(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),app))
def joined(~Value:Type,next:Value -> String -> String,result:Value & String) -> String:
  match result:
    case (value,text):next(value,text)
def sequence(~Value:Type,actions:List<(Value -> Value & String)>,prefix:String,value:Value) -> String:
  match actions:
    case []:prefix
    case first <> rest:joined(~Value,next=>text=>sequence(~Value,rest,prefix ++ text ++ "\n",next),first(value))
def attached(~S:Data,app:Application(~S)) -> String:
  sequence(~Application(~S),[snapshot(~S,True{}),snapshot(~S,True{}),snapshot(~S,False{}),read(~S),relate(~S,1,False{}),snapshot(~S,True{}),barrier(~S),snapshot(~S,True{}),read(~S),relate(~S,3,True{}),snapshot(~S,True{}),relate(~S,3,False{}),barrier(~S),snapshot(~S,True{}),read(~S),snapshot(~S,False{})],"",app)
def pending(~S:Data,world:World(~S)) -> World(~S):
  W.event_publish(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,[A.Original{99}])
def activated(~S:Data,result:World(~S) & W.Status) -> World(~S):
  match result:
    case (world,_):world
def reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> World(~S):
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,handle))
    case (world,W.ReservationRejected{_}):world
def add_entity(~S:Data,world:World(~S)) -> World(~S):
  reserved(~S,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
def entities(~S:Data,world:World(~S)) -> World(~S):
  add_entity(~S,add_entity(~S,add_entity(~S,world)))
def empty_store(~S:Data,value:Unit) -> A.Store<S,State.Components<S>>:
  A.Store{State.Components{ANode{ALeaf{41},ALeaf{42}}},G.Graph{[],[]}}
def created(~S:Data,result:W.Creation<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:attached(~S,Relation.install(~S,~State.Components<S>,~State.Resources<S>,~U32,~declaration(~S),~row(~S),~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),Build.empty(~S,~World(~S),W.enqueue(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,W.event_publish(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,entities(~S,world),[A.Original{91},A.Original{92}]),pending(~S)))))
    case _:"CREATE_REJECTED"
def scenario(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~empty_store(~S),W.factory(),State.Resources{ANode{ALeaf{61},ALeaf{62}}}))
