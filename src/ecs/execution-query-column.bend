import Base
import ./chunk-column.bend as Col
import ./chunk-partition.bend as Part
import ./execution-composer-layout.bend as L
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life

type Edit<-S:Data,-C:Type,-P:Type,-Out:Type> is Type:
  Edited{column:Col.Column<S,C>,output:Out}
  Unchanged{column:Col.Column<S,C>,unused:P -> P & Out}
def rewritten(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,values:Array<Maybe<&1,L.stored(layout,route)>>,stamps:Array<Life.Stamp>,+index:U32,tick:Tick.Tick,result:L.stored(layout,route) & Out) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  match result:
    case (owner,out):Edited{Col.Leaf{Array.set(Maybe<&1,L.stored(layout,route)>,values,index,Some{owner}),Col.edit_stamps(stamps,index,tick,True{})},out}
def taken(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,stamps:Array<Life.Stamp>,index:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out,result:Array<Maybe<&1,L.stored(layout,route)>> & Maybe<&1,L.stored(layout,route)>) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  match result:
    case (values,None{}):Unchanged{Col.Leaf{values,stamps},transform}
    case (values,Some{owner}):rewritten(~S,~layout,~route,Out,values,stamps,index,tick,L.rewrite(~layout,~route,Out,transform,owner))
def left_returned(-S:Data,-C:Type,-P:Type,-Out:Type,half:U32,right:Col.Column<S,C>,result:Edit<S,C,P,Out>) -> Edit<S,C,P,Out>:
  match result:
    case Edited{left,out}:Edited{Col.Branch{half,left,right},out}
    case Unchanged{left,unused}:Unchanged{Col.Branch{half,left,right},unused}
def right_returned(-S:Data,-C:Type,-P:Type,-Out:Type,half:U32,left:Col.Column<S,C>,result:Edit<S,C,P,Out>) -> Edit<S,C,P,Out>:
  match result:
    case Edited{right,out}:Edited{Col.Branch{half,left,right},out}
    case Unchanged{right,unused}:Unchanged{Col.Branch{half,left,right},unused}
def branch(-S:Data,-C:Type,-P:Type,-Out:Type,+half:U32,left:Col.Column<S,C>,right:Col.Column<S,C>,goLeft:Col.Column<S,C> -> (P -> P & Out) -> Edit<S,C,P,Out>,goRight:Col.Column<S,C> -> (P -> P & Out) -> Edit<S,C,P,Out>,transform:P -> P & Out,first:Bool) -> Edit<S,C,P,Out>:
  match first:
    case True{}:left_returned(S,C,P,Out,half,right,goLeft(left,transform))
    case False{}:right_returned(S,C,P,Out,half,left,goRight(right,transform))
def tree(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,shape:Part.Shape,column:Col.Column<S,L.stored(layout,route)>,+index:U32,+tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  match shape column:
    case Part.Leaf{} Col.Leaf{values,stamps}:taken(~S,~layout,~route,Out,stamps,index,tick,transform,Array.swap(Maybe<&1,L.stored(layout,route)>,values,index,None{}))
    case Part.Branch{+half,leftShape,rightShape} Col.Branch{_,left,right}:branch(S,L.stored(layout,route),L.payload(layout,route),Out,half,left,right,(column=>transform=>tree(~S,~layout,~route,Out,leftShape,column,index,tick,transform)),(column=>transform=>tree(~S,~layout,~route,Out,rightShape,column,U32.sub(index,half),tick,transform)),transform,U32.is_lt(index,half))
    case _ column:Unchanged{column,transform}
def checked(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,shape:Part.Shape,column:Col.Column<S,L.stored(layout,route)>,index:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out,valid:Bool) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  match valid:
    case False{}:Unchanged{column,transform}
    case True{}:tree(~S,~layout,~route,Out,shape,column,index,tick,transform)
def inspected(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,+index:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out,result:Col.Column<S,L.stored(layout,route)> & Part.Inspection) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  match result:
    case (column,Part.Inspection{shape,capacity,valid}):checked(~S,~layout,~route,Out,shape,column,index,tick,transform,Bool.and(valid,U32.is_lt(index,capacity)))
def edit(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,column:Col.Column<S,L.stored(layout,route)>,index:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  inspected(~S,~layout,~route,Out,index,tick,transform,Part.inspect(S,L.stored(layout,route),column))
