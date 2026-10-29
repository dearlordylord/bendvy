import Base
type Position is Type:
  Position{token:Array<U32>,value:U32}
def position_observed(+value:U32,result:Array<U32> & U32) -> Position & String:
  match result:
    case (token,id):(Position{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def position(owner:Position) -> Position & String:
  match owner:
    case Position{token,value}:position_observed(value,Array.get(U32,token,0))
def update_position(owner:Position) -> Position & String:
  match owner:
    case Position{token,value}:position_observed(U32.add(value,1),Array.get(U32,token,0))
type Health is Type:
  Health{token:Array<U32>,value:U32}
def health_observed(+value:U32,result:Array<U32> & U32) -> Health & String:
  match result:
    case (token,id):(Health{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def health(owner:Health) -> Health & String:
  match owner:
    case Health{token,value}:health_observed(value,Array.get(U32,token,0))
def update_health(owner:Health) -> Health & String:
  match owner:
    case Health{token,value}:health_observed(U32.add(value,2),Array.get(U32,token,0))
type Counter is Type:
  Counter{token:Array<U32>,value:U32}
def counter_observed(+value:U32,result:Array<U32> & U32) -> Counter & String:
  match result:
    case (token,id):(Counter{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def counter(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,value}:counter_observed(value,Array.get(U32,token,0))
def update_counter(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,value}:counter_observed(U32.add(value,10),Array.get(U32,token,0))
type Score is Type:
  Score{token:Array<U32>,value:U32}
def score_observed(+value:U32,result:Array<U32> & U32) -> Score & String:
  match result:
    case (token,id):(Score{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def score(owner:Score) -> Score & String:
  match owner:
    case Score{token,value}:score_observed(value,Array.get(U32,token,0))
def update_score(owner:Score) -> Score & String:
  match owner:
    case Score{token,value}:score_observed(U32.add(value,3),Array.get(U32,token,0))
