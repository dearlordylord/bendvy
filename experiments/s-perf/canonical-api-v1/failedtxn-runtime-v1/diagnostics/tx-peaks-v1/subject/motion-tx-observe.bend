import Base
import report-doc.bend as Doc
import motion.bend as F
import events.bend as E
import motion-observe.bend as O
import motion-doc-world.bend as DW
import physical-owner-observer.bend as Dump
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/trace-facts.bend as Trace
import ../../../../../../../src/ecs/deferred-command.bend as Deferred

type Facts is Data:
  Facts{undo:Nat,commands:Nat,kinds:String,events:List<&2,E.event_type()>,trace:Trace.State,world:Doc.Doc}
def count_join(~A:Type,head:A,observed:List<A> & Nat) -> List<A> & Nat:
  match observed:
    case (tail,count):(head <> tail,1n+count)
def count(~A:Type,values:List<A>) -> List<A> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:count_join(~A,head,count(~A,rest))
def joined(+events:List<&2,E.event_type()>,+trace:Trace.State,undo:List<(F.World()->F.World())> & Nat,commands:List<Deferred.Command<F.World()>> & (Nat & String),world:F.World() & Doc.Doc) -> Tx.Tx<F.World(),E.event_type()> & Facts:
  (undo,nu)=undo
  (commands,(nc,kinds))=commands
  (world,text)=world
  (Tx.Tx{world,undo,commands,events,trace},Facts{nu,nc,kinds,events,trace,text})
def observe(owner:Tx.Tx<F.World(),E.event_type()>) -> Tx.Tx<F.World(),E.event_type()> & Facts:
  match owner:
    case Tx.Tx{world,undo,commands,events,trace}:joined(events,trace,count(~(F.World()->F.World()),undo),Dump.callbacks(~F.World(),~F.World(),commands),DW.world(world))
