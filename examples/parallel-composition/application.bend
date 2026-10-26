import Base
import ./schema.bend as Schema
import ./declarations.bend as D
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-composer-app.bend as Compose
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec

type Provisions is Type:Provisions{motion:Array<U32>,labels:Array<String>,host:Maybe<&1,Labels.Host>,refused:List<Labels.Host>}
type Handler is Type:Handler{token:Array<U32>,errors:List<&2,String>}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,List.append(&2,String,errors,[error])},Exec.Continue{})
def Application() -> Type:Compose.Composed<Schema.Nominal,Schema.World(),D.Owners(),Provisions,D.Guards(),Handler,String,String,D.dispatch(),D.guards_dispatch(),handle>
def groups() -> List<&2,Scoped.Nested>:
  [Scoped.Nested{[0],[Plan.Edge{1,2}]},Scoped.Nested{[1],[Plan.Edge{3,4}]},Scoped.Nested{[],[Plan.Edge{1,3},Plan.Edge{3,2}]}]
def build(world:Schema.World(),owners:D.Owners(),guards:D.Guards(),nesting:List<&2,Scoped.Nested>) -> Application():
  Compose.build(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Schema.components(),~Schema.resources(),~{==},~{==},~D.Owners(),~Provisions,~D.Guards(),~Handler,~String,~String,~D.dispatch(),~D.guards_dispatch(),~handle,~D.selection,~D.guards_selection,world,owners,guards,Handler{ALeaf{801},[]},Provisions{ALeaf{601},ALeaf{"PROVISION-602"},Some{Labels.Host{ALeaf{"HOST-901"},0}},[]},nesting,[Dep.Binding{3,5},Dep.Binding{4,6}])
def run(value:Application()) -> Application() & Compose.CompositionReport<String,String>:
  Compose.run(~Schema.Nominal,~Schema.World(),~D.Owners(),~Provisions,~D.Guards(),~Handler,~String,~String,~D.dispatch(),~D.guards_dispatch(),~handle,value)
