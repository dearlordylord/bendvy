import Base
type Position is Type:
  Position{token:Array<U32>,value:U32}
type Label is Type:
  Label{token:Array<U32>,value:String}
type Counter is Type:
  Counter{token:Array<U32>,value:U32}
type Secret is Type:
  Secret{token:Array<U32>}
def position_projected(+value:U32,result:Array<U32> & U32) -> Position & String:
  match result:
    case (token,id):(Position{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def position(owner:Position) -> Position & String:
  match owner:
    case Position{token,value}:position_projected(value,Array.get(U32,token,0))
def move(owner:Position) -> Position & String:
  match owner:
    case Position{token,value}:position_projected(U32.add(value,1),Array.get(U32,token,0))
def label_projected(+value:String,result:Array<U32> & U32) -> Label & String:
  match result:
    case (token,id):(Label{token,value},U32.show(id) ++ ":" ++ value)
def label(owner:Label) -> Label & String:
  match owner:
    case Label{token,value}:label_projected(value,Array.get(U32,token,0))
def counter_projected(+value:U32,result:Array<U32> & U32) -> Counter & String:
  match result:
    case (token,id):(Counter{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def counter(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,value}:counter_projected(value,Array.get(U32,token,0))
def count(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,value}:counter_projected(U32.add(value,10),Array.get(U32,token,0))
def secret_projected(result:Array<U32> & U32) -> Secret & String:
  match result:
    case (token,id):(Secret{token},U32.show(id))
def secret(owner:Secret) -> Secret & String:
  match owner:
    case Secret{token}:secret_projected(Array.get(U32,token,0))
