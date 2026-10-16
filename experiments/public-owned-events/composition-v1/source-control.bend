import Base
import ./fixture.bend as F
import ../../../src/ecs/column.bend as Col
import ./scenario.bend as Scenario
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owned-event-storage.bend as Storage
# Concrete pure instantiation only; executable acceptance uses actual WorldIO.
type Workshop is Data:Workshop{}
def empty(value:Unit) -> Unit:value
def second(world:F.World(~Workshop),result:W.Creation<Workshop,Col.Column<Workshop,U32>,Storage.Resources<U32,Array<U32>>,Nat>) -> String:
  match result:
    case W.Created{_,foreign}:Scenario.start(~Workshop,world,foreign)
    case _:"creation failed"
def first(result:W.Creation<Workshop,Col.Column<Workshop,U32>,Storage.Resources<U32,Array<U32>>,Nat>) -> String:
  match result:
    case W.Created{factory,world}:second(world,W.create(~Workshop,~Col.Column<Workshop,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,~F.empty(~Workshop),factory,F.resources()))
    case _:"creation failed"
def main() -> String:first(W.create(~Workshop,~Col.Column<Workshop,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,~F.empty(~Workshop),W.factory(),F.resources()))
