import Base
import ./legacy-fixture.bend as F
import ./game.bend as Game
import ./owner.bend as Owner
import ./legacy-owner.bend as Old
import ../../../../../../src/ecs/world.bend as W

type Observed<-S:Data> is Data:
  Observed{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,handles:List<&2,W.Handle<S>>,store:Old.StoreOwner,resources:Old.ResourceOwner,events:List<&2,Unit>,pendingCount:U32,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
# Observer returns the exact World fields, including the actual pending closures.
def restored(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,store:Game.Store(~S),storeData:Old.StoreOwner,+handles:List<&2,W.Handle<S>>,+events:List<&2,Unit>,pending:List<(W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>)>,pendingCount:U32,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observed:Game.ResourceStore(~S) & Old.ResourceOwner) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Observed<S>:
  match observed:
    case (resource,resourceData):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Observed{namespace,nextId,highWater,capacity,depth,handles,storeData,resourceData,events,pendingCount,registrations,nextSystemId,clock})
def store_done(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,resource:Game.ResourceStore(~S),+handles:List<&2,W.Handle<S>>,+events:List<&2,Unit>,pending:List<(W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>)>,pendingCount:U32,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observed:Game.Store(~S) & Old.StoreOwner) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Observed<S>:
  match observed:
    case (store,storeData):restored(~S,namespace,nextId,highWater,live,capacity,depth,store,storeData,handles,events,pending,pendingCount,registrations,nextSystemId,clock,Owner.resource(~S,resource))
def fields(~S:Data,pendingCount:U32,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & List<&2,W.Handle<S>>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Observed<S>:
  match observed:
    case (W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock},+handles):store_done(~S,namespace,nextId,highWater,live,capacity,depth,resource,handles,events,pending,pendingCount,registrations,nextSystemId,clock,Owner.store(~S,[W.Handle{namespace,1},W.Handle{namespace,2},W.Handle{namespace,3}],store))
def pending_done(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & U32) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Observed<S>:
  match observed:
    case (world,count):fields(~S,count,W.handles(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world))
def observe(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Observed<S>:
  pending_done(~S,W.pending_count(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world))
