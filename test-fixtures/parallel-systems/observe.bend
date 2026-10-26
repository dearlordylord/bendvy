import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./bodies.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Lifecycle
import ../../src/ecs/deferred-command.bend as Deferred

def optional(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"absent"
    case Some{text}:text
def projected(~T:Type,result:T & String) -> String:
  match result:
    case (_,value):value
def stamp_text(value:Maybe<&2,Lifecycle.Stamp>) -> String:
  match value:
    case None{}:"invalid"
    case Some{Lifecycle.Stamp{added,changed}}:Tick.cursor_show(added) ++ "/" ++ Tick.cursor_show(changed)
type Walk<-S:Data,-P:Type> is Type:
  Walk{column:Col.Column<S,P>,index:U32,text:String}
def stamp_done(~S:Data,~P:Type,+index:U32,text:String,value:String,result:Col.Column<S,P> & Maybe<&2,Lifecycle.Stamp>) -> Walk<S,P>:
  match result:
    case (column,stamp):Walk{column,U32.add(index,1),text ++ U32.show(index) ++ "=" ++ value ++ "@" ++ stamp_text(stamp) ++ ";"}
def view_done(~S:Data,~P:Type,+index:U32,text:String,result:Col.Column<S,P> & Maybe<&2,String>) -> Walk<S,P>:
  match result:
    case (column,value):stamp_done(~S,~P,index,text,optional(value),Col.lifecycle(~S,~P,column,index))
def step(~S:Data,~P:Type,~project:P -> P & String,state:Walk<S,P>) -> Walk<S,P>:
  match state:
    case Walk{column,+index,text}:view_done(~S,~P,index,text,Col.view(~S,~P,~String,~project,column,index))
def walk(~S:Data,~P:Type,~project:P -> P & String,fuel:Nat,state:Walk<S,P>) -> String:
  match fuel state:
    case 0n Walk{_,_,text}:text
    case 1n++rest state:walk(~S,~P,~project,rest,step(~S,~P,~project,state))
def capacity_done(~S:Data,~P:Type,~project:P -> P & String,result:Col.Column<S,P> & U32) -> String:
  match result:
    case (column,capacity):"capacity=" ++ U32.show(capacity) ++ "[" ++ walk(~S,~P,~project,32n,Walk{column,0,""}) ++ "]"
def left_store(~S:Data,store:D.LeftStore(~S)) -> String:
  match store:
    case Product.Owner{column,_}:capacity_done(~S,~P.Position,~P.position,Col.capacity(~S,~P.Position,column))
def left_resource(resource:D.LeftResource()) -> String:
  match resource:
    case Product.Owner{payload,_}:projected(~P.Counter,P.counter(payload))
def right_store(~S:Data,store:D.RightStore(~S)) -> String:
  match store:
    case Product.Owner{column,_}:capacity_done(~S,~P.Health,~P.health,Col.capacity(~S,~P.Health,column))
def right_resource(resource:D.RightResource()) -> String:
  match resource:
    case Product.Owner{payload,_}:projected(~P.Score,P.score(payload))
def stores(~S:Data,store:D.Store(~S)) -> String:
  match store:
    case Product.Owner{left,right}:left_store(~S,left) ++ ";" ++ right_store(~S,right)
def resources(resource:D.Resources()) -> String:
  match resource:
    case Product.Owner{left,right}:left_resource(left) ++ ";" ++ right_resource(right)
def handles(~S:Data,values:List<&2,W.Handle<S>>) -> U32:
  match values:
    case []:0
    case _ <> rest:U32.add(1,handles(~S,rest))
def tick(value:Tick.Tick) -> String:
  match value:
    case Tick.Tick{epoch,low}:Nat.show(epoch) ++ ":" ++ U32.show(low)
def clock_text(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}:tick(now) ++ ";scopes=" ++ Nat.show(List.length(&2,Tick.Tick,scopes))
def observed(~S:Data,result:W.World<S,D.Store(~S),D.Resources(),Unit> & List<&2,W.Handle<S>>) -> String:
  match result:
    case (W.World{namespace,_,store,resource,events,pending,registrations,next,clock},live):stores(~S,store) ++ ";" ++ resources(resource) ++ ";live=" ++ U32.show(handles(~S,live)) ++ ";systems=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations)) ++ ";tick=" ++ clock_text(clock) ++ ";namespace=" ++ U32.show(namespace) ++ ";next-system=" ++ U32.show(next) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),D.Resources(),Unit>>,pending))
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(),Unit>) -> String:
  observed(~S,W.handles(~S,~D.Store(~S),~D.Resources(),~Unit,value))
def local_observed(runs:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(runs)
def local(~S:Data,value:Body.Local<S>) -> String:
  match value:
    case Body.Local{token,runs,_}:local_observed(runs,Array.get(U32,token,0))
