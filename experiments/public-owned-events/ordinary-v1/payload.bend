import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T

type Request is Type: Request{index:U32,markers:Array<U32>}
type Projection is Data: Projection{value:U32,markers:List<&2,U32>}
type Error is Data: ReadFailed{}
type Args is Type: Args{fail:Bool,values:List<&2,Projection>,scratch:Array<U32>}
type Tree is Data:
  Leaf{value:U32}
  Node{left:Tree,right:Tree}
def payload(+seed:U32) -> Array<U32>:ANode{ALeaf{seed},ALeaf{(seed+1 : U32)}}
def cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}:[value]
    case ANode{left,right}:List.append(&2,U32,cells(left),cells(right))
def joined(left:Array<U32> & Tree,right:Array<U32> & Tree) -> Array<U32> & Tree:
  match left right:
    case (left,lview), (right,rview):(ANode{left,right},Node{lview,rview})
def view(owner:Array<U32>) -> Array<U32> & Tree:
  match owner:
    case ALeaf{+value}:(ALeaf{value},Leaf{value})
    case ANode{left,right}:joined(view(left),view(right))
def projected(markers:List<&2,U32>,result:Array<U32> & U32) -> Array<U32> & Projection:
  match result:
    case (owner,value):(owner,Projection{value,markers})
def at(owner:Array<U32>,input:Request) -> Array<U32> & Projection:
  match input:
    case Request{index,markers}:projected(cells(markers),Array.get(U32,owner,index))
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{ReadFailed{}}
def increment(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,n):Array.set(U32,owner,0,(n+1 : U32))
def read_done(~H:Type,+fail:Bool,values:List<&2,Projection>,scratch:Array<U32>,result:H & Projection) -> H & (T.Outcome<Error> & Args):
  match result:
    case (owner,+projection):(owner,(outcome(fail),Args{fail,List.append(&2,Projection,values,[projection]),increment(Array.get(U32,scratch,0))}))
def read(~H:Type,~grant:Cap.Request<H,Request,Projection>,owner:H,args:Args) -> H & (T.Outcome<Error> & Args):
  match args:
    case Args{+fail,values,scratch}:read_done(~H,fail,values,scratch,Cap.request(~H,~Request,~Projection,~grant,owner,Request{0,payload(90)}))
def args(fail:Bool,seed:U32) -> Args:Args{fail,[],payload(seed)}
