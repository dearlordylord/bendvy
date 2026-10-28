import Base
import ./execution-reservation-task.bend as Task
import ./world.bend as W
import ./chunk-query.bend as Row
import ./lifecycle.bend as Life
import ./execution-resource-policy.bend as Policy
import ./execution-query-schema.bend as Schema
import ./execution-query-slice.bend as Slice
import ./execution-query-matches.bend as Q
import ./chunk-partition.bend as Part
import ./chunk-column.bend as Col
import ./execution-composer-layout.bend as L
import ./owner-product.bend as Product
import ./schema-fragments.bend as Fragment
import ./execution-query-domain.bend as D
import ./change-tick.bend as Tick
import ./execution-query-admission.bend as Admission

type Slot<-S:Data,-P:Type,-V:Data,-origin:L.Layout> is Type:
  Slot{writes:Slice.Slot<S,L.Viewed<P,V>,origin>,reads:Q.ReadCache<S,V,origin>}
type Rest<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Rest{column:Col.Column<S,L.Viewed<P,V>>,join:Part.JoinOwner<S,L.Viewed<P,V>>}
def stores(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy}:Slot<S,P,V,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}:Slot<S,P,V,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>
    case L.LayoutPair{left,right}:Product.Owner<stores(~S,left),stores(~S,right)>
def retained(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy}:Rest<S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}:Rest<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>
    case L.LayoutPair{left,right}:Product.Owner<retained(~S,left),retained(~S,right)>
type Separation<-S:Data,-full:L.Layout> is Type:
  Separated{left:stores(~S,full),right:stores(~S,full),rest:retained(~S,full),repack:stores(~S,full) -> stores(~S,full) -> retained(~S,full) -> Schema.families(~S,full)}
  SeparationRefused{inventory:Schema.families(~S,full)}
def family_repack(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,left:Slot<S,P,V,origin>,right:Slot<S,P,V,origin>,rest:Rest<S,P,V,key,origin>) -> Schema.Family<S,P,V,key,origin>:
  match left right rest:
    case Slot{Slice.Slot{left},lc} Slot{Slice.Slot{right},rc} Rest{column,join}:Schema.Family{Part.Split{column,left,right,join},lc,rc}
def separate_plain(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-accessPolicy:Policy.Policy,family:Schema.Family<S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>) -> Separation<S,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>:
  match family:
    case Schema.Family{Part.Split{column,left,right,join},lc,rc}:Separated{Slot{Slice.Slot{left},lc},Slot{Slice.Slot{right},rc},Rest{column,join},(left => right => rest => family_repack(S,P,V,key,L.LayoutLeaf{P,V,refresh,key,accessPolicy},left,right,rest))}
    case family:SeparationRefused{family}
def separate_classified(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,-accessPolicy:Policy.Policy,family:Schema.Family<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>) -> Separation<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>:
  match family:
    case Schema.Family{Part.Split{column,left,right,join},lc,rc}:Separated{Slot{Slice.Slot{left},lc},Slot{Slice.Slot{right},rc},Rest{column,join},(left => right => rest => family_repack(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy},left,right,rest))}
    case family:SeparationRefused{family}

def pair_repack(~S:Data,-ll:L.Layout,-rr:L.Layout,lp:stores(~S,ll) -> stores(~S,ll) -> retained(~S,ll) -> Schema.families(~S,ll),rp:stores(~S,rr) -> stores(~S,rr) -> retained(~S,rr) -> Schema.families(~S,rr),left:stores(~S,L.LayoutPair{ll,rr}),right:stores(~S,L.LayoutPair{ll,rr}),rest:retained(~S,L.LayoutPair{ll,rr})) -> Schema.families(~S,L.LayoutPair{ll,rr}):
  match left right rest:
    case Product.Owner{ll,lr} Product.Owner{rl,rr} Product.Owner{sl,sr}:Product.Owner{lp(ll,rl,sl),rp(lr,rr,sr)}
def separated_pair(~S:Data,-leftLayout:L.Layout,-rightLayout:L.Layout,left:Separation<S,leftLayout>,right:Separation<S,rightLayout>) -> Separation<S,L.LayoutPair{leftLayout,rightLayout}>:
  match left right:
    case Separated{ll,lr,ls,lp} Separated{rl,rr,rs,rp}:Separated{Product.Owner{ll,rl},Product.Owner{lr,rr},Product.Owner{ls,rs},(left => right => rest => pair_repack(~S,leftLayout,rightLayout,lp,rp,left,right,rest))}
    case Separated{ll,lr,ls,lp} SeparationRefused{right}:SeparationRefused{Product.Owner{lp(ll,lr,ls),right}}
    case SeparationRefused{left} Separated{rl,rr,rs,rp}:SeparationRefused{Product.Owner{left,rp(rl,rr,rs)}}
    case SeparationRefused{left} SeparationRefused{right}:SeparationRefused{Product.Owner{left,right}}
def separate(~S:Data,layout:L.Layout,tree:Schema.families(~S,layout)) -> Separation<S,layout>:
  match layout tree:
    case L.EmptyLayout{} Unit{}:Separated{Unit{},Unit{},Unit{},(left => right => rest => Unit{})}
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} family:separate_plain(S,P,V,refresh,key,accessPolicy,family)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} family:separate_classified(S,P,V,refresh,key,kind,accessPolicy,family)
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:separated_pair(~S,ll,rr,separate(~S,ll,l),separate(~S,rr,r))
def reunite(~S:Data,~full:L.Layout,left:stores(~S,full),right:stores(~S,full),rest:retained(~S,full),repack:stores(~S,full) -> stores(~S,full) -> retained(~S,full) -> Schema.families(~S,full)) -> Schema.Assembly<S,full>:
  Schema.rejoin(~S,~full,Schema.PartitionedInventory{repack(left,right,rest)})

def route_rest(~S:Data,layout:L.Layout,route:L.Route) -> Type:
  match layout route:
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{}:Unit
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{}:Unit
    case L.LayoutPair{left,right} L.InLeft{rest}:stores(~S,right) & route_rest(~S,left,rest)
    case L.LayoutPair{left,right} L.InRight{rest}:stores(~S,left) & route_rest(~S,right,rest)
    case layout _:stores(~S,layout)
def route_joined(-Outer:Type,-Inner:Type,-Selected:Type,outer:Outer,result:Inner & Selected) -> (Outer & Inner) & Selected:
  match result:
    case (inner,slot):((outer,inner),slot)
def empty_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout) -> Slot<S,P,V,origin>:
  Slot{Slice.Slot{Part.Slice{D.Domain{[]},[]}},Q.ReadCache{[]}}
def take(~S:Data,layout:L.Layout,route:L.Route,owner:stores(~S,layout)) -> route_rest(~S,layout,route) & Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>:
  match layout route owner:
    case L.EmptyLayout{} _ owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{} owner:(Unit{},owner)
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{} owner:(Unit{},owner)
    case L.LayoutLeaf{_,_,_,_,_} L.InLeft{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutLeaf{_,_,_,_,_} L.InRight{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InLeft{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InRight{_} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutPair{_,_} L.AtLeaf{} owner:(owner,empty_slot(S,Unit,Unit,L.EmptyLayout{}))
    case L.LayoutPair{left,right} L.InLeft{rest} Product.Owner{l,r}:route_joined(stores(~S,right),route_rest(~S,left,rest),Slot<S,L.payload(left,rest),L.view(left,rest),L.origin(left,rest)>,r,take(~S,left,rest,l))
    case L.LayoutPair{left,right} L.InRight{rest} Product.Owner{l,r}:route_joined(stores(~S,left),route_rest(~S,right,rest),Slot<S,L.payload(right,rest),L.view(right,rest),L.origin(right,rest)>,l,take(~S,right,rest,r))
def put(~S:Data,layout:L.Layout,route:L.Route,rest:route_rest(~S,layout,route),slot:Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>) -> stores(~S,layout):
  match layout route rest:
    case L.EmptyLayout{} _ rest:rest
    case L.LayoutLeaf{_,_,_,_,_} L.AtLeaf{} _:slot
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.AtLeaf{} _:slot
    case L.LayoutLeaf{_,_,_,_,_} L.InLeft{_} rest:rest
    case L.LayoutLeaf{_,_,_,_,_} L.InRight{_} rest:rest
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InLeft{_} rest:rest
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_} L.InRight{_} rest:rest
    case L.LayoutPair{_,_} L.AtLeaf{} rest:rest
    case L.LayoutPair{left,right} L.InLeft{path}, (outer,inner):Product.Owner{put(~S,left,path,inner,slot),outer}
    case L.LayoutPair{left,right} L.InRight{path}, (outer,inner):Product.Owner{outer,put(~S,right,path,inner,slot)}

type Lookup<-V:Data> is Data:
  OutsideDomain{}
  Known{view:Maybe<&2,V>}
def cached_lookup_here(-V:Data,view:Maybe<&2,V>,next:Lookup<V>,found:Bool) -> Lookup<V>:
  match found:
    case False{}:next
    case True{}:Known{view}
def cached_lookup(-V:Data,rows:List<&2,Q.Row<V>>,+offset:U32) -> Lookup<V>:
  match rows:
    case []:OutsideDomain{}
    case +row <> rest:cached_lookup_here(V,Q.row_view(V,row),cached_lookup(V,rest,offset),U32.is_eq(Q.row_offset(V,row),offset))
def read_slot_done(-S:Data,-P:Type,-V:Data,-origin:L.Layout,cache:Q.ReadCache<S,V,origin>,result:Slice.Slot<S,L.Viewed<P,V>,origin> & Maybe<&2,V>) -> Slot<S,P,V,origin> & Lookup<V>:
  match result:
    case (writes,view):(Slot{writes,cache},Known{view})
def read_slot_checked(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>,offset:U32,ownWrite:Bool) -> Slot<S,P,V,origin> & Lookup<V>:
  match slot ownWrite:
    case Slot{writes,cache} True{}:read_slot_done(S,P,V,origin,cache,Slice.read(S,P,V,origin,writes,offset))
    case Slot{writes,Q.ReadCache{+rows}} False{}:(Slot{writes,Q.ReadCache{rows}},cached_lookup(V,rows,offset))
def read_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>,+offset:U32) -> Slot<S,P,V,origin> & Lookup<V>:
  match slot:
    case Slot{Slice.Slot{Part.Slice{+domain,cells}},cache}:read_slot_checked(S,P,V,origin,Slot{Slice.Slot{Part.Slice{domain,cells}},cache},offset,D.contains(domain,offset))
type Edit<-S:Data,-P:Type,-V:Data,-origin:L.Layout,-Out:Type> is Type:
  Edited{slot:Slot<S,P,V,origin>,output:Out}
  Unchanged{slot:Slot<S,P,V,origin>,unused:P -> P & Out}
def edited_slot(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,result:Slice.Edit<S,L.stored(layout,route),L.origin(layout,route),L.payload(layout,route),Out>) -> Edit<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route),Out>:
  match result:
    case Slice.Edited{slot,out}:Edited{Slot{slot,cache},out}
    case Slice.Unchanged{slot,unused}:Unchanged{Slot{slot,cache},unused}
def edit_slot(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,slot:Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>,offset:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out) -> Edit<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route),Out>:
  match slot:
    case Slot{writes,cache}:edited_slot(~S,~layout,~route,Out,cache,Slice.edit(~S,~layout,~route,Out,writes,offset,tick,transform))

type StorageModel is Data:
  Whole{}
  Sparse{}
type Storage<-S:Data,-full:L.Layout> is Type:
  Storage{namespace:U32,columns:stores(~S,full),grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>}
def owner(~S:Data,layout:L.Layout,model:StorageModel) -> Type:
  match model:
    case Whole{}:L.columns(~S,layout)
    case Sparse{}:Storage<S,layout>

def cached_stamp(-V:Data,rows:List<&2,Q.Row<V>>,+index:U32) -> Life.Stamp:
  match rows:
    case []:Life.Stamp{None{},None{}}
    case +row <> rest:Life.choose(U32.is_eq(index,Q.row_offset(V,row)),Q.row_stamp(V,row),cached_stamp(V,rest,index))
def stamped_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,cache:Q.ReadCache<S,V,origin>,result:Slice.Slot<S,L.Viewed<P,V>,origin> & Life.Stamp) -> Slot<S,P,V,origin> & Life.Stamp:
  match result:
    case (writes,stamp):(Slot{writes,cache},stamp)
def stamp_slot_checked(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>,index:U32,owned:Bool) -> Slot<S,P,V,origin> & Life.Stamp:
  match slot owned:
    case Slot{writes,cache} True{}:stamped_slot(S,P,V,origin,cache,Slice.stamp(S,L.Viewed<P,V>,origin,writes,index))
    case Slot{writes,Q.ReadCache{+rows}} False{}:(Slot{writes,Q.ReadCache{rows}},cached_stamp(V,rows,index))
def stamp_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,slot:Slot<S,P,V,origin>,+index:U32) -> Slot<S,P,V,origin> & Life.Stamp:
  match slot:
    case Slot{Slice.Slot{Part.Slice{+domain,cells}},Q.ReadCache{+rows}}:stamp_slot_checked(S,P,V,origin,Slot{Slice.Slot{Part.Slice{domain,cells}},Q.ReadCache{rows}},index,D.contains(domain,index))

def traverse_slot_returned(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,domain:D.Domain,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,result:List<&1,Part.Cell<L.stored(layout,route)>> & (O & List<&2,Row.Error<E>>)) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match result:
    case (cells,(output,errors)):(Slot{Slice.Slot{Part.Slice{domain,cells}},cache},(output,(errors,True{})))
def traverse_slot_admitted(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> L.payload(layout,route) & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,output:O,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,domain:D.Domain,cells:List<&1,Part.Cell<L.stored(layout,route)>>,admitted:Bool) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match admitted:
    case False{}:(Slot{Slice.Slot{Part.Slice{domain,cells}},cache},(output,([],False{})))
    case True{}:traverse_slot_returned(~S,~layout,~route,~O,~E,domain,cache,Slice.traverse_cells(~S,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,cells,output))
def traverse_slot_present(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> L.payload(layout,route) & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,output:O,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,domain:D.Domain,result:List<&1,Part.Cell<L.stored(layout,route)>> & List<&2,U32>) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match result:
    case (cells,offsets):traverse_slot_admitted(~S,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,output,cache,domain,cells,Slice.traverse_targets_present(~S,handles,offsets))
def traverse_slot_checked(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> L.payload(layout,route) & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,output:O,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,result:Part.CheckedSlice<S,L.stored(layout,route)>) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match result:
    case Part.CheckedSlice{slice,False{}}:(Slot{Slice.Slot{slice},cache},(output,([],False{})))
    case Part.CheckedSlice{Part.Slice{domain,cells},True{}}:traverse_slot_present(~S,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,output,cache,domain,Slice.traverse_present(~L.stored(layout,route),cells))
def traverse_output_slot(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> L.payload(layout,route) & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,slot:Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>,output:O) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match slot:
    case Slot{Slice.Slot{Part.Slice{+domain,cells}},cache}:traverse_slot_checked(~S,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,output,cache,Part.check_slice(S,L.stored(layout,route),Col.maximum_capacity(),domain,Part.Slice{domain,cells}))

def task_slot_returned(~S:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,domain:D.Domain,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,result:List<&1,Part.Cell<L.stored(layout,route)>> & (O & List<&2,Row.Error<E>>)) -> Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool)):
  match result:
    case (cells,(output,errors)):(Slot{Slice.Slot{Part.Slice{domain,cells}},cache},(output,(errors,True{})))

def task_slot_checked(~S:Data,~Permit:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> Task.Task<S,Permit,L.payload(layout,route) & (O & Maybe<&2,E>)>,~split:O -> O & O,~merge:O -> O -> O,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,output:O,cache:Q.ReadCache<S,L.view(layout,route),L.origin(layout,route)>,result:Part.CheckedSlice<S,L.stored(layout,route)>) -> Task.Task<S,Permit,Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool))>:
  match result:
    case Part.CheckedSlice{slice,False{}}:Task.TDone{(Slot{Slice.Slot{slice},cache},(output,([],False{})))}
    case Part.CheckedSlice{Part.Slice{domain,cells},True{}}:Task.TBind{List<&1,Part.Cell<L.stored(layout,route)>> & (O & List<&2,Row.Error<E>>),Slice.task_cells(~S,~Permit,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,cells,output),result=>Task.TDone{task_slot_returned(~S,~layout,~route,~O,~E,domain,cache,result)}}

def task_output_slot(~S:Data,~Permit:Data,~layout:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(layout,route) -> L.payload(layout,route) -> O -> Task.Task<S,Permit,L.payload(layout,route) & (O & Maybe<&2,E>)>,~split:O -> O & O,~merge:O -> O -> O,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,selection:Row.Selection,slot:Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)>,output:O) -> Task.Task<S,Permit,Slot<S,L.payload(layout,route),L.view(layout,route),L.origin(layout,route)> & (O & (List<&2,Row.Error<E>> & Bool))>:
  match slot:
    case Slot{Slice.Slot{Part.Slice{+domain,cells}},cache}:task_slot_checked(~S,~Permit,~layout,~route,~O,~E,~body,~split,~merge,handles,tick,parallel,selection,output,cache,Part.check_slice(S,L.stored(layout,route),Col.maximum_capacity(),domain,Part.Slice{domain,cells}))
