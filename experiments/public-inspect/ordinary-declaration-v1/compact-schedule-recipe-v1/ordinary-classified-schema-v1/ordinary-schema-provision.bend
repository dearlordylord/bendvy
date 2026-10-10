import Base
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
# The single ordinary Schema owns all keys. The erased traversal holds no keys,
# presenters or payloads. Ordinary builders generate matching leaf slots/order.
type Provision<-S:Data,-C:Type,-R:Type,-empty:Unit -> C,-count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>> is Data:
  Provision{schema:Schema.Schema<S,C,R>}
def counted(~S:Data,~P:Type,total:U32,result:Col.Column<S,P> & Bool,ih:Col.Column<S,P> -> U32 -> Col.Column<S,P> & U32) -> Col.Column<S,P> & U32:
  match result:
    case (column,True{}):ih(column,(total + 1 : U32))
    case (column,False{}):ih(column,total)
def column_count(~S:Data,~P:Type,handles:List<&2,W.Handle<S>>,column:Col.Column<S,P>,total:U32) -> Col.Column<S,P> & U32:
  match handles:
    case []:(column,total)
    case W.Handle{_,id} <> rest:counted(~S,~P,total,Col.has(~S,~P,column,id),column => total => column_count(~S,~P,rest,column,total))
def component_counted(~S:Data,~P:Type,result:Col.Column<S,P> & U32) -> Col.Column<S,P> & List<&2,Maybe<&2,U32>>:
  match result:
    case (column,count):(column,[Some{count}])
def component_count(~S:Data,~P:Type,column:Col.Column<S,P>,handles:List<&2,W.Handle<S>>) -> Col.Column<S,P> & List<&2,Maybe<&2,U32>>:
  component_counted(~S,~P,column_count(~S,~P,handles,column,0))
def component_empty(~S:Data,~P:Type,unit:Unit) -> Col.Column<S,P>:Col.empty(~S,~P)
def resource_count(~S:Data,value:Unit,handles:List<&2,W.Handle<S>>) -> Unit & List<&2,Maybe<&2,U32>>:(value,[None{}])
def resource_empty(unit:Unit) -> Unit:unit
def component(~S:Data,~P:Type,declaration:Identity.Declaration<S,P>) -> Provision<S,Col.Column<S,P>,Unit,component_empty(~S,~P),component_count(~S,~P)>:
  Provision{Schema.component(~S,~P,declaration)}
def resource(~S:Data,~P:Type,declaration:Schema.Resource<S,P>) -> Provision<S,Unit,P,resource_empty,resource_count(~S)>:
  Provision{Schema.resource_schema(~S,~P,declaration)}
def product_counted(~L:Type,~R:Type,left:L,before:List<&2,Maybe<&2,U32>>,right:R & List<&2,Maybe<&2,U32>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,U32>>:
  match right:
    case (right,after):(Product.Owner{left,right},List.append(&2,Maybe<&2,U32>,before,after))
def product_left(~S:Data,~L:Type,~R:Type,~rightCount:R -> List<&2,W.Handle<S>> -> R & List<&2,Maybe<&2,U32>>,right:R,handles:List<&2,W.Handle<S>>,left:L & List<&2,Maybe<&2,U32>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,U32>>:
  match left:
    case (left,before):product_counted(~L,~R,left,before,rightCount(right,handles))
def product_count(~S:Data,~L:Type,~R:Type,~leftCount:L -> List<&2,W.Handle<S>> -> L & List<&2,Maybe<&2,U32>>,~rightCount:R -> List<&2,W.Handle<S>> -> R & List<&2,Maybe<&2,U32>>,store:Product.Owner<L,R>,handles:List<&2,W.Handle<S>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,U32>>:
  match store:
    case Product.Owner{left,right}:
      +handles=handles
      product_left(~S,~L,~R,~rightCount,right,handles,leftCount(left,handles))
def product_empty(~L:Type,~R:Type,~leftEmpty:Unit -> L,~rightEmpty:Unit -> R,unit:Unit) -> Product.Owner<L,R>:
  Product.Owner{leftEmpty(Unit{}),rightEmpty(Unit{})}
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,~leftEmpty:Unit -> LC,~leftCount:LC -> List<&2,W.Handle<S>> -> LC & List<&2,Maybe<&2,U32>>,~rightEmpty:Unit -> RC,~rightCount:RC -> List<&2,W.Handle<S>> -> RC & List<&2,Maybe<&2,U32>>,left:Provision<S,LC,LR,leftEmpty,leftCount>,right:Provision<S,RC,RR,rightEmpty,rightCount>) -> Provision<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>,product_empty(~LC,~RC,~leftEmpty,~rightEmpty),product_count(~S,~LC,~RC,~leftCount,~rightCount)>:
  match left right:
    case Provision{left} Provision{right}:Provision{Schema.product(~S,~LC,~LR,~RC,~RR,left,right)}
def create(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,provision:Provision<S,C,R,empty,count>,factory:W.Factory,resource:R) -> Provision<S,C,R,empty,count> & W.Creation<S,C,R,E>:
  (provision,W.create(~S,~C,~R,~E,~empty,factory,resource))

def component_plain(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Provision<S,Col.Column<S,P>,Unit,component_empty(~S,~P),component_count(~S,~P)>:Provision{Schema.component_plain(~S,~P,~identity,extension)}

def component_transient(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Provision<S,Col.Column<S,P>,Unit,component_empty(~S,~P),component_count(~S,~P)>:Provision{Schema.component_transient(~S,~P,~identity,extension)}

def component_constructed(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Provision<S,Col.Column<S,P>,Unit,component_empty(~S,~P),component_count(~S,~P)>:Provision{Schema.component_constructed(~S,~P,~identity,~project,extension)}

def resource_plain(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Plain<S,P,identity>) -> Provision<S,Unit,P,resource_empty,resource_count(~S)>:Provision{Schema.resource_plain(~S,~P,~identity,extension)}

def resource_transient(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,extension:Persist.Transient<S,P,identity>) -> Provision<S,Unit,P,resource_empty,resource_count(~S)>:Provision{Schema.resource_transient(~S,~P,~identity,extension)}

def resource_constructed(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,identity,project>) -> Provision<S,Unit,P,resource_empty,resource_count(~S)>:Provision{Schema.resource_constructed(~S,~P,~identity,~project,extension)}
