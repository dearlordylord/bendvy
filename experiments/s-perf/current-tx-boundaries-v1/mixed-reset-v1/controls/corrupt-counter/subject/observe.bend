import Base
import schema.bend as S
import ../private/experiments/public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../private/experiments/public-audit61/app-a-current-carrier-v1/allocator-observer.bend as Gen
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/transaction.bend as T
import ../private/src/ecs/bundle-batch.bend as Batch
import ../private/src/ecs/deferred-command.bend as Deferred
import ../private/src/ecs/trace-facts.bend as Trace
import ../private/src/ecs/entity-key.bend as K
import ../meter.bend as Meter

def world(value:S.World()) -> S.World() & String:Dump.world(~S.Schema,~Array<U32>,~Array<U32>,~U32,~Dump.u32_array,~Dump.u32_array,~U32.show,value)
def handle(value:W.Handle<S.Schema>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Gen.key_text(key)
def packet_join(undo:Array<U32> -> Array<U32>,observed:Array<U32> & String) -> S.Packet & String:
  match observed:
    case (value,text):(S.Packet{value,undo},text)
def packet(value:S.Packet) -> S.Packet & String:
  match value:
    case S.Packet{value,undo}:packet_join(undo,Dump.u32_array(value))
def prepared_join(+target:W.Handle<S.Schema>,+position:Nat,observed:S.Packet & String) -> Batch.Prepared<S.Schema,S.Packet> & String:
  match observed:
    case (value,text):(Batch.Prepared{target,value,position},"P(" ++ handle(target) ++ ";" ++ text ++ ";" ++ Nat.show(position) ++ ")")
def prepared(value:Batch.Prepared<S.Schema,S.Packet>) -> Batch.Prepared<S.Schema,S.Packet> & String:
  match value:
    case Batch.Prepared{target,payload,position}:prepared_join(target,position,packet(payload))
    case Batch.ReservationReceipt{+target}:(Batch.ReservationReceipt{target},"R(" ++ handle(target) ++ ")")
def prepared_cons(head:Batch.Prepared<S.Schema,S.Packet> & String,tail:List<Batch.Prepared<S.Schema,S.Packet>> & List<&2,String>) -> List<Batch.Prepared<S.Schema,S.Packet>> & List<&2,String>:
  match head tail:
    case (head,text),(tail,texts):(head <> tail,text <> texts)
def prepared_list(values:List<Batch.Prepared<S.Schema,S.Packet>>) -> List<Batch.Prepared<S.Schema,S.Packet>> & List<&2,String>:
  match values:
    case []:([],[])
    case head <> tail:prepared_cons(prepared(head),prepared_list(tail))
def batch_join(undo:List<(S.World()->S.World())>,commands:List<Deferred.Command<S.World()>>,events:List<&2,U32>,trace:Trace.State,meter:Meter.State,observed:S.World() & String,packets:List<Batch.Prepared<S.Schema,S.Packet>> & List<&2,String>) -> Batch.Batch<S.Schema,S.Store(),Array<U32>,U32,S.Packet> & String:
  match observed packets:
    case (world,text),(prepared,texts):(Batch.Batch{T.Tx{world,undo,commands,events,trace,meter},prepared},text ++ "|prepared=" ++ List.show(&2,String,x=>x,texts))
def batch(value:Batch.Batch<S.Schema,S.Store(),Array<U32>,U32,S.Packet>) -> Batch.Batch<S.Schema,S.Store(),Array<U32>,U32,S.Packet> & String:
  match value:
    case Batch.Batch{T.Tx{value,undo,commands,events,trace,meter},prepared}:batch_join(undo,commands,events,trace,meter,world(value),prepared_list(prepared))
def returned_cons(head:Array<U32> & String,tail:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & List<&2,String>:
  match head tail:
    case (head,text),(tail,texts):(head <> tail,text <> texts)
def returned(values:List<Array<U32>>) -> List<Array<U32>> & List<&2,String>:
  match values:
    case []:([],[])
    case head <> tail:returned_cons(Dump.u32_array(head),returned(tail))
