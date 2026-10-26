import Base
import ./chunk-column.bend as Column
import ./owner-product.bend as Product
import ./lifecycle.bend as Lifecycle
import ./schema-fragments.bend as Fragment

type Viewed<-P:Type,-V:Data> is Type:
  Viewed{owner:P,view:V}
def read(~P:Type,~V:Data,value:Viewed<P,V>) -> Viewed<P,V> & V:
  match value:
    case Viewed{owner,+view}:(Viewed{owner,view},view)
def initialized(-P:Type,-V:Data,result:P & V) -> Viewed<P,V>:
  match result:
    case (owner,view):Viewed{owner,view}

type Layout is Type:
  EmptyLayout{}
  LayoutLeaf{P:Type,V:Data,refresh:P -> P & V,key:String}
  ClassifiedLayoutLeaf{P:Type,V:Data,refresh:P -> P & V,key:String,persistence:Fragment.PersistenceKind}
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
    case LayoutLeaf{P,V,_,key}:ColumnSlot<S,Viewed<P,V>,key>
    case ClassifiedLayoutLeaf{P,V,_,key,_}:ColumnSlot<S,Viewed<P,V>,key>
    case LayoutPair{left,right}:Product.Owner<columns(~S,left),columns(~S,right)>
def resources(~S:Data,layout:Layout) -> Type:
  match layout:
    case EmptyLayout{}:Unit
    case LayoutLeaf{P,V,_,key}:ResourceSlot<S,Viewed<P,V>,key>
    case ClassifiedLayoutLeaf{P,V,_,key,_}:ResourceSlot<S,Viewed<P,V>,key>
    case LayoutPair{left,right}:Product.Owner<resources(~S,left),resources(~S,right)>
def payload(layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{P,V,_,_} AtLeaf{}:P
    case ClassifiedLayoutLeaf{P,V,_,_,_} AtLeaf{}:P
    case LayoutPair{left,_} InLeft{rest}:payload(left,rest)
    case LayoutPair{_,right} InRight{rest}:payload(right,rest)
    case _ _:Unit
def view(layout:Layout,route:Route) -> Data:
  match layout route:
    case LayoutLeaf{_,V,_,_} AtLeaf{}:V
    case ClassifiedLayoutLeaf{_,V,_,_,_} AtLeaf{}:V
    case LayoutPair{left,_} InLeft{rest}:view(left,rest)
    case LayoutPair{_,right} InRight{rest}:view(right,rest)
    case _ _:Unit
def stored(layout:Layout,route:Route) -> Type:Viewed<payload(layout,route),view(layout,route)>
def initialize(layout:Layout,route:Route,owner:payload(layout,route)) -> stored(layout,route):
  match layout route owner:
    case LayoutLeaf{P,V,refresh,_} AtLeaf{} owner:initialized(P,V,refresh(owner))
    case ClassifiedLayoutLeaf{P,V,refresh,_,_} AtLeaf{} owner:initialized(P,V,refresh(owner))
    case LayoutPair{left,_} InLeft{rest} owner:initialize(left,rest,owner)
    case LayoutPair{_,right} InRight{rest} owner:initialize(right,rest,owner)
    case EmptyLayout{} _ owner:Viewed{owner,Unit{}}
    case LayoutLeaf{_,_,_,_} InLeft{_} owner:Viewed{owner,Unit{}}
    case LayoutLeaf{_,_,_,_} InRight{_} owner:Viewed{owner,Unit{}}
    case ClassifiedLayoutLeaf{_,_,_,_,_} InLeft{_} owner:Viewed{owner,Unit{}}
    case ClassifiedLayoutLeaf{_,_,_,_,_} InRight{_} owner:Viewed{owner,Unit{}}
    case LayoutPair{_,_} AtLeaf{} owner:Viewed{owner,Unit{}}
def rewritten(~layout:Layout,~route:Route,-Out:Type,result:payload(layout,route) & Out) -> stored(layout,route) & Out:
  match result:
    case (owner,out):(initialize(layout,route,owner),out)
def rewrite(~layout:Layout,~route:Route,-Out:Type,transform:payload(layout,route) -> payload(layout,route) & Out,value:stored(layout,route)) -> stored(layout,route) & Out:
  match value:
    case Viewed{owner,_}:rewritten(~layout,~route,Out,transform(owner))
def key(layout:Layout,route:Route) -> String:
  match layout route:
    case LayoutLeaf{_,V,_,key} AtLeaf{}:key
    case ClassifiedLayoutLeaf{_,V,_,key,_} AtLeaf{}:key
    case LayoutPair{left,_} InLeft{rest}:key(left,rest)
    case LayoutPair{_,right} InRight{rest}:key(right,rest)
    case _ _:""
def valid(layout:Layout,route:Route) -> Bool:
  match layout route:
    case LayoutLeaf{_,V,_,_} AtLeaf{}:True{}
    case ClassifiedLayoutLeaf{_,V,_,_,_} AtLeaf{}:True{}
    case LayoutPair{left,_} InLeft{rest}:valid(left,rest)
    case LayoutPair{_,right} InRight{rest}:valid(right,rest)
    case _ _:False{}
def empty_column(-S:Data,-P:Type) -> Column.Column<S,P>:
  Column.Leaf{ANode{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}}},[Lifecycle.Stamp{None{},None{}} : Lifecycle.Stamp^3n]}
def empty_columns(~S:Data,layout:Layout) -> columns(~S,layout):
  match layout:
    case EmptyLayout{}:Unit{}
    case LayoutLeaf{P,V,_,key}:ColumnSlot{empty_column(S,Viewed<P,V>)}
    case ClassifiedLayoutLeaf{P,V,_,key,_}:ColumnSlot{empty_column(S,Viewed<P,V>)}
    case LayoutPair{left,right}:Product.Owner{empty_columns(~S,left),empty_columns(~S,right)}
def column_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,V,_,_} AtLeaf{}:Unit
    case ClassifiedLayoutLeaf{_,V,_,_,_} AtLeaf{}:Unit
    case LayoutPair{left,right} InLeft{rest}:columns(~S,right) & column_rest(~S,left,rest)
    case LayoutPair{left,right} InRight{rest}:columns(~S,left) & column_rest(~S,right,rest)
    case layout _:columns(~S,layout)
def column_joined(~S:Data,-P:Type,-key:String,-Outer:Type,-Inner:Type,outer:Outer,result:Inner & ColumnSlot<S,P,key>) -> (Outer & Inner) & ColumnSlot<S,P,key>:
  match result:
    case (inner,slot):((outer,inner),slot)
def column_take(~S:Data,layout:Layout,route:Route,owner:columns(~S,layout)) -> column_rest(~S,layout,route) & ColumnSlot<S,stored(layout,route),key(layout,route)>:
  match layout route owner:
    case EmptyLayout{} _ owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case LayoutLeaf{P,V,_,key} AtLeaf{} owner:(Unit{},owner)
    case ClassifiedLayoutLeaf{P,V,_,key,_} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,V,_,key} InLeft{_} owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case ClassifiedLayoutLeaf{P,V,_,key,_} InLeft{_} owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case LayoutLeaf{P,V,_,key} InRight{_} owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case ClassifiedLayoutLeaf{P,V,_,key,_} InRight{_} owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ColumnSlot{Column.empty(~S,~Viewed<Unit,Unit>)})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:column_joined(~S,stored(left,rest),key(left,rest),columns(~S,right),column_rest(~S,left,rest),r,column_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:column_joined(~S,stored(right,rest),key(right,rest),columns(~S,left),column_rest(~S,right,rest),l,column_take(~S,right,rest,r))
def column_put(~S:Data,layout:Layout,route:Route,rest:column_rest(~S,layout,route),slot:ColumnSlot<S,stored(layout,route),key(layout,route)>) -> columns(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,V,_,key} AtLeaf{} _:slot
    case ClassifiedLayoutLeaf{P,V,_,key,_} AtLeaf{} _:slot
    case LayoutLeaf{P,V,_,key} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{P,V,_,key,_} InLeft{_} rest:rest
    case LayoutLeaf{P,V,_,key} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{P,V,_,key,_} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{column_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,column_put(~S,right,path,inner,slot)}
def resource_rest(~S:Data,layout:Layout,route:Route) -> Type:
  match layout route:
    case LayoutLeaf{_,V,_,_} AtLeaf{}:Unit
    case ClassifiedLayoutLeaf{_,V,_,_,_} AtLeaf{}:Unit
    case LayoutPair{left,right} InLeft{rest}:resources(~S,right) & resource_rest(~S,left,rest)
    case LayoutPair{left,right} InRight{rest}:resources(~S,left) & resource_rest(~S,right,rest)
    case layout _:resources(~S,layout)
def resource_joined(~S:Data,-P:Type,-key:String,-Outer:Type,-Inner:Type,outer:Outer,result:Inner & ResourceSlot<S,P,key>) -> (Outer & Inner) & ResourceSlot<S,P,key>:
  match result:
    case (inner,slot):((outer,inner),slot)
def resource_take(~S:Data,layout:Layout,route:Route,owner:resources(~S,layout)) -> resource_rest(~S,layout,route) & ResourceSlot<S,stored(layout,route),key(layout,route)>:
  match layout route owner:
    case EmptyLayout{} _ owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case LayoutLeaf{P,V,_,key} AtLeaf{} owner:(Unit{},owner)
    case ClassifiedLayoutLeaf{P,V,_,key,_} AtLeaf{} owner:(Unit{},owner)
    case LayoutLeaf{P,V,_,key} InLeft{_} owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case ClassifiedLayoutLeaf{P,V,_,key,_} InLeft{_} owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case LayoutLeaf{P,V,_,key} InRight{_} owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case ClassifiedLayoutLeaf{P,V,_,key,_} InRight{_} owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case LayoutPair{left,right} AtLeaf{} owner:(owner,ResourceSlot{Viewed{Unit{},Unit{}}})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:resource_joined(~S,stored(left,rest),key(left,rest),resources(~S,right),resource_rest(~S,left,rest),r,resource_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:resource_joined(~S,stored(right,rest),key(right,rest),resources(~S,left),resource_rest(~S,right,rest),l,resource_take(~S,right,rest,r))
def resource_put(~S:Data,layout:Layout,route:Route,rest:resource_rest(~S,layout,route),slot:ResourceSlot<S,stored(layout,route),key(layout,route)>) -> resources(~S,layout):
  match layout route rest:
    case EmptyLayout{} _ rest:rest
    case LayoutLeaf{P,V,_,key} AtLeaf{} _:slot
    case ClassifiedLayoutLeaf{P,V,_,key,_} AtLeaf{} _:slot
    case LayoutLeaf{P,V,_,key} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{P,V,_,key,_} InLeft{_} rest:rest
    case LayoutLeaf{P,V,_,key} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{P,V,_,key,_} InRight{_} rest:rest
    case LayoutPair{left,right} AtLeaf{} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{resource_put(~S,left,path,inner,slot),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,resource_put(~S,right,path,inner,slot)}
def checked_owner(-A:Type,-B:Type,same:{A == B : Type},owner:A) -> B:
  %same : _
  owner
def names(layout:Layout) -> List<&2,String>:
  match layout:
    case EmptyLayout{}:[]
    case LayoutLeaf{_,V,_,name}:[name]
    case ClassifiedLayoutLeaf{_,V,_,name,_}:[name]
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
    case LayoutLeaf{_,V,_,_} InLeft{_} owner:(owner,Unit{})
    case ClassifiedLayoutLeaf{_,V,_,_,_} InLeft{_} owner:(owner,Unit{})
    case LayoutLeaf{_,V,_,_} InRight{_} owner:(owner,Unit{})
    case ClassifiedLayoutLeaf{_,V,_,_,_} InRight{_} owner:(owner,Unit{})
    case LayoutPair{left,right} InLeft{rest} Product.Owner{l,r}:subtree_joined(columns(~S,right),subtree_rest(~S,left,rest),columns(~S,subtree(left,rest)),r,subtree_take(~S,left,rest,l))
    case LayoutPair{left,right} InRight{rest} Product.Owner{l,r}:subtree_joined(columns(~S,left),subtree_rest(~S,right,rest),columns(~S,subtree(right,rest)),l,subtree_take(~S,right,rest,r))
def subtree_put(~S:Data,layout:Layout,route:Route,rest:subtree_rest(~S,layout,route),selected:columns(~S,subtree(layout,route))) -> columns(~S,layout):
  match layout route rest:
    case _ AtLeaf{} _:selected
    case EmptyLayout{} InLeft{_} rest:rest
    case EmptyLayout{} InRight{_} rest:rest
    case LayoutLeaf{_,V,_,_} InLeft{_} rest:rest
    case ClassifiedLayoutLeaf{_,V,_,_,_} InLeft{_} rest:rest
    case LayoutLeaf{_,V,_,_} InRight{_} rest:rest
    case ClassifiedLayoutLeaf{_,V,_,_,_} InRight{_} rest:rest
    case LayoutPair{left,right} InLeft{path}, (outer,inner):Product.Owner{subtree_put(~S,left,path,inner,selected),outer}
    case LayoutPair{left,right} InRight{path}, (outer,inner):Product.Owner{outer,subtree_put(~S,right,path,inner,selected)}
def pair_input(layout:Layout) -> Type:
  match layout:
    case LayoutPair{LayoutLeaf{P,V,_,_},LayoutLeaf{_,V,_,_}}:P
    case LayoutPair{LayoutLeaf{P,V,_,_},ClassifiedLayoutLeaf{_,V,_,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{P,V,_,_,_},LayoutLeaf{_,V,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{P,V,_,_,_},ClassifiedLayoutLeaf{_,V,_,_,_}}:P
    case _:Unit
def pair_output(layout:Layout) -> Type:
  match layout:
    case LayoutPair{LayoutLeaf{_,V,_,_},LayoutLeaf{P,V,_,_}}:P
    case LayoutPair{LayoutLeaf{_,V,_,_},ClassifiedLayoutLeaf{P,V,_,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{_,V,_,_,_},LayoutLeaf{P,V,_,_}}:P
    case LayoutPair{ClassifiedLayoutLeaf{_,V,_,_,_},ClassifiedLayoutLeaf{P,V,_,_,_}}:P
    case _:Unit
def pair_leaves(layout:Layout) -> Bool:
  match layout:
    case LayoutPair{LayoutLeaf{_,V,_,_},LayoutLeaf{_,V,_,_}}:True{}
    case LayoutPair{LayoutLeaf{_,V,_,_},ClassifiedLayoutLeaf{_,V,_,_,_}}:True{}
    case LayoutPair{ClassifiedLayoutLeaf{_,V,_,_,_},LayoutLeaf{_,V,_,_}}:True{}
    case LayoutPair{ClassifiedLayoutLeaf{_,V,_,_,_},ClassifiedLayoutLeaf{_,V,_,_,_}}:True{}
    case _:False{}
def query_view(layout:Layout,route:Route) -> Data:view(subtree(layout,route),InLeft{AtLeaf{}})
def query_input(layout:Layout,route:Route) -> Type:payload(subtree(layout,route),InLeft{AtLeaf{}})
def query_output(layout:Layout,route:Route) -> Type:payload(subtree(layout,route),InRight{AtLeaf{}})
def query_read_key(layout:Layout,route:Route) -> String:key(subtree(layout,route),InLeft{AtLeaf{}})
def query_write_key(layout:Layout,route:Route) -> String:key(subtree(layout,route),InRight{AtLeaf{}})
def query_pair(~S:Data,~layout:Layout,~route:Route) -> Type:
  Product.Owner<ColumnSlot<S,stored(subtree(layout,route),InLeft{AtLeaf{}}),query_read_key(layout,route)>,ColumnSlot<S,stored(subtree(layout,route),InRight{AtLeaf{}}),query_write_key(layout,route)>>
def query_valid(~layout:Layout,~route:Route) -> Bool:
  Bool.and(unique(layout),pair_leaves(subtree(layout,route)))

def normalize_resources(~S:Data,layout:Layout,owners:resources(~S,layout)) -> resources(~S,layout):
  match layout owners:
    case EmptyLayout{} owner:owner
    case LayoutLeaf{P,V,refresh,key} ResourceSlot{Viewed{owner,_}}:ResourceSlot{initialized(P,V,refresh(owner))}
    case ClassifiedLayoutLeaf{P,V,refresh,key,_} ResourceSlot{Viewed{owner,_}}:ResourceSlot{initialized(P,V,refresh(owner))}
    case LayoutPair{left,right} Product.Owner{l,r}:Product.Owner{normalize_resources(~S,left,l),normalize_resources(~S,right,r)}
