import Base
import ./fixture.bend as F
import ./observe.bend as View
import ../../../src/ecs/ordinary-owned-event-query.bend as O
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-storage.bend as Storage
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T

type Host<S:Data> is Type:Host{world:F.World(~S),registry:F.Registry(~S),foreign:F.World(~S)}
def outcome(value:T.Outcome<Q.Error<F.Error>>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{Q.UserError{F.FailedAt{value}}}:"failed-at=" ++ U32.show(value)
    case T.Failure{Q.UserError{F.Missing{}}}:"missing"
    case T.Failure{Q.AccessError{_}}:"access-failed"
def args(value:F.Args & U32) -> String:
  match value:
    case (F.Args{delta,failed},cursor):String.concat([U32.show(delta),":",U32.show(failed),":",U32.show(cursor)])
def returned(~S:Data,result:Sys.RunResult<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat,F.Args & U32,Unit,Pub.Reply<Q.Error<F.Error>,List<&2,U32>,Array<U32>>,O.runner(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~F.domain(~S),~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body(~S))>) -> (F.World(~S) & F.Registry(~S)) & String:
  match result:
    case Sys.RegistrationRejected{registry,world,input}:((world,registry),"refused:" ++ args(input) ++ "\n")
    case Sys.Completed{registry,Sys.Succeeded{world,Pub.Reply{status,output,recovered}}}:((world,registry),outcome(status) ++ ":values=" ++ View.values(output) ++ ":recovered=" ++ View.payloads(recovered) ++ "\n")
    case Sys.Completed{registry,Sys.Failed{world,_}}:((world,registry),"unexpected-transport-failure\n")
def called(~S:Data,foreign:F.World(~S),result:(F.World(~S) & F.Registry(~S)) & String) -> Host<S> & String:
  match result:
    case ((world,registry),text):(Host{world,registry,foreign},text)
def call(~S:Data,host:Host<S>,input:F.Args) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign}:called(~S,foreign,returned(~S,F.run(~S,registry,world,input)))
def foreign_called(~S:Data,world:F.World(~S),result:(F.World(~S) & F.Registry(~S)) & String) -> Host<S> & String:
  match result:
    case ((foreign,registry),text):(Host{world,registry,foreign},text)
def call_foreign(~S:Data,host:Host<S>) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign}:foreign_called(~S,world,returned(~S,F.run(~S,registry,foreign,F.Args{99,0})))
def snapshot_join(~S:Data,primary:F.World(~S) & String,registry:F.Registry(~S) & String,foreign:F.World(~S) & String) -> Host<S> & String:
  match primary registry foreign:
    case (world,first), (registry,reg), (foreign,second):(Host{world,registry,foreign},"world:" ++ first ++ "registry:" ++ reg ++ "foreign:" ++ second)
def snapshot(~S:Data,host:Host<S>) -> Host<S> & String:
  match host:
    case Host{world,registry,foreign}:snapshot_join(~S,View.world(~S,world),View.registry(~S,registry),View.world(~S,foreign))
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
def registered(~S:Data,foreign:F.World(~S),result:Sys.RegistrationResult<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat,F.Args & U32,Unit,Pub.Reply<Q.Error<F.Error>,List<&2,U32>,Array<U32>>,O.runner(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~F.domain(~S),~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body(~S))>) -> String:
  match result:
    case Sys.Registered{world,registry}:checked(~S,committed(~S),snapshot(~S,Host{world,registry,foreign}))
    case _:"REGISTRATION_FAILED\n"
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:
  registered(~S,foreign,F.define(~S,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)))
