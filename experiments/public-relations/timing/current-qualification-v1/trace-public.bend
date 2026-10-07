import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-graph.bend as Graph
import ../../../../src/ecs/relation-commands.bend as A
import ../../promotion-stage/application/next-version/v1/owned-world.bend as O
import trace-value.bend as J

def store_target(~S:Data,store:A.Store<S,O.Components<S>>,+descriptor:G.Descriptor<S>,+id:U32) -> A.Store<S,O.Components<S>> & J.Value:
  match store:
    case A.Store{components,+graph}:(A.Store{components,graph},J.maybe_number(Graph.target(~S,graph,descriptor,id)))
def target_checked(~S:Data,checked:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Bool,+descriptor:G.Descriptor<S>,+id:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  match checked:
    case (world,False{}):(world,J.Null{})
    case (world,True{}):W.with_store(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~J.Value,store => store_target(~S,store,descriptor,id),world)
def inverse_value(value:Maybe<&2,List<&2,U32>>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{ids}:J.Items{J.numbers(ids)}
def lookup_join(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,List<&2,U32>>,target:J.Value,targets:List<&2,J.Value>,sources:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>):
  (world,source) = result
  (world,(List.append(&2,J.Value,targets,[target]),List.append(&2,J.Value,sources,[inverse_value(source)])))
def lookup_target(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,+descriptor:G.Descriptor<S>,+id:U32,targets:List<&2,J.Value>,sources:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>):
  (world,target) = result
  lookup_join(~S,A.inverse(~S,~O.Components<S>,~U32,~U32,world,descriptor,W.Handle{1,id}),target,targets,sources)
def lookup_next(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>),next:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> List<&2,J.Value> -> List<&2,J.Value> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>)) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>):
  (world,(targets,sources)) = result
  next(world,targets,sources)
def lookups(~S:Data,fuel:Nat,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+descriptor:G.Descriptor<S>,+id:U32,targets:List<&2,J.Value>,sources:List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>):
  match fuel:
    case 0n:(world,(targets,sources))
    case 1n+rest:
      lookup_next(~S,lookup_target(~S,target_checked(~S,W.valid(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world,W.Handle{1,id}),descriptor,id),descriptor,id,targets,sources),world => targets => sources => lookups(~S,rest,world,descriptor,(id+1:U32),targets,sources))
def graph_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & (List<&2,J.Value> & List<&2,J.Value>),+descriptor:G.Descriptor<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value:
  match result descriptor:
    case (world,(targets,sources)) G.Descriptor{key,name,_,_}:(world,J.Object{[J.Field{"key",J.Number{key}},J.Field{"name",J.Text{name}},J.Field{"targets",J.Items{targets}},J.Field{"sources",J.Items{sources}}]})
def graphs_cons(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>,graph:J.Value) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,values) = result
  (world,graph <> values)
def graphs_next(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & J.Value,next:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  (world,graph) = result
  graphs_cons(~S,next(world),graph)
def graphs(~S:Data,descriptors:List<&2,G.Descriptor<S>>,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+count:Nat) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,J.Value>:
  match descriptors:
    case []:(world,[])
    case +descriptor <> rest:
      graphs_next(~S,graph_done(~S,lookups(~S,count,world,descriptor,1,[],[]),descriptor),world => graphs(~S,rest,world,count))
def failure(~S:Data,value:G.Failure<S>) -> J.Value:
  match value:
    case G.Failure{G.Descriptor{_,name,_,_},_,source,target,G.SelfRelationNotAllowed{entity,relation}}:J.Object{[J.Field{"operation",J.Text{"relate"}},J.Field{"relation",J.Text{name}},J.Field{"source",J.Number{source}},J.Field{"target",J.Number{target}},J.Field{"error",J.Object{[J.Field{"_tag",J.Text{"SelfRelationNotAllowed"}},J.Field{"entityId",J.Number{entity}},J.Field{"relation",J.Text{relation}}]}}]}
    case _:J.Text{"UNEXPECTED_FAILURE_VARIANT"}
def notice_cons(~S:Data,result:List<&2,J.Value> & (List<&2,J.Value> & List<&2,J.Value>),event:A.Notice<S,U32>) -> List<&2,J.Value> & (List<&2,J.Value> & List<&2,J.Value>):
  (failures,(removed,despawned)) = result
  match event:
    case A.RelationFailed{value}:(failure(~S,value) <> failures,(removed,despawned))
    case A.ComponentRemoved{id}:(failures,(J.Number{id} <> removed,despawned))
    case A.Original{event}:(failures,(removed,J.Number{(event-1000:U32)} <> despawned))
    case A.CleanupPaused{_}:(J.Text{"UNEXPECTED_CLEANUP_PAUSE"} <> failures,(removed,despawned))
def notices(~S:Data,events:List<&2,A.Notice<S,U32>>) -> List<&2,J.Value> & (List<&2,J.Value> & List<&2,J.Value>):
  match events:
    case []:([],([],[]))
    case event <> rest:
      notice_cons(~S,notices(~S,rest),event)
def status(value:Maybe<&2,U32>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{error}:J.Object{[J.Field{"kind",J.Text{"SystemFailure"}},J.Field{"system",J.Text{"relation-write-5"}},J.Field{"error",J.Number{error}}]}
