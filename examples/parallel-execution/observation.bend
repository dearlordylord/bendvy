import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product

def optional(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"absent"
    case Some{text}:text
def position_end(~S:Data,a:String,b:String,result:Col.Column<S,P.Position> & Maybe<&2,String>) -> String:
  match result:
    case (_,missing):a ++ "," ++ b ++ "," ++ optional(missing)
def position_second(~S:Data,a:String,result:Col.Column<S,P.Position> & Maybe<&2,String>) -> String:
  match result:
    case (column,b):position_end(~S,a,optional(b),Col.view(~S,~P.Position,~String,~P.position,column,8))
def position_first(~S:Data,result:Col.Column<S,P.Position> & Maybe<&2,String>) -> String:
  match result:
    case (column,a):position_second(~S,optional(a),Col.view(~S,~P.Position,~String,~P.position,column,16))
def label_done(~S:Data,result:Col.Column<S,P.Label> & Maybe<&2,String>) -> String:
  match result:
    case (_,label):optional(label)
def store(~S:Data,value:D.Store(~S)) -> String:
  match value:
    case Product.Owner{position,label}:position_first(~S,Col.view(~S,~P.Position,~String,~P.position,position,1)) ++ ";" ++ label_done(~S,Col.view(~S,~P.Label,~String,~P.label,label,2))
def counter_done(result:P.Counter & String) -> String:
  match result:
    case (_,value):value
def secret_done(result:P.Secret & String) -> String:
  match result:
    case (_,value):value
def resources(value:D.Resources()) -> String:
  match value:
    case Product.Owner{counter,secret}:counter_done(P.counter(counter)) ++ ";" ++ secret_done(P.secret(secret))
def count(~S:Data,handles:List<&2,W.Handle<S>>) -> U32:
  match handles:
    case []:0
    case _ <> rest:U32.add(1,count(~S,rest))
def world_parts(~S:Data,result:W.World<S,D.Store(~S),D.Resources(),Unit> & List<&2,W.Handle<S>>) -> String:
  match result:
    case (W.World{_,_,components,resource,_,_,registrations,_,_},handles):store(~S,components) ++ ";" ++ resources(resource) ++ ";live=" ++ U32.show(count(~S,handles)) ++ ";registered=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations))
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(),Unit>) -> String:
  world_parts(~S,W.handles(~S,~D.Store(~S),~D.Resources(),~Unit,value))
def local_token(runs:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(runs)
def local(~S:Data,value:Body.Local<S>) -> String:
  match value:
    case Body.Local{token,runs,_}:local_token(runs,Array.get(U32,token,0))
