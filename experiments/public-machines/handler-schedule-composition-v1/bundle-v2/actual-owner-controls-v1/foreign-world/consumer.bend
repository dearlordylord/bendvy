import Base
import ../../consumer.bend as C
import ../../bridge.bend as Bridge
import ../../../application.bend as Old
import ../../../consumer.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import ../../../systems.bend as Systems
type Twin<S:Data> is Type:
  Twin{factory:W.Factory,home:C.Application<S>,foreign:C.Application<S>}
def observed(~S:Data,+next:U32,home:C.Application<S> & String,foreign:C.Application<S> & String) -> Twin<S> & String:
  match home foreign:
    case (home,a),(foreign,b):(Twin{W.Factory{next},home,foreign},"factory=" ++ U32.show(next) ++ "/home=" ++ a ++ "/foreign=" ++ b)
def factory_observed(~S:Data,factory:W.Factory,home:C.Application<S>,foreign:C.Application<S>) -> Twin<S> & String:
  match factory:
    case W.Factory{next}:observed(~S,next,C.observe(~S,home),C.observe(~S,foreign))
def observe(~S:Data,app:Twin<S>) -> Twin<S> & String:
  match app:
    case Twin{factory,home,foreign}:factory_observed(~S,factory,home,foreign)
def shown(~S:Data,label:String,pair:Twin<S> & String) -> Twin<S> & String:
  (app,text)=pair
  (app,label ++ ":" ++ text)
def snapshot(~S:Data,app:Twin<S>) -> Twin<S> & String:shown(~S,"snapshot",observe(~S,app))
def stopped(~S:Data,factory:W.Factory,homeBundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,homeReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,foreignWorld:W.World<S,T.Store<S>,T.Resources<S>,Unit>,foreignReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,result:Bridge.MarkerResult<S>) -> Twin<S> & String:
  match result:
    case Bridge.MarkerResult{B.Returned{foreignBundle,homeWorld,status},steps,observations}:shown(~S,"foreign-marker=" ++ C.status(status) ++ "/steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ "/observations=" ++ List.show(&2,Sch.Observation,Prior.observation,observations),observe(~S,Twin{factory,C.Application{homeWorld,homeBundle,homeReader},C.Application{foreignWorld,foreignBundle,foreignReader}}))
    case Bridge.MarkerResult{B.InternalOwnerRemainder{namespace,recovery,homeWorld,_},_,_}:(Twin{factory,C.Application{homeWorld,homeBundle,homeReader},C.Internal{foreignWorld,namespace,recovery,foreignReader}},"internal-owner-remainder")
def foreign_marker(~S:Data,app:Twin<S>) -> Twin<S> & String:
  match app:
    case Twin{factory,C.Application{homeWorld,homeBundle,homeReader},C.Application{foreignWorld,foreignBundle,foreignReader}}:stopped(~S,factory,homeBundle,homeReader,foreignWorld,foreignReader,Bridge.run(~S,~C.has(~S),foreignBundle,homeWorld))
    case app:(app,"internal-owner-remainder")
def prepared(~S:Data,app:Old.Application<S>) -> C.Application<S>:C.converted(~S,Old.queue_play(~S,Old.install_reader(~S,Prior.seeded(~S,1,app))))
def created_foreign(~S:Data,home:Old.Application<S>,result:Old.Construction<S>) -> String:
  match result:
    case Old.Constructed{factory,foreign}:Prior.sequence(~Twin<S>,[snapshot(~S),foreign_marker(~S),snapshot(~S),foreign_marker(~S),snapshot(~S)],"",Twin{factory,prepared(~S,home),prepared(~S,foreign)})
    case Old.ConstructionRefused{_}:"foreign-construction-refused"
def created_home(~S:Data,result:Old.Construction<S>) -> String:
  match result:
    case Old.Constructed{factory,home}:created_foreign(~S,home,Old.create(~S,factory))
    case Old.ConstructionRefused{_}:"home-construction-refused"
def report(~S:Data) -> String:created_home(~S,Old.create(~S,W.factory()))
