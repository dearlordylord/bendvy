import Base
import ./consumer-public-pruned.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine-handler.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/application.bend as Old
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/consumer.bend as Prior
type Twin<S:Data> is Type:Twin{left:Consumer.ordinary_application(~S),right:Consumer.ordinary_application(~S)}
def paired(~S:Data,left:Consumer.ordinary_application(~S) & String,right:Consumer.ordinary_application(~S) & String) -> Twin<S> & String:
  (left,a)=left
  (right,b)=right
  (Twin{left,right},"left=" ++ a ++ "/right=" ++ b)
def snapshot(~S:Data,flag:Bool,value:Twin<S>) -> Twin<S> & String:
  match value:
    case Twin{left,right}:paired(~S,Consumer.ordinary_snapshot(~S,flag,left),Consumer.physical(~S,"",right))
def run(~S:Data,value:Twin<S>) -> Twin<S> & String:
  match value:
    case Twin{left,right}:paired(~S,Consumer.ordinary_marker(~S,left),Consumer.physical(~S,"",right))
def swapped(~S:Data,left:Consumer.ordinary_application(~S),right:Consumer.ordinary_application(~S)) -> Twin<S>:
  match left right:
    case App.Application{world1,bundle1,declaration1,reader1,debug1},App.Application{world2,bundle2,declaration2,reader2,debug2}:Twin{App.Application{world2,bundle1,declaration1,reader1,debug1},App.Application{world1,bundle2,declaration2,reader2,debug2}}
    case left,right:Twin{left,right}
def second(~S:Data,left:Old.Application<S>,result:Old.Construction<S>) -> String:
  match result:
    case Old.ConstructionRefused{_}:"second-construction-refused"
    case Old.Constructed{_,right}:Prior.sequence(~Twin<S>,[snapshot(~S,False{}),snapshot(~S,True{}),run(~S),snapshot(~S,True{}),snapshot(~S,False{})],"",swapped(~S,Consumer.ordinary_converted(~S,Old.queue_play(~S,Old.install_reader(~S,left))),Consumer.ordinary_converted(~S,Old.queue_play(~S,Old.install_reader(~S,right)))))
def first(~S:Data,result:Old.Construction<S>) -> String:
  match result:
    case Old.ConstructionRefused{_}:"first-construction-refused"
    case Old.Constructed{factory,left}:second(~S,left,Old.create(~S,factory))
def scenario(~S:Data) -> String:first(~S,Old.create(~S,W.factory()))
