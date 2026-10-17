import Base
import ../fixture.bend as F
import ../scenario.bend as S
import ../observe.bend as O
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/entity-allocator.bend as A

def replace_order(order:List<&2,K.Key>,+before:K.Key,+after:K.Key) -> List<&2,K.Key>:
  match order:
    case []:[]
    case +key <> rest:Bool.pick(K.Key,K.equal(key,before),after,key) <> replace_order(rest,before,after)
def seeded_join(~S:Data,+namespace:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,store:F.Store<S>,resource:Array<U32>,+events:List<&2,F.Notice<S>>,pending:List<(F.World(~S) -> F.World(~S))>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,+before:K.Key,+after:K.Key,observed:Array<A.Slot> & A.Slot) -> F.World(~S) & W.Handle<S>:
  match observed:
    case (slots,A.Slot{_,phase}):(W.World{namespace,A.Allocator{next,high,Array.set(A.Slot,slots,K.index(after),A.Slot{4294967295,phase}),capacity,depth,free,replace_order(order,before,after)},store,resource,events,pending,regs,sid,clock},W.Handle{namespace,after})
# Explicit trusted admin seeding of an actual allocated live slot. All other
# physical state is returned unchanged; no gameplay API fabricates this state.
def seed_world(~S:Data,world:F.World(~S),handle:W.Handle<S>) -> F.World(~S) & W.Handle<S>:
  match world handle:
    case W.World{+namespace,A.Allocator{+next,+high,slots,+capacity,+depth,+free,+order},store,resource,+events,pending,+regs,+sid,+clock} W.Handle{_,+key}:seeded_join(~S,namespace,next,high,capacity,depth,free,order,store,resource,events,pending,regs,sid,clock,key,K.EntityKey{K.index(key),4294967295},Array.get(A.Slot,slots,K.index(key)))
def seed_join(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:F.World(~S) & W.Handle<S>) -> S.Session<S>:
  match result:
    case (world,+current):S.Session{world,foreign,foreignHandle,List.append(&2,W.Handle<S>,handles,[current]),log ++ "admin-current-key:" ++ F.handle_text(~S,current) ++ "\n"}
def seed_target(~S:Data,session:S.Session<S>,target:Maybe<&2,W.Handle<S>>) -> S.Session<S>:
  match session target:
    case session None{}:S.row(~S,"admin-seed",session,"missing-actual-receipt")
    case S.Session{world,foreign,foreignHandle,handles,log} Some{handle}:seed_join(~S,foreign,foreignHandle,handles,log,seed_world(~S,world,handle))
def seed(~S:Data,session:S.Session<S>) -> S.Session<S>:
  match session:
    case S.Session{world,foreign,foreignHandle,+handles,log}:seed_target(~S,S.Session{world,foreign,foreignHandle,handles,log},S.at(~S,0n,handles))
def steps(~S:Data,session:S.Session<S>) -> S.Session<S>:
  session=S.checkpoint(~S,"initial",session)
  session=S.checkpoint(~S,"actual-original-generation-zero",S.barrier(~S,S.spawn(~S,100,session)))
  session=S.checkpoint(~S,"admin-live-generation-max",seed(~S,session))
  session=S.checkpoint(~S,"queued-max-clear",S.despawn(~S,1n,session))
  session=S.checkpoint(~S,"free-generation-wrapped-zero",S.barrier(~S,session))
  session=S.checkpoint(~S,"ordinary-reuse-zero-pending",S.spawn(~S,200,session))
  session=S.checkpoint(~S,"ordinary-reuse-zero-live",S.barrier(~S,session))
  session=S.checkpoint(~S,"ancient-zero-read-alias",S.read(~S,0n,session))
  session=S.checkpoint(~S,"foreign-same-zero-refused",S.foreign_despawn(~S,session))
  session=S.checkpoint(~S,"ancient-zero-despawn-alias",S.despawn(~S,0n,session))
  session=S.checkpoint(~S,"alias-cleaned-generation-one",S.barrier(~S,session))
  session=S.checkpoint(~S,"ancient-zero-no-live-entity",S.read(~S,0n,session))
  session=S.checkpoint(~S,"ordinary-reuse-one-live",S.barrier(~S,S.spawn(~S,300,session)))
  S.checkpoint(~S,"ancient-zero-stale-again",S.read(~S,0n,session))
def started(~S:Data,world:F.World(~S),sender:F.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match sender:
    case (foreign,None{}):"sender-spawn-refused"
    case (foreign,Some{foreignHandle}):S.rendered(~S,steps(~S,S.Session{world,W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,foreign),foreignHandle,[],""}))
def sender_created(created:WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,world:F.World(~F.Workshop)) -> IO(Unit):
  match created:
    case WI.Refused{_}:IO.print("sender-creation-refused")
    case WI.Created{sender}:IO.print(started(~F.Workshop,world,F.spawn(~F.Workshop,sender,700)))
def receiver_created(created:WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>) -> IO(Unit):
  match created:
    case WI.Refused{_}:IO.print("receiver-creation-refused")
    case WI.Created{world}:IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{71},ALeaf{72}}),created=>sender_created(created,world))
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{61},ALeaf{62}}),receiver_created)
