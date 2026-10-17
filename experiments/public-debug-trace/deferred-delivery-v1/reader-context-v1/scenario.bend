import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import ../../../../src/ecs/ordinary-app-checked-schedule.bend as App
import ../../../../src/ecs/checked-condition-schedule.bend as Engine
import ../../../../src/ecs/execution-trace.bend as Trace

type State<S:Data> is Type:
  State{app:F.Application(~S),subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,ids:List<&2,Nat>}
def collectors_join(first:F.Collector & String,rest:List<F.Collector> & String) -> List<F.Collector> & String:
  match first rest:
    case (first,a), (rest,b):(first <> rest,"[" ++ a ++ ";" ++ b ++ "]")
def collectors(items:List<F.Collector>) -> List<F.Collector> & String:
  match items:
    case []:([],"[]")
    case first <> rest:collectors_join(Obs.collector(first),collectors(rest))
def render_statuses(~S:Data,items:List<&2,F.RunStatus<S>>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Obs.status(~S,first) ++ ";" ++ render_statuses(~S,rest) ++ "]"
def render_ids(items:List<&2,Nat>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Nat.show(first) ++ ";" ++ render_ids(rest) ++ "]"
def captured_owners(~S:Data,label:String,app:F.Application(~S),subscriber:F.Subscriber(),+statuses:List<&2,F.RunStatus<S>>,+published:List<&2,Nat>,prefix:String,returned:List<F.Collector> & String) -> State<S> & String:
  match returned:
    case (returned,text):(State{app,subscriber,returned,statuses,published},"checkpoint=" ++ label ++ "\n" ++ prefix ++ "\nreturned=" ++ text ++ ";statuses=" ++ render_statuses(~S,statuses) ++ ";ids=" ++ render_ids(published) ++ "\n")
def captured_subscriber(~S:Data,label:String,app:F.Application(~S),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,prefix:String,result:F.Subscriber() & String) -> State<S> & String:
  match result:
    case (subscriber,text):captured_owners(~S,label,app,subscriber,statuses,published,prefix ++ "\nsubscriber=" ++ text,collectors(returned))
def captured_last_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_subscriber(~S,label,app,returned,statuses,published,prefix ++ "\nappAfterRepeatedSnapshot=" ++ text,Obs.subscriber(subscriber))
def captured_snapshot_two(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,F.Rows()>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_last_app(~S,label,subscriber,returned,statuses,published,prefix ++ "\nsnapshotRepeated=" ++ Obs.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_middle_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_two(~S,label,subscriber,returned,statuses,published,prefix ++ "\nappAfterSnapshot=" ++ text,F.snapshot(~S,app))
def captured_snapshot_one(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,F.Rows()>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_middle_app(~S,label,subscriber,returned,statuses,published,prefix ++ "\nsnapshot=" ++ Obs.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_first_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_one(~S,label,subscriber,returned,statuses,published,"appBeforeSnapshot=" ++ text,F.snapshot(~S,app))
def checkpoint(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,published}:captured_first_app(~S,label,subscriber,returned,statuses,published,Obs.app(~S,app))
def delivered(~S:Data,+batch:Trace.Batch<Engine.Error<String>>,state:State<S>) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,published}:State{app,Trace.deliver(~F.Collector,~Engine.Error<String>,~F.step,subscriber,batch),returned,statuses,published}
def delivery_finished(~S:Data,before:String,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,after):(state,before ++ after)
def delivery_observed(~S:Data,label:String,+batch:Trace.Batch<Engine.Error<String>>,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,before):delivery_finished(~S,before ++ "batch=" ++ Obs.batch(batch) ++ "\n",checkpoint(~S,label ++ ":after-delivery",delivered(~S,batch,state)))
def resumed(~S:Data,+label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,value:F.Application(~S) & (F.RunStatus<S> & Trace.Batch<Engine.Error<String>>)) -> State<S> & String:
  match value:
    case (app,(status,batch)):delivery_observed(~S,label,batch,checkpoint(~S,label ++ ":after-execution",State{app,subscriber,returned,List.append(&2,F.RunStatus<S>,statuses,[status]),published}))
def perform(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,published}:resumed(~S,label,subscriber,returned,statuses,published,F.resume(~S,F.run(~S,app)))
def enabled(~S:Data,state:State<S>,flag:Bool) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,published}:State{F.enabled(~S,app,flag),subscriber,returned,statuses,published}
def guarded(~S:Data,state:State<S>,flag:Bool) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,published}:State{F.guard(~S,app,flag),subscriber,returned,statuses,published}
def failing(~S:Data,state:State<S>,flag:Bool) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,published}:State{F.failure(~S,app,flag),subscriber,returned,statuses,published}
def published_returned(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,value:F.Application(~S) & Nat) -> State<S> & String:
  match value:
    case (app,id):checkpoint(~S,label,State{app,subscriber,returned,statuses,List.append(&2,Nat,published,[id])})
def publish(~S:Data,label:String,state:State<S>,+value:U32) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,published}:published_returned(~S,label,subscriber,returned,statuses,published,F.publish(~S,app,ANode{ALeaf{value},ALeaf{U32.add(value,1)}}))
def framed(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,value:F.Application(~S) & Unit) -> State<S> & String:
  match value:
    case (app,_):checkpoint(~S,label,State{app,subscriber,returned,statuses,published})
def frame(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,published}:framed(~S,label,subscriber,returned,statuses,published,F.frame(~S,app))
def reset_returned(~S:Data,app:F.Application(~S),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,result:F.Subscriber() & F.Collector) -> State<S> & String:
  match result:
    case (subscriber,old):checkpoint(~S,"reset",State{app,subscriber,old <> returned,statuses,published})
def reset(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,published}:reset_returned(~S,app,returned,statuses,published,Trace.reset(~F.Collector,~Engine.Error<String>,~F.step,subscriber,F.collector(300,400)))
def terminal_owners(prefix:String,returned:List<F.Collector> & String) -> String:
  match returned:
    case (_,text):prefix ++ "returnedAndUnsubscribed=" ++ text ++ "\n"
def terminal_app(~S:Data,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,F.RunStatus<S>>,published:List<&2,Nat>,value:F.Application(~S) & String) -> String:
  match value:
    case (_,text):terminal_owners("terminalApp=" ++ text ++ "\nstatuses=" ++ render_statuses(~S,statuses) ++ ";ids=" ++ render_ids(published) ++ "\n",collectors(Trace.unsubscribe(~F.Collector,~Engine.Error<String>,~F.step,subscriber) <> returned))
def terminal(~S:Data,state:State<S>) -> String:
  match state:
    case State{app,subscriber,returned,statuses,published}:terminal_app(~S,subscriber,returned,statuses,published,Obs.app(~S,app))
def joined(~S:Data,first:String,value:State<S> & String,next:State<S> -> String) -> String:
  match value:
    case (state,text):first ++ text ++ next(state)
def chain(~S:Data,value:State<S> & String,next:State<S> -> String) -> String:
  match value:
    case (state,text):text ++ next(state)
def step_20(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"after-reset-empty-read",state),terminal(~S))
def step_19(~S:Data,state:State<S>) -> String:chain(~S,reset(~S,state),step_20(~S))
def step_18(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"enabled-empty-read",enabled(~S,state,True{})),step_19(~S))
def step_17(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"disabled-read",guarded(~S,state,True{})),step_18(~S))
def step_16(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"disabled-skip",state),step_17(~S))
def step_15(~S:Data,state:State<S>) -> String:chain(~S,publish(~S,"publish-fifty",guarded(~S,state,False{}),50),step_16(~S))
def step_14(~S:Data,state:State<S>) -> String:chain(~S,checkpoint(~S,"disabled",enabled(~S,state,False{})),step_15(~S))
def step_13(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"retry-returned-args",failing(~S,state,False{})),step_14(~S))
def step_12(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"semantic-failure",failing(~S,state,True{})),step_13(~S))
def step_11(~S:Data,state:State<S>) -> String:chain(~S,publish(~S,"publish-forty",state,40),step_12(~S))
def step_10(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"lagged-read",guarded(~S,state,True{})),step_11(~S))
def step_9(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"false-unread",state),step_10(~S))
def step_8(~S:Data,state:State<S>) -> String:chain(~S,frame(~S,"frame-thirty",state),step_9(~S))
def step_7(~S:Data,state:State<S>) -> String:chain(~S,publish(~S,"publish-thirty",state,30),step_8(~S))
def step_6(~S:Data,state:State<S>) -> String:chain(~S,frame(~S,"frame-twenty",state),step_7(~S))
def step_5(~S:Data,state:State<S>) -> String:chain(~S,publish(~S,"publish-twenty",guarded(~S,state,False{}),20),step_6(~S))
def step_4(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"first-read",guarded(~S,state,True{})),step_5(~S))
def step_3(~S:Data,state:State<S>) -> String:chain(~S,perform(~S,"false-before-read",state),step_4(~S))
def step_2(~S:Data,state:State<S>) -> String:chain(~S,publish(~S,"publish-ten",state,10),step_3(~S))
def step_1(~S:Data,state:State<S>) -> String:chain(~S,checkpoint(~S,"enabled",enabled(~S,state,True{})),step_2(~S))
def step_0(~S:Data,state:State<S>) -> String:chain(~S,checkpoint(~S,"initial",state),step_1(~S))
def rejected_observed(~S:Data,value:F.SetupResult<S> & String) -> String:
  match value:
    case (_,text):"setup-rejected=" ++ text ++ "\n"
def rejected(~S:Data,value:F.SetupResult<S>) -> String:rejected_observed(~S,Obs.setup(~S,value))
def run(~S:Data,value:F.SetupResult<S>) -> String:
  match value:
    case F.Ready{app}:step_0(~S,State{app,Trace.subscribe(~F.Collector,~Engine.Error<String>,~F.step,F.collector(100,200)),[],[],[]})
    case value:rejected(~S,value)
