import Base
import ./consumer-public-pruned.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine-handler.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/application.bend as Old
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/systems.bend as Systems
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/consumer.bend as Prior
def mismatch(~S:Data,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>) -> List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>:
  match items:
    case []:[]
    case B.Scheduled{selector,needs,H.Entry{id,registry}} <> rest:B.Scheduled{selector,needs,H.Entry{U32.add(id,100),registry}} <> rest
def changed(~S:Data,app:Consumer.ordinary_application(~S)) -> Consumer.ordinary_application(~S):
  match app:
    case App.Application{world,B.Bundle{namespace,entries},declaration,reader,debug}:App.Application{world,B.Bundle{namespace,mismatch(~S,entries)},declaration,reader,debug}
    case app:app
def created(~S:Data,result:Old.Construction<S>) -> String:
  match result:
    case Old.ConstructionRefused{_}:"construction-refused"
    case Old.Constructed{_,app}:Prior.sequence(~Consumer.ordinary_application(~S),[Consumer.ordinary_snapshot(~S,False{}),Consumer.ordinary_snapshot(~S,True{}),Consumer.ordinary_snapshot(~S,True{}),Consumer.ordinary_snapshot(~S,False{})],"",changed(~S,Consumer.ordinary_converted(~S,Old.queue_play(~S,Old.install_reader(~S,app)))))
def scenario(~S:Data) -> String:created(~S,Old.create(~S,W.factory()))
