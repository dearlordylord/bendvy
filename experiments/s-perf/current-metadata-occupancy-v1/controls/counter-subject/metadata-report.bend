import Base
import ../../private/occupancy.bend as O
import ../../private/src/ecs/column.bend as Col
import ../../private/src/ecs/world.bend as W
import ../../private/src/ecs/owner-product.bend as Product
import motion.bend as F
import types.bend as T
import events.bend as E
import ../../private/src/ecs/entity-allocator.bend as A
import ../../private/src/ecs/deferred-command.bend as Deferred

def shape(value:O.Shape) -> String:
  match value:
    case O.Shape{leaves,nodes}:"[" ++ Nat.show(leaves) ++ "," ++ Nat.show(nodes) ++ "]"
def array(value:O.ArrayStats) -> String:
  match value:
    case O.ArrayStats{leaves,nodes,nonzero}:"[" ++ Nat.show(leaves) ++ "," ++ Nat.show(nodes) ++ "," ++ Nat.show(1n+nonzero) ++ "]"
def entries(value:O.EntryStats) -> String:
  match value:
    case O.EntryStats{physical,added,changed,populated}:"[" ++ Nat.show(physical) ++ "," ++ Nat.show(added) ++ "," ++ Nat.show(changed) ++ "," ++ Nat.show(populated) ++ "]"
def metadata(value:O.MetadataStats) -> String:
  match value:
    case O.MetadataStats{added,changed,capacity,depth,exceptional,populated}:"{\"added\":" ++ array(added) ++ ",\"changed\":" ++ array(changed) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"exceptional\":" ++ entries(exceptional) ++ ",\"populated\":" ++ Nat.show(populated) ++ "}"
def snapshot(value:O.Snapshot) -> String:
  match value:
    case O.Plain{values,stamps}:"{\"kind\":\"plain\",\"values\":" ++ shape(values) ++ ",\"entries\":" ++ entries(stamps) ++ "}"
    case O.Indexed{values,marks}:"{\"kind\":\"indexed\",\"values\":" ++ shape(values) ++ ",\"metadata\":" ++ metadata(marks) ++ "}"
def sample(value:O.Sample) -> String:
  match value:
    case O.Sample{site,value}:"{\"site\":\"" ++ site ++ "\",\"snapshot\":" ++ snapshot(value) ++ "}"
def tail(values:List<&2,O.Sample>) -> String:
  match values:
    case []:"]"
    case head <> rest:"," ++ sample(head) ++ tail(rest)
def samples(values:List<&2,O.Sample>) -> String:
  match values:
    case []:"[]"
    case head <> rest:"[" ++ sample(head) ++ tail(rest)
def column(~C:Type,value:Col.Column<T.MotionSchema,C>) -> Col.Column<T.MotionSchema,C> & String:
  match value:
    case Col.Monitored{inner,+history}:(Col.Monitored{inner,history},samples(List.reverse(&2,O.Sample,history)))
    case other:(other,"[]")
def store_join(main:Col.Column<T.MotionSchema,T.Position> & String,aux:Col.Column<T.MotionSchema,T.Velocity> & String,flag:Col.Column<T.MotionSchema,T.Selected> & String) -> F.Store() & String:
  match main aux flag:
    case (main,a), (aux,b), (flag,c):(Product.Owner{main,Product.Owner{aux,flag}},"{\"main\":" ++ a ++ ",\"aux\":" ++ b ++ ",\"flag\":" ++ c ++ "}")
def observe_store(value:F.Store()) -> F.Store() & String:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:store_join(column(~T.Position,main),column(~T.Velocity,aux),column(~T.Selected,flag))
def world_join(namespace:U32,allocator:A.Allocator,resource:F.Resources(),events:List<&2,E.event_type()>,pending:List<Deferred.Command<F.World()>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,observed:F.Store() & String) -> F.World() & String:
  match observed:
    case (store,text):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},text)
def world(value:F.World()) -> F.World() & String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:world_join(namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,observe_store(store))
