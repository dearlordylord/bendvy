import Base
import ../../../src/ecs/ordinary-owned-event-family-publisher.bend as Standalone
import ./fixture.bend as F
import ./observe.bend as View
import ../../../src/ecs/ordinary-owned-event-family-query.bend as O
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-storage.bend as Storage
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T

type Host<S:Data> is Type:Host{world:F.World(~S),registry:F.Registry(~S),foreign:F.World(~S),publisher:F.PublisherRegistry(~S)}
def outcome(value:T.Outcome<Q.Error<F.Error>>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{Q.UserError{F.FailedAt{value}}}:"failed-at=" ++ U32.show(value)
    case T.Failure{Q.UserError{F.Missing{}}}:"missing"
    case T.Failure{Q.AccessError{_}}:"access-failed"
def args(value:F.Args & U32) -> String:
  match value:
    case (F.Args{delta,failed},cursor):String.concat([U32.show(delta),":",U32.show(failed),":",U32.show(cursor)])
def returned(~S:Data,result:F.QueryResult(~S)) -> (F.World(~S) & F.Registry(~S)) & String:
  match result:
    case Sys.RegistrationRejected{registry,world,input}:((world,registry),"refused:" ++ args(input) ++ "\n")
    case Sys.Completed{registry,Sys.Succeeded{world,O.Reply{status,output,recovered}}}:((world,registry),outcome(status) ++ ":values=" ++ View.values(output) ++ ":recovered=" ++ View.recovery(recovered) ++ "\n")
    case Sys.Completed{registry,Sys.Failed{world,_}}:((world,registry),"unexpected-transport-failure\n")
def called(~S:Data,foreign:F.World(~S),publisher:F.PublisherRegistry(~S),result:(F.World(~S) & F.Registry(~S)) & String) -> Host<S> & String:
  match result:
    case ((world,registry),text):(Host{world,registry,foreign,publisher},text)
def call(~S:Data,host:Host<S>,input:F.Args) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign,publisher}:called(~S,foreign,publisher,returned(~S,F.run(~S,registry,world,input)))
def foreign_called(~S:Data,world:F.World(~S),publisher:F.PublisherRegistry(~S),result:(F.World(~S) & F.Registry(~S)) & String) -> Host<S> & String:
  match result:
    case ((foreign,registry),text):(Host{world,registry,foreign,publisher},text)
def call_foreign(~S:Data,host:Host<S>) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign,publisher}:foreign_called(~S,world,publisher,returned(~S,F.run(~S,registry,foreign,F.Args{99,0})))
def snapshot_join(~S:Data,primary:F.World(~S) & String,registry:F.Registry(~S) & String,foreign:F.World(~S) & String,publisher:F.PublisherRegistry(~S) & String) -> Host<S> & String:
  match primary registry foreign publisher:
    case (world,first), (registry,reg), (foreign,second), (publisher,pub):(Host{world,registry,foreign,publisher},"world:" ++ first ++ "registry:" ++ reg ++ "foreign:" ++ second ++ "publisher:" ++ pub)
def snapshot(~S:Data,host:Host<S>) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign,publisher}:snapshot_join(~S,View.world(~S,world),View.registry(~S,registry),View.world(~S,foreign),View.publisher_registry(~S,publisher))
def checked(~S:Data,next:Host<S> -> String,result:Host<S> & String) -> String:
  match result:
    case (host,text):text ++ next(host)
def observed(~S:Data,next:Host<S> -> String,result:Host<S> & String) -> String:
  match result:
    case (host,status):status ++ checked(~S,next,snapshot(~S,host))
def foreign_final(~S:Data,host:Host<S>) -> String:observed(~S,unused => "",call_foreign(~S,host))
def retry(~S:Data,host:Host<S>) -> String:observed(~S,foreign_final(~S),call(~S,host,F.Args{2,0}))
def failed(~S:Data,host:Host<S>) -> String:observed(~S,retry(~S),call(~S,host,F.Args{10,21}))
def committed(~S:Data,host:Host<S>) -> String:observed(~S,failed(~S),call(~S,host,F.Args{1,0}))
def registered(~S:Data,foreign:F.World(~S),publisher:F.PublisherRegistry(~S),result:F.Registration(~S)) -> String:
  match result:
    case Sys.Registered{world,registry}:checked(~S,committed(~S),snapshot(~S,Host{world,registry,foreign,publisher}))
    case _:"REGISTRATION_FAILED\n"
def populated(~S:Data,world:F.World(~S),foreign:F.World(~S),publisher:F.PublisherRegistry(~S)) -> String:
  registered(~S,foreign,publisher,F.define(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)))
def published_snapshot(~S:Data,foreign:F.World(~S),observed:F.World(~S) & String,registered:F.PublisherRegistry(~S) & String) -> String:
  match observed registered:
    case (world,text), (publisher,reg):"empty-world-after:" ++ text ++ "publisher:" ++ reg ++ populated(~S,world,foreign,publisher)
def published(~S:Data,foreign:F.World(~S),result:F.PublisherResult(~S)) -> String:
  match result:
    case Sys.Completed{publisher,Sys.Succeeded{world,Standalone.Reply{T.Success{},output,recovered}}}:"empty-published:" ++ U32.show(output) ++ ":recovered=" ++ View.recovery(recovered) ++ "\n" ++ published_snapshot(~S,foreign,View.world(~S,world),View.publisher_registry(~S,publisher))
    case _:"PUBLISH_FAILED\n"
def publisher_snapshot(~S:Data,foreign:F.World(~S),observed:F.World(~S) & String,registered:F.PublisherRegistry(~S) & String) -> String:
  match observed registered:
    case (world,text), (publisher,reg):"empty-world-before:" ++ text ++ "publisher:" ++ reg ++ published(~S,foreign,F.publish_once(~S,publisher,world))
def publisher_registered(~S:Data,foreign:F.World(~S),result:F.PublisherRegistration(~S)) -> String:
  match result:
    case Sys.Registered{world,publisher}:publisher_snapshot(~S,foreign,View.world(~S,world),View.publisher_registry(~S,publisher))
    case _:"PUBLISHER_REGISTRATION_FAILED\n"
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:
  publisher_registered(~S,foreign,F.define_publisher(~S,world))
