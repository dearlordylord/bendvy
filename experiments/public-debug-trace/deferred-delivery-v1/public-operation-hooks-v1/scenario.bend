import Base
import ./fixture.bend as F
import ./operations.bend as Ops
import ./handler-run.bend as Handler
import ./observe.bend as Obs
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/machine.bend as Machine
type Session<S:Data> is Type:
  Session{app:F.Application(~S),handlers:F.HandlerOwners(~S),seeds:List<F.SeedEvidence<S>>,subscriber:Maybe<&1,F.Subscriber()>,batches:List<&2,Trace.Batch<String>>,returned:List<F.Collector>,captures:List<&2,Machine.Snapshot<U32>>,status:String}
type Action is Data:
  Checkpoint{label:String}
  Enable{}
  Run{}
  Handle{}
  Deliver{}
  Reset{}
  Unsubscribe{}
def subscriber_returned(value:F.Subscriber() & String) -> Maybe<&1,F.Subscriber()> & String:
  match value:
    case (owner,text):(Some{owner},"Some(" ++ text ++ ")")
def subscriber_observed(value:Maybe<&1,F.Subscriber()>) -> Maybe<&1,F.Subscriber()> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:subscriber_returned(Obs.subscriber(owner))
def collectors_cons(owner:F.Collector,text:String,value:List<F.Collector> & String) -> List<F.Collector> & String:
  match value:
    case (tail,more):(owner <> tail,text ++ ";" ++ more)
def collectors_both(head:F.Collector & String,tail:List<F.Collector> & String) -> List<F.Collector> & String:
  match head:
    case (owner,text):collectors_cons(owner,text,tail)
def collectors(value:List<F.Collector>) -> List<F.Collector> & String:
  match value:
    case []:([],"[]")
    case head <> tail:collectors_both(Obs.collector(head),collectors(tail))

def bind_pair(~A:Type,~B:Type,~Result:Type,value:A & B,next:A -> B -> Result) -> Result:
  match value:
    case (a,b):next(a,b)
def seeds(~S:Data,values:List<F.SeedEvidence<S>>) -> List<F.SeedEvidence<S>> & String:
  match values:
    case []:([],"[]")
    case value <> rest:
      bind_pair(~F.SeedEvidence<S>,~String,~(List<F.SeedEvidence<S>> & String),Obs.seed(~S,value),value1=>text=>bind_pair(~List<F.SeedEvidence<S>>,~String,~(List<F.SeedEvidence<S>> & String),seeds(~S,rest),rest1=>more=>(value1 <> rest1,text ++ ";" ++ more)))
def batches(values:List<&2,Trace.Batch<String>>) -> String:
  match values:
    case []:"[]"
    case value <> rest:Obs.batch(value) ++ ";" ++ batches(rest)
def captures(values:List<&2,Machine.Snapshot<U32>>) -> String:
  match values:
    case []:"[]"
    case value <> rest:Obs.capturedSnapshot(value) ++ ";" ++ captures(rest)
def checkpoint(~S:Data,label:String,session:Session<S>) -> Session<S> & String:
  match session:
    case Session{app,handlers,evidence,subscriber,+batch,returned,+captured,+status}:
      bind_pair(~F.Application(~S),~String,~(Session<S> & String),Obs.app(~S,app),app1=>appText=>bind_pair(~F.HandlerOwners(~S),~String,~(Session<S> & String),Obs.handler_owners(~S,handlers),handlers1=>handlerText=>bind_pair(~List<F.SeedEvidence<S>>,~String,~(Session<S> & String),seeds(~S,evidence),evidence1=>seedText=>bind_pair(~Maybe<&1,F.Subscriber()>,~String,~(Session<S> & String),subscriber_observed(subscriber),subscriber1=>subText=>bind_pair(~List<F.Collector>,~String,~(Session<S> & String),collectors(returned),returned1=>returnedText=>bind_pair(~F.Application(~S),~Maybe<&2,Single.Description<S,F.Rows(~S)>>,~(Session<S> & String),Ops.snapshot(~S,app1),app2=>view=>(Session{app2,handlers1,evidence1,subscriber1,batch,returned1,captured,status},label ++ "\napp=" ++ appText ++ "\nhandlers=" ++ handlerText ++ "\nseeds=" ++ seedText ++ "\nsubscriber=" ++ subText ++ "\nreturned=" ++ returnedText ++ "\nbatches=" ++ batches(batch) ++ "\ncaptured=" ++ captures(captured) ++ "\nstatus=" ++ status ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")))))))
def ran(~S:Data,handlers:F.HandlerOwners(~S),evidence:List<F.SeedEvidence<S>>,subscriber:Maybe<&1,F.Subscriber()>,returned:List<F.Collector>,captured:List<&2,Machine.Snapshot<U32>>,value:Execution.Run<F.Application(~S),S,String>) -> Session<S>:
  match value:
    case Execution.Run{Single.Finished{app,observations},batch}:Session{app,handlers,evidence,subscriber,[batch],returned,captured,"Finished:" ++ Obs.observations(observations)}
    case Execution.Run{Single.Failed{app,error,observations},batch}:Session{app,handlers,evidence,subscriber,[batch],returned,captured,"Failed:" ++ error ++ ":" ++ Obs.observations(observations)}
    case Execution.Run{Single.Rejected{app},batch}:Session{app,handlers,evidence,subscriber,[batch],returned,captured,"Rejected"}
    case Execution.Run{Single.Missing{app,_},batch}:Session{app,handlers,evidence,subscriber,[batch],returned,captured,"Missing"}
def handled(~S:Data,evidence:List<F.SeedEvidence<S>>,subscriber:Maybe<&1,F.Subscriber()>,batch:List<&2,Trace.Batch<String>>,returned:List<F.Collector>,captured:List<&2,Machine.Snapshot<U32>>,value:Execution.HandlerRun<F.Application(~S),F.HandlerOwners(~S),Machine.Snapshot<U32>>) -> Session<S>:
  match value:
    case Execution.HandlerRun{app,owners,snapshot,failure,added}:Session{app,owners,evidence,subscriber,List.append(&2,Trace.Batch<String>,batch,[added]),returned,snapshot <> captured,"Handlers:" ++ Obs.handler_failure(failure)}
def deliver_one(values:List<&2,Trace.Batch<String>>,owner:F.Subscriber()) -> F.Subscriber():
  match values:
    case []:owner
    case value <> rest:deliver_one(rest,Trace.deliver(~F.Collector,~String,~F.step,owner,value))
def delivered(owner:Maybe<&1,F.Subscriber()>,values:List<&2,Trace.Batch<String>>) -> Maybe<&1,F.Subscriber()>:
  match owner:
    case None{}:None{}
    case Some{owner}:Some{deliver_one(values,owner)}
def reset(~S:Data,app:F.Application(~S),handlers:F.HandlerOwners(~S),evidence:List<F.SeedEvidence<S>>,owner:Maybe<&1,F.Subscriber()>,batch:List<&2,Trace.Batch<String>>,returned:List<F.Collector>,captured:List<&2,Machine.Snapshot<U32>>) -> Session<S>:
  match owner:
    case None{}:Session{app,handlers,evidence,None{},batch,returned,captured,"ResetAbsent"}
    case Some{owner}:
      bind_pair(~F.Subscriber(),~F.Collector,~(Session<S>),Trace.reset(~F.Collector,~String,~F.step,owner,F.collector(300,400)),owner1=>old=>Session{app,handlers,evidence,Some{owner1},batch,old <> returned,captured,"ResetReturnedOwner"})
def unsubscribe(~S:Data,app:F.Application(~S),handlers:F.HandlerOwners(~S),evidence:List<F.SeedEvidence<S>>,owner:Maybe<&1,F.Subscriber()>,batch:List<&2,Trace.Batch<String>>,returned:List<F.Collector>,captured:List<&2,Machine.Snapshot<U32>>) -> Session<S>:
  match owner:
    case None{}:Session{app,handlers,evidence,None{},batch,returned,captured,"UnsubscribeAbsent"}
    case Some{owner}:Session{app,handlers,evidence,None{},batch,Trace.unsubscribe(~F.Collector,~String,~F.step,owner) <> returned,captured,"UnsubscribeReturnedOwner"}
def action(~S:Data,step:Action,session:Session<S>) -> Session<S> & String:
  match step session:
    case Checkpoint{label} session:checkpoint(~S,label,session)
    case Enable{} Session{app,handlers,evidence,subscriber,batch,returned,captured,status}:(Session{Ops.enabled(~S,app,True{}),handlers,evidence,subscriber,batch,returned,captured,status},"Enabled\n")
    case Run{} Session{app,handlers,evidence,subscriber,_,returned,captured,_}:(ran(~S,handlers,evidence,subscriber,returned,captured,Ops.run(~S,app)),"RunCompleted\n")
    case Handle{} Session{app,handlers,evidence,subscriber,batch,returned,captured,_}:(handled(~S,evidence,subscriber,batch,returned,captured,Handler.run(~S,app,handlers)),"HandlersCompleted\n")
    case Deliver{} Session{app,handlers,evidence,subscriber,+batch,returned,captured,status}:(Session{app,handlers,evidence,delivered(subscriber,batch),batch,returned,captured,status},"DeliveryReturned\n")
    case Reset{} Session{app,handlers,evidence,subscriber,batch,returned,captured,_}:(reset(~S,app,handlers,evidence,subscriber,batch,returned,captured),"ResetReturned\n")
    case Unsubscribe{} Session{app,handlers,evidence,subscriber,batch,returned,captured,_}:(unsubscribe(~S,app,handlers,evidence,subscriber,batch,returned,captured),"UnsubscribeReturned\n")
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case step <> rest:
      bind_pair(~Session<S>,~String,~(String),action(~S,step,session),session1=>text=>text ++ actions(~S,rest,session1))
def program() -> List<&2,Action>:[Checkpoint{"disabled-before"},Run{},Checkpoint{"disabled-schedule-completed"},Handle{},Checkpoint{"disabled-handlers-completed"},Deliver{},Checkpoint{"disabled-delivery-bypassed"},Enable{},Checkpoint{"enabled-before"},Run{},Checkpoint{"enabled-schedule-completed"},Handle{},Checkpoint{"enabled-handlers-completed"},Deliver{},Checkpoint{"enabled-delivery-returned"},Reset{},Checkpoint{"reset-returned-owner"},Run{},Checkpoint{"repeated-schedule-completed"},Handle{},Checkpoint{"repeated-handlers-completed"},Deliver{},Checkpoint{"repeated-delivery-returned"},Unsubscribe{},Checkpoint{"unsubscribe-returned-owner"},Checkpoint{"terminal-repeat"}]
def run(~S:Data,evidence:List<F.SeedEvidence<S>>,value:Maybe<&1,F.Application(~S) & F.HandlerOwners(~S)>) -> String:
  match value:
    case None{}:
      bind_pair(~List<F.SeedEvidence<S>>,~String,~(String),seeds(~S,evidence),discarded=>text=>"registration-or-attachment-refused\nseeds=" ++ text)
    case Some{(app,handlers)}:actions(~S,program(),Session{app,handlers,evidence,Some{Trace.subscribe(~F.Collector,~String,~F.step,F.collector(100,200))},[],[],[],"registered"})
