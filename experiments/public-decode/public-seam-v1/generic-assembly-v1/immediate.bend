import Base
import ./owned-journal.bend as Journal
import ../full-assembly-v1/request.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch

# Trusted immediate structural kernel. Reversible receipts and refused owners
# leave the world journal; the provisioning frame retains them for Local.
def deactivated(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,C,R,E> & W.Status) -> W.World<S,C,R,E>:
  match result:
    case (world,_):world

def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,target:W.Handle<S>,result:Install.Restore<W.World<S,C,R,E>,Request.Packet<P>,Q>) -> Install.Restore<W.World<S,C,R,E>,Request.Packet<P>,Q>:
  match result:
    case Install.Restored{world,payload}:Install.Restored{deactivated(~S,~C,~R,~E,W.deactivate(~S,~C,~R,~E,world,target)),payload}
    case Install.Pending{world,recovery,error}:Install.Pending{world,recovery,error}

def receipt(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,+target:W.Handle<S>,world:W.World<S,C,R,E>,inverse:W.World<S,C,R,E> -> Install.Restore<W.World<S,C,R,E>,Request.Packet<P>,Q>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)> & Nat) -> T.Tx<W.World<S,C,R,E>,E> & (Result<&2,&2,W.WorldError,W.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<W.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>))):
  match result:
    case (undo,position):(T.Tx{world,undo,commands,events},(Done{target},(None{},(Some{Journal.Receipt{position,(world => restored(~S,~C,~R,~E,~P,~Q,target,inverse(world)))}},None{}))))

def installed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,+target:W.Handle<S>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:Install.Attempt<W.World<S,C,R,E>,Request.Packet<P>,Q>) -> T.Tx<W.World<S,C,R,E>,E> & (Result<&2,&2,W.WorldError,W.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<W.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>))):
  match result:
    case Install.Installed{world,inverse}:receipt(~S,~C,~R,~E,~P,~Q,target,world,inverse,commands,events,Batch.count_commands(~W.World<S,C,R,E>,undo))
    case Install.Refused{world,payload,error}:(T.Tx{deactivated(~S,~C,~R,~E,W.deactivate(~S,~C,~R,~E,world,target)),undo,commands,events},(Fail{error},(Some{payload},(None{},None{}))))
    case Install.Quarantined{world,recovery,+error}:(T.Tx{world,undo,commands,events},(Fail{error},(None{},(None{},Some{Journal.Pending{recovery,error}}))))

def activated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~install:W.World<S,C,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,C,R,E>,Request.Packet<P>,Q>,+target:W.Handle<S>,payload:Request.Packet<P>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:W.World<S,C,R,E> & W.Status) -> T.Tx<W.World<S,C,R,E>,E> & (Result<&2,&2,W.WorldError,W.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<W.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>))):
  match result:
    case (world,W.Accepted{}):installed(~S,~C,~R,~E,~P,~Q,target,undo,commands,events,install(world,target,payload))
    case (world,W.Rejected{error}):(T.Tx{world,undo,commands,events},(Fail{error},(Some{payload},(None{},None{}))))

def reserved(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~install:W.World<S,C,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,C,R,E>,Request.Packet<P>,Q>,payload:Request.Packet<P>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:W.World<S,C,R,E> & W.Reservation<S>) -> T.Tx<W.World<S,C,R,E>,E> & (Result<&2,&2,W.WorldError,W.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<W.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>))):
  match result:
    case (world,W.Reserved{+target}):activated(~S,~C,~R,~E,~P,~Q,~install,target,payload,undo,commands,events,W.activate(~S,~C,~R,~E,world,target))
    case (world,W.ReservationRejected{error}):(T.Tx{world,undo,commands,events},(Fail{error},(Some{payload},(None{},None{}))))

def reset_clock(~S:Data,~C:Type,~R:Type,~E:Data,clock:U32,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,commands,registrations,system,_}:W.World{ns,next,high,live,capacity,depth,store,resource,events,commands,registrations,system,clock}

def spawn(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~install:W.World<S,C,R,E> -> W.Handle<S> -> Request.Packet<P> -> Install.Attempt<W.World<S,C,R,E>,Request.Packet<P>,Q>,tx:T.Tx<W.World<S,C,R,E>,E>,payload:Request.Packet<P>) -> T.Tx<W.World<S,C,R,E>,E> & (Result<&2,&2,W.WorldError,W.Handle<S>> & (Maybe<&1,Request.Packet<P>> & (Maybe<&1,Journal.Receipt<W.World<S,C,R,E>,Request.Packet<P>,Q>> & Maybe<&1,Journal.Pending<Q>>))):
  match tx:
    case T.Tx{W.World{+ns,+next,+high,live,+capacity,+depth,store,resource,+published,queued,+registrations,+system,+clock},undo,commands,events}:reserved(~S,~C,~R,~E,~P,~Q,~install,payload,(world => reset_clock(~S,~C,~R,~E,clock,world)) <> undo,commands,events,W.reserve_id(~S,~C,~R,~E,W.World{ns,next,high,live,capacity,depth,store,resource,published,queued,registrations,system,clock}))
