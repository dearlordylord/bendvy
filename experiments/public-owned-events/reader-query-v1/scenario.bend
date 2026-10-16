import Base
import ./fixture.bend as F
import ./host.bend as H
import ./observe.bend as View
import ../family-readers-v1/fixture.bend as Readers
import ../families-v1/fixture.bend as Pub
import ../families-v1/observe.bend as PubView
import ../../../src/ecs/owned-event-family-reader-query.bend as Core
import ../../../src/ecs/ordinary-owned-event-family-publisher.bend as Standalone
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/compose.bend as Q

def outcome(value:T.Outcome<Core.Error<F.Error>>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{Core.QueryError{Q.UserError{F.FailedAt{value}}}}:"query-failed-at=" ++ U32.show(value)
    case T.Failure{_}:"other-failure"
def mode(fail:U32,args:F.Args) -> F.Args:
  match args:
    case F.Args{delta,_,scratch}:F.Args{delta,fail,scratch}
def completed(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),previous:List<F.Observation>,result:F.Ran(~S)) -> H.Host<S> & String:
  match result:
    case Route.Ran{runtime,reader,registry,Ev.Succeeded{Core.Reply{status,args,observations,values,lagged}}}:(H.Host{runtime,foreign,publisher,reader,registry,args,List.append(&1,F.Observation,previous,observations)},outcome(status) ++ ":lag=" ++ Bool.show(lagged) ++ ":values=" ++ PubView.values(values) ++ "\n")
    case Route.Ran{runtime,reader,registry,Ev.Rejected{(args,cursor)}}:(H.Host{runtime,foreign,publisher,reader,registry,args,previous},"rejected:" ++ U32.show(cursor) ++ "\n")
    case Route.Ran{runtime,reader,registry,Ev.Failed{_}}:(H.Host{runtime,foreign,publisher,reader,registry,F.args(999,999),previous},"UNEXPECTED_TRANSPORT_FAILURE\n")
def call(~S:Data,fail:U32,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,reader,registry,args,observations}:completed(~S,foreign,publisher,observations,F.run(~S,runtime,reader,registry,mode(fail,args)))
def swapped(~S:Data,result:H.Host<S> & String) -> H.Host<S> & String:
  match result:
    case (H.Host{foreign,runtime,publisher,reader,registry,args,observations},text):(H.Host{runtime,foreign,publisher,reader,registry,args,observations},text)
def call_foreign(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,reader,registry,args,observations}:swapped(~S,completed(~S,runtime,publisher,observations,F.run(~S,foreign,reader,registry,args)))
def publish_result(~S:Data,result:Pub.PublisherResult(~S)) -> F.World(~S) & (Pub.PublisherRegistry(~S) & String):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Standalone.Reply{_,output,recovered}}}:(world,(registry,"published:" ++ U32.show(output) ++ ":" ++ PubView.recovery(recovered) ++ "\n"))
    case Sys.RegistrationRejected{registry,world,_}:(world,(registry,"PUBLISH_REJECTED\n"))
    case Sys.Completed{registry,Sys.Failed{world,_}}:(world,(registry,"PUBLISH_TRANSPORT_FAILED\n"))
def published(~S:Data,foreign:F.Runtime(~S),reader:F.Reader(~S),registry:F.Registry(~S),args:F.Args,observations:List<F.Observation>,result:F.Runtime(~S) & (Pub.PublisherRegistry(~S) & String)) -> H.Host<S> & String:
  match result:
    case (runtime,(publisher,text)):(H.Host{runtime,foreign,publisher,reader,registry,args,observations},text)
def publish(~S:Data,host:H.Host<S>) -> H.Host<S> & String:
  match host:
    case H.Host{runtime,foreign,publisher,reader,registry,args,observations}:published(~S,foreign,reader,registry,args,observations,Readers.with_world(~S,~(Pub.PublisherRegistry(~S) & String),world => publish_result(~S,Pub.publish_once(~S,publisher,world)),runtime))
def continued(~S:Data,next:H.Host<S> -> String,result:H.Host<S> & String) -> String:
  match result:
    case (host,text):text ++ next(host)
def observed(~S:Data,label:String,next:H.Host<S> -> String,host:H.Host<S>) -> String:continued(~S,next,View.snapshot(~S,label,host))
def finished(~S:Data,host:H.Host<S>) -> String:
  match host:
    case H.Host{_,_,_,_,_,_,observations}:"returned-observations:" ++ View.observations(observations) ++ "\n"
def step_foreign(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"foreign",finished(~S),next),call_foreign(~S,host))
def step_nochange(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"nochange",step_foreign(~S),next),call(~S,0,host))
def step_retry(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"retry",step_nochange(~S),next),call(~S,0,host))
def step_latefailed(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"latefailed",step_retry(~S),next),call(~S,23,host))
def step_publish2(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"publish2",step_latefailed(~S),next),publish(~S,host))
def step_committed(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"committed",step_publish2(~S),next),call(~S,0,host))
def step_publish1(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"publish1",step_committed(~S),next),publish(~S,host))
def step_empty(~S:Data,host:H.Host<S>) -> String:continued(~S,next => observed(~S,"empty",step_publish1(~S),next),call(~S,0,host))
def registered(~S:Data,foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),result:F.Registration(~S)) -> String:
  match result:
    case Route.Registered{runtime,reader,registry}:observed(~S,"registered",step_empty(~S),H.Host{runtime,foreign,publisher,reader,registry,F.args(1,0),[]})
    case _:"REGISTER_FAILED\n"
def publisher_registered(~S:Data,foreign:F.World(~S),result:Pub.PublisherRegistration(~S)) -> String:
  match result:
    case Sys.Registered{world,publisher}:registered(~S,Readers.setup(~S,foreign),publisher,F.register(~S,Readers.setup(~S,world)))
    case _:"PUBLISHER_REGISTER_FAILED\n"
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:
  publisher_registered(~S,foreign,Pub.define_publisher(~S,Pub.populate(~S,Pub.populate(~S,Pub.spawn(~S,Pub.spawn(~S,Pub.spawn(~S,world))),1,10),2,20)))
