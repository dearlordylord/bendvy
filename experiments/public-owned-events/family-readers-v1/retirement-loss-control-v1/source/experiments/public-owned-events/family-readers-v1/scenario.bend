import Base
import ./fixture.bend as F
import ./catalog.bend as Catalog
import ./host.bend as H
import ./observe.bend as View
import ../families-v1/fixture.bend as Pub
import ../families-v1/observe.bend as PubView
import ../ordinary-v1/payload.bend as P
import ../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../src/ecs/ordinary-owned-event-family-publisher.bend as Standalone
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owned-event-family-lifecycle.bend as Life
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T

def mode(fail:Bool,args:P.Args) -> P.Args:
  match args:
    case P.Args{_,values,scratch}:P.Args{fail,values,scratch}
def status(value:T.Outcome<Core.Failure<P.Error>>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{Core.BodyFailed{P.ReadFailed{}}}:"body-failed"
    case T.Failure{Core.MissingPayload{}}:"missing-payload"
def completion(value:Ev.Completion<Unit,Core.Reply<P.Error,P.Args>,P.Args>) -> P.Args & String:
  match value:
    case Ev.Succeeded{Core.Reply{outcome,args,lagged}}:(args,status(outcome) ++ ":lag=" ++ Bool.show(lagged))
    case Ev.Rejected{args}:(args,"rejected")
    case Ev.Failed{_}:(P.args(False{},999),"UNEXPECTED_TRANSPORT_FAILURE")
def continued(~S:Data,next:H.Host<S> -> String,result:H.Host<S> & String) -> String:
  match result:
    case (host,text):text ++ next(host)
def observed(~S:Data,label:String,next:H.Host<S> -> String,host:H.Host<S>) -> String:
  continued(~S,next,View.snapshot(~S,label,host))
def fast_completion(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),runtime:F.Runtime(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),result:P.Args & String) -> H.Host<S> & String:
  match result:
    case (args,text):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"fast:" ++ text ++ "\n")
def fast_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Ran_a(~S)) -> H.Host<S> & String:
  match result:
    case Route.Ran{runtime,fast,fastRegistry,result}:fast_completion(~S,foreign,publisher,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,runtime,fast,fastRegistry,completion(result))
def call_fast(~S:Data,fail:Bool,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:fast_returned(~S,foreign,publisher,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,F.run_a(~S,runtime,fast,fastRegistry,mode(fail,args)))
def slow_completion(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),runtime:F.Runtime(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),result:P.Args & String) -> H.Host<S> & String:
  match result:
    case (args,text):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"slow:" ++ text ++ "\n")
def slow_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Ran_a(~S)) -> H.Host<S> & String:
  match result:
    case Route.Ran{runtime,slow,slowRegistry,result}:slow_completion(~S,foreign,publisher,fast,fastRegistry,alerts,alertsRegistry,crates,cratesRegistry,runtime,slow,slowRegistry,completion(result))
def call_slow(~S:Data,fail:Bool,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:slow_returned(~S,foreign,publisher,fast,fastRegistry,alerts,alertsRegistry,crates,cratesRegistry,F.run_a(~S,runtime,slow,slowRegistry,mode(fail,args)))
def alerts_completion(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),runtime:F.Runtime(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),result:P.Args & String) -> H.Host<S> & String:
  match result:
    case (args,text):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"alerts:" ++ text ++ "\n")
def alerts_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Ran_b(~S)) -> H.Host<S> & String:
  match result:
    case Route.Ran{runtime,alerts,alertsRegistry,result}:alerts_completion(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,crates,cratesRegistry,runtime,alerts,alertsRegistry,completion(result))
def call_alerts(~S:Data,fail:Bool,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:alerts_returned(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,crates,cratesRegistry,F.run_b(~S,runtime,alerts,alertsRegistry,mode(fail,args)))
def crates_completion(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),runtime:F.Runtime(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:P.Args & String) -> H.Host<S> & String:
  match result:
    case (args,text):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"crates:" ++ text ++ "\n")
def crates_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),result:F.Ran_c(~S)) -> H.Host<S> & String:
  match result:
    case Route.Ran{runtime,crates,cratesRegistry,result}:crates_completion(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,runtime,crates,cratesRegistry,completion(result))
def call_crates(~S:Data,fail:Bool,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:crates_returned(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,F.run_c(~S,runtime,crates,cratesRegistry,mode(fail,args)))
def swap_worlds(~S:Data,host:H.Host<S>) -> H.Host<S>:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:H.Host{foreign,runtime,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}
def swapped(~S:Data,result:H.Host<S> & String) -> H.Host<S> & String:
  match result:
    case (host,text):(swap_worlds(~S,host),text)
def foreign_call(~S:Data,host:H.Host<S>) -> H.Host<S> & String:swapped(~S,call_fast(~S,False{},swap_worlds(~S,host)))
def publish_result(~S:Data,result:Pub.PublisherResult(~S)) -> F.World(~S) & (Pub.PublisherRegistry(~S) & String):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Standalone.Reply{_,output,recovered}}}:(world,(registry,"published:" ++ U32.show(output) ++ ":" ++ PubView.recovery(recovered) ++ "\n"))
    case Sys.RegistrationRejected{registry,world,_}:(world,(registry,"PUBLISH_REJECTED\n"))
    case Sys.Completed{registry,Sys.Failed{world,_}}:(world,(registry,"PUBLISH_TRANSPORT_FAILED\n"))
def published(~S:Data,foreign:F.Runtime(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),args:P.Args,result:F.Runtime(~S) & (Pub.PublisherRegistry(~S) & String)) -> H.Host<S> & String:
  match result:
    case (runtime,(publisher,text)):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},text)
def publish(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:published(~S,foreign,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args,F.with_world(~S,~(Pub.PublisherRegistry(~S) & String),world => publish_result(~S,Pub.publish_once(~S,publisher,world)),runtime))
def frame_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),args:P.Args,result:F.Runtime(~S) & Catalog.Receipt()) -> H.Host<S> & String:
  match result:
    case (runtime,receipt):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"frame:" ++ View.retired(receipt) ++ "\n")
def frame(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:frame_returned(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args,F.frame(~S,runtime))
def shutdown_returned(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),args:P.Args,result:F.Runtime(~S) & Catalog.Receipt()) -> H.Host<S> & String:
  match result:
    case (runtime,receipt):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"shutdown:" ++ View.retired(receipt) ++ "\n")
def shutdown(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:shutdown_returned(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args,F.shutdown(~S,runtime))
def skipped(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),args:P.Args,result:F.Runtime(~S) & F.Reader_a(~S)) -> H.Host<S> & String:
  match result:
    case (runtime,slow):(H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args},"skipped-slow\n")
def skip(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:skipped(~S,foreign,publisher,fast,fastRegistry,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args,F.skip_a(~S,runtime,slow))
def disposal_observed(~S:Data,next:F.Runtime(~S) -> String,result:F.Runtime(~S) & String) -> String:
  match result:
    case (runtime,text):text ++ next(runtime)
def dispose_crates(~S:Data,result:F.Disposal_c(~S)) -> String:
  match result:
    case Life.Disposed{runtime}:disposal_observed(~S,unused => "disposed-all\n",View.runtime(~S,runtime))
    case _:"DISPOSAL_REJECTED\n"
def dispose_alerts(~S:Data,crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Disposal_b(~S)) -> String:
  match result:
    case Life.Disposed{runtime}:disposal_observed(~S,runtime => dispose_crates(~S,F.dispose_c(~S,runtime,crates,cratesRegistry)),View.runtime(~S,runtime))
    case _:"DISPOSAL_REJECTED\n"
def dispose_slow(~S:Data,alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Disposal_a(~S)) -> String:
  match result:
    case Life.Disposed{runtime}:disposal_observed(~S,runtime => dispose_alerts(~S,crates,cratesRegistry,F.dispose_b(~S,runtime,alerts,alertsRegistry)),View.runtime(~S,runtime))
    case _:"DISPOSAL_REJECTED\n"
def dispose_fast(~S:Data,slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),result:F.Disposal_a(~S)) -> String:
  match result:
    case Life.Disposed{runtime}:disposal_observed(~S,runtime => dispose_slow(~S,alerts,alertsRegistry,crates,cratesRegistry,F.dispose_a(~S,runtime,slow,slowRegistry)),View.runtime(~S,runtime))
    case _:"DISPOSAL_REJECTED\n"
def finish(~S:Data,host:H.Host<S>) -> String:
  match host:
    case H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,args}:dispose_fast(~S,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,F.dispose_a(~S,runtime,fast,fastRegistry))
def step_shutdown2(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"shutdown2",finish(~S),next),shutdown(~S,host))
def step_shutdown1(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"shutdown1",step_shutdown2(~S),next),shutdown(~S,host))
def step_fastlag(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"fastlag",step_shutdown1(~S),next),call_fast(~S,False{},host))
def step_slowlag(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"slowlag",step_fastlag(~S),next),call_slow(~S,False{},host))
def step_frame2(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"frame2",step_slowlag(~S),next),frame(~S,host))
def step_publish3(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"publish3",step_frame2(~S),next),publish(~S,host))
def step_frame1(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"frame1",step_publish3(~S),next),frame(~S,host))
def step_skip(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"skip",step_frame1(~S),next),skip(~S,host))
def step_publish2(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"publish2",step_skip(~S),next),publish(~S,host))
def step_foreign(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"foreign",step_publish2(~S),next),foreign_call(~S,host))
def step_cratesread(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"cratesread",step_foreign(~S),next),call_crates(~S,False{},host))
def step_alertsread(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"alertsread",step_cratesread(~S),next),call_alerts(~S,False{},host))
def step_fastretry(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"fastretry",step_alertsread(~S),next),call_fast(~S,False{},host))
def step_fastfail(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"fastfail",step_fastretry(~S),next),call_fast(~S,True{},host))
def step_publish1(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"publish1",step_fastfail(~S),next),publish(~S,host))
def registered_crates(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),result:F.Registered_c(~S)) -> String:
  match result:
    case Route.Registered{runtime,crates,cratesRegistry}:observed(~S,"registered",step_publish1(~S),H.Host{runtime,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,crates,cratesRegistry,P.args(False{},1)})
    case _:"REGISTER_FAILED\n"
def registered_alerts(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),result:F.Registered_b(~S)) -> String:
  match result:
    case Route.Registered{runtime,alerts,alertsRegistry}:registered_crates(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,alerts,alertsRegistry,F.register_c(~S,runtime,"crates"))
    case _:"REGISTER_FAILED\n"
def registered_slow(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),result:F.Registered_a(~S)) -> String:
  match result:
    case Route.Registered{runtime,slow,slowRegistry}:registered_alerts(~S,foreign,publisher,fast,fastRegistry,slow,slowRegistry,F.register_b(~S,runtime,"alerts"))
    case _:"REGISTER_FAILED\n"
def registered_fast(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),result:F.Registered_a(~S)) -> String:
  match result:
    case Route.Registered{runtime,fast,fastRegistry}:registered_slow(~S,foreign,publisher,fast,fastRegistry,F.register_a(~S,runtime,"slow"))
    case _:"REGISTER_FAILED\n"
def publisher_registered(~S:Data,foreign:F.World(~S),result:Pub.PublisherRegistration(~S)) -> String:
  match result:
    case Sys.Registered{world,publisher}:registered_fast(~S,F.setup(~S,foreign),publisher,F.register_a(~S,F.setup(~S,world),"fast"))
    case _:"PUBLISHER_REGISTER_FAILED\n"
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:publisher_registered(~S,foreign,Pub.define_publisher(~S,world))
