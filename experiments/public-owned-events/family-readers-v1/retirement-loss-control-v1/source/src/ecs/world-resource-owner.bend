import Base
import ./world.bend as W
import ./owner-product.bend as Product
# Canonical owner split, used only behind ordinary declaration providers.
type Rest<S:Data,C:Type,R:Type,E:Data> is Type:
  Rest{namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:C,events:List<&2,E>,pending:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
def take(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> Rest<S,C,R,E> & R:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:(Rest{ns,next,high,live,capacity,depth,store,events,pending,regs,sid,clock},resource)
def put(~S:Data,~C:Type,~R:Type,~E:Data,rest:Rest<S,C,R,E>,resource:R) -> W.World<S,C,R,E>:
  match rest:
    case Rest{ns,next,high,live,capacity,depth,store,events,pending,regs,sid,clock}:W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}
def lens(~S:Data,~C:Type,~R:Type,~E:Data) -> Product.Lens<W.World<S,C,R,E>,R,Rest<S,C,R,E>>:
  Product.Lens{take(~S,~C,~R,~E),put(~S,~C,~R,~E)}
