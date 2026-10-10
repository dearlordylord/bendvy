import Base
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as A
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as RB
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
type ComponentRecipe is Type:
  ComponentRecipe{}
def component_described(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~V:Data,world:W.World<S,C,R,E>,rows:DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>,result:System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & DTO.Binding<S>) -> W.World<S,C,R,E> & (System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & (ComponentRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>>)):
  match result:
    case (owner,binding):(world,(owner,(ComponentRecipe{},DTO.Product{[binding],rows})))
def component_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~V:Data,owner:System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>,result:W.World<S,C,R,E> & DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>) -> W.World<S,C,R,E> & (System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & (ComponentRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>>)):
  match result:
    case (world,rows):component_described(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~V,world,rows,DTO.actual_description(~S,~C,~R,~E,~Args,~Error,~Out,~runner,owner))
def append_previous(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~render:V -> String,result:W.World<S,C,R,E> & DTO.Observation<Rows>) -> W.World<S,C,R,E> & DTO.Observation<DTO.Product<Rows,List<&2,IQ.ProjectedRow<S,V>>>>:
  match result:
    case (world,DTO.Observation{previous,summaries}):DTO.appended(~S,~C,~R,~E,~Rows,~V,~render,previous,summaries,DTO.lowered(~S,~C,~R,~E,~V,IQ.each_composed(~I.Frame<S,C,R,E>,~S,~V,~O.inspect_query(~S,~C,~R,~E,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~V,~query),I.Frame{world,1})))
def component_view(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~render:V -> String,recipe:ComponentRecipe,world:W.World<S,C,R,E>,owner:System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>>) -> W.World<S,C,R,E> & (System.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & (ComponentRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>>)):
  component_observed(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~V,owner,append_previous(~S,~C,~R,~E,~Unit,~Ops,~V,~query,~render,(world,DTO.Observation{Unit{},[]})))
type ResourceRecipe is Type:
  ResourceRecipe{}
def resource_described(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~kind:Query.Mode,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>,+value:V,result:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & DTO.Binding<S>) -> W.World<S,C,R,E> & (P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & (ResourceRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<V>>)):
  match result:
    case (owner,binding):(world,(owner,(ResourceRecipe{},DTO.Product{[binding],DTO.Observation{value,[D.name(~S,~C,~R,~E,~Ops,~V,declaration) ++ "=" ++ D.presenter(~S,~C,~R,~E,~Ops,~V,declaration)(value)]}})))
def resource_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~kind:Query.Mode,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,owner:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & (P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & (ResourceRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<V>>)):
  match result:
    case (world,value):resource_described(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~kind,~Ops,~V,~declaration,world,value,RB.actual_description(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,owner))
def resource_view(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~kind:Query.Mode,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,recipe:ResourceRecipe,world:W.World<S,C,R,E>,owner:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> W.World<S,C,R,E> & (P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & (ResourceRecipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<V>>)):
  resource_observed(~S,~C,~R,~E,~Args,~Error,~Out,~runner,~kind,~Ops,~V,~declaration,owner,D.observer(~S,~C,~R,~E,~Ops,~V,declaration)(world))
