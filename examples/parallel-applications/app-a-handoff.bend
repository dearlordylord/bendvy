import Base
import ./app-a-payloads.bend as P
import ./app-a-recovery.bend as Recovery
import ../../src/ecs/world.bend as W
import ../../src/ecs/recoverable-component.bend as RC
import ../../src/ecs/lifecycle.bend as Life

type State is Type:
  State{target:Maybe<&2,W.Handle<P.AuditWorkshop>>,records:Recovery.Records(),output:Maybe<Array<U32>>,loose:Maybe<Array<U32>>,history:List<&2,Life.Stamp>,text:String}
def values(values:List<&2,U32>) -> String:List.show(&2,U32,U32.show,values)
def projected(result:Array<U32> & List<&2,U32>) -> Array<U32> & String:
  match result:
    case (owner,view):(owner,values(view))
def displaced_observed(~R:Type,target:W.Handle<P.AuditWorkshop>,records:Recovery.Records(),nextOutput:Maybe<Array<U32>>,history:List<&2,Life.Stamp>,text:String,world:Recovery.World(~R),result:Array<U32> & String) -> Recovery.World(~R) & State:
  match result:
    case (displaced,view):(world,State{Some{target},records,nextOutput,Some{displaced},history,text ++ ";commit-displaced=" ++ view})
def retried(~R:Type,+target:W.Handle<P.AuditWorkshop>,records:Recovery.Records(),firstStamp:Life.Stamp,text:String,result:Recovery.World(~R) & Recovery.Reply) -> Recovery.World(~R) & State:
  match result:
    case (world,Recovery.Completed{True{},RC.Record{_,stamp,Some{displaced}} <> rest,nextOutput}):displaced_observed(~R,target,List.append(&1,RC.Record<P.AuditWorkshop,Array<U32>>,records,rest),nextOutput,[firstStamp,stamp],text,world,projected(P.project(displaced)))
    case (world,Recovery.Completed{success,nextRecords,nextOutput}):(world,State{Some{target},List.append(&1,RC.Record<P.AuditWorkshop,Array<U32>>,records,nextRecords),nextOutput,None{},[firstStamp],text ++ ";unexpected retry receipt"})
    case (world,Recovery.Refused{incoming,_}):(world,State{Some{target},records,None{},incoming,[firstStamp],text ++ ";retry refused"})
def withdrawn(~R:Type,+target:W.Handle<P.AuditWorkshop>,records:Recovery.Records(),stamp:Life.Stamp,world:Recovery.World(~R),result:Array<U32> & String) -> Recovery.World(~R) & State:
  match result:
    case (incoming,view):retried(~R,target,records,stamp,"rollback-returned=" ++ view,Recovery.run(~R,world,target,incoming,False{}))
def failed(~R:Type,+target:W.Handle<P.AuditWorkshop>,result:Recovery.World(~R) & Recovery.Reply) -> Recovery.World(~R) & State:
  match result:
    case (world,Recovery.Completed{False{},RC.Record{_,stamp,Some{incoming}} <> rest,None{}}):withdrawn(~R,target,rest,stamp,world,projected(P.project(incoming)))
    case (world,Recovery.Completed{success,records,output}):(world,State{Some{target},records,output,None{},[],"unexpected failure receipt"})
    case (world,Recovery.Refused{incoming,_}):(world,State{Some{target},[],None{},incoming,[],"replacement refused"})
def selected(~R:Type,result:Recovery.World(~R) & List<&2,W.Handle<P.AuditWorkshop>>) -> Recovery.World(~R) & State:
  match result:
    case (world,[]):(world,State{None{},[],None{},None{},[],"missing target"})
    case (world,+target <> _):failed(~R,target,Recovery.run(~R,world,target,P.replacement(),True{}))
def begin(~R:Type,world:Recovery.World(~R)) -> Recovery.World(~R) & State:
  selected(~R,W.handles(~P.AuditWorkshop,~Recovery.Columns(),~R,~Unit,world))
