import Base
import ./declarations.bend as D
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W

def World(~S:Data) -> Type:W.World<S,Layout.columns(~S,Plan.layout(D.components(~S))),Layout.resources(~S,Plan.layout(D.resources(~S))),Unit>
def snapshot(~S:Data,schema:Plan.Schema<S,D.components(~S),D.resources(~S)>,world:World(~S)) -> Plan.Schema<S,D.components(~S),D.resources(~S)> & (World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  Save.save(~S,~D.components(~S),~D.resources(~S),~Unit,schema,world)
def alpha(world:World(~D.Alpha)) -> Plan.Schema<D.Alpha,D.components(~D.Alpha),D.resources(~D.Alpha)> & (World(~D.Alpha) & Gate.Outcome<Saved.Snapshot<D.Alpha>,Recipe.Refusal>):snapshot(~D.Alpha,D.schema(~D.Alpha),world)
def beta(world:World(~D.Beta)) -> Plan.Schema<D.Beta,D.components(~D.Beta),D.resources(~D.Beta)> & (World(~D.Beta) & Gate.Outcome<Saved.Snapshot<D.Beta>,Recipe.Refusal>):snapshot(~D.Beta,D.schema(~D.Beta),world)
