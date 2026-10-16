import Base
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as A
import ../../ordinary-array-v1/observe.bend as R
import ../../../public-resource-fields/owner-observer.bend as O

def element(value:Array<U32>) -> Array<U32> & String:O.u32_array(value)
def array(value:Array<Array<U32>>) -> Array<Array<U32>> & String:O.array(~Array<U32>,~element,value)
def siblings_done(a:Array<Array<U32>> & String,b:Array<U32> & String) -> F.Siblings() & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"samePayloadSibling=" ++ x ++ ":otherAffine=" ++ y)
def siblings(value:F.Siblings()) -> F.Siblings() & String:
  match value:
    case Product.Owner{a,b}:siblings_done(array(a),element(b))
def resources_done(a:Array<Array<U32>> & String,b:F.Siblings() & String) -> F.Resources() & String:
  match a b:
    case (a,x),(b,y):(Product.Owner{a,b},"target=" ++ x ++ ":siblings={" ++ y ++ "}")
def resources(value:F.Resources()) -> F.Resources() & String:
  match value:
    case Product.Owner{a,b}:resources_done(array(a),siblings(b))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~R.text,access)
def unit(value:Unit) -> String:"Unit"
# Pending callbacks are preserved and counted without execution.
def world_done(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,store:Unit,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,observedLive:Array<Bool> & String,observedResources:F.Resources() & String,observedPending:List<(F.World(~S) -> F.World(~S))> & Nat) -> F.World(~S) & String:
  (live,lt)=observedLive
  (resource,rt)=observedResources
  (pending,count)=observedPending
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"ns=" ++ U32.show(ns) ++ ":next=" ++ U32.show(next) ++ ":high=" ++ U32.show(high) ++ ":capacity=" ++ U32.show(capacity) ++ ":depth=" ++ Nat.show(depth) ++ ":live=" ++ lt ++ ":store=Unit:resource={" ++ rt ++ "}:events=" ++ List.show(~&2,~Unit,~unit,events) ++ ":pending=" ++ Nat.show(count) ++ ":regs=" ++ List.show(~&2,~W.RegistrationMeta,~registration,regs) ++ ":sid=" ++ U32.show(sid) ++ ":clock=" ++ U32.show(clock))
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:world_done(~S,ns,next,high,capacity,depth,store,events,regs,sid,clock,O.bool_array(live),resources(resource),O.callbacks(~F.World(~S),~F.World(~S),pending))
def owned_done(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,observed:Array<U32> & String) -> F.Owned(~S) & String:
  (capture,text)=observed
  (System.Owner{Sys.Registry{ns,id,name,access,cursor},capture},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~R.text,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":capture=" ++ text)
def owned(~S:Data,value:F.Owned(~S)) -> F.Owned(~S) & String:
  match value:
    case System.Owner{Sys.Registry{ns,id,name,access,cursor},capture}:owned_done(~S,ns,id,name,access,cursor,element(capture))
def args_done(a:Array<Array<U32>> & String,b:Array<U32> & String,c:Array<Array<U32>> & String,d:Array<U32> & String,+fail:Bool) -> F.Args & String:
  match a b c d:
    case (a,x),(b,y),(c,z),(d,w):(F.Args{a,b,c,d,fail},"first=" ++ x ++ ":element=" ++ y ++ ":second=" ++ z ++ ":rejected=" ++ w ++ ":fail=" ++ Bool.show(fail))
def args(value:F.Args) -> F.Args & String:
  match value:
    case F.Args{a,b,c,d,fail}:args_done(array(a),element(b),array(c),element(d),fail)
def output_done(a:List<Array<Array<U32>>> & String,b:List<Array<U32>> & String) -> F.Output & String:
  match a b:
    case (a,x),(b,y):(F.Output{a,b},"arrays=" ++ x ++ ":elements=" ++ y)
def output(value:F.Output) -> F.Output & String:
  match value:
    case F.Output{a,b}:output_done(R.items(~Array<Array<U32>>,~array,a),R.items(~Array<U32>,~element,b))
def replaced(value:Array<Array<U32>> & String) -> A.Record<Array<U32>> & String:
  (value,text)=value
  (A.Replaced{value},"replaced:" ++ text)
def swapped(+index:U32,value:Array<U32> & String) -> A.Record<Array<U32>> & String:
  (value,text)=value
  (A.Swapped{index,value},"swapped:" ++ U32.show(index) ++ ":" ++ text)
def record(value:A.Record<Array<U32>>) -> A.Record<Array<U32>> & String:
  match value:
    case A.Replaced{value}:replaced(array(value))
    case A.Swapped{index,value}:swapped(index,element(value))
def records(value:F.Recovery()) -> F.Recovery() & String:R.items(~A.Record<Array<U32>>,~record,value)
