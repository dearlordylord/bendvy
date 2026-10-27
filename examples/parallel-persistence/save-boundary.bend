import Base
import ../parallel-machines/pending-boundaries.bend as Ordinary
import ../parallel-machines/declarations.bend as D
import ../parallel-machines/scheduled.bend as Main
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-application.bend as App

# A concrete ordinary adapter, not an inventory supplied by the caller. The
# pending fold consumes and reconstructs the actual command-owner tree before
# this metadata-only projection can inspect World. Field export follows in the
# persistence-schema adapter; this result is not yet a restorable snapshot.
def captured(owners:Ordinary.Left() & Ordinary.Right(),guards:Unit,handler:Ordinary.Handler,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,rules:Part.Rules,deferred:Schedule.Deferred,result:Ordinary.World() & Metadata.Metadata<Ordinary.Schema>) -> Ordinary.Application() & Gate.Outcome<Metadata.Metadata<Ordinary.Schema>,Unit>:
  match owners result:
    case (left,right), (world,metadata):(Schedule.Scheduled{App.Application{App.State{world,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings},rules,deferred},Gate.Saved{metadata})
def project(actual:Ordinary.Application()) -> Ordinary.Application() & Gate.Outcome<Metadata.Metadata<Ordinary.Schema>,Unit>:
  match actual:
    case Schedule.Scheduled{App.Application{App.State{world,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings},rules,deferred}:captured((left,right),guards,handler,stateBindings,plan,bindings,rules,deferred,Metadata.capture(~Ordinary.Schema,~D.Store(~Ordinary.Schema),~Main.Resources(~Ordinary.Schema),~Unit,world))
def inspect(actual:Ordinary.Application()) -> Ordinary.Application() & Gate.Outcome<Metadata.Metadata<Ordinary.Schema>,Unit>:
  Gate.save(~Ordinary.Application(),~Metadata.Metadata<Ordinary.Schema>,~Unit,~Ordinary.pending,~project,actual)
