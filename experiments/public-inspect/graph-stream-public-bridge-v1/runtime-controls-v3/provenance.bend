import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import ../state.bend as State
import ../dump.bend as Dump
import ../relation-projection.bend as RP
import consumer.bend as Consumer
import foreign-world.bend as Foreign

type Report<S:Data> is Data:
  Report{factoryNext:U32,handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,ownCursor:U32,ownLookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,otherAfterOwn:String,primary:Consumer.Report<S>,primaryAfter:String,otherAfter:String}
def finish(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,ownCursor:U32,ownLookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,otherAfterOwn:String,primary:Consumer.Report<S>,primaryAfter:String,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (other,otherAfter)=observed
  Report{factoryNext,handle,statuses,otherBefore,ownCursor,ownLookup,otherAfterOwn,primary,primaryAfter,otherAfter}
def primary_dumped(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,ownCursor:U32,ownLookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,otherAfterOwn:String,primary:Consumer.Report<S>,other:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (world,primaryAfter)=observed
  finish(~S,factoryNext,handle,statuses,otherBefore,ownCursor,ownLookup,otherAfterOwn,primary,primaryAfter,Dump.world(~S,other))
def primary_done(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,ownCursor:U32,ownLookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,otherAfterOwn:String,other:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Consumer.Report<S>) -> Report<S>:
  (world,primary)=observed
  primary_dumped(~S,factoryNext,handle,statuses,otherBefore,ownCursor,ownLookup,otherAfterOwn,primary,other,Dump.world(~S,world))
def own_dumped(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,ownCursor:U32,ownLookup:Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (other,otherAfterOwn)=observed
  primary_done(~S,factoryNext,handle,statuses,otherBefore,ownCursor,ownLookup,otherAfterOwn,other,Consumer.run(~S,handle,world))
def own_done(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,otherBefore:String,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,observed:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> Report<S>:
  match observed:
    case (I.Frame{other,cursor},ownLookup):own_dumped(~S,factoryNext,handle,statuses,otherBefore,cursor,ownLookup,world,Dump.world(~S,other))
def other_dumped(~S:Data,factoryNext:U32,+handle:W.Handle<S>,statuses:List<&2,W.Status>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> Report<S>:
  (other,otherBefore)=observed
  own_done(~S,factoryNext,handle,statuses,otherBefore,world,IQ.get_composed(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~RP.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~Consumer.declaration(~S)),I.Frame{other,41},handle))
def factory_done(~S:Data,handle:W.Handle<S>,statuses:List<&2,W.Status>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,other:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,factory:W.Factory) -> Report<S>:
  match factory:
    case W.Factory{next}:other_dumped(~S,next,handle,statuses,world,Dump.world(~S,other))
def created(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,result:Maybe<Foreign.Created<S>>) -> Maybe<Report<S>>:
  match result:
    case None{}:None{}
    case Some{Foreign.Created{factory,other,None{},statuses}}:None{}
    case Some{Foreign.Created{factory,other,Some{handle},statuses}}:Some{factory_done(~S,handle,statuses,world,other,factory)}
def run(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Maybe<Report<S>>:
  created(~S,world,Foreign.create(~S))
