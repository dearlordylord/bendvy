import Base
import ./world.bend as W
import ./owner-product.bend as Product
import ./owned-event-log.bend as Log
import ./owned-event-family-storage.bend as Storage
import ./recovery-journal.bend as Journal
# Trusted transport. Ordinary declaration builders derive both paths together;
# authored gameplay receives only the abstract emission capability.
type Stage<State:Type,Recovery:Type> is Type:
  Stage{newest:List<Journal.Action(~State,~Recovery)>}
def empty(~State:Type,~Recovery:Type) -> Stage<State,Recovery>:Stage{[]}
def recovered(~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<P>,Rest>,payload:P,parts:Rest & List<P>) -> All:
  match parts:
    case (rest,values):Product.put_field(~All,~List<P>,~Rest,path)(rest,List.append(&1,P,values,[payload]))
def recover(~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<P>,Rest>,payload:P,all:All) -> All:
  recovered(~P,~All,~Rest,~path,payload,Product.get_field(~All,~List<P>,~Rest,path)(all))
def action(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~All:Type,~RecoveryRest:Type,~recovery:Product.Lens<All,List<P>,RecoveryRest>,payload:P,success:Bool,world:W.World<S,C,R,E>,all:All) -> W.World<S,C,R,E> & All:
  match success:
    case True{}:(Storage.commit_owned(~S,~C,~R,~P,~Rest,~E,~path,~inject,world,[payload]),all)
    case False{}:(world,recover(~P,~All,~RecoveryRest,~recovery,payload,all))
def emit(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~All:Type,~RecoveryRest:Type,~recovery:Product.Lens<All,List<P>,RecoveryRest>,stage:Stage<W.World<S,C,R,E>,All>,payload:P) -> Stage<W.World<S,C,R,E>,All>:
  match stage:
    case Stage{newest}:Stage{(success => world => all => action(~S,~C,~R,~P,~Rest,~E,~path,~inject,~All,~RecoveryRest,~recovery,payload,success,world,all)) <> newest}
# Reverse the action spine once: commits retain the global inter-family order,
# and abort receipts retain each family's order. Every closure executes once.
def finish(~State:Type,~Recovery:Type,stage:Stage<State,Recovery>,success:Bool,state:State,recovery:Recovery) -> State & Recovery:
  match stage:
    case Stage{newest}:Journal.finish(~State,~Recovery,List.reverse(&1,Journal.Action(~State,~Recovery),newest),success,state,recovery)
