import Base
import schema-families.bend as D
import runtime-named-declarations.bend as Decl
import runtime-owners.bend as Owners
import execution.bend as Execution
import consumer-witness.bend as Caps
import world-observer.bend as Dump
import core/world.bend as W
import core/inspector.bend as I

type Boundary is Data:
  Boundary{worldBefore:String,worldAfter:String,instanceBefore:String,instanceAfter:String,record:String,failed:Bool}
type Retry<S:Data> is Type:
  Retry{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>,boundaries:List<&2,Boundary>}
def refused(~H:Type,value:H & Result<&2,&2,Unit,String>) -> H & Result<&2,&2,String,String>:
  match value:
    case (owner,Done{record}):(owner,Fail{record})
    case (owner,Fail{_}):(owner,Fail{"UNEXPECTED_PROJECTION_FAILURE"})
def failing_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Decl.ValueAddedBoth>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,String,String>:
  refused(~H,Execution.addedBoth_body(~S,~H,~caps,targets,owner))
def failing(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,D.Store<S>,Owners.Resource<S>,U32,String,String>:
  I.run(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Execution.addedBoth_ops(~S),~List<&2,W.Handle<S>>,~String,~String,~Execution.addedBoth_plan(~S),~failing_body(~S),instance,targets,world)
def finished(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary>,before:String,instanceBefore:String,record:String,failed:Bool,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String,observedInstance:I.Instance<S> & String) -> Retry<S>:
  (world,after)=observedWorld
  (instance,instanceAfter)=observedInstance
  Retry{world,instance,targets,List.append(&2,Boundary,prior,[Boundary{before,after,instanceBefore,instanceAfter,record,failed}])}
def failure_observed(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary>,before:String,instanceBefore:String,value:I.Observed<S,D.Store<S>,Owners.Resource<S>,U32,String,String>) -> Retry<S>:
  match value:
    case I.Observed{world,instance,Fail{record}}:finished(~S,targets,prior,before,instanceBefore,record,True{},Dump.world(~S,world),Dump.instance(~S,instance))
    case I.Observed{world,instance,Done{record}}:finished(~S,targets,prior,before,instanceBefore,record,False{},Dump.world(~S,world),Dump.instance(~S,instance))
def success_observed(~S:Data,targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary>,before:String,instanceBefore:String,value:I.Observed<S,D.Store<S>,Owners.Resource<S>,U32,Unit,String>) -> Retry<S>:
  match value:
    case I.Observed{world,instance,Done{record}}:finished(~S,targets,prior,before,instanceBefore,record,False{},Dump.world(~S,world),Dump.instance(~S,instance))
    case I.Observed{world,instance,Fail{_}}:finished(~S,targets,prior,before,instanceBefore,"UNEXPECTED_INSPECTOR_FAILURE",True{},Dump.world(~S,world),Dump.instance(~S,instance))
def choose(~S:Data,+targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,before:String,instance:I.Instance<S>,instanceBefore:String,fail:Bool) -> Retry<S>:
  match fail:
    case True{}:failure_observed(~S,targets,prior,before,instanceBefore,failing(~S,world,instance,targets))
    case False{}:success_observed(~S,targets,prior,before,instanceBefore,Execution.addedBoth(~S,world,instance,targets))
def prepared(~S:Data,+targets:List<&2,W.Handle<S>>,prior:List<&2,Boundary>,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String,observedInstance:I.Instance<S> & String,fail:Bool) -> Retry<S>:
  (world,before)=observedWorld
  (instance,instanceBefore)=observedInstance
  choose(~S,targets,prior,world,before,instance,instanceBefore,fail)
def step(~S:Data,fail:Bool,value:Retry<S>) -> Retry<S>:
  match value:
    case Retry{world,instance,targets,prior}:prepared(~S,targets,prior,Dump.world(~S,world),Dump.instance(~S,instance),fail)
def run(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,targets:List<&2,W.Handle<S>>) -> Retry<S>:
  step(~S,False{},step(~S,False{},step(~S,True{},Retry{world,I.Fresh{},targets,[]})))
def workshop(world:W.World<D.Workshop,D.Store<D.Workshop>,Owners.Resource<D.Workshop>,U32>,targets:List<&2,W.Handle<D.Workshop>>) -> Retry<D.Workshop>:
  run(~D.Workshop,world,targets)
def garden(world:W.World<D.Garden,D.Store<D.Garden>,Owners.Resource<D.Garden>,U32>,targets:List<&2,W.Handle<D.Garden>>) -> Retry<D.Garden>:
  run(~D.Garden,world,targets)
def main() -> Unit:
  Unit{}
