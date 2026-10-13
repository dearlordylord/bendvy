import Base
import schema-families.bend as D
import runtime-named-declarations.bend as Decl
import runtime-owners.bend as Owners
import execution.bend as Execution
import phase-driver.bend as Phase
import execution.bend as Caps
import world-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

type Boundary<S:Data> is Data:
  Boundary{worldBefore:U32,worldAfter:U32,instanceBefore:Phase.InstanceView,instanceAfter:Phase.InstanceView,record:Execution.Record<S>,failed:Bool}
type Retry<S:Data> is Type:
  Retry{world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>,boundaries:List<&2,Boundary<S>>}
def refused(~H:Type,~S:Data,value:H & Result<&2,&2,Unit,Execution.Record<S>>) -> H & Result<&2,&2,Execution.Record<S>,Execution.Record<S>>:
  match value:
    case (owner,Done{record}):(owner,Fail{record})
    case (owner,Fail{_}):(owner,Fail{Execution.ErrorRecord{"UNEXPECTED_PROJECTION_FAILURE"}})
def failing_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Execution.Record<S>,Execution.Record<S>>:
  refused(~H,~S,Execution.addedBoth_body(~S,~H,~caps,targets,owner))
def failing(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,D.Store<S>,Owners.Resource(~S),U32,Execution.Record<S>,Execution.Record<S>>:
  I.run(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Execution.addedBoth_ops(~S),~List<&2,W.Handle<S>>,~Execution.Record<S>,~Execution.Record<S>,~Execution.addedBoth_plan(~S),~failing_body(~S),instance,targets,world)
def finished(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary<S>>,before:U32,instanceBefore:Phase.InstanceView,record:Execution.Record<S>,failed:Bool,observedWorld:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32,observedInstance:I.Instance<S> & Phase.InstanceView) -> Retry<S>:
  (world,after)=observedWorld
  (instance,instanceAfter)=observedInstance
  Retry{world,instance,targets,List.append(&2,Boundary<S>,prior,[Boundary{before,after,instanceBefore,instanceAfter,record,failed}])}
def failure_observed(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary<S>>,before:U32,instanceBefore:Phase.InstanceView,value:I.Observed<S,D.Store<S>,Owners.Resource(~S),U32,Execution.Record<S>,Execution.Record<S>>) -> Retry<S>:
  match value:
    case I.Observed{world,instance,Fail{record}}:finished(~S,targets,prior,before,instanceBefore,record,True{},Phase.clock(~S,world),Phase.instance_view(~S,instance))
    case I.Observed{world,instance,Done{record}}:finished(~S,targets,prior,before,instanceBefore,record,False{},Phase.clock(~S,world),Phase.instance_view(~S,instance))
def success_observed(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary<S>>,before:U32,instanceBefore:Phase.InstanceView,value:I.Observed<S,D.Store<S>,Owners.Resource(~S),U32,Unit,Execution.Record<S>>) -> Retry<S>:
  match value:
    case I.Observed{world,instance,Done{record}}:finished(~S,targets,prior,before,instanceBefore,record,False{},Phase.clock(~S,world),Phase.instance_view(~S,instance))
    case I.Observed{world,instance,Fail{_}}:finished(~S,targets,prior,before,instanceBefore,Execution.ErrorRecord{"UNEXPECTED_INSPECTOR_FAILURE"},True{},Phase.clock(~S,world),Phase.instance_view(~S,instance))
def choose(~S:Data,+targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary<S>>,world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>,before:U32,instance:I.Instance<S>,instanceBefore:Phase.InstanceView,fail:Bool) -> Retry<S>:
  match fail:
    case True{}:failure_observed(~S,targets,prior,before,instanceBefore,failing(~S,world,instance,targets))
    case False{}:success_observed(~S,targets,prior,before,instanceBefore,Execution.addedBoth(~S,world,instance,targets))
def prepared(~S:Data,+targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary<S>>,observedWorld:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32,observedInstance:I.Instance<S> & Phase.InstanceView,fail:Bool) -> Retry<S>:
  (world,before)=observedWorld
  (instance,instanceBefore)=observedInstance
  choose(~S,targets,prior,world,before,instance,instanceBefore,fail)
def step(~S:Data,fail:Bool,value:Retry<S>) -> Retry<S>:
  match value:
    case Retry{world,instance,targets,prior}:prepared(~S,targets,prior,Phase.clock(~S,world),Phase.instance_view(~S,instance),fail)
