import Base
import ./owner-product.bend as Product
import ./recoverable-array.bend as A
import ./recoverable-owner.bend as Owner
import ./recovery-journal.bend as Journal
# Trusted implementation: ordinary grants hide journals and product lenses.
type Attempt<State:Type,Recovery:Type,P:Type> is Type:
  Applied{state:State,journal:List<Journal.Action(~State,~Recovery)>}
  Refused{state:State,journal:List<Journal.Action(~State,~Recovery)>,replacement:P}
def restored(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,rest:Rest,recovery:Recovery,result:Array<P> & A.Record<P>) -> State & Recovery:
  match result:
    case (array,replacement):(Product.put_field(~State,~Array<P>,~Rest,lens)(rest,array),Owner.append(~Recovery,~A.Record<P>,~ReleasedRest,~release,recovery,replacement))
def restore(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,old:A.Record<P>,recovery:Recovery,taken:Rest & Array<P>) -> State & Recovery:
  match taken:
    case (rest,array):restored(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,rest,recovery,A.undo(~P,old,array))
def inverse(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,old:A.Record<P>,success:Bool,state:State,recovery:Recovery) -> State & Recovery:
  match success:
    case True{}:(state,Owner.append(~Recovery,~A.Record<P>,~ReleasedRest,~release,recovery,old))
    case False{}:restore(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,old,recovery,Product.get_field(~State,~Array<P>,~Rest,lens)(state))
def record(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,state:State,journal:List<Journal.Action(~State,~Recovery)>,old:A.Record<P>) -> State & List<Journal.Action(~State,~Recovery)>:
  (state,(success => s => r => inverse(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,old,success,s,r)) <> journal)
def replaced(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,journal:List<Journal.Action(~State,~Recovery)>,result:State & Array<P>) -> State & List<Journal.Action(~State,~Recovery)>:
  match result:
    case (state,old):record(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,state,journal,A.Replaced{old})
def replace(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,state:State,journal:List<Journal.Action(~State,~Recovery)>,replacement:Array<P>) -> State & List<Journal.Action(~State,~Recovery)>:
  replaced(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,journal,Owner.exchange(~State,~Array<P>,~Rest,~lens,state,replacement))
def swapped(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,rest:Rest,+index:U32,journal:List<Journal.Action(~State,~Recovery)>,result:Array<P> & P) -> State & List<Journal.Action(~State,~Recovery)>:
  match result:
    case (array,old):record(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,Product.put_field(~State,~Array<P>,~Rest,lens)(rest,array),journal,A.Swapped{index,old})
def applied(~State:Type,~Recovery:Type,~P:Type,result:State & List<Journal.Action(~State,~Recovery)>) -> Attempt<State,Recovery,P>:
  match result:
    case (state,journal):Applied{state,journal}
def bounded(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,valid:Bool,rest:Rest,array:Array<P>,journal:List<Journal.Action(~State,~Recovery)>,+index:U32,replacement:P) -> Attempt<State,Recovery,P>:
  match valid:
    case False{}:Refused{Product.put_field(~State,~Array<P>,~Rest,lens)(rest,array),journal,replacement}
    case True{}:applied(~State,~Recovery,~P,swapped(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,rest,index,journal,Array.swap(P,array,index,replacement)))
def sized(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,rest:Rest,journal:List<Journal.Action(~State,~Recovery)>,+index:U32,replacement:P,result:Array<P> & U32) -> Attempt<State,Recovery,P>:
  match result:
    case (array,size):bounded(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,U32.is_lt(index,size),rest,array,journal,index,replacement)
def taken(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,journal:List<Journal.Action(~State,~Recovery)>,index:U32,replacement:P,result:Rest & Array<P>) -> Attempt<State,Recovery,P>:
  match result:
    case (rest,array):sized(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,rest,journal,index,replacement,Array.size(P,array))
def swap(~State:Type,~P:Type,~Rest:Type,~lens:Product.Lens<State,Array<P>,Rest>,~Recovery:Type,~ReleasedRest:Type,~release:Product.Lens<Recovery,List<A.Record<P>>,ReleasedRest>,state:State,journal:List<Journal.Action(~State,~Recovery)>,index:U32,replacement:P) -> Attempt<State,Recovery,P>:
  taken(~State,~P,~Rest,~lens,~Recovery,~ReleasedRest,~release,journal,index,replacement,Product.get_field(~State,~Array<P>,~Rest,lens)(state))
