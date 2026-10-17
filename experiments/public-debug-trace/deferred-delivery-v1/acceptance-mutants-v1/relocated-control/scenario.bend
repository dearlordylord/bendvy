import Base
import ./delivery.bend as Delivery
import ./fixture.bend as F
import ./observe.bend as Obs
import ../../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/execution-trace.bend as Trace

type State<S:Data> is Type:
  State{app:F.Application(~S),subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queues:List<&2,T.Outcome<String>>}
def collectors_join(first:F.Collector & String,rest:List<F.Collector> & String) -> List<F.Collector> & String:
  match first rest:
    case (first,a), (rest,b):(first <> rest,"[" ++ a ++ ";" ++ b ++ "]")
def collectors(items:List<F.Collector>) -> List<F.Collector> & String:
  match items:
    case []:([],"[]")
    case first <> rest:collectors_join(Obs.collector(first),collectors(rest))
def render_statuses(items:List<&2,B.Status<F.Need>>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Obs.status(first) ++ ";" ++ render_statuses(rest) ++ "]"
def render_queues(items:List<&2,T.Outcome<String>>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Obs.tx_outcome(first) ++ ";" ++ render_queues(rest) ++ "]"
def captured_owners(~S:Data,label:String,app:F.Application(~S),subscriber:F.Subscriber(),+statuses:List<&2,B.Status<F.Need>>,+queued:List<&2,T.Outcome<String>>,prefix:String,returned:List<F.Collector> & String) -> State<S> & String:
  match returned:
    case (returned,text):(State{app,subscriber,returned,statuses,queued},"checkpoint=" ++ label ++ "\n" ++ prefix ++ "\nreturned=" ++ text ++ ";statuses=" ++ render_statuses(statuses) ++ ";queues=" ++ render_queues(queued) ++ "\n")
def captured_subscriber(~S:Data,label:String,app:F.Application(~S),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Subscriber() & String) -> State<S> & String:
  match result:
    case (subscriber,text):captured_owners(~S,label,app,subscriber,statuses,queued,prefix ++ "\nsubscriber=" ++ text,collectors(returned))
def captured_last_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_subscriber(~S,label,app,returned,statuses,queued,prefix ++ "\nappAfterRepeatedSnapshot=" ++ text,Obs.subscriber(subscriber))
def captured_snapshot_two(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,F.Mode,U32,F.Need>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_last_app(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nsnapshotRepeated=" ++ Obs.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_middle_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_two(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nappAfterSnapshot=" ++ text,F.snapshot(~S,app))
def captured_snapshot_one(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,F.Mode,U32,F.Need>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_middle_app(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nsnapshot=" ++ Obs.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_first_app(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_one(~S,label,subscriber,returned,statuses,queued,"appBeforeSnapshot=" ++ text,F.snapshot(~S,app))
def checkpoint(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:captured_first_app(~S,label,subscriber,returned,statuses,queued,Obs.app(~S,app))
def delivered(~S:Data,+batch:Trace.Batch<String>,state:State<S>) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,queued}:State{app,Delivery.deliver(~F.Collector,~String,~F.step,subscriber,batch),returned,statuses,queued}
def delivery_finished(~S:Data,before:String,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,after):(state,before ++ after)
def delivery_observed(~S:Data,label:String,+batch:Trace.Batch<String>,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,before):delivery_finished(~S,before ++ "batch=" ++ Obs.batch(batch) ++ "\n",checkpoint(~S,label ++ ":after-delivery",delivered(~S,batch,state)))
def resumed(~S:Data,+label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,batch:Trace.Batch<String>,value:F.Application(~S) & B.Status<F.Need>) -> State<S> & String:
  match value:
    case (app,status):delivery_observed(~S,label,batch,checkpoint(~S,label ++ ":after-execution",State{app,subscriber,returned,List.append(&2,B.Status<F.Need>,statuses,[status]),queued}))
def executed(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,value:App.RunResult<S,F.Mode,U32,F.Need,Unit,F.Resources(~S),Unit,F.runner(~S),Array<U32>> & Trace.Batch<String>) -> State<S> & String:
  match value:
    case (result,batch):resumed(~S,label,subscriber,returned,statuses,queued,batch,F.resume(~S,result))
def perform(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:executed(~S,label,subscriber,returned,statuses,queued,F.run(~S,app))
def enabled(~S:Data,state:State<S>,flag:Bool) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,queued}:State{F.enabled(~S,app,flag),subscriber,returned,statuses,queued}
def inserted(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,queued}:State{F.insert(~S,app),subscriber,returned,statuses,queued}
def queued_returned(~S:Data,label:String,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,value:F.Application(~S) & T.Outcome<String>) -> State<S> & String:
  match value:
    case (app,outcome):checkpoint(~S,label,State{app,subscriber,returned,statuses,List.append(&2,T.Outcome<String>,queued,[outcome])})
def queue(~S:Data,label:String,value:U32,skip:Bool,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:queued_returned(~S,label,subscriber,returned,statuses,queued,F.queue(~S,app,value,skip))
def reset_returned(~S:Data,app:F.Application(~S),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,value:F.Subscriber() & F.Collector) -> State<S> & String:
  match value:
    case (subscriber,old):checkpoint(~S,"reset",State{app,subscriber,List.append(&1,F.Collector,returned,[old]),statuses,queued})
def reset(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:reset_returned(~S,app,returned,statuses,queued,Delivery.reset(~F.Collector,~String,~F.step,subscriber,F.collector(300,400)))
def then(~S:Data,value:State<S> & String,next:State<S> -> State<S> & String) -> State<S> & String:
  match value:
    case (state,before):delivery_finished(~S,before,next(state))
def program(~S:Data,state:State<S>) -> State<S> & String:
  then(~S,checkpoint(~S,"initial",state),s =>
  then(~S,perform(~S,"missing-disabled",s),s =>
  then(~S,checkpoint(~S,"enabled",enabled(~S,s,True{})),s =>
  then(~S,perform(~S,"missing-enabled",s),s =>
  then(~S,queue(~S,"queued-one",1,False{},inserted(~S,s)),s =>
  then(~S,perform(~S,"transition-one",s),s =>
  then(~S,queue(~S,"queued-two",2,False{},s),s =>
  then(~S,perform(~S,"transition-two-fails",s),s =>
  then(~S,perform(~S,"retry-same-two",s),s =>
  then(~S,queue(~S,"queued-zero",0,False{},s),s =>
  then(~S,perform(~S,"transition-zero",s),s =>
  then(~S,checkpoint(~S,"disabled-again",enabled(~S,s,False{})),s =>
  then(~S,queue(~S,"queued-one-disabled",1,False{},s),s =>
  then(~S,perform(~S,"transition-one-disabled",s),s =>
  then(~S,reset(~S,s),s =>
  then(~S,checkpoint(~S,"re-enabled",enabled(~S,s,True{})),s =>
  perform(~S,"idle-enabled",s)))))))))))))))))
def unsubscribed(~S:Data,before:String,value:List<F.Collector> & String) -> String:
  match value:
    case (_,text):before ++ "unsubscribedOwners=" ++ text ++ "\n"
def terminal_app(~S:Data,subscriber:F.Subscriber(),returned:List<F.Collector>,statuses:List<&2,B.Status<F.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,value:F.Application(~S) & String) -> String:
  match value:
    case (_,text):unsubscribed(~S,prefix ++ "terminalApp=" ++ text ++ ";terminalStatuses=" ++ render_statuses(statuses) ++ ";terminalQueues=" ++ render_queues(queued) ++ "\n",collectors(List.append(&1,F.Collector,returned,[Trace.unsubscribe(~F.Collector,~String,~F.step,subscriber)])))
def terminal(~S:Data,value:State<S> & String) -> String:
  match value:
    case (State{app,subscriber,returned,statuses,queued},text):terminal_app(~S,subscriber,returned,statuses,queued,text,Obs.app(~S,app))
def setup_rejected(~S:Data,value:F.Setup<S> & String) -> String:
  match value:
    case (_,text):"setup-rejected=" ++ text ++ "\n"
def run(~S:Data,setup:F.Setup<S>) -> String:
  match setup:
    case F.Ready{app}:terminal(~S,program(~S,State{app,Trace.subscribe(~F.Collector,~String,~F.step,F.collector(100,200)),[],[],[]}))
    case setup:setup_rejected(~S,Obs.setup(~S,setup))
