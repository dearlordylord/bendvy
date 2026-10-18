import Base
import ./owner-product.bend as Product
# Only canonical product exchanges create these inverses. No body-provided inverse.
def replaced(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,P,Rest>,replacement:P,taken:Rest & P) -> State & P:
  match taken:
    case (rest,old):(Product.put_field(~State,~P,~Rest,lens)(rest,replacement),old)
def exchange(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,P,Rest>,state:State,replacement:P) -> State & P:
  replaced(~State,~P,~Rest,~lens,replacement,Product.get_field(~State,~P,~Rest,lens)(state))
def appended(~Recovery:Type,~P:Type,~Rest:Type,~lens:Product.Lens<Recovery,List<P>,Rest>,value:P,taken:Rest & List<P>) -> Recovery:
  match taken:
    case (rest,values):Product.put_field(~Recovery,~List<P>,~Rest,lens)(rest,value <> values)
def append(~Recovery:Type,~P:Type,~Rest:Type,~lens:Product.Lens<Recovery,List<P>,Rest>,recovery:Recovery,value:P) -> Recovery:
  appended(~Recovery,~P,~Rest,~lens,value,Product.get_field(~Recovery,~List<P>,~Rest,lens)(recovery))
