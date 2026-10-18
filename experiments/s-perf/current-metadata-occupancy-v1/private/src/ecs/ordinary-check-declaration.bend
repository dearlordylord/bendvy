import Base
import ./world.bend as W
import ./check.bend as K
import ./capabilities.bend as Cap
import ./ordinary-schema.bend as Schema
import ./ordinary-optional-resource.bend as O
import ./optional-resource-binding.bend as B
import ./owner-product.bend as Product

# Metadata belongs to the same operational read; no caller-authored access list.
type ComponentSelection is Data:
  Required{}
  Optional{}
  With{}
  Without{}
type RelationKind is Data:
  Ordinary{}
  Hierarchy{}
type RelationDirection is Data:
  Outgoing{}
  Incoming{}
type RelationSelection is Data:
  RelationRequired{}
  RelationOptional{}
  RelationPresent{}
  RelationAbsent{}
type RelationIdentity is Data:
  RelationIdentity{id:U32,name:String,inverseName:String,kind:RelationKind}
type Category is Data:
  Resource{}
  Component{selection:ComponentSelection}
  Machine{}
  Relation{identity:RelationIdentity,direction:RelationDirection,selection:RelationSelection,cellKey:Maybe<&2,String>}
type Mode is Data:Read{}
type Use is Data:Use{category:Category,key:String,mode:Mode,required:Bool}
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Declaration{plan:K.Plan<S,C,R,E,Ops>,uses:List<&2,Use>}
type ResourceRead<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  ResourceRead{read:Cap.ValueRead<H,Maybe<&2,V>>}
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:ResourceRead<S,P,identity,H,V>
def read_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,value:ResourceRead<S,P,identity,H,V>) -> H -> H & Maybe<&2,V>:
  match value:
    case ResourceRead{read}:Cap.value_read_field(~H,~Maybe<&2,V>,read)
def read(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~value:ResourceRead<S,P,identity,H,V>,owner:H) -> H & Maybe<&2,V>:
  read_field(~S,~P,~identity,~H,~V,value)(owner)
def provided(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:(world,[])
def optional_resource(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V)>:
  Declaration{K.Plan{provided(~S,~C,~R,~E),ResourceRead{O.condition(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{})}},[Use{Resource{},Schema.resource_key(~S,~P,identity),Read{},False{}}]}
def required_resource(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V)>:
  Declaration{K.Plan{O.required(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{}),ResourceRead{O.condition(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{})}},[Use{Resource{},Schema.resource_key(~S,~P,identity),Read{},True{}}]}
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,value:Declaration<S,C,R,E,Ops>) -> K.Plan<S,C,R,E,Ops>:
  match value:
    case Declaration{plan,_}:plan
def uses(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,value:Declaration<S,C,R,E,Ops>) -> List<&2,Use>:
  match value:
    case Declaration{_,uses}:uses

# A single reached predicate may request several declared reads. Validation
# threads the original World in authored order and retains each returned name.
def PairOps(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:Cap.Bundle<L(H),R(H)>
def required_join(~S:Data,~C:Type,~R:Type,~E:Data,before:List<&2,String>,observed:W.World<S,C,R,E> & List<&2,String>) -> W.World<S,C,R,E> & List<&2,String>:
  match observed:
    case (world,after):(world,List.append(&2,String,before,after))
def required_right(~S:Data,~C:Type,~R:Type,~E:Data,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,String>,observed:W.World<S,C,R,E> & List<&2,String>) -> W.World<S,C,R,E> & List<&2,String>:
  match observed:
    case (world,before):required_join(~S,~C,~R,~E,before,right(world))
def required_pair(~S:Data,~C:Type,~R:Type,~E:Data,~left:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,String>,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,String>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:required_right(~S,~C,~R,~E,~right,left(world))
def both(~S:Data,~C:Type,~R:Type,~E:Data,~LOps:Type -> Type,~ROps:Type -> Type,~left:Declaration<S,C,R,E,LOps>,~right:Declaration<S,C,R,E,ROps>) -> Declaration<S,C,R,E,PairOps(~LOps,~ROps)>:
  Declaration{K.Plan{required_pair(~S,~C,~R,~E,~K.required_field(~S,~C,~R,~E,~LOps,plan(~S,~C,~R,~E,~LOps,left)),~K.required_field(~S,~C,~R,~E,~ROps,plan(~S,~C,~R,~E,~ROps,right))),Cap.Bundle{K.caps_field(~S,~C,~R,~E,~LOps,plan(~S,~C,~R,~E,~LOps,left)),K.caps_field(~S,~C,~R,~E,~ROps,plan(~S,~C,~R,~E,~ROps,right))}},List.append(&2,Use,uses(~S,~C,~R,~E,~LOps,left),uses(~S,~C,~R,~E,~ROps,right))}
