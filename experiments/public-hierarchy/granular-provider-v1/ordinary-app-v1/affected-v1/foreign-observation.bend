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
import ../fixture.bend as Seed
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/observer.bend as Obs

import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/affected-v1/foreign-observer.bend as Physical
def namespace_observed(~S:Data,result:C.World(~S) & U32) -> C.World(~S) & DTO.Observation<String>:
  match result:
    case (world,namespace):C.prior_complete(~S,Physical.observe(~S,namespace,world))
def prior(~S:Data,world:C.World(~S)) -> C.World(~S) & DTO.Observation<String>:
  namespace_observed(~S,W.namespace(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world))
def Application(~S:Data) -> Type:
  App.Application(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S))
def AppObserved(~S:Data) -> Data:
  Relation.ObservedRows(~S,~String)
def snap_done(~S:Data,label:String,ownerText:String,result:Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<AppObserved(~S)>>>) -> Application(~S) & String:
  match result:
    case (app,None{}):(app,label ++ "|SNAPSHOT_DISABLED")
    case (app,Some{DTO.Product{_,DTO.Observation{_,values}}}):(app,label ++ "|owners=" ++ ownerText ++ "\n" ++ C.texts(values))
def owners_seen(~S:Data,label:String,world:C.World(~S),recipe:Relation.Recipe(~S,~O.Components<S>,~Array<U32>,~U32,~App.declaration(~S,C.hierarchy(~S)),~Array<U32>,~String,~prior(~S),~C.fold(~S)),debug:Bool,result:Array<U32> & List<&2,U32>) -> Application(~S) & String:
  match result:
    case (owners,values):snap_done(~S,label,O.show_ids(values),App.snapshot_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S),Build.Registered{world,owners,recipe,debug},True{}))
def snapshot(~S:Data,label:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:owners_seen(~S,label,world,recipe,debug,O.project_cells(2n,owners,0))
def read_breadth_done(~S:Data,text:String,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):(app,text ++ "|breadth=" ++ Seed.show_optional_path(~S,value))
def read_depth_done(~S:Data,text:String,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_breadth_done(~S,text ++ "|depth=" ++ Seed.show_optional_path(~S,value),App.descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S),app,target,Traversal.Breadth{}))
def read_ancestors_done(~S:Data,text:String,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,Path.Path<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_depth_done(~S,text ++ "|ancestors=" ++ Seed.show_optional_path(~S,value),target,App.descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S),app,target,Traversal.Depth{}))
def read_root_done(~S:Data,+target:W.Handle<S>,result:Application(~S) & Maybe<&2,W.Handle<S>>) -> Application(~S) & String:
  match result:
    case (app,value):read_ancestors_done(~S,"entity=" ++ Seed.show_handle(~S,Some{target}) ++ "|root=" ++ Seed.show_handle(~S,value),target,App.ancestors_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S),app,target))
def read(~S:Data,app:Application(~S),+target:W.Handle<S>) -> Application(~S) & String:
  read_root_done(~S,target,App.root_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~prior(~S),~C.fold(~S),app,target))
