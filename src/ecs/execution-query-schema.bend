import Base
import ./execution-resource-policy.bend as Policy
import ./execution-composer-layout.bend as L
import ./execution-query-domain.bend as D
import ./execution-query-matches.bend as Q
import ./chunk-partition.bend as Part
import ./chunk-column.bend as Col
import ./owner-product.bend as Product
import ./lifecycle.bend as Life

# A full-layout-indexed framework Book. Ordinary lowering must construct its
# entries from the same closed declaration that provisions H operations.
type Entry is Data:
  Entry{route:L.Route,recipe:Q.Recipe}
type Book<-S:Data,-full:L.Layout> is Data:
  Book{entries:List<&2,Entry>}
def same_route(left:L.Route,right:L.Route) -> Bool:
  match left right:
    case L.AtLeaf{} L.AtLeaf{}:True{}
    case L.InLeft{left} L.InLeft{right}:same_route(left,right)
    case L.InRight{left} L.InRight{right}:same_route(left,right)
    case _ _:False{}
def access_union(left:D.Access,right:D.Access) -> D.Access:
  match left right:
    case D.Access{lr,lw} D.Access{rr,rw}:D.Access{D.union(lr,rr),D.union(lw,rw)}
def access(recipe:Q.Recipe) -> D.Access:
  match recipe:
    case Q.Read{domain}:D.Access{domain,D.Domain{[]}}
    case Q.Write{+domain}:D.Access{domain,domain}
    case Q.Both{left,right}:access_union(access(left),access(right))
def access_entry(recipe:Q.Recipe,next:D.Access,selected:Bool) -> D.Access:
  match selected:
    case False{}:next
    case True{}:access_union(access(recipe),next)
def entry_access(+route:L.Route,entries:List<&2,Entry>) -> D.Access:
  match entries:
    case []:D.Access{D.Domain{[]},D.Domain{[]}}
    case Entry{at,recipe} <> rest:access_entry(recipe,entry_access(route,rest),same_route(route,at))
def family_access(-S:Data,-full:L.Layout,book:Book<S,full>,route:L.Route) -> D.Access:
  match book:
    case Book{entries}:entry_access(route,entries)
def routes_valid(~full:L.Layout,entries:List<&2,Entry>) -> Bool:
  match entries:
    case []:True{}
    case Entry{route,_} <> rest:Bool.and(L.valid(full,route),routes_valid(~full,rest))
def all_recipes_valid(+route:L.Route,+capacity:U32,entries:List<&2,Entry>) -> Bool:
  match entries:
    case []:True{}
    case Entry{at,recipe} <> rest:Bool.and(Bool.or(Bool.not(same_route(route,at)),Q.validate_recipe(capacity,recipe)),all_recipes_valid(route,capacity,rest))

def checked_leaf(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,+route:L.Route,+left:List<&2,Entry>,+right:List<&2,Entry>,result:Col.Column<S,L.Viewed<P,V>> & Part.Inspection) -> L.ColumnSlot<S,L.Viewed<P,V>,key,origin> & Bool:
  match result:
    case (column,Part.Inspection{_,+capacity,valid}):(L.ColumnSlot{column},Bool.and(valid,Bool.and(all_recipes_valid(route,capacity,left),Bool.and(all_recipes_valid(route,capacity,right),Bool.not(D.conflicts(entry_access(route,left),entry_access(route,right)))))))
def checked_pair(-S:Data,-left:L.Layout,-right:L.Layout,l:L.columns(~S,left) & Bool,r:L.columns(~S,right) & Bool) -> L.columns(~S,L.LayoutPair{left,right}) & Bool:
  match l r:
    case (l,lv), (r,rv):(Product.Owner{l,r},Bool.and(lv,rv))
def append_route(prefix:L.Route,+suffix:L.Route) -> L.Route:
  match prefix:
    case L.AtLeaf{}:suffix
    case L.InLeft{rest}:L.InLeft{append_route(rest,suffix)}
    case L.InRight{rest}:L.InRight{append_route(rest,suffix)}
def inspect(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Entry>,+right:List<&2,Entry>,columns:L.columns(~S,layout)) -> L.columns(~S,layout) & Bool:
  match layout columns:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} L.ColumnSlot{column}:checked_leaf(S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy},route,left,right,Part.inspect(S,L.Viewed<P,V>,column))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} L.ColumnSlot{column}:checked_leaf(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy},route,left,right,Part.inspect(S,L.Viewed<P,V>,column))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:checked_pair(S,ll,rr,inspect(~S,ll,append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),inspect(~S,rr,append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))

def cached_cell(-P:Type,-V:Data,+offset:U32,result:Array<Maybe<&1,L.Viewed<P,V>>> & Maybe<&1,L.Viewed<P,V>>) -> Array<Maybe<&1,L.Viewed<P,V>>> & Q.Row<V>:
  match result:
    case (values,None{}):(values,Q.Row{offset,None{}})
    case (values,Some{L.Viewed{owner,+view}}):(Array.set(Maybe<&1,L.Viewed<P,V>>,values,U32.mod(offset,8),Some{L.Viewed{owner,view}}),Q.Row{offset,Some{view}})
def cached_step(-P:Type,-V:Data,rows:List<&2,Q.Row<V>>,result:Array<Maybe<&1,L.Viewed<P,V>>> & Q.Row<V>) -> Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>:
  match result:
    case (values,row):(values,row <> rows)
def cache_leaf(-P:Type,-V:Data,fuel:Nat,+base:U32,+index:U32,result:Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>) -> Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>:
  match fuel result:
    case 0n result:result
    case 1n+rest, (values,rows):cache_leaf(P,V,rest,base,U32.add(index,1),cached_step(P,V,rows,cached_cell(P,V,U32.add(base,index),Array.swap(Maybe<&1,L.Viewed<P,V>>,values,index,None{}))))
def cached_leaf(-S:Data,-P:Type,-V:Data,stamps:Array<Life.Stamp>,result:Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match result:
    case (values,rows):(Col.Leaf{values,stamps},rows)
def cached_pair(-S:Data,-P:Type,-V:Data,half:U32,left:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>,right:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match left right:
    case (l,lr), (r,rr):(Col.Branch{half,l,r},List.append(&2,Q.Row<V>,lr,rr))
def cache_column(-S:Data,-P:Type,-V:Data,column:Col.Column<S,L.Viewed<P,V>>,+base:U32) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match column:
    case Col.Leaf{values,stamps}:cached_leaf(S,P,V,stamps,cache_leaf(P,V,8n,base,0,(values,[])))
    case Col.Branch{+half,l,r}:cached_pair(S,P,V,half,cache_column(S,P,V,l,base),cache_column(S,P,V,r,U32.add(base,half)))
def filtered_row(-V:Data,row:Q.Row<V>,rest:List<&2,Q.Row<V>>,selected:Bool) -> List<&2,Q.Row<V>>:
  match selected:
    case False{}:rest
    case True{}:row <> rest
def filter_rows(-V:Data,+domain:D.Domain,rows:List<&2,Q.Row<V>>) -> List<&2,Q.Row<V>>:
  match rows:
    case []:[]
    case Q.Row{+offset,+view} <> rest:filtered_row(V,Q.Row{offset,view},filter_rows(V,domain,rest),D.contains(domain,offset))

type Family<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Family{physical:Part.Cut<S,L.Viewed<P,V>>,leftCache:Q.ReadCache<S,V,origin>,rightCache:Q.ReadCache<S,V,origin>}
def families(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy}:Family<S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}:Family<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>
    case L.LayoutPair{left,right}:Product.Owner<families(~S,left),families(~S,right)>
def cut_cached(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,left:D.Access,right:D.Access,result:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>) -> Family<S,P,V,key,origin>:
  match left right result:
    case D.Access{lr,lw} D.Access{rr,rw}, (column,+rows):Family{Part.cut(S,L.Viewed<P,V>,column,lw,rw),Q.ReadCache{filter_rows(V,lr,rows)},Q.ReadCache{filter_rows(V,rr,rows)}}
def cut_tree(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Entry>,+right:List<&2,Entry>,columns:L.columns(~S,layout)) -> families(~S,layout):
  match layout columns:
    case L.EmptyLayout{} Unit{}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} L.ColumnSlot{column}:cut_cached(S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy},entry_access(route,left),entry_access(route,right),cache_column(S,P,V,column,0))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} L.ColumnSlot{column}:cut_cached(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy},entry_access(route,left),entry_access(route,right),cache_column(S,P,V,column,0))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:Product.Owner{cut_tree(~S,ll,append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),cut_tree(~S,rr,append_route(route,L.InRight{L.AtLeaf{}}),left,right,r)}
type Partition<-S:Data,-full:L.Layout> is Type:
  Refused{columns:L.columns(~S,full)}
  PartitionedInventory{families:families(~S,full)}
def cut_checked(~S:Data,~full:L.Layout,left:List<&2,Entry>,right:List<&2,Entry>,columns:L.columns(~S,full),valid:Bool) -> Partition<S,full>:
  match valid:
    case False{}:Refused{columns}
    case True{}:PartitionedInventory{cut_tree(~S,full,L.AtLeaf{},left,right,columns)}
def cut_inspected(~S:Data,~full:L.Layout,+left:List<&2,Entry>,+right:List<&2,Entry>,result:L.columns(~S,full) & Bool) -> Partition<S,full>:
  match result:
    case (columns,valid):cut_checked(~S,~full,left,right,columns,Bool.and(valid,Bool.and(routes_valid(~full,left),routes_valid(~full,right))))
def cut(~S:Data,~full:L.Layout,left:Book<S,full>,right:Book<S,full>,columns:L.columns(~S,full)) -> Partition<S,full>:
  match left right:
    case Book{+left} Book{+right}:cut_inspected(~S,~full,left,right,inspect(~S,full,L.AtLeaf{},left,right,columns))

type Recovery<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Recovered{column:L.ColumnSlot<S,L.Viewed<P,V>,key,origin>,displaced:List<&1,Part.Cell<L.Viewed<P,V>>>}
  Unrecovered{inventory:Part.Joined<S,L.Viewed<P,V>>}
def recoveries(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy}:Recovery<S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}:Recovery<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>
    case L.LayoutPair{left,right}:Product.Owner<recoveries(~S,left),recoveries(~S,right)>
def displacements(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,_,_,_}:List<&1,Part.Cell<L.Viewed<P,V>>>
    case L.ClassifiedLayoutLeaf{P,V,_,_,_,_}:List<&1,Part.Cell<L.Viewed<P,V>>>
    case L.LayoutPair{left,right}:Product.Owner<displacements(~S,left),displacements(~S,right)>
def recovered(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,result:Part.Joined<S,L.Viewed<P,V>>) -> Recovery<S,P,V,key,origin>:
  match result:
    case Part.Joined{column,displaced}:Recovered{L.ColumnSlot{column},displaced}
    case result:Unrecovered{result}
def restore_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,family:Family<S,P,V,key,origin>) -> Recovery<S,P,V,key,origin>:
  match family:
    case Family{Part.Refused{column,_},_,_}:Recovered{L.ColumnSlot{column},[]}
    case Family{Part.Split{column,left,right,join},_,_}:recovered(S,P,V,key,origin,Part.join(S,L.Viewed<P,V>,join,column,left,right))
def restore_tree(~S:Data,layout:L.Layout,tree:families(~S,layout)) -> recoveries(~S,layout):
  match layout tree:
    case L.EmptyLayout{} Unit{}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} family:restore_family(S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy},family)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} family:restore_family(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy},family)
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:Product.Owner{restore_tree(~S,ll,l),restore_tree(~S,rr,r)}
type Assembly<-S:Data,-full:L.Layout> is Type:
  Assembled{columns:L.columns(~S,full),displaced:displacements(~S,full)}
  AssemblyRefused{inventory:recoveries(~S,full)}
type Staged<-S:Data,-full:L.Layout> is Type:
  Staged{columns:L.columns(~S,full),displaced:displacements(~S,full),pack:L.columns(~S,full) -> displacements(~S,full) -> recoveries(~S,full)}
  StagingRefused{inventory:recoveries(~S,full)}
def pack_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,lp:L.columns(~S,ll) -> displacements(~S,ll) -> recoveries(~S,ll),rp:L.columns(~S,rr) -> displacements(~S,rr) -> recoveries(~S,rr),columns:L.columns(~S,L.LayoutPair{ll,rr}),displaced:displacements(~S,L.LayoutPair{ll,rr})) -> recoveries(~S,L.LayoutPair{ll,rr}):
  match columns displaced:
    case Product.Owner{l,r} Product.Owner{ld,rd}:Product.Owner{lp(l,ld),rp(r,rd)}
def assembled_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Staged<S,ll>,right:Staged<S,rr>) -> Staged<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Staged{l,ld,lp} Staged{r,rd,rp}:Staged{Product.Owner{l,r},Product.Owner{ld,rd},(columns => displaced => pack_pair(~S,ll,rr,lp,rp,columns,displaced))}
    case Staged{l,ld,lp} StagingRefused{r}:StagingRefused{Product.Owner{lp(l,ld),r}}
    case StagingRefused{l} Staged{r,rd,rp}:StagingRefused{Product.Owner{l,rp(r,rd)}}
    case StagingRefused{l} StagingRefused{r}:StagingRefused{Product.Owner{l,r}}
def assemble(~S:Data,layout:L.Layout,tree:recoveries(~S,layout)) -> Staged<S,layout>:
  match layout tree:
    case L.EmptyLayout{} Unit{}:Staged{Unit{},Unit{},(columns => displaced => Unit{})}
    case L.LayoutLeaf{_,_,_,_,_} Recovered{column,displaced}:Staged{column,displaced,(column => displaced => Recovered{column,displaced})}
    case L.LayoutLeaf{_,_,_,_,_} tree:StagingRefused{tree}
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} Recovered{column,displaced}:Staged{column,displaced,(column => displaced => Recovered{column,displaced})}
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} tree:StagingRefused{tree}
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:assembled_pair(~S,ll,rr,assemble(~S,ll,l),assemble(~S,rr,r))
def finish(~S:Data,-full:L.Layout,result:Staged<S,full>) -> Assembly<S,full>:
  match result:
    case Staged{columns,displaced,_}:Assembled{columns,displaced}
    case StagingRefused{tree}:AssemblyRefused{tree}
def empty_displacements(~S:Data,layout:L.Layout) -> displacements(~S,layout):
  match layout:
    case L.EmptyLayout{}:Unit{}
    case L.LayoutLeaf{_,_,_,_,_}:[]
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_}:[]
    case L.LayoutPair{left,right}:Product.Owner{empty_displacements(~S,left),empty_displacements(~S,right)}
def rejoin(~S:Data,~full:L.Layout,partition:Partition<S,full>) -> Assembly<S,full>:
  match partition:
    case Refused{columns}:Assembled{columns,empty_displacements(~S,full)}
    case PartitionedInventory{tree}:finish(~S,full,assemble(~S,full,restore_tree(~S,full,tree)))

type Info is Data:
  Info{route:L.Route,capacity:U32,present:D.Domain}
type Description<-S:Data,-full:L.Layout> is Type:
  Description{columns:L.columns(~S,full),info:List<&2,Info>,valid:Bool}
def present_offsets(-V:Data,rows:List<&2,Q.Row<V>>) -> List<&2,U32>:
  match rows:
    case []:[]
    case Q.Row{_,None{}} <> rest:present_offsets(V,rest)
    case Q.Row{offset,Some{_}} <> rest:offset <> present_offsets(V,rest)
def described_cache(-S:Data,-P:Type,-V:Data,route:L.Route,capacity:U32,result:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  match result:
    case (column,rows):(column,(Info{route,capacity,D.Domain{present_offsets(V,rows)}},True{}))
def described_inspection(-S:Data,-P:Type,-V:Data,route:L.Route,result:Col.Column<S,L.Viewed<P,V>> & Part.Inspection) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  match result:
    case (column,Part.Inspection{_,capacity,False{}}):(column,(Info{route,capacity,D.Domain{[]}},False{}))
    case (column,Part.Inspection{_,capacity,True{}}):described_cache(S,P,V,route,capacity,cache_column(S,P,V,column,0))
def describe_leaf(-S:Data,-P:Type,-V:Data,route:L.Route,column:Col.Column<S,L.Viewed<P,V>>) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  described_inspection(S,P,V,route,Part.inspect(S,L.Viewed<P,V>,column))
def leaf_description(-S:Data,-P:Type,-V:Data,-Out:Type,make:Col.Column<S,L.Viewed<P,V>> -> Info -> Bool -> Out,result:Col.Column<S,L.Viewed<P,V>> & (Info & Bool)) -> Out:
  match result:
    case (column,(info,valid)):make(column,info,valid)
def described_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Description<S,ll>,right:Description<S,rr>) -> Description<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Description{l,li,lv} Description{r,ri,rv}:Description{Product.Owner{l,r},List.append(&2,Info,li,ri),Bool.and(lv,rv)}
def describe(~S:Data,layout:L.Layout,+route:L.Route,columns:L.columns(~S,layout)) -> Description<S,layout>:
  match layout columns:
    case L.EmptyLayout{} Unit{}:Description{Unit{},[],True{}}
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} L.ColumnSlot{column}:leaf_description(S,P,V,Description<S,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>,(column => info => valid => Description{L.ColumnSlot{column},[info],valid}),describe_leaf(S,P,V,route,column))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} L.ColumnSlot{column}:leaf_description(S,P,V,Description<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>,(column => info => valid => Description{L.ColumnSlot{column},[info],valid}),describe_leaf(S,P,V,route,column))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:described_pair(~S,ll,rr,describe(~S,ll,append_route(route,L.InLeft{L.AtLeaf{}}),l),describe(~S,rr,append_route(route,L.InRight{L.AtLeaf{}}),r))
