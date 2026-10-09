import Base
import application.bend as A
import provider.bend as P
import gameplay.bend as G
import context.bend as Ctx
import hooks.bend as H
import catalog.bend as Cat
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W

# Pure concrete instantiation only. The raw factory is not a foreign-scope test.
def finished(~S: Data,result: A.FrameResult<S>) -> String:
  match result:
    case A.FrameResult{_,_,status}: status
def provisioned(~S: Data,result: H.Provision<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> String:
  match result:
    case H.ProvisionFailed{_}: "provision-rejected"
    case H.Provisioned{world,hooks}:
      finished(~S,A.frame(~S,A.Owners{Cat.Catalog{[]},hooks,[],[],[],[],[]},world,"concrete-integration",[A.Body{1,"seed",G.Seed{}},A.Deferred{},A.Body{2,"definition-order",G.MarkerQueues{}},A.Marker{True{}},A.Read{10,"reader",False{}}]))
def created(~S: Data,result: W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}: "create-rejected"
    case W.Created{_,world}: provisioned(~S,H.provision(~S,~(world => operation => Ctx.hook_runner(~S,world,operation)),world))
def scenario(~S: Data) -> String:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),W.factory(),P.initial_resources(~S)))
def main() -> String:
  scenario(~P.SchemaA) ++ ":" ++ scenario(~P.SchemaB)
