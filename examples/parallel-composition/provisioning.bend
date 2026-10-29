import Base
import ./schema.bend as S
import ./application.bend as App
import ./feature-labels.bend as Labels
import ../../src/ecs/feature.bend as Feature
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/execution-composer-service.bend as Service

def returned(extra:Bool,restore:S.World() -> App.Provisions -> App.Application(),provisions:App.Provisions,result:Service.Provision<S.World(),Labels.Host>) -> App.Application():
  match extra provisions result:
    case _ provisions Service.Provisioned{world}:restore(world,provisions)
    case False{} App.Provisions{a,b,_,refused} Service.ProvisionRefused{world,incoming}:restore(world,App.Provisions{a,b,Some{incoming},refused})
    case True{} App.Provisions{a,b,pending,refused} Service.ProvisionRefused{world,incoming}:restore(world,App.Provisions{a,b,pending,incoming <> refused})
# Provisioning requires a physical World. Refused cut inventories stay owned.
def install(value:App.Application()) -> App.Application():
  match value:
    case Feature.Application{Scheduled.Scheduled{Dep.State{Root.Present{world,displaced},owners,guards,handler,bindings},plan,original,rules,deferred},App.Provisions{a,b,Some{host},refused},invalid}:returned(False{},world => provisions => Feature.Application{Scheduled.Scheduled{Dep.State{Root.Present{world,displaced},owners,guards,handler,bindings},plan,original,rules,deferred},provisions,invalid},App.Provisions{a,b,None{},refused},Service.provide(~S.Nominal,~S.Store(),~S.Resources(),~Unit,~Labels.Host,~S.resources(),~S.host_route(),~{==},~{==},~{==},world,host))
    case value:value
def extra(value:App.Application()) -> App.Application():
  match value:
    case Feature.Application{Scheduled.Scheduled{Dep.State{Root.Present{world,displaced},owners,guards,handler,bindings},plan,original,rules,deferred},provisions,invalid}:returned(True{},world => provisions => Feature.Application{Scheduled.Scheduled{Dep.State{Root.Present{world,displaced},owners,guards,handler,bindings},plan,original,rules,deferred},provisions,invalid},provisions,Service.provide(~S.Nominal,~S.Store(),~S.Resources(),~Unit,~Labels.Host,~S.resources(),~S.host_route(),~{==},~{==},~{==},world,Labels.Host{ALeaf{"HOST-902"},0}))
    case value:value
