import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-builtin.bend as Builtin
# One retained ordinary Provision/Schema. Read indices contain no keys or owners.
type Provision<-S:Data,-C:Type,-R:Type,-empty:Unit -> C,-count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,-components:C -> U32 -> C & List<&2,Maybe<&2,String>>,-resources:R -> R & List<&2,Maybe<&2,String>>> is Data:
  Provision{ordinary:Ordinary.Provision<S,C,R,empty,count>}
def component_returned(~S:Data,~P:Type,result:Col.Column<S,P> & Maybe<&2,String>) -> Col.Column<S,P> & List<&2,Maybe<&2,String>>:
  match result:
    case (column,value):(column,[value])
def component_read(~S:Data,~P:Type,~show:P -> P & String,column:Col.Column<S,P>,id:U32) -> Col.Column<S,P> & List<&2,Maybe<&2,String>>:
  component_returned(~S,~P,Col.view(~S,~P,~String,~show,column,id))
def component_resources(value:Unit) -> Unit & List<&2,Maybe<&2,String>>:(value,[None{}])
def resource_components(value:Unit,id:U32) -> Unit & List<&2,Maybe<&2,String>>:(value,[None{}])
def resource_returned(~P:Type,result:P & String) -> P & List<&2,Maybe<&2,String>>:
  match result:
    case (value,text):(value,[Some{text}])
def resource_read(~P:Type,~show:P -> P & String,value:P) -> P & List<&2,Maybe<&2,String>>:
  resource_returned(~P,show(value))
# Opaque payload display is an explicit allowed extension; built-ins below need none.
def component(~S:Data,~P:Type,~show:P -> P & String,declaration:Identity.Declaration<S,P>) -> Provision<S,Col.Column<S,P>,Unit,Ordinary.component_empty(~S,~P),Ordinary.component_count(~S,~P),component_read(~S,~P,~show),component_resources>:
  Provision{Ordinary.component(~S,~P,declaration)}
def resource(~S:Data,~P:Type,~show:P -> P & String,declaration:Schema.Resource<S,P>) -> Provision<S,Unit,P,Ordinary.resource_empty,Ordinary.resource_count(~S),resource_components,resource_read(~P,~show)>:
  Provision{Ordinary.resource(~S,~P,declaration)}
def array_component(~S:Data,declaration:Identity.Declaration<S,Array<U32>>) -> Provision<S,Col.Column<S,Array<U32>>,Unit,Ordinary.component_empty(~S,~Array<U32>),Ordinary.component_count(~S,~Array<U32>),component_read(~S,~Array<U32>,~Builtin.array),component_resources>:
  component(~S,~Array<U32>,~Builtin.array,declaration)
def array_resource(~S:Data,declaration:Schema.Resource<S,Array<U32>>) -> Provision<S,Unit,Array<U32>,Ordinary.resource_empty,Ordinary.resource_count(~S),resource_components,resource_read(~Array<U32>,~Builtin.array)>:
  resource(~S,~Array<U32>,~Builtin.array,declaration)
def u32_component(~S:Data,declaration:Identity.Declaration<S,U32>) -> Provision<S,Col.Column<S,U32>,Unit,Ordinary.component_empty(~S,~U32),Ordinary.component_count(~S,~U32),component_read(~S,~U32,~Builtin.u32),component_resources>:
  component(~S,~U32,~Builtin.u32,declaration)
def bool_component(~S:Data,declaration:Identity.Declaration<S,Bool>) -> Provision<S,Col.Column<S,Bool>,Unit,Ordinary.component_empty(~S,~Bool),Ordinary.component_count(~S,~Bool),component_read(~S,~Bool,~Builtin.bool),component_resources>:
  component(~S,~Bool,~Builtin.bool,declaration)
def joined(~L:Type,~R:Type,left:L,before:List<&2,Maybe<&2,String>>,result:R & List<&2,Maybe<&2,String>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,String>>:
  match result:
    case (right,after):(Product.Owner{left,right},List.append(&2,Maybe<&2,String>,before,after))
def components_left(~L:Type,~R:Type,~rightRead:R -> U32 -> R & List<&2,Maybe<&2,String>>,right:R,id:U32,result:L & List<&2,Maybe<&2,String>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,String>>:
  match result:
    case (left,before):joined(~L,~R,left,before,rightRead(right,id))
def product_components(~L:Type,~R:Type,~leftRead:L -> U32 -> L & List<&2,Maybe<&2,String>>,~rightRead:R -> U32 -> R & List<&2,Maybe<&2,String>>,store:Product.Owner<L,R>,id:U32) -> Product.Owner<L,R> & List<&2,Maybe<&2,String>>:
  match store:
    case Product.Owner{left,right}:
      +id=id
      components_left(~L,~R,~rightRead,right,id,leftRead(left,id))
def resources_left(~L:Type,~R:Type,~rightRead:R -> R & List<&2,Maybe<&2,String>>,right:R,result:L & List<&2,Maybe<&2,String>>) -> Product.Owner<L,R> & List<&2,Maybe<&2,String>>:
  match result:
    case (left,before):joined(~L,~R,left,before,rightRead(right))
def product_resources(~L:Type,~R:Type,~leftRead:L -> L & List<&2,Maybe<&2,String>>,~rightRead:R -> R & List<&2,Maybe<&2,String>>,value:Product.Owner<L,R>) -> Product.Owner<L,R> & List<&2,Maybe<&2,String>>:
  match value:
    case Product.Owner{left,right}:resources_left(~L,~R,~rightRead,right,leftRead(left))
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,~leftEmpty:Unit -> LC,~leftCount:LC -> List<&2,W.Handle<S>> -> LC & List<&2,Maybe<&2,U32>>,~leftComponents:LC -> U32 -> LC & List<&2,Maybe<&2,String>>,~leftResources:LR -> LR & List<&2,Maybe<&2,String>>,~rightEmpty:Unit -> RC,~rightCount:RC -> List<&2,W.Handle<S>> -> RC & List<&2,Maybe<&2,U32>>,~rightComponents:RC -> U32 -> RC & List<&2,Maybe<&2,String>>,~rightResources:RR -> RR & List<&2,Maybe<&2,String>>,left:Provision<S,LC,LR,leftEmpty,leftCount,leftComponents,leftResources>,right:Provision<S,RC,RR,rightEmpty,rightCount,rightComponents,rightResources>) -> Provision<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>,Ordinary.product_empty(~LC,~RC,~leftEmpty,~rightEmpty),Ordinary.product_count(~S,~LC,~RC,~leftCount,~rightCount),product_components(~LC,~RC,~leftComponents,~rightComponents),product_resources(~LR,~RR,~leftResources,~rightResources)>:
  match left right:
    case Provision{left} Provision{right}:Provision{Ordinary.product(~S,~LC,~LR,~RC,~RR,~leftEmpty,~leftCount,~rightEmpty,~rightCount,left,right)}

# Metadata-free token generated by the same operational provisioning constructor.
type Recipe<-S:Data,-C:Type,-R:Type,-count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,-components:C -> U32 -> C & List<&2,Maybe<&2,String>>,-resources:R -> R & List<&2,Maybe<&2,String>>> is Data:
  Recipe{}
def prepared(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,value:Provision<S,C,R,empty,count,components,resources>) -> Schema.Schema<S,C,R> & Recipe<S,C,R,count,components,resources>:
  match value:
    case Provision{Ordinary.Provision{schema}}:(schema,Recipe{})
