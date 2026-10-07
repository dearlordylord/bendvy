import Base
import full-readers.bend as R
import full-observe.bend as O
import full-query.bend as Q
import full-locals.bend as Local
import handlers-tracked.bend as H
import full-provider.bend as P
import full-context.bend as Ctx
import ../../public-machines/machine.bend as M
import ../../public-machines/stream.bend as St
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as Tx
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/world.bend as W

# A closed template test predicate, not an owned runtime capture.
def exit_failure(phase:H.Phase,ordinal:U32) -> Bool:
  match phase:
    case H.Exit{}: U32.is_eq(ordinal,0)
    case _: False{}
def transition_failure(phase:H.Phase,ordinal:U32) -> Bool:
  match phase:
    case H.Transition{}: U32.is_eq(ordinal,0)
    case _: False{}
def enter_failure(phase:H.Phase,ordinal:U32) -> Bool:
  match phase:
    case H.Enter{}: U32.is_eq(ordinal,0)
    case _: False{}
def success(phase:H.Phase,ordinal:U32) -> Bool:
  False{}
def phase_code(phase:H.Phase) -> U32:
  match phase:
    case H.Exit{}: 1
    case H.Transition{}: 2
    case H.Enter{}: 3
def outcome(failed:Bool) -> Tx.Outcome<String>:
  match failed:
    case True{}: Tx.Failure{"HandlerFailed"}
    case False{}: Tx.Success{}
type Work<S:Data,-F:Type> is Type:
  Work{cells:Cap.Send<F,Unit>,owned:Cap.Send<F,Unit>,next:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,emit:Cap.Send<F,P.Ping>,spawn:Cap.Send<F,Array<U32>>}
def send(~S:Data,-F:Type,cap:Cap.Send<F,Array<U32>>,owner:F,value:Array<U32>) -> F:
  match cap:
    case Cap.Send{send}: send(owner,value)
def operate(-F:Type,cap:Cap.Send<F,Unit>,owner:F) -> F:
  match cap:
    case Cap.Send{send}: send(owner,Unit{})
def emit_ping(-F:Type,cap:Cap.Send<F,P.Ping>,owner:F,event:P.Ping) -> F:
  match cap:
    case Cap.Send{send}: send(owner,event)
def next_in_enter(~S:Data,-F:Type,cap:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,owner:F) -> F:
  match cap:
    case Cap.ValueWrite{_,set}: set(owner,M.Set{P.Pause{},False{}})
def next_selected(~S:Data,-F:Type,cap:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,phase:H.Phase,ordinal:U32,owner:F) -> F:
  match phase ordinal:
    case H.Enter{}, 0: next_in_enter(~S,F,cap,owner)
    case _, _: owner
# F is rank2 abstract; gameplay never receives a concrete World or Frame.
def invoked(~S:Data,~V:Data,~failure:H.Phase -> U32 -> Bool,-F:Type,cells:Cap.Send<F,Unit>,owned:Cap.Send<F,Unit>,next:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,emit:Cap.Send<F,P.Ping>,spawn:Cap.Send<F,Array<U32>>,invocation:H.Invocation<V>,+attempt:U32,owner:F) -> F & Tx.Outcome<String>:
  match invocation:
    case H.Invocation{+phase,+ordinal,_,_}:
      +code=U32.add(U32.mul(phase_code(phase),10),ordinal)
      owner=operate(F,cells,owner)
      owner=operate(F,owned,owner)
      +index=U32.add(U32.mul(U32.sub(phase_code(phase),1),2),ordinal)
      owner=emit_ping(F,emit,owner,P.Ping{index,attempt})
      owner=send(~S,F,spawn,owner,ANode{ANode{ALeaf{U32.add(100,index)},ALeaf{U32.add(1000,index)}},ANode{ALeaf{0},ALeaf{0}}})
      (next_selected(~S,F,next,phase,ordinal,owner),outcome(Bool.and(failure(phase,ordinal),U32.is_eq(attempt,1))))
def body(~S:Data,~V:Data,~failure:H.Phase -> U32 -> Bool,-F:Type,caps:Work<S,F>,invocation:H.Invocation<V>,attempt:U32,owner:F) -> F & Tx.Outcome<String>:
  match caps:
    case Work{cells,owned,next,emit,spawn}: invoked(~S,~V,~failure,F,cells,owned,next,emit,spawn,invocation,attempt,owner)
def invoked_local(~S:Data,~failure:H.Phase -> U32 -> Bool,invocation:H.Invocation<P.Flow>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  (world,attempt)=pair
  Ctx.finish(~S,body(~S,~P.Flow,~failure,Ctx.Frame<S>,Work{Cap.Send{frame => value => Q.increment_all(~S,frame,value)},Cap.Send{frame => value => Q.increment_owned(~S,frame,value)},Cap.ValueWrite{frame => Ctx.flow_pending(~S,frame),frame => value => Ctx.flow_next(~S,frame,value)},Cap.Send{frame => event => Ctx.emit(~S,frame,event)},Cap.Send{frame => value => Ctx.spawn_seed(~S,frame,value)}},invocation,attempt,Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,~P.Ping,world),None{}}))
def handler_name(index:U32) -> String:
  match index:
    case 0: "exit0"
    case 1: "exit1"
    case 2: "transition0"
    case 3: "transition1"
    case 4: "enter0"
    case 5: "enter1"
    case _: "level0"
def hook_finished(~S:Data,+index:U32,+attempt:U32,result:Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match result:
    case Sys.Failed{world,_}: Sys.Failed{world,"hook-failed:" ++ handler_name(index)}
    case Sys.Succeeded{world,_}: Sys.Succeeded{R.hook_succeeded(~S,U32.add(index,1),P.Ping{index,attempt},world),Unit{}}
def hook_world(~S:Data,~failure:H.Phase -> U32 -> Bool,+invocation:H.Invocation<P.Flow>,+index:U32,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match invocation pair:
    case H.Invocation{_,_,from,to}, (world,+attempt): hook_finished(~S,index,attempt,invoked_local(~S,~failure,invocation,(R.before_hook(~S,world,U32.add(index,1),handler_name(index),attempt,O.flow(from) ++ ">" ++ O.flow(to)),attempt)))
def runner_invocation(~S:Data,~failure:H.Phase -> U32 -> Bool,+invocation:H.Invocation<P.Flow>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match invocation:
    case H.Invocation{phase,ordinal,_,_}: hook_world(~S,~failure,invocation,U32.add(U32.mul(U32.sub(phase_code(phase),1),2),ordinal),Local.invoke(~S,world,U32.add(U32.mul(U32.sub(phase_code(phase),1),2),U32.add(ordinal,1))))

def runner(~S:Data,~failure:H.Phase -> U32 -> Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,invocation:H.Invocation<P.Flow>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  runner_invocation(~S,~failure,invocation,world)

def publish_resource(~S:Data,resources:P.Resources<S>,event:M.Transition<P.Flow>) -> P.Resources<S>:
  match resources:
    case P.Resources{owned,flow,level,stream,levelStream,frame,+tick,trace,aux}: P.Resources{owned,flow,level,St.publish(~P.Flow,stream,1n+tick,event),levelStream,frame,1n+tick,trace,aux}
def publish(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,event:M.Transition<P.Flow>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}: W.World{ns,next,high,live,capacity,depth,store,publish_resource(~S,resources,event),events,commands,registrations,nextSystem,clock}


def register(~S:Data,~failure:H.Phase -> U32 -> Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,name:String) -> Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,runner(~S,~failure)>:
  Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~H.Invocation<P.Flow>,~String,~Unit,~runner(~S,~failure),world,name,["component.Cells.write","resource.Owned.write","event.Ping.read","event.Ping.emit","machine.Flow.read","machine.Level.read","machine.Flow.next","transition.Flow.read","transition.Level.read"])
def apply_phases(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,captured:M.Snapshot<P.Flow>) -> H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>:
  H.run(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~P.Flow,~runner(~S,~failure),~P.FlowToken,~(world => P.flow_take(~S,world)),~(world => slot => P.flow_put(~S,world,slot)),~(world => event => publish(~S,world,event)),~P.flow_same,owners,world,captured)

def restored_idle(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>,result:H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>) -> H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>:
  match result:
    case H.Completed{_,world}: H.Completed{owners,world}
    case H.Stopped{_,world,phase,error}: H.Stopped{owners,world,phase,error}
def selected_phases(~S:Data,~failure:H.Phase -> U32 -> Bool,applicable:Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,captured:M.Snapshot<P.Flow>) -> H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>:
  match applicable:
    case True{}: apply_phases(~S,~failure,owners,world,captured)
    case False{}: restored_idle(~S,~failure,owners,apply_phases(~S,~failure,H.Owners{[],[],[]},world,captured))
def selected_slot(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & M.Slot<S,P.FlowToken,P.Flow>,+captured:M.Snapshot<P.Flow>) -> H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>:
  match pair captured:
    case (world,+slot), M.Scheduled{P.Play{},_}: selected_phases(~S,~failure,M.current_matches(~S,~P.FlowToken,~P.Flow,~P.flow_same,slot,P.Boot{}),owners,P.flow_put(~S,world,slot),captured)
    case (world,slot), captured: selected_phases(~S,~failure,False{},owners,P.flow_put(~S,world,slot),captured)
def apply(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,captured:M.Snapshot<P.Flow>) -> H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,runner(~S,~failure)>:
  selected_slot(~S,~failure,owners,P.flow_take(~S,world),captured)

def level_body(~S:Data,invocation:H.Invocation<P.Level>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match invocation pair:
    case +invocation, (world,+attempt): hook_finished(~S,6,attempt,Ctx.finish(~S,body(~S,~P.Level,~success,Ctx.Frame<S>,Work{Cap.Send{frame => value => Q.increment_all(~S,frame,value)},Cap.Send{frame => value => Q.increment_owned(~S,frame,value)},Cap.ValueWrite{frame => Ctx.flow_pending(~S,frame),frame => value => Ctx.flow_next(~S,frame,value)},Cap.Send{frame => event => Ctx.emit(~S,frame,event)},Cap.Send{frame => value => Ctx.spawn_seed(~S,frame,value)}},invocation,attempt,Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,~P.Ping,world),None{}})))
def level_hook(~S:Data,+invocation:H.Invocation<P.Level>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & U32) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match invocation pair:
    case H.Invocation{_,_,from,to}, (world,+attempt): level_body(~S,invocation,(R.before_hook(~S,world,7,"level0",attempt,O.level(from) ++ ">" ++ O.level(to)),attempt))
def level_runner(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,invocation:H.Invocation<P.Level>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  level_hook(~S,invocation,Local.invoke(~S,world,7))
