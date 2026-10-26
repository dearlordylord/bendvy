import Base
import ./chunk-column.bend as C
import ./lifecycle.bend as L
import ./change-tick.bend as Tick

type Error<-E:Data> is Data:
  Error{index:U32,value:E}
type Row<-A:Type,-B:Type,-E:Data> is Type:
  Row{read:Maybe<&1,A>,write:Maybe<&1,B>,stamp:L.Stamp,errors:List<&2,Error<E>>}
type Values<-A:Type,-B:Type,-E:Data> is Type:
  Values{read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,errors:List<&2,Error<E>>,aligned:Bool}
type Run<-S:Data,-A:Type,-B:Type,-E:Data> is Type:
  Run{read:C.Column<S,A>,write:C.Column<S,B>,errors:List<&2,Error<E>>,aligned:Bool}

def row_result(~A:Type,~B:Type,~E:Data,owner:A,index:U32,stamp:L.Stamp,result:B & Maybe<&2,E>) -> Row<A,B,E>:
  match result:
    case (write,None{}): Row{Some{owner},Some{write},stamp,[]}
    case (write,Some{error}): Row{Some{owner},Some{write},stamp,[Error{index,error}]}
def row_projected(~A:Type,~B:Type,~V:Data,~E:Data,~body:U32 -> V -> B -> B & Maybe<&2,E>,write:B,+index:U32,stamp:L.Stamp,tick:Tick.Tick,result:A & V) -> Row<A,B,E>:
  match result:
    case (read,view): row_result(~A,~B,~E,read,index,L.written(True{},stamp,tick),body(index,view,write))
def row(~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:Maybe<&1,A>,write:Maybe<&1,B>,index:U32,stamp:L.Stamp,tick:Tick.Tick) -> Row<A,B,E>:
  match read write:
    case None{} write: Row{None{},write,stamp,[]}
    case Some{read} None{}: Row{Some{read},None{},stamp,[]}
    case Some{read} Some{write}: row_projected(~A,~B,~V,~E,~body,write,index,stamp,tick,project(read))
def row_values(~A:Type,~B:Type,~E:Data,result:Row<A,B,E>) -> Values<A,B,E>:
  match result:
    case Row{read,write,stamp,errors}: Values{ALeaf{read},ALeaf{write},ALeaf{stamp},errors,True{}}
def values_join(~A:Type,~B:Type,~E:Data,left:Values<A,B,E>,right:Values<A,B,E>) -> Values<A,B,E>:
  match left right:
    case Values{la,lb,ls,le,lv} Values{ra,rb,rs,re,rv}: Values{ANode{la,ra},ANode{lb,rb},ANode{ls,rs},List.append(&2,Error<E>,le,re),Bool.and(lv,rv)}
def leaf_rows(~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,+offset:U32,+size:U32,+tick:Tick.Tick) -> Values<A,B,E>:
  match read write stamps:
    case ALeaf{a} ALeaf{b} ALeaf{stamp}: row_values(~A,~B,~E,row(~A,~B,~V,~E,~project,~body,a,b,offset,stamp,tick))
    case ANode{al,ar} ANode{bl,br} ANode{sl,sr}:
      values_join(~A,~B,~E,leaf_rows(~A,~B,~V,~E,~project,~body,al,bl,sl,offset,U32.shr(size),tick),leaf_rows(~A,~B,~V,~E,~project,~body,ar,br,sr,U32.add(offset,U32.shr(size)),U32.shr(size),tick))
    case a b s: Values{a,b,s,[],False{}}
def leaf_run(~S:Data,~A:Type,~B:Type,~E:Data,readStamps:Array<L.Stamp>,result:Values<A,B,E>) -> Run<S,A,B,E>:
  match result:
    case Values{a,b,stamps,errors,aligned}: Run{C.Leaf{a,readStamps},C.Leaf{b,stamps},errors,aligned}
def run_join(~S:Data,~A:Type,~B:Type,~E:Data,+half:U32,left:Run<S,A,B,E>,right:Run<S,A,B,E>) -> Run<S,A,B,E>:
  match left right:
    case Run{la,lb,le,lv} Run{ra,rb,re,rv}: Run{C.Branch{half,la,ra},C.Branch{half,lb,rb},List.append(&2,Error<E>,le,re),Bool.and(lv,rv)}
def serial_rows(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,+offset:U32,+tick:Tick.Tick) -> Run<S,A,B,E>:
  match read write:
    case C.Leaf{a,sa} C.Leaf{b,sb}: leaf_run(~S,~A,~B,~E,sa,leaf_rows(~A,~B,~V,~E,~project,~body,a,b,sb,offset,8,tick))
    case C.Branch{+half,al,ar} C.Branch{_,bl,br}:
      run_join(~S,~A,~B,~E,half,serial_rows(~S,~A,~B,~V,~E,~project,~body,al,bl,offset,tick),serial_rows(~S,~A,~B,~V,~E,~project,~body,ar,br,U32.add(offset,half),tick))
    case a b: Run{a,b,[],False{}}
def parallel_rows(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,+offset:U32,+tick:Tick.Tick) -> Run<S,A,B,E>:
  match read write:
    case C.Leaf{a,sa} C.Leaf{b,sb}: leaf_run(~S,~A,~B,~E,sa,leaf_rows(~A,~B,~V,~E,~project,~body,a,b,sb,offset,8,tick))
    case C.Branch{+half,al,ar} C.Branch{_,bl,br}:
      left right = parallel_rows(~S,~A,~B,~V,~E,~project,~body,al,bl,offset,tick) parallel_rows(~S,~A,~B,~V,~E,~project,~body,ar,br,U32.add(offset,half),tick)
      run_join(~S,~A,~B,~E,half,left,right)
    case a b: Run{a,b,[],False{}}

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
def execute(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,parallel:Bool,aligned:Bool) -> Run<S,A,B,E>:
  match parallel aligned:
    case _ False{}: Run{read,write,[],False{}}
    case False{} True{}: serial_rows(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick)
    case True{} True{}: parallel_rows(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick)
def prepared(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,offset:U32,tick:Tick.Tick,parallel:Bool,left:C.Column<S,A> & Layout,right:C.Column<S,B> & Layout) -> Run<S,A,B,E>:
  match left right:
    case Tuple{read,ls} Tuple{write,rs}: execute(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,parallel,same(ls,rs))
def serial(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick) -> Run<S,A,B,E>:
  prepared(~S,~A,~B,~V,~E,~project,~body,offset,tick,False{},layout(~S,~A,read),layout(~S,~B,write))
def parallel(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick) -> Run<S,A,B,E>:
  prepared(~S,~A,~B,~V,~E,~project,~body,offset,tick,True{},layout(~S,~A,read),layout(~S,~B,write))
