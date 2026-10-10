import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H

# Generic existing handler prepare/commit/retry sequencing; C and R remain affine Type.
type Intent<V:Data> is Data:
  Idle{}
  Ready{from:V,to:V,skipSame:Bool}
type Owners<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Owners{handlers:H.Owners<S,C,R,E,V,runner>,intent:Intent<V>}
def published(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,world:W.World<S,C,R,E>,event:M.Transition<V>) -> W.World<S,C,R,E>:publish(world,event)
def requeued(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,to:V,skipSame:Bool,pair:W.World<S,C,R,E> & M.Slot<S,K,V>) -> W.World<S,C,R,E>:
  (world,slot)=pair
  put(world,M.queue(~S,~K,~V,slot,to,skipSame))
def committed(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,+from:V,+to:V,pair:W.World<S,C,R,E> & M.Slot<S,K,V>) -> W.World<S,C,R,E>:
  (world,slot)=pair
  published(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,put(world,H.committed(~S,~K,~V,slot,from,to)),M.Transition{from,to})
def prepared(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,handlers:H.Owners<S,C,R,E,V,runner>,world:W.World<S,C,R,E>,value:H.Prepared<S,K,V>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match value:
    case H.Idle{slot}:(Owners{handlers,Idle{}},Sys.Succeeded{put(world,slot),Unit{}})
    case H.Ready{slot,M.Transition{from,to},skipSame}:(Owners{handlers,Ready{from,to,skipSame}},Sys.Succeeded{put(world,slot),Unit{}})
def captured(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,handlers:H.Owners<S,C,R,E,V,runner>,pair:W.World<S,C,R,E> & M.Slot<S,K,V>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  (world,+slot)=pair
  prepared(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,handlers,world,H.prepare(~S,~K,~V,~same,slot,M.snapshot(~S,~K,~V,slot)))
def apply(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{handlers,_}:captured(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,handlers,take(frame(world)))
def exited(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,transition:List<&1,H.Entry<S,C,R,E,V,runner>>,enter:List<&1,H.Entry<S,C,R,E,V,runner>>,+from:V,+to:V,+skipSame:Bool,result:H.PhaseResult<S,C,R,E,V,runner>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case H.Complete{exit,world}:(Owners{H.Owners{exit,transition,enter},Ready{from,to,skipSame}},Sys.Succeeded{world,Unit{}})
    case H.Failed{exit,world,error}:(Owners{H.Owners{exit,transition,enter},Ready{from,to,skipSame}},Sys.Failed{requeued(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,to,skipSame,take(world)),error})
def exit(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{handlers,Idle{}}:(Owners{handlers,Idle{}},Sys.Succeeded{world,Unit{}})
    case Owners{H.Owners{exit,transition,enter},Ready{+from,+to,+skipSame}}:exited(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,transition,enter,from,to,skipSame,H.run_phase(~S,~C,~R,~E,~V,~runner,exit,world,H.Exit{},from,to,None{}))
def transitioned(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,exit:List<&1,H.Entry<S,C,R,E,V,runner>>,enter:List<&1,H.Entry<S,C,R,E,V,runner>>,+from:V,+to:V,+skipSame:Bool,result:H.PhaseResult<S,C,R,E,V,runner>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case H.Complete{transition,world}:(Owners{H.Owners{exit,transition,enter},Ready{from,to,skipSame}},Sys.Succeeded{committed(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,from,to,take(world)),Unit{}})
    case H.Failed{transition,world,error}:(Owners{H.Owners{exit,transition,enter},Ready{from,to,skipSame}},Sys.Failed{requeued(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,to,skipSame,take(world)),error})
def transition(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{handlers,Idle{}}:(Owners{handlers,Idle{}},Sys.Succeeded{world,Unit{}})
    case Owners{H.Owners{exit,transition,enter},Ready{+from,+to,+skipSame}}:transitioned(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,exit,enter,from,to,skipSame,H.run_phase(~S,~C,~R,~E,~V,~runner,transition,world,H.Transition{},from,to,None{}))
def entered(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,exit:List<&1,H.Entry<S,C,R,E,V,runner>>,transition:List<&1,H.Entry<S,C,R,E,V,runner>>,intent:Intent<V>,result:H.PhaseResult<S,C,R,E,V,runner>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case H.Complete{enter,world}:(Owners{H.Owners{exit,transition,enter},intent},Sys.Succeeded{world,Unit{}})
    case H.Failed{enter,world,error}:(Owners{H.Owners{exit,transition,enter},intent},Sys.Failed{world,error})
def enter(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{handlers,Idle{}}:(Owners{handlers,Idle{}},Sys.Succeeded{world,Unit{}})
    case Owners{H.Owners{exit,transition,enter},Ready{+from,+to,+skipSame}}:entered(~S,~K,~V,~C,~R,~E,~runner,~take,~put,~publish,~same,~frame,exit,transition,Ready{from,to,skipSame},H.run_phase(~S,~C,~R,~E,~V,~runner,enter,world,H.Enter{},from,to,None{}))
