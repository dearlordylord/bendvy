import Base
import ./extended-declarations.bend as Schema
import ./extended-population.bend as Population
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-world-publication.bend as Relation
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-provider.bend as Provider
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

type Prepared<-S:Data> is Type:
  Prepared{world:Schema.World(~S),previous:Population.Previous(~S),receipt:Store.Receipt<S>}
  Refused{result:Population.Population<S>}
def related(~S:Data,previous:Population.Previous(~S),result:Schema.World(~S) & (Context.Binding<S,Schema.Resources(~S),Schema.resource_layout(~S),{==},Layout.InLeft{Layout.AtLeaf{}},Schema.hierarchy(~S),{==},{==},{==}> & Store.Receipt<S>)) -> Prepared<S>:
  match result:
    case (world,(_,receipt)):Prepared{world,previous,receipt}
# A real self-relation refusal populates the canonical receiver failure channel.
# Restore must retain this receiver history instead of importing source history.
def clocked(~S:Data,+handle:W.Handle<S>,previous:Population.Previous(~S),result:Schema.World(~S) & Tick.Tick) -> Prepared<S>:
  match handle result:
    case W.Handle{namespace,key}, (world,tick):related(~S,previous,Relation.apply(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Schema.resource_layout(~S),~{==},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Schema.hierarchy(~S),~{==},~{==},~{==},Provider.bind(~S,~Schema.Resources(~S),~Schema.resource_layout(~S),~{==},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Schema.hierarchy(~S),~{==},~{==},~{==},Context.Context{namespace}),world,Operation.Relate{W.Handle{namespace,key},W.Handle{namespace,key}},tick))
def populated(~S:Data,result:Population.Population<S>) -> Prepared<S>:
  match result:
    case Population.Populated{world,[handle,_],previous}:clocked(~S,handle,previous,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
    case other:Refused{other}
def prepare(~S:Data,world:Schema.World(~S)) -> Prepared<S>:populated(~S,Population.source(~S,world))
