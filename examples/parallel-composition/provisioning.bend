import Base
import ./schema.bend as Schema
import ./declarations.bend as D
import ./application.bend as Application
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-composer-app.bend as Compose
import ../../src/ecs/dependency-composer.bend as Composition
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/schema-fragments.bend as Fragment

type Rest is Type:
  Rest{owners:D.Owners(),guards:D.Guards(),handler:Application.Handler,bindings:List<&2,Dep.Binding>,plan:Plan.Build<String>,original:List<&2,Dep.Binding>,entries:List<&2,Fragment.Entry<Schema.Nominal>>,provisions:Application.Provisions,invalid:Maybe<&2,Composition.Error>}
def restore(world:Schema.World(),rest:Rest) -> Application.Application():
  match rest:
    case Rest{owners,guards,handler,bindings,plan,original,entries,provisions,invalid}:Compose.Composed{Dep.Application{Dep.State{world,owners,guards,handler,bindings},plan,original},Fragment.Fragment{entries,provisions},invalid}
def returned(extra:Bool,rest:Rest,result:Service.Provision<Schema.World(),Labels.Host>) -> Application.Application():
  match extra rest result:
    case _ rest Service.Provisioned{world}:restore(world,rest)
    case False{} Rest{owners,guards,handler,bindings,plan,original,entries,Application.Provisions{a,b,_,refused},invalid} Service.ProvisionRefused{world,incoming}:restore(world,Rest{owners,guards,handler,bindings,plan,original,entries,Application.Provisions{a,b,Some{incoming},refused},invalid})
    case True{} Rest{owners,guards,handler,bindings,plan,original,entries,Application.Provisions{a,b,pending,refused},invalid} Service.ProvisionRefused{world,incoming}:restore(world,Rest{owners,guards,handler,bindings,plan,original,entries,Application.Provisions{a,b,pending,incoming <> refused},invalid})
def install(value:Application.Application()) -> Application.Application():
  match value:
    case Compose.Composed{Dep.Application{Dep.State{world,owners,guards,handler,bindings},plan,original},Fragment.Fragment{entries,Application.Provisions{a,b,Some{host},refused}},invalid}:returned(False{},Rest{owners,guards,handler,bindings,plan,original,entries,Application.Provisions{a,b,None{},refused},invalid},Service.provide(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Host,~Schema.resources(),~Schema.host_route(),~{==},~{==},~{==},world,host))
    case value:value
def extra(value:Application.Application()) -> Application.Application():
  match value:
    case Compose.Composed{Dep.Application{Dep.State{world,owners,guards,handler,bindings},plan,original},Fragment.Fragment{entries,provisions},invalid}:returned(True{},Rest{owners,guards,handler,bindings,plan,original,entries,provisions,invalid},Service.provide(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Host,~Schema.resources(),~Schema.host_route(),~{==},~{==},~{==},world,Labels.Host{ALeaf{"HOST-902"},0}))
