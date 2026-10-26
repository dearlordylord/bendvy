import Base
import ./chunk-column.bend as Column
import ./owner-product.bend as Product
import ./lifecycle.bend as Lifecycle
import ./schema-fragments.bend as Fragment

type Layout is Type:
  EmptyLayout{}
  LayoutLeaf{P:Type,key:String}
  ClassifiedLayoutLeaf{P:Type,key:String,persistence:Fragment.PersistenceKind}
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
    case ClassifiedLayoutLeaf{P,key,_}:ColumnSlot<S,P,key>
    case LayoutPair{left,right}:Product.Owner<columns(~S,left),columns(~S,right)>
def resources(~S:Data,layout:Layout) -> Type:
  match layout:
    case EmptyLayout{}:Unit
    case LayoutLeaf{P,key}:ResourceSlot<S,P,key>
    case ClassifiedLayoutLeaf{P,key,_}:ResourceSlot<S,P,key>
    case LayoutPair{left,right}:Product.Owner<resources(~S,left),resources(~S,right)>
def payload(layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{P,_} AtLeaf{}:P
    case ClassifiedLayoutLeaf{P,_,_} AtLeaf{}:P
    case LayoutPair{left,_} InLeft{rest}:payload(left,rest)
    case LayoutPair{_,right} InRight{rest}:payload(right,rest)
    case _ _:Unit
def key(layout:Layout,route:Route) -> String:
  match layout route:
    case LayoutLeaf{_,key} AtLeaf{}:key
    case ClassifiedLayoutLeaf{_,key,_} AtLeaf{}:key
    case LayoutPair{left,_} InLeft{rest}:key(left,rest)
    case LayoutPair{_,right} InRight{rest}:key(right,rest)
    case _ _:""
def valid(layout:Layout,route:Route) -> Bool:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:True{}
    case ClassifiedLayoutLeaf{_,_,_} AtLeaf{}:True{}
    case LayoutPair{left,_} InLeft{rest}:valid(left,rest)
    case LayoutPair{_,right} InRight{rest}:valid(right,rest)
    case _ _:False{}
def empty_column(-S:Data,-P:Type) -> Column.Column<S,P>:
  Column.Leaf{ANode{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}}},[Lifecycle.Stamp{None{},None{}} : Lifecycle.Stamp^3n]}
def empty_columns(~S:Data,layout:Layout) -> columns(~S,layout):
  match layout:
    case EmptyLayout{}:Unit{}
    case LayoutLeaf{P,key}:ColumnSlot{empty_column(S,P)}
    case ClassifiedLayoutLeaf{P,key,_}:ColumnSlot{empty_column(S,P)}
    case LayoutPair{left,right}:Product.Owner{empty_columns(~S,left),empty_columns(~S,right)}
def column_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:Unit
    case ClassifiedLayoutLeaf{_,_,_} AtLeaf{}:Unit
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
    case ClassifiedLayoutLeaf{P,key,_} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,key} InLeft{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case ClassifiedLayoutLeaf{P,key,_} InLeft{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutLeaf{P,key} InRight{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case ClassifiedLayoutLeaf{P,key,_} InRight{_} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ColumnSlot{Column.empty(~S,~Unit)})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:column_joined(~S,payload(left,rest),key(left,rest),columns(~S,right),column_rest(~S,left,rest),r,column_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:column_joined(~S,payload(right,rest),key(right,rest),columns(~S,left),column_rest(~S,right,rest),l,column_take(~S,right,rest,r))
def column_put(~S:Data,layout:Layout,route:Route,rest:column_rest(~S,layout,route),slot:ColumnSlot<S,payload(layout,route),key(layout,route)>) -> columns(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,key} AtLeaf{} _:slot
    case ClassifiedLayoutLeaf{P,key,_} AtLeaf{} _:slot
    case LayoutLeaf{P,key} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{P,key,_} InLeft{_} rest:rest
    case LayoutLeaf{P,key} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{P,key,_} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{column_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,column_put(~S,right,path,inner,slot)}
def resource_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,_} AtLeaf{}:Unit
    case ClassifiedLayoutLeaf{_,_,_} AtLeaf{}:Unit
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
    case ClassifiedLayoutLeaf{P,key,_} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,key} InLeft{_} owner:(owner,ResourceSlot{Unit{}})
    case ClassifiedLayoutLeaf{P,key,_} InLeft{_} owner:(owner,ResourceSlot{Unit{}})
    case LayoutLeaf{P,key} InRight{_} owner:(owner,ResourceSlot{Unit{}})
    case ClassifiedLayoutLeaf{P,key,_} InRight{_} owner:(owner,ResourceSlot{Unit{}})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ResourceSlot{Unit{}})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:resource_joined(~S,payload(left,rest),key(left,rest),resources(~S,right),resource_rest(~S,left,rest),r,resource_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:resource_joined(~S,payload(right,rest),key(right,rest),resources(~S,left),resource_rest(~S,right,rest),l,resource_take(~S,right,rest,r))
def resource_put(~S:Data,layout:Layout,route:Route,rest:resource_rest(~S,layout,route),slot:ResourceSlot<S,payload(layout,route),key(layout,route)>) -> resources(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,key} AtLeaf{} _:slot
    case ClassifiedLayoutLeaf{P,key,_} AtLeaf{} _:slot
    case LayoutLeaf{P,key} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{P,key,_} InLeft{_} rest:rest
    case LayoutLeaf{P,key} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{P,key,_} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{resource_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,resource_put(~S,right,path,inner,slot)}
def checked_owner(-A:Type,-B:Type,same:{A == B : Type},owner:A) -> B:
  %same : _
  owner
def names(layout:Layout) -> List<&2,String>:
  match layout:
    case EmptyLayout{}:[]
    case LayoutLeaf{_,name}:[name]
    case ClassifiedLayoutLeaf{_,name,_}:[name]
    case LayoutPair{left,right}:List.append(&2,String,names(left),names(right))
def contains_name(values:List<&2,String>,+name:String) -> Bool:
  match values:
    case []:False{}
    case current <> rest:Bool.or(String.eq(current,name),contains_name(rest,name))
def unique_names(values:List<&2,String>) -> Bool:
  match values:
    case []:True{}
    case +name <> +rest:Bool.and(Bool.not(contains_name(rest,name)),unique_names(rest))
def unique(layout:Layout) -> Bool:unique_names(names(layout))
def grant_valid(~layout:Layout,~route:Route) -> Bool:
  Bool.and(unique(layout),valid(layout,route))
def subtree(layout:Layout,route:Route) -> Layout:
  match layout route:
    case layout AtLeaf{}:layout
    case LayoutPair{left,_} InLeft{rest}:subtree(left,rest)
    case LayoutPair{_,right} InRight{rest}:subtree(right,rest)
    case _ _:EmptyLayout{}
def subtree_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case _ AtLeaf{}:Unit
    case LayoutPair{left,right} InLeft{rest}:columns(~S,right) & subtree_rest(~S,left,rest)
    case LayoutPair{left,right} InRight{rest}:columns(~S,left) & subtree_rest(~S,right,rest)
    case layout _:columns(~S,layout)
def subtree_joined(-Outer:Type,-Inner:Type,-Selected:Type,outer:Outer,result:Inner & Selected) -> (Outer & Inner) & Selected:
  match result:
    case (inner,selected):((outer,inner),selected)
def subtree_take(~S:Data,layout:Layout,route:Route,owner:columns(~S,layout)) -> subtree_rest(~S,layout,route) & columns(~S,subtree(layout,route)):
  match layout route owner:
    case layout AtLeaf{} owner:(Unit{},owner)
    case EmptyLayout{} InLeft{_} owner:(owner,Unit{})
    case EmptyLayout{} InRight{_} owner:(owner,Unit{})
    case LayoutLeaf{_,_} InLeft{_} owner:(owner,Unit{})
    case ClassifiedLayoutLeaf{_,_,_} InLeft{_} owner:(owner,Unit{})
    case LayoutLeaf{_,_} InRight{_} owner:(owner,Unit{})
    case ClassifiedLayoutLeaf{_,_,_} InRight{_} owner:(owner,Unit{})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:subtree_joined(columns(~S,right),subtree_rest(~S,left,rest),columns(~S,subtree(left,rest)),r,subtree_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:subtree_joined(columns(~S,left),subtree_rest(~S,right,rest),columns(~S,subtree(right,rest)),l,subtree_take(~S,right,rest,r))
def subtree_put(~S:Data,layout:Layout,route:Route,rest:subtree_rest(~S,layout,route),selected:columns(~S,subtree(layout,route))) -> columns(~S,layout):
  match layout route rest:
    case _ AtLeaf{} _:selected
    case EmptyLayout{} InLeft{_} rest:rest
    case EmptyLayout{} InRight{_} rest:rest
    case LayoutLeaf{_,_} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{_,_,_} InLeft{_} rest:rest
    case LayoutLeaf{_,_} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{_,_,_} InRight{_} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{subtree_put(~S,left,path,inner,selected),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,subtree_put(~S,right,path,inner,selected)}
def pair_input(layout:Layout) -> Type:
  match layout:
    case LayoutPair{LayoutLeaf{P,_},LayoutLeaf{_,_}}:P
    case LayoutPair{LayoutLeaf{P,_},ClassifiedLayoutLeaf{_,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{P,_,_},LayoutLeaf{_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{P,_,_},ClassifiedLayoutLeaf{_,_,_}}:P
    case _:Unit
def pair_output(layout:Layout) -> Type:
  match layout:
    case LayoutPair{LayoutLeaf{_,_},LayoutLeaf{P,_}}:P
    case LayoutPair{LayoutLeaf{_,_},ClassifiedLayoutLeaf{P,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{_,_,_},LayoutLeaf{P,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{_,_,_},ClassifiedLayoutLeaf{P,_,_}}:P
    case _:Unit
def pair_leaves(layout:Layout) -> Bool:
  match layout:
    case LayoutPair{LayoutLeaf{_,_},LayoutLeaf{_,_}}:True{}
    case LayoutPair{LayoutLeaf{_,_},ClassifiedLayoutLeaf{_,_,_}}:True{}
    case LayoutPair{ClassifiedLayoutLeaf{_,_,_},LayoutLeaf{_,_}}:True{}
    case LayoutPair{ClassifiedLayoutLeaf{_,_,_},ClassifiedLayoutLeaf{_,_,_}}:True{}
    case _:False{}
def query_input(layout:Layout,route:Route) -> Type:pair_input(subtree(layout,route))
def query_output(layout:Layout,route:Route) -> Type:pair_output(subtree(layout,route))
def query_read_key(layout:Layout,route:Route) -> String:key(subtree(layout,route),InLeft{AtLeaf{}})
def query_write_key(layout:Layout,route:Route) -> String:key(subtree(layout,route),InRight{AtLeaf{}})
def query_pair(~S:Data,~layout:Layout,~route:Route) -> Type:
  Product.Owner<ColumnSlot<S,query_input(layout,route),query_read_key(layout,route)>,ColumnSlot<S,query_output(layout,route),query_write_key(layout,route)>>
def query_valid(~layout:Layout,~route:Route) -> Bool:
  Bool.and(unique(layout),pair_leaves(subtree(layout,route)))
