import Base
import ./spawn.bend as S
import ./spawn-identity.bend as I
import ./spawn-identity-observation.bend as O
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/owner-product.bend as Product

def near(world:O.World()) -> O.World() & Bool:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle}:
      O.joined(A.Allocator,Bool,O.World() & Bool,A.advance_floor(allocator,131072),allocator => allowed =>
        (W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle},allowed))
def foreign_created(world:O.World(),result:W.Creation<S.Schema,S.Store(),S.Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{_,foreign}:I.reserved_join(foreign => handle => I.registered_at(10,1n,world,foreign,handle),W.reserve_id(~S.Schema,~S.Store(),~S.Resources(),~Unit,foreign))
    case W.CreateRejected{_,_}:IO.pure(String,"foreign-creation-refused")
def near_join(factory:W.Factory,result:O.World() & Bool) -> IO(String):
  match result:
    case (world,True{}):foreign_created(world,W.create(~S.Schema,~S.Store(),~S.Resources(),~Unit,~S.empty,factory,Product.Owner{Unit{},Unit{}}))
    case (_,False{}):IO.pure(String,"floor-refused")
def created(result:W.Creation<S.Schema,S.Store(),S.Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}:I.reserved_join(world => _ => near_join(factory,near(world)),W.reserve_id(~S.Schema,~S.Store(),~S.Resources(),~Unit,world))
    case W.CreateRejected{_,_}:IO.pure(String,"creation-refused")
def main() -> IO(Unit):
  IO.bind(String,Unit,created(W.create(~S.Schema,~S.Store(),~S.Resources(),~Unit,~S.empty,W.factory(),Product.Owner{Unit{},Unit{}})),IO.print)
