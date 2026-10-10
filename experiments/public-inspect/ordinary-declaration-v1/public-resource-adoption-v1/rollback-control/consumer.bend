import Base
import ./ordinary-resource-system.bend as P
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/capabilities.bend as Cap
import ../owner-observer.bend as Dump
type A is Data:
  A{}
type Counter is Type:
  Counter{values:Array<U32>}
type Output is Type:
  Output{values:Array<U32>}
type Error is Data:
  RolledBack{prior:U32}
def viewed(result:Array<U32> & U32) -> Counter & U32:
  match result:
    case (values,value):(Counter{values},value)
def view(value:Counter) -> Counter & U32:
  match value:
    case Counter{values}:viewed(Array.get(U32,values,0))
def ops(H:Type) -> Type:
  Cap.ValueWrite<H,Counter,U32>
def body_done(~H:Type,fail:Bool,+prior:U32,owner:H) -> H & (T.Outcome<Error> & Output):
  match fail:
    case False{}:(owner,(T.Success{},Output{Array.new(U32,0n,prior)}))
    case True{}:(owner,(T.Failure{RolledBack{prior}},Output{Array.new(U32,0n,prior)}))
def body_observed(~H:Type,~caps:ops(H),fail:Bool,result:H & U32) -> H & (T.Outcome<Error> & Output):
  match result:
    case (owner,+prior):body_done(~H,fail,prior,Cap.value_set(~H,~Counter,~U32,~caps,owner,Counter{Array.new(U32,0n,(prior+1:U32))}))
def body(~H:Type,~caps:ops(H),fail:Bool,owner:H) -> H & (T.Outcome<Error> & Output):
  body_observed(~H,~caps,fail,Cap.value_get(~H,~Counter,~U32,~caps,owner))
def declaration(~S:Data) -> P.Declaration<S,Counter,T.Tx<W.World<S,Col.Column<S,Unit>,Counter,U32>,U32>,ops(T.Tx<W.World<S,Col.Column<S,Unit>,Counter,U32>,U32>)>:
  P.write(~S,~Col.Column<S,Unit>,~Counter,~U32,~U32,~view,Schema.resource(~S,~Counter,"Counter"))
def RegistryType(~S:Data,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>) -> Type:
  Sys.Registry<S,Col.Column<S,Unit>,Counter,U32,Bool,Error,Output,runFn>
def OwnerType(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>) -> Type:
  P.Owner<S,RegistryType(~S,~runFn),kind>
def unit_view(value:Unit) -> Unit & String:
  (value,"Unit")
def counter_join(result:Array<U32> & String) -> Counter & String:
  match result:
    case (values,text):(Counter{values},"Counter{" ++ text ++ "}")
def counter(value:Counter) -> Counter & String:
  match value:
    case Counter{values}:counter_join(Dump.u32_array(values))
def world(~S:Data,value:W.World<S,Col.Column<S,Unit>,Counter,U32>) -> W.World<S,Col.Column<S,Unit>,Counter,U32> & String:
  Dump.world(~S,~Unit,~Counter,~U32,~unit_view,~counter,~U32.show,value)
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{name,Query.Write{}}:name ++ ":Write"
    case Query.Clause{name,_}:name ++ ":OTHER"
def owner_described(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,value:OwnerType(~S,~kind,~runFn) & List<&2,Query.Clause<S>>) -> OwnerType(~S,~kind,~runFn) & String:
  match value:
    case (P.Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor},+slot},+clauses):
      (P.Owner{Sys.Registry{namespace,id,name,access,cursor},slot},"owner{" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":access=" ++ List.show(&2,String,(s=>s),access) ++ ":cursor=" ++ U32.show(cursor) ++ ":slot=" ++ slot ++ ":clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ "}")
def observed_owner(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,value:OwnerType(~S,~kind,~runFn)) -> OwnerType(~S,~kind,~runFn) & String:
  owner_described(~S,~kind,~runFn,P.describe(~S,~Col.Column<S,Unit>,~Counter,~U32,~Bool,~Error,~Output,~kind,~runFn,value))
def output_value(result:Array<U32> & U32) -> String:
  match result:
    case (_,prior):"Success{prior=" ++ U32.show(prior) ++ "}"
def output(value:Output) -> String:
  match value:
    case Output{values}:output_value(Array.get(U32,values,0))
def outcome(~S:Data,value:Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>) -> W.World<S,Col.Column<S,Unit>,Counter,U32> & String:
  match value:
    case Sys.Succeeded{world,value}:(world,output(value))
    case Sys.Failed{world,RolledBack{prior}}:(world,"Failure{prior=" ++ U32.show(prior) ++ "}")
def snapshot_join(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,ownerResult:OwnerType(~S,~kind,~runFn) & String,worldResult:W.World<S,Col.Column<S,Unit>,Counter,U32> & String,label:String) -> OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String):
  (owner,a)=ownerResult
  (world,b)=worldResult
  (owner,(world,label ++ "|" ++ a ++ "|world{" ++ b ++ "}"))
def completed_outcome(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,owner:OwnerType(~S,~kind,~runFn),result:W.World<S,Col.Column<S,Unit>,Counter,U32> & String) -> OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String):
  match result:
    case (value,label):snapshot_join(~S,~kind,~runFn,observed_owner(~S,~kind,~runFn,owner),world(~S,value),label)
def completed(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,result:Sys.RunResult<S,Col.Column<S,Unit>,Counter,U32,Bool,Error,Output,runFn> & String) -> OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String):
  match result:
    case (Sys.Completed{registry,result},slot):completed_outcome(~S,~kind,~runFn,P.Owner{registry,slot},outcome(~S,result))
    case (Sys.RegistrationRejected{registry,world,_},slot):(P.Owner{registry,slot},(world,"REGISTRATION_REJECTED"))
def run(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,owner:OwnerType(~S,~kind,~runFn),world:W.World<S,Col.Column<S,Unit>,Counter,U32>,fail:Bool) -> OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String):
  completed(~S,~kind,~runFn,P.run(~S,~Col.Column<S,Unit>,~Counter,~U32,~Bool,~Error,~Output,~kind,~runFn,owner,world,fail))
def third(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,first:String,second:String,result:OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String)) -> String:
  match result:
    case (_,(world,last)):first ++ "\n" ++ second ++ "\n" ++ last
def second(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,first:String,result:OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String)) -> String:
  match result:
    case (owner,(world,text)):third(~S,~kind,~runFn,first,text,run(~S,~kind,~runFn,owner,world,False{}))
def first(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,result:OwnerType(~S,~kind,~runFn) & (W.World<S,Col.Column<S,Unit>,Counter,U32> & String)) -> String:
  match result:
    case (owner,(world,text)):second(~S,~kind,~runFn,text,run(~S,~kind,~runFn,owner,world,True{}))
def registered(~S:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,Counter,U32> -> Bool -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,Counter,U32>,Error,Output>,result:P.Defined<S,W.World<S,Col.Column<S,Unit>,Counter,U32>,RegistryType(~S,~runFn),kind>) -> String:
  match result:
    case P.Rejected{_}:"DEFINE_REJECTED"
    case P.Defined{world,owner}:first(~S,~kind,~runFn,run(~S,~kind,~runFn,owner,world,False{}))
def start(~S:Data,world:W.World<S,Col.Column<S,Unit>,Counter,U32>) -> String:
  registered(~S,~Query.Write{},~P.runner(~S,~Col.Column<S,Unit>,~Counter,~U32,~ops,~Bool,~Error,~Output,~declaration(~S),~body),P.define(~S,~Col.Column<S,Unit>,~Counter,~U32,~ops,~Bool,~Error,~Output,~declaration(~S),~body,world,"CounterUpdate","Update"))
def activated(~S:Data,result:W.World<S,Col.Column<S,Unit>,Counter,U32> & W.Status) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match result:
    case (world,_):world
def reserved(~S:Data,result:W.World<S,Col.Column<S,Unit>,Counter,U32> & W.Reservation<S>) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Col.Column<S,Unit>,~Counter,~U32,world,handle))
    case (world,_):world
def entities(~S:Data,count:Nat,world:W.World<S,Col.Column<S,Unit>,Counter,U32>) -> W.World<S,Col.Column<S,Unit>,Counter,U32>:
  match count:
    case 0n:world
    case 1n+k:entities(~S,k,reserved(~S,W.reserve_id(~S,~Col.Column<S,Unit>,~Counter,~U32,world)))
def empty(~S:Data,unit:Unit) -> Col.Column<S,Unit>:
  Col.empty(~S,~Unit)
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Unit>,Counter,U32>) -> String:
  match result:
    case W.Created{_,world}:start(~S,entities(~S,count,world))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Unit>,~Counter,~U32,~empty(~S),W.factory(),Counter{Array.new(U32,0n,10)}))
type Report is Data:
  Report{empty:String,nonempty:String}
def main() -> Report:
  Report{scenario(~A,0n),scenario(~A,2n)}
