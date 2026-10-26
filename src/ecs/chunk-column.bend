import Base
import ./lifecycle.bend as L
import ./change-tick.bend as Tick

# Trusted storage. Public declarations confine these owners before gameplay runs.
type Column<-S:Data,-C:Type> is Type:
  Leaf{values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>}
  Branch{half:U32,left:Column<S,C>,right:Column<S,C>}
type SwapOutcome<-S:Data,-C:Type> is Type:
  Accepted{column:Column<S,C>,previous:Maybe<&1,C>}
  Rejected{column:Column<S,C>,incoming:Maybe<&1,C>}

def absent(~C:Type,depth:Nat) -> Array<Maybe<&1,C>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n++rest: ANode{absent(~C,rest),absent(~C,rest)}
def empty(~S:Data,~C:Type) -> Column<S,C>:
  Leaf{absent(~C,3n),[L.Stamp{None{},None{}} : L.Stamp^3n]}
def capacity(~S:Data,~C:Type,column:Column<S,C>) -> Column<S,C> & U32:
  match column:
    case Leaf{values,stamps}: (Leaf{values,stamps},8)
    case Branch{+half,left,right}: (Branch{half,left,right},U32.add(half,half))
def vacant(~S:Data,~C:Type,depth:Nat) -> Column<S,C>:
  match depth:
    case 0n: empty(~S,~C)
    case 1n++rest:
      +half = U32.shln(8,rest)
      Branch{half,vacant(~S,~C,rest),vacant(~S,~C,rest)}
def grown(~S:Data,~C:Type,fuel:Nat,column:Column<S,C>,+size:U32,+depth:Nat,+target:U32,enough:Bool) -> Column<S,C>:
  match fuel enough:
    case _ True{}: column
    case 0n False{}: column
    case 1n+rest False{}:
      grown(~S,~C,rest,Branch{size,column,vacant(~S,~C,depth)},U32.add(size,size),1n+depth,target,U32.is_le(target,U32.add(size,size)))
def ensure_sized(~S:Data,~C:Type,+target:U32,result:Column<S,C> & U32) -> Column<S,C>:
  match result:
    case (column,+size): grown(~S,~C,14n,column,size,Nat.sub(U32.log2(size),3n),target,U32.is_le(target,size))
def maximum_capacity() -> U32:131072
def ensure(~S:Data,~C:Type,column:Column<S,C>,target:U32) -> Column<S,C>:
  ensure_sized(~S,~C,U32.min(target,maximum_capacity()),capacity(~S,~C,column))

def present(~C:Type,value:Maybe<&1,C>) -> Maybe<&1,C> & Bool:
  match value:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})
def swap_finish(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,+index:U32,incoming:Bool,previous:Maybe<&1,C>,wasPresent:Bool,tick:Tick.Tick,result:Array<L.Stamp> & L.Stamp) -> SwapOutcome<S,C>:
  match result:
    case (stamps,stamp): Accepted{Leaf{values,Array.set(L.Stamp,stamps,index,L.after_write(incoming,wasPresent,stamp,tick))},previous}
def swap_presence(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,+index:U32,incoming:Bool,tick:Tick.Tick,result:Maybe<&1,C> & Bool) -> SwapOutcome<S,C>:
  match result:
    case (previous,wasPresent): swap_finish(~S,~C,values,index,incoming,previous,wasPresent,tick,Array.get(L.Stamp,stamps,index))
def swap_previous(~S:Data,~C:Type,stamps:Array<L.Stamp>,index:U32,incoming:Bool,tick:Tick.Tick,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> SwapOutcome<S,C>:
  match result:
    case (values,previous): swap_presence(~S,~C,values,stamps,index,incoming,tick,present(~C,previous))
def swap_incoming(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,+index:U32,tick:Tick.Tick,result:Maybe<&1,C> & Bool) -> SwapOutcome<S,C>:
  match result:
    case (incoming,isPresent): swap_previous(~S,~C,stamps,index,isPresent,tick,Array.swap(Maybe<&1,C>,values,index,incoming))
def swap_leaf(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,+index:U32,incoming:Maybe<&1,C>,tick:Tick.Tick,valid:Bool) -> SwapOutcome<S,C>:
  match valid:
    case False{}: Rejected{Leaf{values,stamps},incoming}
    case True{}: swap_incoming(~S,~C,values,stamps,index,tick,present(~C,incoming))
def swap_left(~S:Data,~C:Type,half:U32,right:Column<S,C>,result:SwapOutcome<S,C>) -> SwapOutcome<S,C>:
  match result:
    case Accepted{left,previous}: Accepted{Branch{half,left,right},previous}
    case Rejected{left,incoming}: Rejected{Branch{half,left,right},incoming}
def swap_right(~S:Data,~C:Type,half:U32,left:Column<S,C>,result:SwapOutcome<S,C>) -> SwapOutcome<S,C>:
  match result:
    case Accepted{right,previous}: Accepted{Branch{half,left,right},previous}
    case Rejected{right,incoming}: Rejected{Branch{half,left,right},incoming}
type Path<-S:Data,-C:Type> is Type:
  Root{}
  FromLeft{half:U32,right:Column<S,C>,parent:Path<S,C>}
  FromRight{half:U32,left:Column<S,C>,parent:Path<S,C>}
def rebuild(~S:Data,~C:Type,path:Path<S,C>,column:Column<S,C>) -> Column<S,C>:
  match path:
    case Root{}: column
    case FromLeft{half,right,parent}: rebuild(~S,~C,parent,Branch{half,column,right})
    case FromRight{half,left,parent}: rebuild(~S,~C,parent,Branch{half,left,column})
def returned(~S:Data,~C:Type,path:Path<S,C>,result:SwapOutcome<S,C>) -> SwapOutcome<S,C>:
  match result:
    case Accepted{column,previous}: Accepted{rebuild(~S,~C,path,column),previous}
    case Rejected{column,incoming}: Rejected{rebuild(~S,~C,path,column),incoming}
type Search<-S:Data,-C:Type> is Type:
  Search{column:Column<S,C>,index:U32,incoming:Maybe<&1,C>,path:Path<S,C>}
def route(~S:Data,~C:Type,left:Column<S,C>,right:Column<S,C>,+half:U32,+index:U32,incoming:Maybe<&1,C>,path:Path<S,C>,first:Bool) -> Search<S,C>:
  match first:
    case True{}: Search{left,index,incoming,FromLeft{half,right,path}}
    case False{}: Search{right,U32.sub(index,half),incoming,FromRight{half,left,path}}
def search(~S:Data,~C:Type,fuel:Nat,state:Search<S,C>,+tick:Tick.Tick) -> SwapOutcome<S,C>:
  match fuel state:
    case 0n Search{column,_,incoming,path}: Rejected{rebuild(~S,~C,path,column),incoming}
    case 1n+_ Search{Leaf{values,stamps},+index,incoming,path}: returned(~S,~C,path,swap_leaf(~S,~C,values,stamps,index,incoming,tick,U32.is_lt(index,8)))
    case 1n+rest Search{Branch{+half,left,right},+index,incoming,path}: search(~S,~C,rest,route(~S,~C,left,right,half,index,incoming,path,U32.is_lt(index,half)),tick)
def swap_at(~S:Data,~C:Type,column:Column<S,C>,index:U32,incoming:Maybe<&1,C>,tick:Tick.Tick) -> SwapOutcome<S,C>:
  search(~S,~C,15n,Search{column,index,incoming,Root{}},tick)
def swap(~S:Data,~C:Type,column:Column<S,C>,index:U32,incoming:Maybe<&1,C>) -> SwapOutcome<S,C>:
  swap_at(~S,~C,column,index,incoming,Tick.zero())

def edit_mark(index:U32,tick:Tick.Tick,result:Array<L.Stamp> & L.Stamp) -> Array<L.Stamp>:
  match result:
    case (stamps,stamp): Array.set(L.Stamp,stamps,index,L.written(True{},stamp,tick))
def edit_stamps(stamps:Array<L.Stamp>,+index:U32,tick:Tick.Tick,write:Bool) -> Array<L.Stamp>:
  match write:
    case False{}: stamps
    case True{}: edit_mark(index,tick,Array.get(L.Stamp,stamps,index))
def edit_projected(~S:Data,~C:Type,~V:Data,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,+index:U32,tick:Tick.Tick,write:Bool,result:C & V) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (owner,value): (Leaf{Array.set(Maybe<&1,C>,values,index,Some{owner}),edit_stamps(stamps,index,tick,write)},Some{value})
def edit_taken(~S:Data,~C:Type,~V:Data,transform:C -> C & V,stamps:Array<L.Stamp>,index:U32,tick:Tick.Tick,write:Bool,result:Array<Maybe<&1,C>> & Maybe<&1,C>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (values,None{}): (Leaf{values,stamps},None{})
    case (values,Some{owner}): edit_projected(~S,~C,~V,values,stamps,index,tick,write,transform(owner))
def edit_leaf(~S:Data,~C:Type,~V:Data,transform:C -> C & V,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,+index:U32,tick:Tick.Tick,write:Bool,valid:Bool) -> Column<S,C> & Maybe<&2,V>:
  match valid:
    case False{}: (Leaf{values,stamps},None{})
    case True{}: edit_taken(~S,~C,~V,transform,stamps,index,tick,write,Array.swap(Maybe<&1,C>,values,index,None{}))
def edit_return(~S:Data,~C:Type,~V:Data,path:Path<S,C>,result:Column<S,C> & Maybe<&2,V>) -> Column<S,C> & Maybe<&2,V>:
  match result:
    case (column,value): (rebuild(~S,~C,path,column),value)
type Visit<-S:Data,-C:Type> is Type:
  Visit{column:Column<S,C>,index:U32,path:Path<S,C>}
def edit_route(~S:Data,~C:Type,left:Column<S,C>,right:Column<S,C>,+half:U32,+index:U32,path:Path<S,C>,first:Bool) -> Visit<S,C>:
  match first:
    case True{}: Visit{left,index,FromLeft{half,right,path}}
    case False{}: Visit{right,U32.sub(index,half),FromRight{half,left,path}}
def edit_search(~S:Data,~C:Type,~V:Data,transform:C -> C & V,fuel:Nat,state:Visit<S,C>,+tick:Tick.Tick,+write:Bool) -> Column<S,C> & Maybe<&2,V>:
  match fuel state:
    case 0n Visit{column,_,path}: (rebuild(~S,~C,path,column),None{})
    case 1n+_ Visit{Leaf{values,stamps},+index,path}: edit_return(~S,~C,~V,path,edit_leaf(~S,~C,~V,transform,values,stamps,index,tick,write,U32.is_lt(index,8)))
    case 1n+rest Visit{Branch{+half,left,right},+index,path}: edit_search(~S,~C,~V,transform,rest,edit_route(~S,~C,left,right,half,index,path,U32.is_lt(index,half)),tick,write)
def view(~S:Data,~C:Type,~V:Data,~project:C -> C & V,column:Column<S,C>,index:U32) -> Column<S,C> & Maybe<&2,V>:
  edit_search(~S,~C,~V,project,15n,Visit{column,index,Root{}},Tick.zero(),False{})
def modify_at(~S:Data,~C:Type,~V:Data,~transform:C -> C & V,column:Column<S,C>,index:U32,tick:Tick.Tick) -> Column<S,C> & Maybe<&2,V>:
  edit_search(~S,~C,~V,transform,15n,Visit{column,index,Root{}},tick,True{})
def modify(~S:Data,~C:Type,~V:Data,~transform:C -> C & V,column:Column<S,C>,index:U32) -> Column<S,C> & Maybe<&2,V>:
  modify_at(~S,~C,~V,~transform,column,index,Tick.zero())
def stamp_got(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,result:Array<L.Stamp> & L.Stamp) -> Column<S,C> & Maybe<&2,L.Stamp>:
  match result:
    case (stamps,stamp): (Leaf{values,stamps},Some{stamp})
def stamp_leaf(~S:Data,~C:Type,values:Array<Maybe<&1,C>>,stamps:Array<L.Stamp>,index:U32,valid:Bool) -> Column<S,C> & Maybe<&2,L.Stamp>:
  match valid:
    case False{}: (Leaf{values,stamps},None{})
    case True{}: stamp_got(~S,~C,values,Array.get(L.Stamp,stamps,index))
def stamp_search(~S:Data,~C:Type,fuel:Nat,state:Visit<S,C>) -> Column<S,C> & Maybe<&2,L.Stamp>:
  match fuel state:
    case 0n Visit{column,_,path}: (rebuild(~S,~C,path,column),None{})
    case 1n+_ Visit{Leaf{values,stamps},+index,path}: edit_return(~S,~C,~L.Stamp,path,stamp_leaf(~S,~C,values,stamps,index,U32.is_lt(index,8)))
    case 1n+rest Visit{Branch{+half,left,right},+index,path}: stamp_search(~S,~C,rest,edit_route(~S,~C,left,right,half,index,path,U32.is_lt(index,half)))
def lifecycle(~S:Data,~C:Type,column:Column<S,C>,index:U32) -> Column<S,C> & Maybe<&2,L.Stamp>:
  stamp_search(~S,~C,15n,Visit{column,index,Root{} })

def modify_runtime(~S:Data,~C:Type,~V:Data,transform:C -> C & V,column:Column<S,C>,index:U32,tick:Tick.Tick) -> Column<S,C> & Maybe<&2,V>:
  edit_search(~S,~C,~V,transform,15n,Visit{column,index,Root{}},tick,True{})
