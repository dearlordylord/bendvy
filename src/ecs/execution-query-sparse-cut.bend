import ./execution-resource-policy.bend as Policy
import ./schema-fragments.bend as Fragment
import Base
import ./execution-composer-layout.bend as L
import ./execution-query-store.bend as Store
import ./execution-query-slice.bend as Slice
import ./execution-query-matches.bend as Match
import ./execution-query-domain.bend as D
import ./execution-query-schema.bend as Schema
import ./chunk-partition.bend as Part
import ./owner-product.bend as Product

# Parent writes are actual sparse owners; this partition never constructs a full column.
type Memo<-S:Data,-P:Type,-V:Data,-origin:L.Layout> is Type:
  Memo{left:D.Domain,right:D.Domain,parent:D.Domain,reads:Match.ReadCache<S,V,origin>}
def memos(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,policy}:Memo<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}:Memo<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}>
    case L.LayoutPair{left,right}:Product.Owner<memos(~S,left),memos(~S,right)>
def row_offsets(-V:Data,rows:List<&2,Match.Row<V>>) -> List<&2,U32>:
  match rows:
    case []:[]
    case Match.Row{offset,_} <> rest:offset <> row_offsets(V,rest)
def read_cache_valid(-S:Data,-V:Data,-origin:L.Layout,+expected:D.Domain,cache:Match.ReadCache<S,V,origin>) -> Bool:
  match cache:
    case Match.ReadCache{rows}:Part.subset(expected,D.Domain{row_offsets(V,rows)})
def checked_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+reads:Match.ReadCache<S,V,origin>,expected:D.Domain,compatible:Bool,result:Part.CheckedSlice<S,L.Viewed<P,V>>) -> Store.Slot<S,P,V,origin> & Bool:
  match result:
    case Part.CheckedSlice{slice,valid}:(Store.Slot{Slice.Slot{slice},reads},Bool.and(compatible,Bool.and(valid,read_cache_valid(S,V,origin,expected,reads))))
def inspect_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:D.Access,right:D.Access,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  match left right slot:
    case D.Access{+lr,+lw} D.Access{+rr,+rw} Store.Slot{Slice.Slot{slice},reads}:checked_slot(S,P,V,origin,reads,D.union(lr,rr),Bool.not(D.conflicts(D.Access{lr,lw},D.Access{rr,rw})),Part.check_slice(S,L.Viewed<P,V>,4294967295,D.union(lw,rw),slice))
def inspect_rest_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:D.Access,right:D.Access,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  match left right slot:
    case D.Access{+lr,+lw} D.Access{+rr,+rw} Store.Slot{Slice.Slot{slice},reads}:checked_slot(S,P,V,origin,reads,D.union(lr,rr),Bool.not(D.intersects(lw,rw)),Part.check_slice(S,L.Viewed<P,V>,4294967295,D.union(lw,rw),slice))
def inspected_pair(-Left:Type,-Right:Type,left:Left & Bool,right:Right & Bool) -> Product.Owner<Left,Right> & Bool:
  match left right:
    case (left,lv), (right,rv):(Product.Owner{left,right},Bool.and(lv,rv))
def inspect(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Schema.Entry>,+right:List<&2,Schema.Entry>,owner:Store.stores(~S,layout)) -> Store.stores(~S,layout) & Bool:
  match layout owner:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:inspect_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:inspect_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot)
    case L.LayoutPair{ll,rr} Product.Owner{leftOwner,rightOwner}:inspected_pair(Store.stores(~S,ll),Store.stores(~S,rr),inspect(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,leftOwner),inspect(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,rightOwner))
def inspect_rest(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Schema.Entry>,+right:List<&2,Schema.Entry>,owner:Store.stores(~S,layout)) -> Store.stores(~S,layout) & Bool:
  match layout owner:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:inspect_rest_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:inspect_rest_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot)
    case L.LayoutPair{ll,rr} Product.Owner{leftOwner,rightOwner}:inspected_pair(Store.stores(~S,ll),Store.stores(~S,rr),inspect_rest(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,leftOwner),inspect_rest(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,rightOwner))
def distribute_cons(-C:Type,cell:Part.Cell<C>,left:Bool,result:List<&1,Part.Cell<C>> & List<&1,Part.Cell<C>>) -> List<&1,Part.Cell<C>> & List<&1,Part.Cell<C>>:
  match left result:
    case True{}, (ls,rs):(cell <> ls,rs)
    case False{}, (ls,rs):(ls,cell <> rs)
def distribute(-C:Type,+left:D.Domain,cells:List<&1,Part.Cell<C>>) -> List<&1,Part.Cell<C>> & List<&1,Part.Cell<C>>:
  match cells:
    case []:([],[])
    case Part.Cell{+offset,value,stamp} <> rest:distribute_cons(C,Part.Cell{offset,value,stamp},D.contains(left,offset),distribute(C,left,rest))
def filtered_row(-V:Data,row:Match.Row<V>,selected:Bool,rest:List<&2,Match.Row<V>>) -> List<&2,Match.Row<V>>:
  match selected:
    case True{}:row <> rest
    case False{}:rest
def filter_rows(-V:Data,+domain:D.Domain,rows:List<&2,Match.Row<V>>) -> List<&2,Match.Row<V>>:
  match rows:
    case []:[]
    case Match.Row{+offset,view} <> rest:filtered_row(V,Match.Row{offset,view},D.contains(domain,offset),filter_rows(V,domain,rest))
type Pieces<-S:Data,-layout:L.Layout> is Type:
  Pieces{left:Store.stores(~S,layout),right:Store.stores(~S,layout),memo:memos(~S,layout)}
def divided_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+lr:D.Domain,+lw:D.Domain,+rr:D.Domain,+rw:D.Domain,parent:D.Domain,+reads:Match.ReadCache<S,V,origin>,result:List<&1,Part.Cell<L.Viewed<P,V>>> & List<&1,Part.Cell<L.Viewed<P,V>>>) -> Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<S,P,V,origin>):
  match reads result:
    case Match.ReadCache{+rows}, (ls,rs):(Store.Slot{Slice.Slot{Part.Slice{lw,ls}},Match.ReadCache{filter_rows(V,lr,rows)}},(Store.Slot{Slice.Slot{Part.Slice{rw,rs}},Match.ReadCache{filter_rows(V,rr,rows)}},Memo{lw,rw,parent,Match.ReadCache{rows}}))
def divide_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:D.Access,right:D.Access,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<S,P,V,origin>):
  match left right slot:
    case D.Access{lr,+lw} D.Access{rr,rw} Store.Slot{Slice.Slot{Part.Slice{parent,cells}},reads}:divided_slot(S,P,V,origin,lr,lw,rr,rw,parent,reads,distribute(L.Viewed<P,V>,lw,cells))
def paired_pieces(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Pieces<S,ll>,right:Pieces<S,rr>) -> Pieces<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Pieces{ll,lr,lm} Pieces{rl,rr,rm}:Pieces{Product.Owner{ll,rl},Product.Owner{lr,rr},Product.Owner{lm,rm}}
def family_0(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-policy:Policy.Policy,result:Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & (Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & Memo<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}>)) -> Pieces<S,L.LayoutLeaf{P,V,refresh,key,policy}>:
  match result:
    case (left,(right,memo)):Pieces{left,right,memo}
def family_1(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,-policy:Policy.Policy,result:Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & (Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Memo<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}>)) -> Pieces<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}>:
  match result:
    case (left,(right,memo)):Pieces{left,right,memo}
def divide(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Schema.Entry>,+right:List<&2,Schema.Entry>,owner:Store.stores(~S,layout)) -> Pieces<S,layout>:
  match layout owner:
    case L.EmptyLayout{} Unit{}:Pieces{Unit{},Unit{},Unit{}}
    case L.LayoutLeaf{P,V,refresh,key,policy} slot:family_0(S,P,V,refresh,key,policy,divide_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} slot:family_1(S,P,V,refresh,key,kind,policy,divide_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},Schema.entry_access(route,left),Schema.entry_access(route,right),slot))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:paired_pieces(~S,ll,rr,divide(~S,ll,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),divide(~S,rr,Schema.append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))
def checked_child(-S:Data,-P:Type,-V:Data,-origin:L.Layout,reads:Match.ReadCache<S,V,origin>,result:Part.CheckedSlice<S,L.Viewed<P,V>>) -> Store.Slot<S,P,V,origin> & Bool:
  match result:
    case Part.CheckedSlice{slice,valid}:(Store.Slot{Slice.Slot{slice},reads},valid)
def inspect_child(-S:Data,-P:Type,-V:Data,-origin:L.Layout,expected:D.Domain,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  match slot:
    case Store.Slot{Slice.Slot{slice},reads}:checked_child(S,P,V,origin,reads,Part.check_slice(S,L.Viewed<P,V>,4294967295,expected,slice))
def inspected_children(-S:Data,-P:Type,-V:Data,-origin:L.Layout,memo:Memo<S,P,V,origin>,left:Store.Slot<S,P,V,origin> & Bool,right:Store.Slot<S,P,V,origin> & Bool) -> (Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<S,P,V,origin>)) & Bool:
  match left right:
    case (left,lv), (right,rv):((left,(right,memo)),Bool.and(lv,rv))
def inspect_children(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,memo:Memo<S,P,V,origin>) -> (Store.Slot<S,P,V,origin> & (Store.Slot<S,P,V,origin> & Memo<S,P,V,origin>)) & Bool:
  match memo:
    case Memo{+ld,+rd,parent,reads}:inspected_children(S,P,V,origin,Memo{ld,rd,parent,reads},inspect_child(S,P,V,origin,ld,left),inspect_child(S,P,V,origin,rd,right))
def cache_step(-S:Data,-P:Type,-V:Data,-origin:L.Layout,index:U32,next:Slice.Slot<S,L.Viewed<P,V>,origin> -> List<&2,Match.Row<V>> -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>,rows:List<&2,Match.Row<V>>,result:Slice.Slot<S,L.Viewed<P,V>,origin> & Maybe<&2,V>) -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>:
  match result:
    case (slot,view):next(slot,Match.Row{index,view} <> rows)
def cache_selected(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+index:U32,view:Maybe<&2,V>,rows:List<&2,Match.Row<V>>,slot:Slice.Slot<S,L.Viewed<P,V>,origin>,next:Slice.Slot<S,L.Viewed<P,V>,origin> -> List<&2,Match.Row<V>> -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>,selected:Bool) -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>:
  match selected:
    case False{}:next(slot,Match.Row{index,view} <> rows)
    case True{}:cache_step(S,P,V,origin,index,next,rows,Slice.read(S,P,V,origin,slot,index))
def cache_choice(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+index:U32,view:Maybe<&2,V>,rows:List<&2,Match.Row<V>>,slot:Slice.Slot<S,L.Viewed<P,V>,origin>,next:Slice.Slot<S,L.Viewed<P,V>,origin> -> List<&2,Match.Row<V>> -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>) -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>:
  match slot:
    case Slice.Slot{Part.Slice{+domain,cells}}:cache_selected(S,P,V,origin,index,view,rows,Slice.Slot{Part.Slice{domain,cells}},next,D.contains(domain,index))
def cache_rows(-S:Data,-P:Type,-V:Data,-origin:L.Layout,remaining:List<&2,Match.Row<V>>,slot:Slice.Slot<S,L.Viewed<P,V>,origin>,rows:List<&2,Match.Row<V>>) -> Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>:
  match remaining:
    case []:(slot,rows)
    case Match.Row{index,view} <> rest:cache_choice(S,P,V,origin,index,view,rows,slot,(slot => rows => cache_rows(S,P,V,origin,rest,slot,rows)))
def cache_refreshed(-S:Data,-P:Type,-V:Data,-origin:L.Layout,result:Slice.Slot<S,L.Viewed<P,V>,origin> & List<&2,Match.Row<V>>) -> Store.Slot<S,P,V,origin>:
  match result:
    case (slot,rows):Store.Slot{slot,Match.ReadCache{List.reverse(&2,Match.Row<V>,rows)}}
def merged_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,memo:Memo<S,P,V,origin>) -> Store.Slot<S,P,V,origin>:
  match left right memo:
    case Store.Slot{Slice.Slot{Part.Slice{_,ls}},_} Store.Slot{Slice.Slot{Part.Slice{_,rs}},_} Memo{_,_,parent,Match.ReadCache{rows}}:cache_refreshed(S,P,V,origin,cache_rows(S,P,V,origin,rows,Slice.Slot{Part.Slice{parent,Part.append(L.Viewed<P,V>,ls,rs)}},[]))
def checked_family_0(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-policy:Policy.Policy,result:(Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & (Store.Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}> & Memo<S,P,V,L.LayoutLeaf{P,V,refresh,key,policy}>)) & Bool) -> Pieces<S,L.LayoutLeaf{P,V,refresh,key,policy}> & Bool:
  match result:
    case ((left,(right,memo)),valid):(Pieces{left,right,memo},valid)
def checked_family_1(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,-policy:Policy.Policy,result:(Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & (Store.Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Memo<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}>)) & Bool) -> Pieces<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy}> & Bool:
  match result:
    case ((left,(right,memo)),valid):(Pieces{left,right,memo},valid)
def inspected_pieces(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Pieces<S,ll> & Bool,right:Pieces<S,rr> & Bool) -> Pieces<S,L.LayoutPair{ll,rr}> & Bool:
  match left right:
    case (left,lv), (right,rv):(paired_pieces(~S,ll,rr,left,right),Bool.and(lv,rv))
def inspect_join(~S:Data,layout:L.Layout,left:Store.stores(~S,layout),right:Store.stores(~S,layout),memo:memos(~S,layout)) -> Pieces<S,layout> & Bool:
  match layout left right memo:
    case L.EmptyLayout{} Unit{} Unit{} Unit{}:(Pieces{Unit{},Unit{},Unit{}},True{})
    case L.LayoutLeaf{P,V,refresh,key,policy} left right memo:checked_family_0(S,P,V,refresh,key,policy,inspect_children(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},left,right,memo))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} left right memo:checked_family_1(S,P,V,refresh,key,kind,policy,inspect_children(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},left,right,memo))
    case L.LayoutPair{ll,rr} Product.Owner{l1,r1} Product.Owner{l2,r2} Product.Owner{lm,rm}:inspected_pieces(~S,ll,rr,inspect_join(~S,ll,l1,l2,lm),inspect_join(~S,rr,r1,r2,rm))
def merge(~S:Data,layout:L.Layout,pieces:Pieces<S,layout>) -> Store.stores(~S,layout):
  match layout pieces:
    case L.EmptyLayout{} Pieces{Unit{},Unit{},Unit{}}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key,policy} Pieces{left,right,memo}:merged_slot(S,P,V,L.LayoutLeaf{P,V,refresh,key,policy},left,right,memo)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy} Pieces{left,right,memo}:merged_slot(S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,policy},left,right,memo)
    case L.LayoutPair{ll,rr} Pieces{Product.Owner{l1,r1},Product.Owner{l2,r2},Product.Owner{lm,rm}}:Product.Owner{merge(~S,ll,Pieces{l1,l2,lm}),merge(~S,rr,Pieces{r1,r2,rm})}
