import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import ../state.bend as State
import ../dump.bend as Dump
import ../consumer.bend as Consumer
import ../machine-declaration.bend as MD
import ../relation-condition.bend as RC

# Same ordinary machine and relation declarations generate actual condition grants.
def lookup_done(~S:Data,~H:Type,observed:H & Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> H & Bool:
  match observed:
    case (owner,Done{row}):(owner,True{})
    case (owner,Fail{error}):(owner,False{})
def relation_done(~S:Data,~H:Type,~query:IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>,target:W.Handle<S>,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):lookup_done(~S,~H,IQ.get_composed(~H,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~query,owner,target))
def machine_field(~S:Data,~H:Type,caps:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>> & IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>) -> Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>:
  match caps:
    case (machine,_):machine
def relations_field(~S:Data,~H:Type,caps:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>> & IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>) -> IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>:
  match caps:
    case (_,relations):relations
def body(~S:Data,~H:Type,~caps:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>> & IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>,target:W.Handle<S>,owner:H) -> H & Bool:
  relation_done(~S,~H,~relations_field(~S,~H,caps),target,MD.matches(~H,~S,~State.FlowToken,~U32,~U32.is_eq,~machine_field(~S,~H,caps),owner,7))
def plan(~S:Data) -> K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>> & IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>:
  K.Plan{MD.required(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~Consumer.flow(~S)),(MD.condition(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~Consumer.flow(~S)),RC.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~K.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~Consumer.declaration(~S)))}
def outcome(~S:Data,checked:K.Checked<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,K.Error,Bool>:
  match checked:
    case K.Checked{world,Done{value}}:Sys.Succeeded{world,value}
    case K.Checked{world,Fail{error}}:Sys.Failed{world,error}
def runner(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,target:W.Handle<S>) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,K.Error,Bool>:
  outcome(~S,K.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~(H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>> & IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>),~W.Handle<S>,~body(~S),~plan(~S),target,world))
type Observed<S:Data> is Data:
  Observed{registryCursor:U32,value:Consumer.Observation<S>}
type Report<S:Data> is Data:
  Report{before:String,first:Observed<S>,afterFirst:String,second:Observed<S>,afterSecond:String,namespace:U32,id:U32,name:String,access:List<&2,String>,result:Maybe<&2,Result<&2,&2,K.Error,Bool>>,registryAfterRun:U32,afterRun:String}
def final_dump(~S:Data,before:String,first:Observed<S>,afterFirst:String,second:Observed<S>,afterSecond:String,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,result:Maybe<&2,Result<&2,&2,K.Error,Bool>>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (world,afterRun)=observed
  Report{before,first,afterFirst,second,afterSecond,namespace,id,name,access,result,cursor,afterRun}
def finished(~S:Data,before:String,first:Observed<S>,afterFirst:String,second:Observed<S>,afterSecond:String,result:Sys.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>) -> Report<S>:
  match result:
    case Sys.Completed{Sys.Registry{namespace,id,name,access,cursor},Sys.Succeeded{world,value}}:final_dump(~S,before,first,afterFirst,second,afterSecond,namespace,id,name,access,cursor,Some{Done{value}},Dump.world(~S,world))
    case Sys.Completed{Sys.Registry{namespace,id,name,access,cursor},Sys.Failed{world,error}}:final_dump(~S,before,first,afterFirst,second,afterSecond,namespace,id,name,access,cursor,Some{Fail{error}},Dump.world(~S,world))
    case Sys.RegistrationRejected{Sys.Registry{namespace,id,name,access,cursor},world,target}:final_dump(~S,before,first,afterFirst,second,afterSecond,namespace,id,name,access,cursor,None{},Dump.world(~S,world))

def captured(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>,+cursor:U32,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Consumer.Observation<S>) -> Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observed<S>:
  (world,value)=observed
  (registry,world,Observed{cursor,value})
def snapshot(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observed<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,+cursor}:captured(~S,Sys.Registry{namespace,id,name,access,cursor},cursor,Consumer.snapshot(~S,world))
def after_second(~S:Data,before:String,first:Observed<S>,afterFirst:String,second:Observed<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (world,afterSecond)=observed
  finished(~S,before,first,afterFirst,second,afterSecond,Sys.run_tracked(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~W.Handle<S>,~K.Error,~Bool,~runner(~S),registry,world,W.Handle{31,2}))
def second(~S:Data,before:String,first:Observed<S>,afterFirst:String,observed:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observed<S>) -> Report<S>:
  (registry,world,second)=observed
  after_second(~S,before,first,afterFirst,second,registry,Dump.world(~S,world))
def after_first(~S:Data,before:String,first:Observed<S>,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (world,afterFirst)=observed
  second(~S,before,first,afterFirst,snapshot(~S,registry,world))
def first(~S:Data,before:String,observed:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observed<S>) -> Report<S>:
  (registry,world,first)=observed
  after_first(~S,before,first,registry,Dump.world(~S,world))
def before(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (world,before)=observed
  first(~S,before,snapshot(~S,registry,world))
def wrap(~S:Data,report:Report<S>) -> Maybe<&2,Report<S>>:
  Some{report}
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,W.Handle<S>,K.Error,Bool,runner(~S)>) -> Maybe<&2,Report<S>>:
  match result:
    case Sys.RegistrationFailed{world}:None{}
    case Sys.Registered{world,registry}:wrap(~S,before(~S,registry,Dump.world(~S,world)))
def run(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Maybe<&2,Report<S>>:
  registered(~S,Sys.register(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~W.Handle<S>,~K.Error,~Bool,~runner(~S),world,"CommittedFlowAndRelations",["Flow","Link","LinkedBy","Parent","Children"]))
