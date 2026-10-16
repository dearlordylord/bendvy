import Base
import ./owner-product.bend as Product
import ./capabilities.bend as Cap
import ./owned-event-journal.bend as Frame
# Canonical event declarations compose heterogeneous payload grants with one
# ordered journal. Builder remains erased until the full recovery tree is known.
# Raw constructors/builders are trusted engine administration, not gameplay.
def Builder(~State:Type,~Recovery:Type,~Ops:Type -> Type) -> Type:
  @-All:Type -> @-Rest:Type -> @-path:Product.Lens<All,Recovery,Rest> -> Unit -> Ops(Frame.Stage<State,All>)
type Declaration<-S:Data,-State:Type,-Recovery:Type,-Ops:Type -> Type,-builder:Builder(~State,~Recovery,~Ops)> is Type:
  Declaration{empty:Unit -> Recovery,access:List<&2,String>}
def empty(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> Unit -> Recovery:
  match value:
    case Declaration{empty,_}:empty
def access(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> List<&2,String>:
  match value:
    case Declaration{_,access}:access
def PairOps(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:Cap.Bundle<L(H),R(H)>
def pair_empty(~L:Type,~R:Type,~left:Unit -> L,~right:Unit -> R,unit:Unit) -> Product.Owner<L,R>:Product.Owner{left(Unit{}),right(unit)}
def pair_grant(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~left:Builder(~State,~L,~LOps),~right:Builder(~State,~R,~ROps),~All:Type,~Rest:Type,~path:Product.Lens<All,Product.Owner<L,R>,Rest>,unit:Unit) -> Cap.Bundle<LOps(Frame.Stage<State,All>),ROps(Frame.Stage<State,All>)>:
  Cap.Bundle{left(All,Rest & R,Product.compose(~All,~Product.Owner<L,R>,~Rest,~L,~R,~path,~Product.lens(~L,~R,~Product.Left{})),Unit{}),right(All,Rest & L,Product.compose(~All,~Product.Owner<L,R>,~Rest,~R,~L,~path,~Product.lens(~L,~R,~Product.Right{})),unit)}
def both(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~leftBuilder:Builder(~State,~L,~LOps),~rightBuilder:Builder(~State,~R,~ROps),~left:Declaration<S,State,L,LOps,leftBuilder>,~right:Declaration<S,State,R,ROps,rightBuilder>) -> Declaration<S,State,Product.Owner<L,R>,PairOps(~LOps,~ROps),pair_grant(~S,~State,~L,~R,~LOps,~ROps,~leftBuilder,~rightBuilder)>:
  Declaration{pair_empty(~L,~R,~empty(~S,~State,~L,~LOps,~leftBuilder,left),~empty(~S,~State,~R,~ROps,~rightBuilder,right)),List.append(&2,String,access(~S,~State,~L,~LOps,~leftBuilder,left),access(~S,~State,~R,~ROps,~rightBuilder,right))}
def identity_take(~R:Type,value:R) -> Unit & R:(Unit{},value)
def identity_put(~R:Type,unit:Unit,value:R) -> R:value
def identity(~R:Type) -> Product.Lens<R,R,Unit>:Product.Lens{identity_take(~R),identity_put(~R)}
def root_grant(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops)) -> Ops(Frame.Stage<State,Recovery>):builder(Recovery,Unit,identity(~Recovery),Unit{})
