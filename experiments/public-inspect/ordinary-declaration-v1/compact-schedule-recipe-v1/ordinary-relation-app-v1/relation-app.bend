import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/inspector-relation-projection.bend as IR
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Select
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd

# One trusted ordinary relation declaration drives operational grants and view.
def descriptor(~S:Data,declaration:Ord.Declaration<S>) -> G.Descriptor<S>:
  match declaration:
    case Ord.Declaration{value}:value
def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor_text(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverseName,tag}:"Relation{key=" ++ U32.show(key) ++ "|name=" ++ name ++ "|inverse=" ++ inverseName ++ "|kind=" ++ kind(tag) ++ "}"
def declared_spec(~S:Data,+value:G.Descriptor<S>) -> RQ.Spec<S>:
  match value:
    case G.Descriptor{+key,+name,+inverseName,+tag}:RQ.Spec{[RQ.optional_relation(~S,name,G.Descriptor{key,name,inverseName,tag}),RQ.optional_related(~S,inverseName,G.Descriptor{key,name,inverseName,tag})]}
def spec(~S:Data,declaration:Ord.Declaration<S>) -> RQ.Spec<S>:
  match declaration:
    case Ord.Declaration{+value}:declared_spec(~S,value)
def World(~S:Data,~C:Type,~R:Type,~E:Data) -> Type:
  W.World<S,A.Store<S,C>,R,A.Notice<S,E>>
def Row(~S:Data) -> Data:
  IQ.ProjectedRow<S,Select.Product<Unit,List<&2,RQ.Cell<S>>>>
type View<S:Data> is Data:
  View{descriptor:G.Descriptor<S>,rows:List<&2,Row(~S)>}
def ObservedRows(~S:Data,~Rows:Data) -> Data:
  DTO.Product<Rows,View<S>>
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
def builtin_row(~S:Data,value:Row(~S)) -> String:
  match value:
    case IQ.ProjectedRow{entity,Select.Product{_,cells}}:handle(~S,entity) ++ ":" ++ List.show(&2,RQ.Cell<S>,cell(~S),cells)
def rendered(~S:Data,~render:Row(~S) -> String,rows:List<&2,Row(~S)>) -> List<&2,String>:
  match rows:
    case []:[]
    case first <> rest:render(first) <> rendered(~S,~render,rest)
def presented(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,result:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Row(~S)>) -> World(~S,~C,~R,~E) & DTO.Observation<View<S>>:
  match result:
    case (I.Frame{world,_},+rows):(world,DTO.Observation{View{descriptor(~S,declaration),rows},descriptor_text(~S,descriptor(~S,declaration)) <> rendered(~S,~render,rows)})
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,world:World(~S,~C,~R,~E)) -> World(~S,~C,~R,~E) & DTO.Observation<View<S>>:
  presented(~S,~C,~R,~E,~declaration,~render,IQ.each_composed(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~Select.Product<Unit,List<&2,RQ.Cell<S>>>,~IR.grant(~S,~C,~R,~E,~Unit,~Select.empty(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S),~spec(~S,declaration)),I.Frame{world,0}))
def observation(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<ObservedRows(~S,~Rows)>:
  Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render))
def presented_Application(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Build.Registered<S,World(~S,~C,~R,~E),Owners,ObservedRows(~S,~Rows),Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),fold>
def presented_Recipe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Tree.Recipe<World(~S,~C,~R,~E),ObservedRows(~S,~Rows),Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render))>
def presented_install(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold):
  match app:
    case Build.Registered{world,owners,_,debug}:Build.Registered{world,owners,Tree.Recipe{},debug}
def presented_snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),flag:Bool) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<ObservedRows(~S,~Rows)>>>:
  Build.snapshot(~S,~World(~S,~C,~R,~E),~Owners,~ObservedRows(~S,~Rows),~Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),~fold,Build.enabled(~S,~World(~S,~C,~R,~E),~Owners,~ObservedRows(~S,~Rows),~Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),~fold,app,flag))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,result:T.Returned<World(~S,~C,~R,~E),Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match result:
    case T.Returned{world,status}:(Build.Registered{world,owners,recipe,debug},status)
def queue_finished(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,status:A.QueueStatus,result:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match result:
    case (app,outcome):(app,DTO.Product{status,outcome})
def queued(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,outcome:T.Outcome<Error>,result:T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>> & A.QueueStatus) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match result:
    case (frame,+status):queue_finished(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,status,returned(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Error,frame,outcome)))
def presented_relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:queued(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,outcome,P.relate(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_write(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),targets))
def presented_unrelate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),source:W.Handle<S>,outcome:T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:queued(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,outcome,P.unrelate(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_write(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),source))
def inverse_finished(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,value:Maybe<&2,List<&2,W.Handle<S>>>,result:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Unit>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match result:
    case (app,_):(app,value)
def inverse_taken(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,result:T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match result:
    case (frame,value):inverse_finished(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,value,returned(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Unit,owners,recipe,debug,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,frame,T.Success{})))
def presented_inverse_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:inverse_taken(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,owners,recipe,debug,P.read(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_read(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),target))
def presented_barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold)) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold):
  match app:
    case Build.Registered{world,owners,recipe,debug}:Build.Registered{W.barrier(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world),owners,recipe,debug}
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  presented_Application(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold)

def Recipe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  presented_Recipe(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold)

def install(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold):
  presented_install(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app)

def snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<ObservedRows(~S,~Rows)>>>:
  presented_snapshot_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app,flag)

def relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:T.Outcome<Error>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  presented_relate_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,~Error,app,targets,outcome)

def unrelate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),source:W.Handle<S>,outcome:T.Outcome<Error>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  presented_unrelate_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,~Error,app,source,outcome)

def inverse_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  presented_inverse_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app,target)

def barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold)) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold):
  presented_barrier_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app)
