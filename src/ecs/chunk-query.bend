import Base
import ./chunk-column.bend as C
import ./lifecycle.bend as L
import ./change-tick.bend as Tick

type Error<-E:Data> is Data:
  Error{index:U32,value:E}
type Run<-S:Data,-A:Type,-B:Type,-E:Data> is Type:
  Run{read:C.Column<S,A>,write:C.Column<S,B>,errors:List<&2,Error<E>>,aligned:Bool}

type Selection is Data:
  All{}
  Selected{indices:List<&2,U32>}
def contains(+index:U32,indices:List<&2,U32>) -> Bool:
  match indices:
    case []: False{}
    case current <> rest: U32.is_eq(index,current) || contains(index,rest)
def eligible(index:U32,selection:Selection) -> Bool:
  match selection:
    case All{}: True{}
    case Selected{indices}: contains(index,indices)
type Layout is Data:
  LayoutLeaf{}
  LayoutBranch{half:U32,left:Layout,right:Layout}
def layout_join(~S:Data,~A:Type,+half:U32,left:C.Column<S,A> & Layout,right:C.Column<S,A> & Layout) -> C.Column<S,A> & Layout:
  match left right:
    case Tuple{l,ls} Tuple{r,rs}: (C.Branch{half,l,r},LayoutBranch{half,ls,rs})
def layout(~S:Data,~A:Type,column:C.Column<S,A>) -> C.Column<S,A> & Layout:
  match column:
    case C.Leaf{values,stamps}: (C.Leaf{values,stamps},LayoutLeaf{})
    case C.Branch{+half,left,right}: layout_join(~S,~A,half,layout(~S,~A,left),layout(~S,~A,right))
def same(left:Layout,right:Layout) -> Bool:
  match left right:
    case LayoutLeaf{} LayoutLeaf{}: True{}
    case LayoutBranch{lh,ll,lr} LayoutBranch{rh,rl,rr}: U32.is_eq(lh,rh) && same(ll,rl) && same(lr,rr)
    case _ _: False{}
# Each worker owns both its physical columns and its affine output channel.
# Context is reusable selection data; it cannot contain affine payload owners.
type OutputRow<-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputRow{read:Maybe<&1,A>,write:Maybe<&1,B>,stamp:L.Stamp,output:O,errors:List<&2,Error<E>>}
type OutputValues<-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputValues{read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,output:O,errors:List<&2,Error<E>>,aligned:Bool}
type OutputRun<-S:Data,-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputRun{read:C.Column<S,A>,write:C.Column<S,B>,output:O,errors:List<&2,Error<E>>,aligned:Bool}
def output_result(~A:Type,~B:Type,~O:Type,~E:Data,read:A,index:U32,stamp:L.Stamp,result:B & (O & Maybe<&2,E>)) -> OutputRow<A,B,O,E>:
  match result:
    case (write,(output,None{})):OutputRow{Some{read},Some{write},stamp,output,[]}
    case (write,(output,Some{error})):OutputRow{Some{read},Some{write},stamp,output,[Error{index,error}]}
def output_projected(~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),context:K,write:B,output:O,+index:U32,stamp:L.Stamp,tick:Tick.Tick,result:A & V) -> OutputRow<A,B,O,E>:
  match result:
    case (read,view):output_result(~A,~B,~O,~E,read,index,L.written(True{},stamp,tick),body(context,index,view,write,output))
def output_allowed(~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),context:K,read:A,write:B,output:O,index:U32,stamp:L.Stamp,tick:Tick.Tick,allowed:Bool) -> OutputRow<A,B,O,E>:
  match allowed:
    case False{}:OutputRow{Some{read},Some{write},stamp,output,[]}
    case True{}:output_projected(~A,~B,~O,~V,~K,~E,~body,context,write,output,index,stamp,tick,project(read))
def output_row(~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),context:K,read:Maybe<&1,A>,write:Maybe<&1,B>,output:O,+index:U32,stamp:L.Stamp,tick:Tick.Tick,selection:Selection) -> OutputRow<A,B,O,E>:
  match read write:
    case None{} write:OutputRow{None{},write,stamp,output,[]}
    case Some{read} None{}:OutputRow{Some{read},None{},stamp,output,[]}
    case Some{read} Some{write}:output_allowed(~A,~B,~O,~V,~K,~E,~project,~body,context,read,write,output,index,stamp,tick,eligible(index,selection))
def output_values(~A:Type,~B:Type,~O:Type,~E:Data,result:OutputRow<A,B,O,E>) -> OutputValues<A,B,O,E>:
  match result:
    case OutputRow{read,write,stamp,output,errors}:OutputValues{ALeaf{read},ALeaf{write},ALeaf{stamp},output,errors,True{}}
def output_values_join(~A:Type,~B:Type,~O:Type,~E:Data,leftRead:Array<Maybe<&1,A>>,leftWrite:Array<Maybe<&1,B>>,leftStamps:Array<L.Stamp>,leftErrors:List<&2,Error<E>>,leftAligned:Bool,right:OutputValues<A,B,O,E>) -> OutputValues<A,B,O,E>:
  match right:
    case OutputValues{read,write,stamps,output,errors,aligned}:OutputValues{ANode{leftRead,read},ANode{leftWrite,write},ANode{leftStamps,stamps},output,List.append(&2,Error<E>,leftErrors,errors),Bool.and(leftAligned,aligned)}
def output_leaf_right(~A:Type,~B:Type,~O:Type,~E:Data,offset:U32,size:U32,tick:Tick.Tick,selection:Selection,left:OutputValues<A,B,O,E>,walk:O -> @+offset:U32 -> @+size:U32 -> @+tick:Tick.Tick -> @+selection:Selection -> OutputValues<A,B,O,E>) -> OutputValues<A,B,O,E>:
  match left:
    case OutputValues{la,lb,ls,output,errors,aligned}:output_values_join(~A,~B,~O,~E,la,lb,ls,errors,aligned,walk(output,offset,size,tick,selection))
def output_leaf(~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),+context:K,read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,output:O,+offset:U32,+size:U32,+tick:Tick.Tick,+selection:Selection) -> OutputValues<A,B,O,E>:
  match read write stamps:
    case ALeaf{a} ALeaf{b} ALeaf{stamp}:output_values(~A,~B,~O,~E,output_row(~A,~B,~O,~V,~K,~E,~project,~body,context,a,b,output,offset,stamp,tick,selection))
    case ANode{al,ar} ANode{bl,br} ANode{sl,sr}:output_leaf_right(~A,~B,~O,~E,U32.add(offset,U32.shr(size)),U32.shr(size),tick,selection,output_leaf(~A,~B,~O,~V,~K,~E,~project,~body,context,al,bl,sl,output,offset,U32.shr(size),tick,selection),output_leaf(~A,~B,~O,~V,~K,~E,~project,~body,context,ar,br,sr))
    case a b s:OutputValues{a,b,s,output,[],False{}}
def output_leaf_run(~S:Data,~A:Type,~B:Type,~O:Type,~E:Data,readStamps:Array<L.Stamp>,result:OutputValues<A,B,O,E>) -> OutputRun<S,A,B,O,E>:
  match result:
    case OutputValues{a,b,stamps,output,errors,aligned}:OutputRun{C.Leaf{a,readStamps},C.Leaf{b,stamps},output,errors,aligned}
def output_join(~S:Data,~A:Type,~B:Type,~O:Type,~E:Data,~merge:O -> O -> O,+half:U32,left:OutputRun<S,A,B,O,E>,right:OutputRun<S,A,B,O,E>) -> OutputRun<S,A,B,O,E>:
  match left right:
    case OutputRun{la,lb,lo,le,lv} OutputRun{ra,rb,ro,re,rv}:OutputRun{C.Branch{half,la,ra},C.Branch{half,lb,rb},merge(lo,ro),List.append(&2,Error<E>,le,re),Bool.and(lv,rv)}
def output_pair(~S:Data,~A:Type,~B:Type,~O:Type,~E:Data,~merge:O -> O -> O,half:U32,parallel:Bool,outputs:O & O,left:O -> OutputRun<S,A,B,O,E>,right:O -> OutputRun<S,A,B,O,E>) -> OutputRun<S,A,B,O,E>:
  match parallel outputs:
    case False{} Tuple{lo,ro}:output_join(~S,~A,~B,~O,~E,~merge,half,left(lo),right(ro))
    case True{} Tuple{lo,ro}:
      l r = left(lo) right(ro)
      output_join(~S,~A,~B,~O,~E,~merge,half,l,r)
def output_rows(~S:Data,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,+context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,+offset:U32,+tick:Tick.Tick,+selection:Selection,+parallel:Bool) -> OutputRun<S,A,B,O,E>:
  match read write:
    case C.Leaf{a,sa} C.Leaf{b,sb}:output_leaf_run(~S,~A,~B,~O,~E,sa,output_leaf(~A,~B,~O,~V,~K,~E,~project,~body,context,a,b,sb,output,offset,8,tick,selection))
    case C.Branch{+half,al,ar} C.Branch{_,bl,br}:output_pair(~S,~A,~B,~O,~E,~merge,half,parallel,split(output),lo=>output_rows(~S,~A,~B,~O,~V,~K,~E,~project,~body,~split,~merge,context,al,bl,lo,offset,tick,selection,parallel),ro=>output_rows(~S,~A,~B,~O,~V,~K,~E,~project,~body,~split,~merge,context,ar,br,ro,U32.add(offset,half),tick,selection,parallel))
    case a b:OutputRun{a,b,output,[],False{}}
def output_execute(~S:Data,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,offset:U32,tick:Tick.Tick,selection:Selection,parallel:Bool,aligned:Bool) -> OutputRun<S,A,B,O,E>:
  match aligned:
    case False{}:OutputRun{read,write,output,[],False{}}
    case True{}:output_rows(~S,~A,~B,~O,~V,~K,~E,~project,~body,~split,~merge,context,read,write,output,offset,tick,selection,parallel)
def output_prepared(~S:Data,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,context:K,output:O,offset:U32,tick:Tick.Tick,selection:Selection,parallel:Bool,left:C.Column<S,A> & Layout,right:C.Column<S,B> & Layout) -> OutputRun<S,A,B,O,E>:
  match left right:
    case Tuple{read,ls} Tuple{write,rs}:output_execute(~S,~A,~B,~O,~V,~K,~E,~project,~body,~split,~merge,context,read,write,output,offset,tick,selection,parallel,same(ls,rs))
def with_output(~S:Data,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),~split:O -> O & O,~merge:O -> O -> O,context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,offset:U32,tick:Tick.Tick,selection:Selection,parallel:Bool) -> OutputRun<S,A,B,O,E>:
  output_prepared(~S,~A,~B,~O,~V,~K,~E,~project,~body,~split,~merge,context,output,offset,tick,selection,parallel,layout(~S,~A,read),layout(~S,~B,write))

def unit_split(_:Unit) -> Unit & Unit:(Unit{},Unit{})
def unit_merge(_:Unit,_:Unit) -> Unit:Unit{}
def unit_result(~B:Type,~E:Data,result:B & Maybe<&2,E>) -> B & (Unit & Maybe<&2,E>):
  match result:
    case (owner,error):(owner,(Unit{},error))
def unit_body(~B:Type,~V:Data,~E:Data,~body:U32 -> V -> B -> B & Maybe<&2,E>,_:Unit,index:U32,view:V,owner:B,_:Unit) -> B & (Unit & Maybe<&2,E>):
  unit_result(~B,~E,body(index,view,owner))
def unit_run(~S:Data,~A:Type,~B:Type,~E:Data,result:OutputRun<S,A,B,Unit,E>) -> Run<S,A,B,E>:
  match result:
    case OutputRun{read,write,_,errors,aligned}:Run{read,write,errors,aligned}
def selected(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,selection:Selection,parallel:Bool) -> Run<S,A,B,E>:
  unit_run(~S,~A,~B,~E,with_output(~S,~A,~B,~Unit,~V,~Unit,~E,~project,~unit_body(~B,~V,~E,~body),~unit_split,~unit_merge,Unit{},read,write,Unit{},offset,tick,selection,parallel))
def serial(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,All{},False{})
def parallel(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,All{},True{})
def serial_selected(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,selection:Selection) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,selection,False{})
def parallel_selected(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,selection:Selection) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,selection,True{})
