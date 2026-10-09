import Base
import ../../mutant-caller.bend as Caller
import owner-observer.bend as Dump
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/component.bend as C
import ../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../src/ecs/ordinary-query-declaration.bend as Normal

def payload_done(observed:Array<U32> & String) -> Caller.Payload & String:
  (values,text)=observed
  (Caller.Payload{values},"Payload{" ++ text ++ "}")
def payload(value:Caller.Payload) -> Caller.Payload & String:
  match value:
    case Caller.Payload{values}:payload_done(Dump.u32_array(values))
def access(value:C.Access<U32>) -> String:
  match value:
    case C.Found{value}:"Found:" ++ U32.show(value)
    case C.ComponentAbsent{}:"ComponentAbsent"
    case C.MissingEntity{}:"MissingEntity"
def row(~S:Data,value:Projection.Row<S,U32>) -> String:
  match value:
    case Projection.Row{W.Handle{namespace,id},I.Value{value,added,changed}}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ access(value) ++ ":" ++ Bool.show(added) ++ ":" ++ Bool.show(changed)
def mode(value:Normal.Mode) -> String:
  match value:
    case Normal.Read{}:"Read"
    case Normal.Write{}:"Write"
    case Normal.Optional{}:"Optional"
    case Normal.With{}:"With"
    case Normal.Without{}:"Without"
    case Normal.Added{}:"Added"
    case Normal.Changed{}:"Changed"
def clause(~S:Data,value:Normal.Clause<S>) -> String:
  match value:
    case Normal.Clause{name,value}:name ++ ":" ++ mode(value)
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def delivered(~S:Data,+next:U32,+cursor:U32,+rows:List<&2,Projection.Row<S,U32>>,+clauses:List<&2,Normal.Clause<S>>,+found:C.Access<U32>,+events:List<&2,U32>,observedWorld:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String,observedPrevious:Maybe<&1,Caller.Payload> & String,observedUndo:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)> & Nat,observedCommands:List<(W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>)> & Nat) -> Caller.Delivery<S> & String:
  (world,sw)=observedWorld
  (previous,sp)=observedPrevious
  (undo,+nu)=observedUndo
  (commands,+nc)=observedCommands
  (Caller.Delivered{W.Factory{next},I.Frame{world,cursor},rows,clauses,found,previous,undo,commands,events},"Delivered{factory=" ++ U32.show(next) ++ "|cursor=" ++ U32.show(cursor) ++ "|world={" ++ sw ++ "}|rows=" ++ List.show(&2,Projection.Row<S,U32>,row(~S),rows) ++ "|clauses=" ++ List.show(&2,Normal.Clause<S>,clause(~S),clauses) ++ "|access=" ++ access(found) ++ "|previous=" ++ sp ++ "|undoCount=" ++ Nat.show(nu) ++ "|undoEmpty=" ++ Bool.show(Nat.is_eq(nu,0n)) ++ "|commandsCount=" ++ Nat.show(nc) ++ "|commandsEmpty=" ++ Bool.show(Nat.is_eq(nc,0n)) ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "}")
def refused_setup(~S:Data,+next:U32,+cause:W.WorldError,observedWorld:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String,observedIncoming:Maybe<&1,Caller.Payload> & String) -> Caller.Delivery<S> & String:
  (world,sw)=observedWorld
  (incoming,si)=observedIncoming
  (Caller.SetupRefused{W.Factory{next},world,incoming,cause},"SetupRefused{factory=" ++ U32.show(next) ++ "|world={" ++ sw ++ "}|incoming=" ++ si ++ "|error=" ++ error(cause) ++ "}")
def refused(~S:Data,+next:U32,observed:Array<U32> & String) -> Caller.Delivery<S> & String:
  (resource,text)=observed
  (Caller.Refused{W.Factory{next},resource},"Refused{factory=" ++ U32.show(next) ++ "|resource=" ++ text ++ "}")
def observe(~S:Data,value:Caller.Delivery<S>) -> Caller.Delivery<S> & String:
  match value:
    case Caller.Delivered{W.Factory{next},I.Frame{world,cursor},rows,clauses,found,previous,undo,commands,events}:delivered(~S,next,cursor,rows,clauses,found,events,Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~payload,~Dump.u32_array,~U32.show,world),Dump.optional(~Caller.Payload,~payload,previous),Dump.callbacks(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,undo),Dump.callbacks(~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,~W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,commands))
    case Caller.SetupRefused{W.Factory{next},world,incoming,cause}:refused_setup(~S,next,cause,Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~payload,~Dump.u32_array,~U32.show,world),Dump.optional(~Caller.Payload,~payload,incoming))
    case Caller.Refused{W.Factory{next},resource}:refused(~S,next,Dump.u32_array(resource))
def repeated_done(~S:Data,before:String,observed:Caller.Delivery<S> & String) -> Caller.Delivery<S> & String:
  (owner,after)=observed
  (owner,"before|" ++ before ++ "\nafter|" ++ after)
def repeated_first(~S:Data,observed:Caller.Delivery<S> & String) -> Caller.Delivery<S> & String:
  (owner,before)=observed
  repeated_done(~S,before,observe(~S,owner))
def repeated(~S:Data,owner:Caller.Delivery<S>) -> Caller.Delivery<S> & String:
  repeated_first(~S,observe(~S,owner))
def joined(first:Caller.Delivery<Caller.A> & String,second:Caller.Delivery<Caller.Other> & String) -> (Caller.Delivery<Caller.A> & Caller.Delivery<Caller.Other>) & String:
  (a,sa)=first
  (b,sb)=second
  ((a,b),"first." ++ sa ++ "\nsecond." ++ sb)
def run() -> (Caller.Delivery<Caller.A> & Caller.Delivery<Caller.Other>) & String:
  joined(repeated(~Caller.A,Caller.run(~Caller.A)),repeated(~Caller.Other,Caller.run(~Caller.Other)))
