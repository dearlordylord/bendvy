import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owned-event-storage.bend as Storage
# Concrete pure instantiation only; executable acceptance uses actual WorldIO.
type Workshop is Data:Workshop{}
def empty(value:Unit) -> Unit:value
def second(world:F.World(~Workshop),result:W.Creation<Workshop,Unit,Storage.Resources<Unit,Array<U32>>,Nat>) -> String:
  match result:
    case W.Created{_,foreign}:Scenario.start(~Workshop,world,foreign)
    case _:"creation failed"
def first(result:W.Creation<Workshop,Unit,Storage.Resources<Unit,Array<U32>>,Nat>) -> String:
  match result:
    case W.Created{factory,world}:second(world,W.create(~Workshop,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,~empty,factory,F.resources()))
    case _:"creation failed"
def main() -> String:first(W.create(~Workshop,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,~empty,W.factory(),F.resources()))
