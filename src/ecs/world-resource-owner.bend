import Base
import entity-allocator.bend as Alloc
import ./world.bend as W
import ./owner-product.bend as Product
# Canonical owner split, used only behind ordinary declaration providers.
type Rest<S:Data,C:Type,R:Type,E:Data> is Type:
  Rest{namespace:U32,allocator:Alloc.Allocator,store:C,events:List<&2,E>,pending:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
def take(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> Rest<S,C,R,E> & R:
  match world:
    case W.World{ns,allocator,store,resource,events,pending,regs,sid,clock}:(Rest{ns,allocator,store,events,pending,regs,sid,clock},resource)
def put(~S:Data,~C:Type,~R:Type,~E:Data,rest:Rest<S,C,R,E>,resource:R) -> W.World<S,C,R,E>:
  match rest:
    case Rest{ns,allocator,store,events,pending,regs,sid,clock}:W.World{ns,allocator,store,resource,events,pending,regs,sid,clock}
def lens(~S:Data,~C:Type,~R:Type,~E:Data) -> Product.Lens<W.World<S,C,R,E>,R,Rest<S,C,R,E>>:
  Product.Lens{take(~S,~C,~R,~E),put(~S,~C,~R,~E)}
