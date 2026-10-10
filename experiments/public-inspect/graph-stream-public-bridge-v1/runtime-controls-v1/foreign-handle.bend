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

import ../consumer.bend as Consumer
type ForeignReport<S:Data> is Data:
  ForeignReport{before:String,lookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,cursor:U32,after:String,ordinary:Consumer.Report<S>}
def finished(~S:Data,before:String,result:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,+cursor:U32,after:String,ordinary:Consumer.Report<S>) -> ForeignReport<S>:
  ForeignReport{before,result,cursor,after,ordinary}
def after(~S:Data,before:String,result:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,+cursor:U32,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> ForeignReport<S>:
  (world,after)=observed
  finished(~S,before,result,cursor,after,Consumer.run(~S,world))
def looked_up(~S:Data,before:String,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> ForeignReport<S>:
  match observed:
    case (I.Frame{world,cursor},result):after(~S,before,result,cursor,Dump.world(~S,world))
def before(~S:Data,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> ForeignReport<S>:
  (world,before)=observed
  looked_up(~S,before,IQ.get_composed(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~RP.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~Consumer.declaration(~S)),I.Frame{world,23},W.Handle{47,2}))
def run(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> ForeignReport<S>:
  before(~S,Dump.world(~S,world))
