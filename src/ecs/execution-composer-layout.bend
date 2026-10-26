import Base
import ./chunk-column.bend as Column
import ./owner-product.bend as Product
import ./lifecycle.bend as Lifecycle

type Layout is Type:
  EmptyLayout{}
  LayoutLeaf{P:Type,key:String}
  LayoutPair{left:Layout,right:Layout}
type Route is Data:
  AtLeaf{}
  InLeft{rest:Route}
  InRight{rest:Route}
type ColumnSlot<-S:Data,-P:Type,-key:String> is Type:
  ColumnSlot{column:Column.Column<S,P>}
type ResourceSlot<-S:Data,-P:Type,-key:String> is Type:
  ResourceSlot{owner:P}
def columns(~S:Data,layout:Layout) -> Type:
  match layout:
    case EmptyLayout{}:Unit
    case LayoutLeaf{P,key}:ColumnSlot<S,P,key>
    case LayoutPair{left,right}:Product.Owner<columns(~S,left),columns(~S,right)>
def resources(~S:Data,layout:Layout) -> Type:
  match layout:
    case EmptyLayout{}:Unit
    case LayoutLeaf{P,key}:ResourceSlot<S,P,key>
    case LayoutPair{left,right}:Product.Owner<resources(~S,left),resources(~S,right)>
def payload(layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{P,_} AtLeaf{}:P
    case LayoutPair{left,_} InLeft{rest}:payload(left,rest)
    case LayoutPair{_,right} InRight{rest}:payload(right,rest)
    case _ _:Unit
def key(layout:Layout,route:Route) -> String:
  match layout route:
    case LayoutLeaf{_,key} AtLeaf{}:key
    case LayoutPair{left,_} InLeft{rest}:key(left,rest)
    case LayoutPair{_,right} InRight{rest}:key(right,rest)
    case _ _:""
def valid(layout:Layout,route:Route) -> Bool:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:True{}
    case LayoutPair{left,_} InLeft{rest}:valid(left,rest)
    case LayoutPair{_,right} InRight{rest}:valid(right,rest)
    case _ _:False{}
def empty_column(-S:Data,-P:Type) -> Column.Column<S,P>:
  Column.Leaf{ANode{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}}},[Lifecycle.Stamp{None{},None{}} : Lifecycle.Stamp^3n]}
def empty_columns(~S:Data,layout:Layout) -> columns(~S,layout):
  match layout:
    case EmptyLayout{}:Unit{}
    case LayoutLeaf{P,key}:ColumnSlot{empty_column(S,P)}
    case LayoutPair{left,right}:Product.Owner{empty_columns(~S,left),empty_columns(~S,right)}
def column_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:Unit
    case LayoutPair{left,right} InLeft{rest}:columns(~S,right) & column_rest(~S,left,rest)
    case LayoutPair{left,right} InRight{rest}:columns(~S,left) & column_rest(~S,right,rest)
    case layout _:columns(~S,layout)
def column_joined(~S:Data,-P:Type,-key:String,-Outer:Type,-Inner:Type,outer:Outer,result:Inner & ColumnSlot<S,P,key>) -> (Outer & Inner) & ColumnSlot<S,P,key>:
  match result:
    case (inner,slot):((outer,inner),slot)
def column_take(~S:Data,layout:Layout,route:Route,owner:columns(~S,layout)) -> column_rest(~S,layout,route) & ColumnSlot<S,payload(layout,route),key(layout,route)>:
  match layout route owner:
    case EmptyLayout{} _ owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutLeaf{P,key} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,key} InLeft{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutLeaf{P,key} InRight{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:column_joined(~S,payload(left,rest),key(left,rest),columns(~S,right),column_rest(~S,left,rest),r,column_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:column_joined(~S,payload(right,rest),key(right,rest),columns(~S,left),column_rest(~S,right,rest),l,column_take(~S,right,rest,r))
def column_put(~S:Data,layout:Layout,route:Route,rest:column_rest(~S,layout,route),slot:ColumnSlot<S,payload(layout,route),key(layout,route)>) -> columns(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,key} AtLeaf{} _:slot
    case LayoutLeaf{P,key} InLeft{_} rest:rest
    case LayoutLeaf{P,key} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{column_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,column_put(~S,right,path,inner,slot)}
def resource_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:Unit
    case LayoutPair{left,right} InLeft{rest}:resources(~S,right) & resource_rest(~S,left,rest)
    case LayoutPair{left,right} InRight{rest}:resources(~S,left) & resource_rest(~S,right,rest)
    case layout _:resources(~S,layout)
def resource_joined(~S:Data,-P:Type,-key:String,-Outer:Type,-Inner:Type,outer:Outer,result:Inner & ResourceSlot<S,P,key>) -> (Outer & Inner) & ResourceSlot<S,P,key>:
  match result:
    case (inner,slot):((outer,inner),slot)
def resource_take(~S:Data,layout:Layout,route:Route,owner:resources(~S,layout)) -> resource_rest(~S,layout,route) & ResourceSlot<S,payload(layout,route),key(layout,route)>:
  match layout route owner:
    case EmptyLayout{} _ owner:(owner,ResourceSlot{Unit{}})
    case LayoutLeaf{P,key} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,key} InLeft{_} owner:(owner,ResourceSlot{Unit{}})
    case LayoutLeaf{P,key} InRight{_} owner:(owner,ResourceSlot{Unit{}})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ResourceSlot{Unit{}})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:resource_joined(~S,payload(left,rest),key(left,rest),resources(~S,right),resource_rest(~S,left,rest),r,resource_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:resource_joined(~S,payload(right,rest),key(right,rest),resources(~S,left),resource_rest(~S,right,rest),l,resource_take(~S,right,rest,r))
def resource_put(~S:Data,layout:Layout,route:Route,rest:resource_rest(~S,layout,route),slot:ResourceSlot<S,payload(layout,route),key(layout,route)>) -> resources(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,key} AtLeaf{} _:slot
    case LayoutLeaf{P,key} InLeft{_} rest:rest
    case LayoutLeaf{P,key} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{resource_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,resource_put(~S,right,path,inner,slot)}
def checked_owner(-A:Type,-B:Type,same:{A == B : Type},owner:A) -> B:
  %same : _
  owner
