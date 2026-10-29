import Base
import ./chunk-column.bend as Col
import ./execution-query-domain.bend as D
import ./lifecycle.bend as L

type Shape is Data:
  Leaf{}
  Branch{half:U32,left:Shape,right:Shape}
type Inspection is Data:
  Inspection{shape:Shape,capacity:U32,valid:Bool}
type Cell<-C:Type> is Type:
  Cell{offset:U32,value:Maybe<&1,C>,stamp:L.Stamp}
type Slice<-S:Data,-C:Type> is Type:
  Slice{domain:D.Domain,cells:List<&1,Cell<C>>}
# This affine association is consumed once by join, independently of Data domains.
type JoinOwner<-S:Data,-C:Type> is Type:
  JoinOwner{shape:Shape,left:D.Domain,right:D.Domain}
type Refusal is Data:
  MalformedTree{}
  InvalidLeft{reason:D.Validation}
  InvalidRight{reason:D.Validation}
  Overlap{}
  ChangedInventory{}
type Cut<-S:Data,-C:Type> is Type:
  Refused{column:Col.Column<S,C>,reason:Refusal}
  Split{remainder:Col.Column<S,C>,left:Slice<S,C>,right:Slice<S,C>,join:JoinOwner<S,C>}
type Scattered<-S:Data,-C:Type> is Type:
  Scattered{column:Col.Column<S,C>,left:List<&1,Cell<C>>,right:List<&1,Cell<C>>}
type Restored<-S:Data,-C:Type> is Type:
  Restored{column:Col.Column<S,C>,displaced:List<&1,Cell<C>>}
type Joined<-S:Data,-C:Type> is Type:
  Joined{column:Col.Column<S,C>,displaced:List<&1,Cell<C>>}
  JoinRefused{remainder:Col.Column<S,C>,left:Slice<S,C>,right:Slice<S,C>,join:JoinOwner<S,C>,reason:Refusal}

def inspected_leaf(-S:Data,-C:Type,values:Array<Maybe<&1,C>>,valueSize:U32,result:Array<L.Stamp> & U32) -> Col.Column<S,C> & Inspection:
  match result:
    case (stamps,stampSize):(Col.Leaf{values,stamps},Inspection{Leaf{},8,Bool.and(U32.is_eq(valueSize,8),U32.is_eq(stampSize,8))})
def inspect_values(-S:Data,-C:Type,stamps:Array<L.Stamp>,result:Array<Maybe<&1,C>> & U32) -> Col.Column<S,C> & Inspection:
  match result:
    case (values,size):inspected_leaf(S,C,values,size,Array.size(L.Stamp,stamps))
def inspected_right(-S:Data,-C:Type,+half:U32,left:Col.Column<S,C>,li:Inspection,result:Col.Column<S,C> & Inspection) -> Col.Column<S,C> & Inspection:
  match li result:
    case Inspection{ls,+lc,lv}, (right,Inspection{rs,rc,rv}):(Col.Branch{half,left,right},Inspection{Branch{half,ls,rs},U32.add(half,half),Bool.and(lv,Bool.and(rv,Bool.and(U32.is_eq(lc,half),Bool.and(U32.is_eq(rc,half),U32.is_le(half,2147483647)))))})
def inspected_pair(-S:Data,-C:Type,half:U32,leftResult:Col.Column<S,C> & Inspection,rightResult:Col.Column<S,C> & Inspection) -> Col.Column<S,C> & Inspection:
  match leftResult:
    case (left,li):inspected_right(S,C,half,left,li,rightResult)

def inspect(-S:Data,-C:Type,column:Col.Column<S,C>) -> Col.Column<S,C> & Inspection:
  match column:
    case Col.Leaf{values,stamps}:inspect_values(S,C,stamps,Array.size(Maybe<&1,C>,values))
    case Col.Branch{half,left,right}:inspected_pair(S,C,half,inspect(S,C,left),inspect(S,C,right))

def append_cell(-S:Data,-C:Type,+base:U32,+index:U32,stamp:L.Stamp,stamps:Array<L.Stamp>,ls:List<&1,Cell<C>>,rs:List<&1,Cell<C>>,isLeft:Bool,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Scattered<S,C>:
  match isLeft result:
    case True{}, (values,value):Scattered{Col.Leaf{values,stamps},Cell{U32.add(base,index),value,stamp} <> ls,rs}
    case False{}, (values,value):Scattered{Col.Leaf{values,stamps},ls,Cell{U32.add(base,index),value,stamp} <> rs}
def selected_stamp(-S:Data,-C:Type,base:U32,+index:U32,values:Array<Maybe<&1,C>>,ls:List<&1,Cell<C>>,rs:List<&1,Cell<C>>,isLeft:Bool,result:Array<L.Stamp> & L.Stamp) -> Scattered<S,C>:
  match result:
    case (stamps,stamp):append_cell(S,C,base,index,stamp,Array.set(L.Stamp,stamps,index,L.Stamp{None{},None{}}),ls,rs,isLeft,Array.swap(Maybe<&1,C>,values,index,None{}))
def select_cell(-S:Data,-C:Type,base:U32,+index:U32,isLeft:Bool,selected:Bool,parts:Scattered<S,C>) -> Scattered<S,C>:
  match selected parts:
    case False{} parts:parts
    case True{} Scattered{Col.Leaf{values,stamps},ls,rs}:selected_stamp(S,C,base,index,values,ls,rs,isLeft,Array.get(L.Stamp,stamps,index))
    case True{} Scattered{column,ls,rs}:Scattered{column,ls,rs}
def leaf_scatter(-S:Data,-C:Type,fuel:Nat,+base:U32,+index:U32,+left:D.Domain,+right:D.Domain,parts:Scattered<S,C>) -> Scattered<S,C>:
  match fuel:
    case 0n:parts
    case 1n+rest:leaf_scatter(S,C,rest,base,U32.add(index,1),left,right,select_cell(S,C,base,index,D.contains(left,U32.add(base,index)),Bool.or(D.contains(left,U32.add(base,index)),D.contains(right,U32.add(base,index))),parts))
def append(-C:Type,left:List<&1,Cell<C>>,right:List<&1,Cell<C>>) -> List<&1,Cell<C>>:
  match left:
    case []:right
    case cell <> rest:cell <> append(C,rest,right)
def scattered_right(-S:Data,-C:Type,half:U32,left:Col.Column<S,C>,ls:List<&1,Cell<C>>,rs:List<&1,Cell<C>>,result:Scattered<S,C>) -> Scattered<S,C>:
  match result:
    case Scattered{right,rl,rr}:Scattered{Col.Branch{half,left,right},append(C,ls,rl),append(C,rs,rr)}
def scattered_pair(-S:Data,-C:Type,half:U32,leftResult:Scattered<S,C>,rightResult:Scattered<S,C>) -> Scattered<S,C>:
  match leftResult:
    case Scattered{left,ls,rs}:scattered_right(S,C,half,left,ls,rs,rightResult)

def scatter(-S:Data,-C:Type,column:Col.Column<S,C>,+base:U32,+left:D.Domain,+right:D.Domain) -> Scattered<S,C>:
  match column:
    case Col.Leaf{values,stamps}:leaf_scatter(S,C,8n,base,0,left,right,Scattered{Col.Leaf{values,stamps},[],[]})
    case Col.Branch{+half,l,r}:scattered_pair(S,C,half,scatter(S,C,l,base,left,right),scatter(S,C,r,U32.add(base,half),left,right))
def split_done(-S:Data,-C:Type,shape:Shape,+left:D.Domain,+right:D.Domain,result:Scattered<S,C>) -> Cut<S,C>:
  match result:
    case Scattered{column,ls,rs}:Split{column,Slice{left,ls},Slice{right,rs},JoinOwner{shape,left,right}}
def cut_valid(-S:Data,-C:Type,column:Col.Column<S,C>,shape:Shape,+left:D.Domain,+right:D.Domain,lv:D.Validation,rv:D.Validation,overlap:Bool,valid:Bool) -> Cut<S,C>:
  match lv rv overlap valid:
    case _ _ _ False{}:Refused{column,MalformedTree{}}
    case D.Valid{} D.Valid{} False{} True{}:split_done(S,C,shape,left,right,scatter(S,C,column,0,left,right))
    case D.Valid{} D.Valid{} True{} True{}:Refused{column,Overlap{}}
    case D.Valid{} reason _ True{}:Refused{column,InvalidRight{reason}}
    case reason _ _ True{}:Refused{column,InvalidLeft{reason}}
def cut_inspected(-S:Data,-C:Type,+left:D.Domain,+right:D.Domain,result:Col.Column<S,C> & Inspection) -> Cut<S,C>:
  match result:
    case (column,Inspection{shape,+capacity,valid}):cut_valid(S,C,column,shape,left,right,D.validate(capacity,left),D.validate(capacity,right),D.intersects(left,right),valid)
def cut(-S:Data,-C:Type,column:Col.Column<S,C>,left:D.Domain,right:D.Domain) -> Cut<S,C>:
  cut_inspected(S,C,left,right,inspect(S,C,column))

def same_shape(left:Shape,right:Shape) -> Bool:
  match left right:
    case Leaf{} Leaf{}:True{}
    case Branch{lh,ll,lr} Branch{rh,rl,rr}:Bool.and(U32.is_eq(lh,rh),Bool.and(same_shape(ll,rl),same_shape(lr,rr)))
    case _ _:False{}
def subset_list(+right:D.Domain,offsets:List<&2,U32>) -> Bool:
  match offsets:
    case []:True{}
    case head <> tail:Bool.and(D.contains(right,head),subset_list(right,tail))
def subset(left:D.Domain,right:D.Domain) -> Bool:
  match left:
    case D.Domain{offsets}:subset_list(right,offsets)
def same_domain(+left:D.Domain,+right:D.Domain) -> Bool:
  Bool.and(subset(left,right),subset(right,left))
type Inventory<-C:Type> is Type:
  Inventory{cells:List<&1,Cell<C>>,offsets:List<&2,U32>}
def inventory_cons(-C:Type,+offset:U32,value:Maybe<&1,C>,stamp:L.Stamp,result:Inventory<C>) -> Inventory<C>:
  match result:
    case Inventory{cells,offsets}:Inventory{Cell{offset,value,stamp} <> cells,offset <> offsets}
def inventory(-C:Type,cells:List<&1,Cell<C>>) -> Inventory<C>:
  match cells:
    case []:Inventory{[],[]}
    case Cell{offset,value,stamp} <> rest:inventory_cons(C,offset,value,stamp,inventory(C,rest))
type CheckedSlice<-S:Data,-C:Type> is Type:
  CheckedSlice{slice:Slice<S,C>,valid:Bool}
def inventory_valid(result:D.Validation) -> Bool:
  match result:
    case D.Valid{}:True{}
    case _:False{}
def checked_inventory(-S:Data,-C:Type,capacity:U32,+expected:D.Domain,+declared:D.Domain,result:Inventory<C>) -> CheckedSlice<S,C>:
  match result:
    case Inventory{cells,+offsets}:CheckedSlice{Slice{declared,cells},Bool.and(same_domain(expected,declared),Bool.and(same_domain(expected,D.Domain{offsets}),inventory_valid(D.validate(capacity,D.Domain{offsets}))))}
def check_slice(-S:Data,-C:Type,capacity:U32,expected:D.Domain,slice:Slice<S,C>) -> CheckedSlice<S,C>:
  match slice:
    case Slice{declared,cells}:checked_inventory(S,C,capacity,expected,declared,inventory(C,cells))

def replaced(-S:Data,-C:Type,index:U32,previousStamp:L.Stamp,stamps:Array<L.Stamp>,displaced:List<&1,Cell<C>>,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Restored<S,C>:
  match result:
    case (values,previous):Restored{Col.Leaf{values,stamps},Cell{index,previous,previousStamp} <> displaced}
def replace_stamped(-S:Data,-C:Type,+global:U32,+index:U32,value:Maybe<&1,C>,stamp:L.Stamp,values:Array<Maybe<&1,C>>,displaced:List<&1,Cell<C>>,result:Array<L.Stamp> & L.Stamp) -> Restored<S,C>:
  match result:
    case (stamps,old):replaced(S,C,global,old,Array.set(L.Stamp,stamps,index,stamp),displaced,Array.swap(Maybe<&1,C>,values,index,value))
def replace_leaf(-S:Data,-C:Type,+global:U32,+index:U32,value:Maybe<&1,C>,stamp:L.Stamp,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,displaced:List<&1,Cell<C>>,valid:Bool) -> Restored<S,C>:
  match valid:
    case False{}:Restored{Col.Leaf{values,stamps},Cell{global,value,stamp} <> displaced}
    case True{}:replace_stamped(S,C,global,index,value,stamp,values,displaced,Array.get(L.Stamp,stamps,index))
def replaced_left(-S:Data,-C:Type,half:U32,right:Col.Column<S,C>,result:Restored<S,C>) -> Restored<S,C>:
  match result:
    case Restored{left,displaced}:Restored{Col.Branch{half,left,right},displaced}
def replaced_right(-S:Data,-C:Type,half:U32,left:Col.Column<S,C>,result:Restored<S,C>) -> Restored<S,C>:
  match result:
    case Restored{right,displaced}:Restored{Col.Branch{half,left,right},displaced}
def replace_branch(-S:Data,-C:Type,half:U32,left:Col.Column<S,C>,right:Col.Column<S,C>,goLeft:Col.Column<S,C> -> Maybe<&1,C> -> L.Stamp -> List<&1,Cell<C>> -> Restored<S,C>,goRight:Col.Column<S,C> -> Maybe<&1,C> -> L.Stamp -> List<&1,Cell<C>> -> Restored<S,C>,value:Maybe<&1,C>,stamp:L.Stamp,displaced:List<&1,Cell<C>>,first:Bool) -> Restored<S,C>:
  match first:
    case True{}:replaced_left(S,C,half,right,goLeft(left,value,stamp,displaced))
    case False{}:replaced_right(S,C,half,left,goRight(right,value,stamp,displaced))
def replace(-S:Data,-C:Type,shape:Shape,column:Col.Column<S,C>,+global:U32,+index:U32,value:Maybe<&1,C>,stamp:L.Stamp,displaced:List<&1,Cell<C>>) -> Restored<S,C>:
  match shape column:
    case Leaf{} Col.Leaf{values,stamps}:replace_leaf(S,C,global,index,value,stamp,values,stamps,displaced,U32.is_lt(index,8))
    case Branch{_,ls,rs} Col.Branch{+half,left,right}:replace_branch(S,C,half,left,right,(column => value => stamp => displaced => replace(S,C,ls,column,global,index,value,stamp,displaced)),(column => value => stamp => displaced => replace(S,C,rs,column,global,U32.sub(index,half),value,stamp,displaced)),value,stamp,displaced,U32.is_lt(index,half))
    case _ column:Restored{column,Cell{global,value,stamp} <> displaced}
def put_all(-S:Data,-C:Type,+shape:Shape,cells:List<&1,Cell<C>>,result:Restored<S,C>) -> Restored<S,C>:
  match cells result:
    case [] result:result
    case Cell{+offset,value,stamp} <> rest Restored{column,displaced}:put_all(S,C,shape,rest,replace(S,C,shape,column,offset,offset,value,stamp,displaced))
def joined(-S:Data,-C:Type,result:Restored<S,C>) -> Joined<S,C>:
  match result:
    case Restored{column,displaced}:Joined{column,displaced}
def join_checked(-S:Data,-C:Type,column:Col.Column<S,C>,join:JoinOwner<S,C>,left:CheckedSlice<S,C>,right:CheckedSlice<S,C>,valid:Bool) -> Joined<S,C>:
  match join left right valid:
    case JoinOwner{+shape,_,_} CheckedSlice{Slice{_,ls},True{}} CheckedSlice{Slice{_,rs},True{}} True{}:joined(S,C,put_all(S,C,shape,rs,put_all(S,C,shape,ls,Restored{column,[]})))
    case join CheckedSlice{left,_} CheckedSlice{right,_} _:JoinRefused{column,left,right,join,ChangedInventory{}}
def join_inspected(-S:Data,-C:Type,join:JoinOwner<S,C>,left:Slice<S,C>,right:Slice<S,C>,result:Col.Column<S,C> & Inspection) -> Joined<S,C>:
  match join result:
    case JoinOwner{+shape,+ld,+rd}, (column,Inspection{actual,+capacity,valid}):join_checked(S,C,column,JoinOwner{shape,ld,rd},check_slice(S,C,capacity,ld,left),check_slice(S,C,capacity,rd,right),Bool.and(valid,same_shape(shape,actual)))
def join(-S:Data,-C:Type,join:JoinOwner<S,C>,remainder:Col.Column<S,C>,left:Slice<S,C>,right:Slice<S,C>) -> Joined<S,C>:
  join_inspected(S,C,join,left,right,inspect(S,C,remainder))
