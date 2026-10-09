import Base
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/registered-v1/log.bend as Log
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

import system.bend as S

def returned(which:Bool,result:S.Returned,other:Ev.Reader<F.Schema>,otherReg:S.Registry(),reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>) -> F.Host:
  match result:
    case S.Returned{events,Ordinary.Reached{Ordinary.Owner{S.Registration{reader,registry},_,_},Sys.Succeeded{world,_},view <> _}}: F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Succeeded{view})
    case S.Returned{events,Ordinary.Reached{Ordinary.Owner{S.Registration{reader,registry},_,_},Sys.Failed{world,error},_}}: F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Failed{error})
    case S.Returned{events,Ordinary.RegistrationRefused{Ordinary.Owner{S.Registration{reader,registry},_,_},world,request}}: F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Rejected{request})
    case S.Returned{events,Ordinary.Reached{Ordinary.Owner{S.Registration{reader,registry},_,_},Sys.Succeeded{world,_},[]}}: F.host_read(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,False{})
def detached(which:Bool,result:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>,reader:Ev.Reader<F.Schema>,registry:S.Registry(),request:F.Request,other:Ev.Reader<F.Schema>,otherReg:S.Registry(),reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>) -> F.Host:
  match result:
    case Domains.Detached{world,events}: returned(which,S.run(events,Ordinary.Owner{S.Registration{reader,registry},"events",Query.clauses(~F.Schema,~P.Payload,~Cap.Request<P.Payload,U32,U32>,F.read_declaration())},world,request),other,otherReg,reads,retired,refused,errors)
def read(host:F.Host,which:Bool,fail:Bool) -> F.Host:
  match host which:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, True{}: detached(True{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),fast,fastReg,F.Request{"fast",fail},slow,slowReg,reads,retired,refused,errors)
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, False{}: detached(False{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),slow,slowReg,F.Request{"slow",fail},fast,fastReg,reads,retired,refused,errors)
def foreign(host:F.Host) -> F.Host:
  match host:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}: detached(True{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),F.foreign_reader(fast),fastReg,F.Request{"fast",False{}},slow,slowReg,reads,retired,refused,errors)
def skip_returned(result:Domains.Events<F.Schema,U32> & (S.Owner() & S.World()),other:Ev.Reader<F.Schema>,otherReg:S.Registry(),reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> F.Host:
  match result:
    case (events,(Ordinary.Owner{S.Registration{reader,registry},_,_},world)): F.host_read(True{},Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,ok)
def skip_detached(result:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>,reader:Ev.Reader<F.Schema>,registry:S.Registry(),other:Ev.Reader<F.Schema>,otherReg:S.Registry(),reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> F.Host:
  match result:
    case Domains.Detached{world,events}: skip_returned(S.skip(events,Ordinary.Owner{S.Registration{reader,registry},"events",Query.clauses(~F.Schema,~P.Payload,~Cap.Request<P.Payload,U32,U32>,F.read_declaration())},world),other,otherReg,reads,retired,refused,errors,ok)
def skip(host:F.Host) -> F.Host:
  match host:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}: skip_detached(Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok)
def second_defined(first:S.Owner(),result:S.Defined) -> F.Started:
  match first result:
    case Ordinary.Owner{S.Registration{fast,fastReg},_,_}, S.DefineRefused{runtime}: F.SlowRefused{runtime,fast,fastReg}
    case Ordinary.Owner{S.Registration{fast,fastReg},_,_}, S.Defined{runtime,Ordinary.Owner{S.Registration{slow,slowReg},_,_}}: F.Started{F.Host{runtime,fast,fastReg,slow,slowReg,[],[],[],[],True{}}}
def first_defined(result:S.Defined) -> F.Started:
  match result:
    case S.DefineRefused{runtime}: F.StartRefused{runtime}
    case S.Defined{runtime,owner}: second_defined(owner,S.define(runtime,"slow","slow-slot"))
def start(capacity:Nat) -> F.Started:
  first_defined(S.define(Ev.start(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,W.World{1,1,0,ALeaf{False{}},1,0n,Unit{},Log.Log{[],[]},[],[],[],1,0},capacity),"fast","fast-slot"))
