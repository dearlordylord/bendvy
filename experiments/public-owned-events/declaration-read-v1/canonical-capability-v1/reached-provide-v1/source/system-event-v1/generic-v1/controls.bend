import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/registered-v1/log.bend as Log
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/system-event-v1/generic-v1/system.bend as S

def returned(which:Bool,result:S.Returned<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>,other:Ev.Reader<F.Schema>,otherReg:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match result:
    case S.Returned{events,S.Reached{Ordinary.Owner{S.Registration{reader,registry},slot,clauses},Sys.Succeeded{world,_},view <> _}}: (F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Succeeded{view}),(slot,clauses))
    case S.Returned{events,S.Reached{Ordinary.Owner{S.Registration{reader,registry},slot,clauses},Sys.Failed{world,error},_}}: (F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Failed{error}),(slot,clauses))
    case S.Returned{events,S.RegistrationRefused{Ordinary.Owner{S.Registration{reader,registry},slot,clauses},world,request}}: (F.read_finished(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,Ev.Rejected{request}),(slot,clauses))
    case S.Returned{events,S.Reached{Ordinary.Owner{S.Registration{reader,registry},slot,clauses},Sys.Succeeded{world,_},[]}}: (F.host_read(which,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,False{}),(slot,clauses))
def detached(which:Bool,result:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>,reader:Ev.Reader<F.Schema>,registry:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,slot:String,clauses:List<&2,Query.Clause<F.Schema>>,request:F.Request,other:Ev.Reader<F.Schema>,otherReg:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match result:
    case Domains.Detached{world,events}: returned(which,S.run(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,events,Ordinary.Owner{S.Registration{reader,registry},slot,clauses},world,request),other,otherReg,reads,retired,refused,errors)
def read_host(host:F.Host,which:Bool,fail:Bool,slot:String,clauses:List<&2,Query.Clause<F.Schema>>) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match host which:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, True{}: detached(True{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),fast,fastReg,slot,clauses,F.Request{"fast",fail},slow,slowReg,reads,retired,refused,errors)
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, False{}: detached(False{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),slow,slowReg,slot,clauses,F.Request{"slow",fail},fast,fastReg,reads,retired,refused,errors)
def foreign_host(host:F.Host,slot:String,clauses:List<&2,Query.Clause<F.Schema>>) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match host:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}: detached(True{},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),F.foreign_reader(fast),fastReg,slot,clauses,F.Request{"fast",False{}},slow,slowReg,reads,retired,refused,errors)
def skip_returned(result:Domains.Events<F.Schema,U32> & (Ordinary.Owner<F.Schema,S.Registration<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>> & W.World<F.Schema,Unit,Log.Log<P.Payload>,U32>),other:Ev.Reader<F.Schema>,otherReg:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match result:
    case (events,(Ordinary.Owner{S.Registration{reader,registry},slot,clauses},world)): (F.host_read(True{},Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,other,otherReg,reads,retired,refused,errors,ok),(slot,clauses))
def skip_detached(result:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>,reader:Ev.Reader<F.Schema>,registry:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,slot:String,clauses:List<&2,Query.Clause<F.Schema>>,other:Ev.Reader<F.Schema>,otherReg:Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>,reads:List<&2,F.ReadCompletion>,retired:List<Log.Row<P.Payload>>,refused:List<Log.Row<P.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match result:
    case Domains.Detached{world,events}: skip_returned(S.skip(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,events,Ordinary.Owner{S.Registration{reader,registry},slot,clauses},world),other,otherReg,reads,retired,refused,errors,ok)
def skip_host(host:F.Host,slot:String,clauses:List<&2,Query.Clause<F.Schema>>) -> F.Host & (String & List<&2,Query.Clause<F.Schema>>):
  match host:
    case F.Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}: skip_detached(Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]),fast,fastReg,slot,clauses,slow,slowReg,reads,retired,refused,errors,ok)

type Host is Type: Host{host:F.Host,fastSlot:String,fastClauses:List<&2,Query.Clause<F.Schema>>,slowSlot:String,slowClauses:List<&2,Query.Clause<F.Schema>>}
type Started is Type:
  Started{host:Host}
  StartRefused{runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>}
  SlowRefused{runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>,owner:Ordinary.Owner<F.Schema,S.Registration<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>>}
def second_defined(first:Ordinary.Owner<F.Schema,S.Registration<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>>,result:S.Defined<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>) -> Started:
  match first result:
    case first, S.DefineRefused{runtime}: SlowRefused{runtime,first}
    case Ordinary.Owner{S.Registration{fast,fastReg},fastSlot,fastClauses}, S.Defined{runtime,Ordinary.Owner{S.Registration{slow,slowReg},slowSlot,slowClauses}}: Started{Host{F.Host{runtime,fast,fastReg,slow,slowReg,[],[],[],[],True{}},fastSlot,fastClauses,slowSlot,slowClauses}}
def first_defined(result:S.Defined<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>) -> Started:
  match result:
    case S.DefineRefused{runtime}: StartRefused{runtime}
    case S.Defined{runtime,owner}: second_defined(owner,S.define(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,runtime,"slow","slow-slot",Query.clauses(~F.Schema,~P.Payload,~Cap.Request<P.Payload,U32,U32>,F.read_declaration())))
def start(capacity:Nat) -> Started:
  first_defined(S.define(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,Ev.start(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,W.World{1,1,0,ALeaf{False{}},1,0n,Unit{},Log.Log{[],[]},[],[],[],1,0},capacity),"fast","fast-slot",Query.clauses(~F.Schema,~P.Payload,~Cap.Request<P.Payload,U32,U32>,F.read_declaration())))
def update(which:Bool,result:F.Host & (String & List<&2,Query.Clause<F.Schema>>),otherSlot:String,otherClauses:List<&2,Query.Clause<F.Schema>>) -> Host:
  match which result:
    case True{}, (host,(slot,clauses)): Host{host,slot,clauses,otherSlot,otherClauses}
    case False{}, (host,(slot,clauses)): Host{host,otherSlot,otherClauses,slot,clauses}
def read(owner:Host,which:Bool,fail:Bool) -> Host:
  match owner which:
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}, True{}: update(True{},read_host(host,True{},fail,fastSlot,fastClauses),slowSlot,slowClauses)
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}, False{}: update(False{},read_host(host,False{},fail,slowSlot,slowClauses),fastSlot,fastClauses)
def foreign(owner:Host) -> Host:
  match owner:
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}: update(True{},foreign_host(host,fastSlot,fastClauses),slowSlot,slowClauses)
def skip(owner:Host) -> Host:
  match owner:
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}: update(True{},skip_host(host,fastSlot,fastClauses),slowSlot,slowClauses)
def publish(owner:Host,rows:List<Log.Row<P.Payload>>) -> Host:
  match owner:
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}: Host{F.publish(host,rows),fastSlot,fastClauses,slowSlot,slowClauses}
def frame(owner:Host) -> Host:
  match owner:
    case Host{host,fastSlot,fastClauses,slowSlot,slowClauses}: Host{F.frame(host),fastSlot,fastClauses,slowSlot,slowClauses}
