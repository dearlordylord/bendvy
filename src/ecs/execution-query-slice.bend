import Base
import ./chunk-partition.bend as Part
import ./execution-query-domain.bend as D
import ./execution-composer-layout.bend as Layout
import ./lifecycle.bend as L
import ./change-tick.bend as Tick

# Origin contains payload, cache type, refresher, key and persistence class.
# S additionally brands the schema. This is sparse storage, never full WC.
type Slot<-S:Data,-C:Type,-origin:Layout.Layout> is Type:
  Slot{slice:Part.Slice<S,C>}
type Edit<-S:Data,-C:Type,-origin:Layout.Layout,-P:Type,-Out:Type> is Type:
  Edited{slot:Slot<S,C,origin>,output:Out}
  Unchanged{slot:Slot<S,C,origin>,unused:P -> P & Out}

def choose_view(-V:Data,view:V,next:Maybe<&2,V>,found:Bool) -> Maybe<&2,V>:
  match found:
    case True{}:Some{view}
    case False{}:next
def read_absent(-P:Type,-V:Data,offset:U32,stamp:L.Stamp,result:List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>) -> List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>:
  match result:
    case (rest,view):(Part.Cell{offset,None{},stamp} <> rest,view)
def read_present(-P:Type,-V:Data,offset:U32,owner:P,+view:V,stamp:L.Stamp,found:Bool,result:List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>) -> List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>:
  match result:
    case (rest,next):(Part.Cell{offset,Some{Layout.Viewed{owner,view}},stamp} <> rest,choose_view(V,view,next,found))
def read_cells(-P:Type,-V:Data,cells:List<&1,Part.Cell<Layout.Viewed<P,V>>>,+index:U32) -> List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>:
  match cells:
    case []:([],None{})
    case Part.Cell{offset,None{},stamp} <> rest:read_absent(P,V,offset,stamp,read_cells(P,V,rest,index))
    case Part.Cell{+offset,Some{Layout.Viewed{owner,view}},stamp} <> rest:read_present(P,V,offset,owner,view,stamp,U32.is_eq(offset,index),read_cells(P,V,rest,index))
def read_done(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,domain:D.Domain,result:List<&1,Part.Cell<Layout.Viewed<P,V>>> & Maybe<&2,V>) -> Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>:
  match result:
    case (cells,view):(Slot{Part.Slice{domain,cells}},view)
def read_checked(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,slot:Slot<S,Layout.Viewed<P,V>,origin>,index:U32,allowed:Bool) -> Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>:
  match slot allowed:
    case slot False{}:(slot,None{})
    case Slot{Part.Slice{domain,cells}} True{}:read_done(S,P,V,origin,domain,read_cells(P,V,cells,index))
def read(-S:Data,-P:Type,-V:Data,-origin:Layout.Layout,slot:Slot<S,Layout.Viewed<P,V>,origin>,+index:U32) -> Slot<S,Layout.Viewed<P,V>,origin> & Maybe<&2,V>:
  match slot:
    case Slot{Part.Slice{+domain,cells}}:read_checked(S,P,V,origin,Slot{Part.Slice{domain,cells}},index,D.contains(domain,index))

type CellsEdit<-C:Type,-P:Type,-Out:Type> is Type:
  CellsEdited{cells:List<&1,Part.Cell<C>>,output:Out}
  CellsUnchanged{cells:List<&1,Part.Cell<C>>,unused:P -> P & Out}
def prepend_edit(-C:Type,-P:Type,-Out:Type,cell:Part.Cell<C>,result:CellsEdit<C,P,Out>) -> CellsEdit<C,P,Out>:
  match result:
    case CellsEdited{cells,output}:CellsEdited{cell <> cells,output}
    case CellsUnchanged{cells,unused}:CellsUnchanged{cell <> cells,unused}
def refreshed(~layout:Layout.Layout,~route:Layout.Route,-Out:Type,offset:U32,stamp:L.Stamp,rest:List<&1,Part.Cell<Layout.stored(layout,route)>>,result:Layout.stored(layout,route) & Out) -> CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>:
  match result:
    case (value,out):CellsEdited{Part.Cell{offset,Some{value},stamp} <> rest,out}
def edit_here(~layout:Layout.Layout,~route:Layout.Route,-Out:Type,offset:U32,value:Layout.stored(layout,route),stamp:L.Stamp,rest:List<&1,Part.Cell<Layout.stored(layout,route)>>,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out,tick:Tick.Tick,found:Bool) -> CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>:
  match found:
    case True{}:refreshed(~layout,~route,Out,offset,L.written(True{},stamp,tick),rest,Layout.rewrite(~layout,~route,Out,transform,value))
    case False{}:CellsUnchanged{Part.Cell{offset,Some{value},stamp} <> rest,transform}
def edit_returned(~layout:Layout.Layout,~route:Layout.Route,-Out:Type,offset:U32,value:Layout.stored(layout,route),stamp:L.Stamp,tick:Tick.Tick,found:Bool,result:CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>) -> CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>:
  match result:
    case CellsEdited{cells,out}:CellsEdited{Part.Cell{offset,Some{value},stamp} <> cells,out}
    case CellsUnchanged{cells,transform}:edit_here(~layout,~route,Out,offset,value,stamp,cells,transform,tick,found)
def edit_cells(~layout:Layout.Layout,~route:Layout.Route,-Out:Type,cells:List<&1,Part.Cell<Layout.stored(layout,route)>>,+index:U32,+tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out) -> CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>:
  match cells:
    case []:CellsUnchanged{[],transform}
    case Part.Cell{offset,None{},stamp} <> rest:prepend_edit(Layout.stored(layout,route),Layout.payload(layout,route),Out,Part.Cell{offset,None{},stamp},edit_cells(~layout,~route,Out,rest,index,tick,transform))
    case Part.Cell{+offset,Some{value},stamp} <> rest:edit_returned(~layout,~route,Out,offset,value,stamp,tick,U32.is_eq(offset,index),edit_cells(~layout,~route,Out,rest,index,tick,transform))
def edit_done(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,domain:D.Domain,result:CellsEdit<Layout.stored(layout,route),Layout.payload(layout,route),Out>) -> Edit<S,Layout.stored(layout,route),Layout.origin(layout,route),Layout.payload(layout,route),Out>:
  match result:
    case CellsEdited{cells,out}:Edited{Slot{Part.Slice{domain,cells}},out}
    case CellsUnchanged{cells,unused}:Unchanged{Slot{Part.Slice{domain,cells}},unused}
def edit_checked(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,slot:Slot<S,Layout.stored(layout,route),Layout.origin(layout,route)>,index:U32,tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out,allowed:Bool) -> Edit<S,Layout.stored(layout,route),Layout.origin(layout,route),Layout.payload(layout,route),Out>:
  match slot allowed:
    case slot False{}:Unchanged{slot,transform}
    case Slot{Part.Slice{domain,cells}} True{}:edit_done(~S,~layout,~route,Out,domain,edit_cells(~layout,~route,Out,cells,index,tick,transform))
def edit(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,slot:Slot<S,Layout.stored(layout,route),Layout.origin(layout,route)>,+index:U32,tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out) -> Edit<S,Layout.stored(layout,route),Layout.origin(layout,route),Layout.payload(layout,route),Out>:
  match slot:
    case Slot{Part.Slice{+domain,cells}}:edit_checked(~S,~layout,~route,Out,Slot{Part.Slice{domain,cells}},index,tick,transform,D.contains(domain,index))

type JoinOwner<-S:Data,-C:Type,-key:String,-origin:Layout.Layout> is Type:
  JoinOwner{owner:Part.JoinOwner<S,C>}
type Cut<-S:Data,-C:Type,-key:String,-origin:Layout.Layout> is Type:
  Refused{column:Layout.ColumnSlot<S,C,key,origin>,reason:Part.Refusal}
  Split{remainder:Layout.ColumnSlot<S,C,key,origin>,left:Slot<S,C,origin>,right:Slot<S,C,origin>,join:JoinOwner<S,C,key,origin>}
def cut_done(-S:Data,-C:Type,-key:String,-origin:Layout.Layout,result:Part.Cut<S,C>) -> Cut<S,C,key,origin>:
  match result:
    case Part.Refused{column,reason}:Refused{Layout.ColumnSlot{column},reason}
    case Part.Split{column,left,right,join}:Split{Layout.ColumnSlot{column},Slot{left},Slot{right},JoinOwner{join}}
def cut(~S:Data,~layout:Layout.Layout,~route:Layout.Route,column:Layout.ColumnSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>,left:D.Domain,right:D.Domain) -> Cut<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>:
  match column:
    case Layout.ColumnSlot{column}:cut_done(S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route),Part.cut(S,Layout.stored(layout,route),column,left,right))
type Joined<-S:Data,-C:Type,-key:String,-origin:Layout.Layout> is Type:
  Joined{column:Layout.ColumnSlot<S,C,key,origin>,displaced:List<&1,Part.Cell<C>>}
  JoinRefused{remainder:Layout.ColumnSlot<S,C,key,origin>,left:Slot<S,C,origin>,right:Slot<S,C,origin>,join:JoinOwner<S,C,key,origin>,reason:Part.Refusal}
def joined(-S:Data,-C:Type,-key:String,-origin:Layout.Layout,result:Part.Joined<S,C>) -> Joined<S,C,key,origin>:
  match result:
    case Part.Joined{column,displaced}:Joined{Layout.ColumnSlot{column},displaced}
    case Part.JoinRefused{column,left,right,join,reason}:JoinRefused{Layout.ColumnSlot{column},Slot{left},Slot{right},JoinOwner{join},reason}
def join(-S:Data,-C:Type,-key:String,-origin:Layout.Layout,join:JoinOwner<S,C,key,origin>,remainder:Layout.ColumnSlot<S,C,key,origin>,left:Slot<S,C,origin>,right:Slot<S,C,origin>) -> Joined<S,C,key,origin>:
  match join remainder left right:
    case JoinOwner{owner} Layout.ColumnSlot{column} Slot{left} Slot{right}:joined(S,C,key,origin,Part.join(S,C,owner,column,left,right))
