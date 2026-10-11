import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as Path
import ./fixture.bend as Seed
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/observer.bend as Obs

type Alpha is Data: Alpha{}
type Beta is Data: Beta{}
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>
def observed(~S:Data,result:World(~S) & String) -> World(~S) & DTO.Observation<String>:
  match result:
    case (world,+text):(world,DTO.Observation{text,[text]})
def resource_cells(resource:Array<U32>) -> Array<U32> & List<&2,U32>:
  O.project_cells(2n,resource,0)
def resource_finished(~S:Data,text:String,result:World(~S) & List<&2,U32>) -> World(~S) & String:
  match result:
    case (world,values):(world,text ++ "|resource-all=" ++ O.show_ids(values))
def prior_complete(~S:Data,result:World(~S) & String) -> World(~S) & DTO.Observation<String>:
  match result:
    case (world,text):observed(~S,resource_finished(~S,text,W.observe_resource(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~List<&2,U32>,~resource_cells,world)))
def prior(~S:Data,world:World(~S)) -> World(~S) & DTO.Observation<String>:
  prior_complete(~S,Obs.observe(~S,world))
def fold(~S:Data,owners:Array<U32>) -> Array<U32> & List<&2,Fields.Fields<S>>:
  (owners,[])
def Application(~S:Data) -> Type:
  App.Application(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S))
def texts(values:List<&2,String>) -> String:
  match values:
    case []:""
    case value <> rest:value ++ "\n" ++ texts(rest)
def AppObserved(~S:Data) -> Data:
  Relation.ObservedRows(~S,~String)
def snap_done(~S:Data,label:String,ownerText:String,result:Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<AppObserved(~S)>>>) -> Application(~S) & String:
  match result:
    case (app,None{}):(app,label ++ "|SNAPSHOT_DISABLED")
    case (app,Some{DTO.Product{_,DTO.Observation{_,values}}}):(app,label ++ "|owners=" ++ ownerText ++ "\n" ++ texts(values))
def owners_seen(~S:Data,label:String,world:World(~S),recipe:Relation.Recipe(~S,~O.Components<S>,~Array<U32>,~U32,~App.declaration(~S,hierarchy(~S)),~Array<U32>,~String,~prior(~S),~fold(~S)),debug:Bool,result:Array<U32> & List<&2,U32>) -> Application(~S) & String:
  match result:
    case (owners,values):snap_done(~S,label,O.show_ids(values),App.snapshot_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),Build.Registered{world,owners,recipe,debug},True{}))
def snapshot(~S:Data,label:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:owners_seen(~S,label,world,recipe,debug,O.project_cells(2n,owners,0))
def read_breadth_done(~S:Data,text:String,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):(app,text ++ "|breadth=" ++ Seed.show_optional_path(~S,value))
def read_depth_done(~S:Data,text:String,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_breadth_done(~S,text ++ "|depth=" ++ Seed.show_optional_path(~S,value),App.descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app,target,Traversal.Breadth{}))
def read_ancestors_done(~S:Data,text:String,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_depth_done(~S,text ++ "|ancestors=" ++ Seed.show_optional_path(~S,value),target,App.descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app,target,Traversal.Depth{}))
def read_root_done(~S:Data,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,W.Handle<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_ancestors_done(~S,"entity=" ++ Seed.show_handle(~S,Some{target}) ++ "|root=" ++ Seed.show_handle(~S,value),target,App.ancestors_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app,target))
def read(~S:Data,app:Application(~S),+target:W.Handle<S>) -> Application(~S) & String:
  read_root_done(~S,target,App.root_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app,target))
def joined(~S:Data,head:String,result:Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,tail):(app,head ++ "\n" ++ tail)
def each_taken(~S:Data,text:String,result:Application(~S) & String,next:Application(~S) -> String -> Application(~S) & String) -> Application(~S) & String:
  match result:
    case (app,row):next(app,text ++ "\n" ++ row)
def each(~S:Data,handles:List<&2,W.Handle<S>>,app:Application(~S),text:String) -> Application(~S) & String:
  match handles:
    case []:(app,text)
    case head <> rest:each_taken(~S,text,read(~S,app,head),app => text => each(~S,rest,app,text))
def queued(~S:Data,result:Application(~S) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>) -> Application(~S):
  match result:
    case (app,_):app
def relate(~S:Data,app:Application(~S),source:W.Handle<S>,target:W.Handle<S>) -> Application(~S):
  queued(~S,App.relate_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),~Unit,app,P.Targets{source,target},Tx.Success{}))
def completed(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (_,tail):text ++ "\n" ++ tail
def final_reads(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):completed(~S,text,each(~S,handles,app,"FINAL_READS"))
def reparent_applied(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ final_reads(~S,handles,snapshot(~S,"REPARENT_APPLIED",App.barrier_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app)))
def reparent_pending(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ reparent_applied(~S,handles,snapshot(~S,"REPARENT_PENDING",app))
def initial_reads(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ reparent_pending(~S,[h1,h2,h3,h4],each(~S,[h1,h2,h3,h4],relate(~S,app,h4,h3),"REPARENT_QUEUED_READS"))
def applied(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match handles result:
    case Con{+h1,Con{+h2,Con{+h3,Con{+h4,Nil{}}}}} Tuple{app,text}:text ++ "\n" ++ initial_reads(~S,h1,h2,h3,h4,each(~S,[h1,h2,h3,h4],app,"INITIAL_READS"))
    case _ _:"HANDLE_LAYOUT_FAILURE"
def pending(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ applied(~S,handles,snapshot(~S,"INITIAL_APPLIED",App.barrier_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app)))
def pending_snapshot(~S:Data,+handles:List<&2,W.Handle<S>>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ pending(~S,handles,snapshot(~S,"INITIAL_PENDING",app))
def initial(~S:Data,+h1:W.Handle<S>,+h2:W.Handle<S>,+h3:W.Handle<S>,+h4:W.Handle<S>,result:Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "\n" ++ pending_snapshot(~S,[h1,h2,h3,h4],each(~S,[h1,h2,h3,h4],relate(~S,relate(~S,relate(~S,app,h2,h1),h3,h1),h4,h2),"QUEUED_READS"))
def seeded(~S:Data,state:World(~S) & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,Con{+h4,Con{+h3,Con{+h2,Con{+h1,Nil{}}}}}):initial(~S,h1,h2,h3,h4,snapshot(~S,"BEFORE",App.install(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}})))
    case _:"RESERVATION_FAILURE"
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:seeded(~S,Seed.spawn(~S,4n,(world,[])))
    case _:"CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("AppHierarchyAlpha\n" ++ run(~Alpha) ++ "\nAppHierarchyBeta\n" ++ run(~Beta))
