import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import ../state.bend as State
import ../dump.bend as Dump
import ../machine-declaration.bend as MD
import ../relation-projection.bend as RP

def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Parent","Children",G.Hierarchy{}}
def declaration(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.optional_relation(~S,"link",link(~S)),RQ.optional_related(~S,"linkedBy",link(~S)),RQ.optional_relation(~S,"parent",parent(~S)),RQ.optional_related(~S,"children",parent(~S))]}
def flow(~S:Data) -> MD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>:
  MD.Declaration{"Flow"}
def level(~S:Data) -> MD.Declaration<S,State.LevelToken,U32,State.Resources<S>,State.level(~S)>:
  MD.Declaration{"Level"}
type Observation<S:Data> is Data:
  Observation{cursor:U32,flow:M.CurrentView<S,State.FlowToken,U32>,level:M.CurrentView<S,State.LevelToken,U32>,rows:List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,foreign:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>}
type Report<S:Data> is Data:
  Report{before:String,first:Observation<S>,afterFirst:String,second:Observation<S>,afterSecond:String,condition:Result<&2,&2,K.Error,Bool>,afterCondition:String}
def rows_done(~S:Data,foreign:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,flow:M.CurrentView<S,State.FlowToken,U32>,level:M.CurrentView<S,State.LevelToken,U32>,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  match observed:
    case (I.Frame{world,cursor},rows):(world,Observation{cursor,flow,level,rows,foreign})
def level_done(~S:Data,foreign:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,flow:M.CurrentView<S,State.FlowToken,U32>,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.CurrentView<S,State.LevelToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  (frame,level)=observed
  rows_done(~S,foreign,flow,level,IQ.each_composed(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~RP.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~declaration(~S)),frame))
def flow_done(~S:Data,foreign:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.CurrentView<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  (frame,flow)=observed
  level_done(~S,foreign,flow,Cap.value_read(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~M.CurrentView<S,State.LevelToken,U32>,~MD.inspect(~S,~State.LevelToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.level(~S),~level(~S)),frame))
def foreign_done(~S:Data,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  (frame,foreign)=observed
  flow_done(~S,foreign,Cap.value_read(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~M.CurrentView<S,State.FlowToken,U32>,~MD.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow(~S)),frame))
def snapshot(~S:Data,+target:W.Handle<S>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>:
  foreign_done(~S,IQ.get_composed(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~RP.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~declaration(~S)),I.Frame{world,19},target))
def condition_body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>,args:Unit,owner:H) -> H & Bool:
  MD.matches(~H,~S,~State.FlowToken,~U32,~U32.is_eq,~cap,owner,7)
def condition_plan(~S:Data) -> K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>>:
  K.Plan{MD.required(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow(~S)),MD.condition(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow(~S))}
def finished(~S:Data,before:String,first:Observation<S>,afterFirst:String,second:Observation<S>,afterSecond:String,result:Result<&2,&2,K.Error,Bool>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,afterCondition)=observed
  (world,Report{before,first,afterFirst,second,afterSecond,result,afterCondition})
def checked(~S:Data,+target:W.Handle<S>,before:String,first:Observation<S>,afterFirst:String,second:Observation<S>,afterSecond:String,result:K.Checked<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  match result:
    case K.Checked{world,result}:finished(~S,before,first,afterFirst,second,afterSecond,result,Dump.world(~S,world))
def after_second(~S:Data,+target:W.Handle<S>,before:String,first:Observation<S>,afterFirst:String,second:Observation<S>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,afterSecond)=observed
  checked(~S,target,before,first,afterFirst,second,afterSecond,K.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~(H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>),~Unit,~condition_body(~S),~condition_plan(~S),Unit{},world))
def second(~S:Data,+target:W.Handle<S>,before:String,first:Observation<S>,afterFirst:String,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,second)=observed
  after_second(~S,target,before,first,afterFirst,second,Dump.world(~S,world))
def after_first(~S:Data,+target:W.Handle<S>,before:String,first:Observation<S>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,afterFirst)=observed
  second(~S,target,before,first,afterFirst,snapshot(~S,target,world))
def first(~S:Data,+target:W.Handle<S>,before:String,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Observation<S>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,first)=observed
  after_first(~S,target,before,first,Dump.world(~S,world))
def before(~S:Data,+target:W.Handle<S>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  (world,before)=observed
  first(~S,target,before,snapshot(~S,target,world))
def run(~S:Data,+target:W.Handle<S>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Report<S>:
  before(~S,target,Dump.world(~S,world))
