import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
import Base
import health.bend as F
import health-events.bend as E
import health-observe.bend as O
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/transaction.bend as Tx
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/trace-facts.bend as Trace
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/deferred-command.bend as Deferred

type Facts is Data:
  Facts{undo:Nat,commands:Nat,kinds:String,events:List<&2,E.event_type()>,trace:Trace.State,world:String}
def count_join(~A:Type,head:A,observed:List<A> & Nat) -> List<A> & Nat:
  match observed:
    case (tail,count):(head <> tail,1n+count)
def count(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:count_join(~A,head,count(~A,rest))
def joined(+events:List<&2,E.event_type()>,+trace:Trace.State,meter:Meter.State,undo:List<(F.World()->F.World())> & Nat,commands:List<Deferred.Command<F.World()>> & (Nat & String),world:F.World() & String) -> Tx.Tx<F.World(),E.event_type()> & Facts:
  (undo,nu)=undo
  (commands,(nc,kinds))=commands
  (world,text)=world
  (Tx.Tx{world,undo,commands,events,trace,meter},Facts{nu,nc,kinds,events,trace,text})
def observe(owner:Tx.Tx<F.World(),E.event_type()>) -> Tx.Tx<F.World(),E.event_type()> & Facts:
  match owner:
    case Tx.Tx{world,undo,commands,events,trace,meter}:joined(events,trace,meter,count(~(F.World()->F.World()),undo),Dump.callbacks(~F.World(),~F.World(),commands),O.world(world))
