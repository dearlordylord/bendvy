import Base
import ./execution-lifecycle-notices.bend as Notice
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import entity-allocator.bend as Alloc
import ./world.bend as W
import ./owner-product.bend as Product
# Canonical owner split, used only behind ordinary declaration providers.
type Rest<S:Data,C:Type,R:Type,E:Data> is Type:
  Rest{namespace:U32,allocator:Alloc.Allocator,store:C,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def take(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> Rest<S,C,R,E> & R:
  match world:
    case W.World{ns,allocator,store,resource,events,pending,regs,sid,clock,lifecycle}:(Rest{ns,allocator,store,events,pending,regs,sid,clock,lifecycle},resource)
def put(~S:Data,~C:Type,~R:Type,~E:Data,rest:Rest<S,C,R,E>,resource:R) -> W.World<S,C,R,E>:
  match rest:
    case Rest{ns,allocator,store,events,pending,regs,sid,clock,lifecycle}:W.World{ns,allocator,store,resource,events,pending,regs,sid,clock,lifecycle}
def lens(~S:Data,~C:Type,~R:Type,~E:Data) -> Product.Lens<W.World<S,C,R,E>,R,Rest<S,C,R,E>>:
  Product.Lens{take(~S,~C,~R,~E),put(~S,~C,~R,~E)}
