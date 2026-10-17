import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import ../selector-handlers-v1/observe.bend as Common
import ../selector-handlers-v1/fixture.bend as BaseF
import ../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/execution-trace.bend as Trace

type State<S:Data> is Type:
  State{app:F.Application(~S),subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queues:List<&2,T.Outcome<String>>}
def collectors_join(first:BaseF.Collector & String,rest:List<BaseF.Collector> & String) -> List<BaseF.Collector> & String:
  match first rest:
    case (first,a), (rest,b):(first <> rest,"[" ++ a ++ ";" ++ b ++ "]")
def collectors(items:List<BaseF.Collector>) -> List<BaseF.Collector> & String:
  match items:
    case []:([],"[]")
    case first <> rest:collectors_join(Common.collector(first),collectors(rest))
def render_statuses(items:List<&2,B.Status<BaseF.Need>>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Common.status(first) ++ ";" ++ render_statuses(rest) ++ "]"
def render_queues(items:List<&2,T.Outcome<String>>) -> String:
  match items:
    case []:"[]"
    case first <> rest:"[" ++ Common.tx_outcome(first) ++ ";" ++ render_queues(rest) ++ "]"
def captured_owners(~S:Data,label:String,app:F.Application(~S),subscriber:BaseF.Subscriber(),+statuses:List<&2,B.Status<BaseF.Need>>,+queued:List<&2,T.Outcome<String>>,prefix:String,returned:List<BaseF.Collector> & String) -> State<S> & String:
  match returned:
    case (returned,text):(State{app,subscriber,returned,statuses,queued},"checkpoint=" ++ label ++ "\n" ++ prefix ++ "\nreturned=" ++ text ++ ";statuses=" ++ render_statuses(statuses) ++ ";queues=" ++ render_queues(queued) ++ "\n")
def captured_subscriber(~S:Data,label:String,app:F.Application(~S),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:BaseF.Subscriber() & String) -> State<S> & String:
  match result:
    case (subscriber,text):captured_owners(~S,label,app,subscriber,statuses,queued,prefix ++ "\nsubscriber=" ++ text,collectors(returned))
def captured_last_app(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_subscriber(~S,label,app,returned,statuses,queued,prefix ++ "\nappAfterRepeatedSnapshot=" ++ text,Common.subscriber(subscriber))
def captured_snapshot_two(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,BaseF.Mode,U32,BaseF.Need>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_last_app(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nsnapshotRepeated=" ++ Common.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_middle_app(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_two(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nappAfterSnapshot=" ++ text,F.snapshot(~S,app))
def captured_snapshot_one(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,result:F.Application(~S) & Maybe<&2,App.Description<S,BaseF.Mode,U32,BaseF.Need>>) -> State<S> & String:
  match result:
    case (app,snapshot):captured_middle_app(~S,label,subscriber,returned,statuses,queued,prefix ++ "\nsnapshot=" ++ Common.snapshot(~S,snapshot),Obs.app(~S,app))
def captured_first_app(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,result:F.Application(~S) & String) -> State<S> & String:
  match result:
    case (app,text):captured_snapshot_one(~S,label,subscriber,returned,statuses,queued,"appBeforeSnapshot=" ++ text,F.snapshot(~S,app))
def checkpoint(~S:Data,label:String,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:captured_first_app(~S,label,subscriber,returned,statuses,queued,Obs.app(~S,app))
def delivered(~S:Data,+batch:Trace.Batch<String>,state:State<S>) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,queued}:State{app,Trace.deliver(~BaseF.Collector,~String,~BaseF.step,subscriber,batch),returned,statuses,queued}
def delivery_finished(~S:Data,before:String,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,after):(state,before ++ after)
def delivery_observed(~S:Data,label:String,+batch:Trace.Batch<String>,value:State<S> & String) -> State<S> & String:
  match value:
    case (state,before):delivery_finished(~S,before ++ "batch=" ++ Common.batch(batch) ++ "\n",checkpoint(~S,label ++ ":after-delivery",delivered(~S,batch,state)))
def resumed(~S:Data,+label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,batch:Trace.Batch<String>,value:F.Application(~S) & B.Status<BaseF.Need>) -> State<S> & String:
  match value:
    case (app,status):delivery_observed(~S,label,batch,checkpoint(~S,label ++ ":after-execution",State{app,subscriber,returned,List.append(&2,B.Status<BaseF.Need>,statuses,[status]),queued}))
def executed(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,value:F.RunResult(~S) & Trace.Batch<String>) -> State<S> & String:
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
    case State{app,subscriber,returned,statuses,queued}:State{F.inserted(~S,app),subscriber,returned,statuses,queued}
def initialized(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{app,subscriber,returned,statuses,queued}:State{F.initialized(~S,app),subscriber,returned,statuses,queued}
def queued_returned(~S:Data,label:String,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,value:F.Application(~S) & T.Outcome<String>) -> State<S> & String:
  match value:
    case (app,outcome):checkpoint(~S,label,State{app,subscriber,returned,statuses,List.append(&2,T.Outcome<String>,queued,[outcome])})
def queue(~S:Data,label:String,value:U32,skip:Bool,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:queued_returned(~S,label,subscriber,returned,statuses,queued,F.queue(~S,app,value,skip))
def reset_returned(~S:Data,app:F.Application(~S),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,value:BaseF.Subscriber() & BaseF.Collector) -> State<S> & String:
  match value:
    case (subscriber,old):checkpoint(~S,"reset",State{app,subscriber,List.append(&1,BaseF.Collector,returned,[old]),statuses,queued})
def reset(~S:Data,state:State<S>) -> State<S> & String:
  match state:
    case State{app,subscriber,returned,statuses,queued}:reset_returned(~S,app,returned,statuses,queued,Trace.reset(~BaseF.Collector,~String,~BaseF.step,subscriber,BaseF.collector(300,400)))
def then(~S:Data,value:State<S> & String,next:State<S> -> State<S> & String) -> State<S> & String:
  match value:
    case (state,before):delivery_finished(~S,before,next(state))
def program(~S:Data,state:State<S>) -> State<S> & String:
  then(~S,checkpoint(~S,"initial",state),s =>
  then(~S,checkpoint(~S,"enabled",enabled(~S,s,True{})),s =>
  then(~S,perform(~S,"missing-required",s),s =>
  then(~S,checkpoint(~S,"initialized",initialized(~S,s)),s =>
  then(~S,perform(~S,"initial-enter",s),s =>
  then(~S,perform(~S,"not-replayed",s),s =>
  then(~S,checkpoint(~S,"init-existing",initialized(~S,s)),s =>
  then(~S,perform(~S,"init-existing-not-replayed",s),s =>
  then(~S,checkpoint(~S,"disabled",enabled(~S,s,False{})),s =>
  then(~S,checkpoint(~S,"insert-replacement",inserted(~S,s)),s =>
  then(~S,perform(~S,"replacement-disabled",s),s =>
  then(~S,checkpoint(~S,"re-enabled",enabled(~S,s,True{})),s =>
  then(~S,perform(~S,"replacement-not-replayed",s),s =>
  then(~S,queue(~S,"queued-zero",0,False{},s),s =>
  then(~S,perform(~S,"transition-zero",s),s =>
  then(~S,reset(~S,s),s =>
  perform(~S,"idle-after-reset",s)))))))))))))))))
def unsubscribed(~S:Data,before:String,value:List<BaseF.Collector> & String) -> String:
  match value:
    case (_,text):before ++ "unsubscribedOwners=" ++ text ++ "\n"
def terminal_app(~S:Data,subscriber:BaseF.Subscriber(),returned:List<BaseF.Collector>,statuses:List<&2,B.Status<BaseF.Need>>,queued:List<&2,T.Outcome<String>>,prefix:String,value:F.Application(~S) & String) -> String:
  match value:
    case (_,text):unsubscribed(~S,prefix ++ "terminalApp=" ++ text ++ ";terminalStatuses=" ++ render_statuses(statuses) ++ ";terminalQueues=" ++ render_queues(queued) ++ "\n",collectors(List.append(&1,BaseF.Collector,returned,[Trace.unsubscribe(~BaseF.Collector,~String,~BaseF.step,subscriber)])))
def terminal(~S:Data,value:State<S> & String) -> String:
  match value:
    case (State{app,subscriber,returned,statuses,queued},text):terminal_app(~S,subscriber,returned,statuses,queued,text,Obs.app(~S,app))
def setup_rejected(~S:Data,value:F.Setup<S> & String) -> String:
  match value:
    case (_,text):"setup-rejected=" ++ text ++ "\n"
def run(~S:Data,setup:F.Setup<S>) -> String:
  match setup:
    case F.Ready{app}:terminal(~S,program(~S,State{app,Trace.subscribe(~BaseF.Collector,~String,~BaseF.step,BaseF.collector(100,200)),[],[],[]}))
    case setup:setup_rejected(~S,Obs.setup(~S,setup))
