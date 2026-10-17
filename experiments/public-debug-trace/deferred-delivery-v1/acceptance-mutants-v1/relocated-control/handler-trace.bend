import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/machine-handlers.bend as H
import ../../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../../src/ecs/ordinary-machine-handler-bundle.bend as Classic
import ../../../../../src/ecs/ordinary-machine-handler-bundle-context.bend as Context
import ../../../../../src/ecs/execution-trace.bend as Trace
import ../../../../../src/ecs/trace-facts.bend as Facts

def observed(fact:Facts.Fact,barrier:Bool,identity:Maybe<&2,Trace.Identity>) -> Trace.TraceEvent<String>:
  match barrier identity:
    case True{} _:Trace.BarrierOperationObserved{fact}
    case False{} Some{identity}:Trace.OperationObserved{identity,fact}
    case False{} None{}:Trace.ExecutionOperationObserved{fact}
def events(items:List<&2,Facts.Fact>,+barrier:Bool,+identity:Maybe<&2,Trace.Identity>) -> List<&2,Trace.TraceEvent<String>>:
  match items:
    case []:[]
    case Facts.BoundaryFact{Facts.PhaseBoundary{name}} <> rest:Trace.PhaseEntered{name} <> events(rest,False{},None{})
    case Facts.BoundaryFact{Facts.BarrierEntered{}} <> rest:events(rest,True{},None{})
    case Facts.BoundaryFact{Facts.BarrierFinished{}} <> rest:Trace.DeferredApplied{} <> events(rest,False{},None{})
    case Facts.HandlerFact{+namespace,+id,+name,ordinal,phase,from,to,result} <> rest:Trace.ExecutionOperationObserved{Facts.HandlerFact{namespace,id,name,ordinal,phase,from,to,result}} <> events(rest,barrier,Some{Trace.Identity{namespace,id,Some{name}}})
    case Facts.ReaderFact{+namespace,+id,+name,readerId,domain,lagged} <> rest:Trace.OperationObserved{Trace.Identity{namespace,id,Some{name}},Facts.ReaderFact{namespace,id,name,readerId,domain,lagged}} <> events(rest,barrier,identity)
    case fact <> rest:observed(fact,barrier,identity) <> events(rest,barrier,identity)
def named(~Q:Data,namespace:U32,name:String,status:B.Status<Q>,facts:List<&2,Facts.Fact>) -> Trace.Batch<String>:
  match status:
    case B.ForeignBundle{}:Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndRejected{}}]}
    case B.MissingRequirements{_}:Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndMissing{}}]}
    case B.HandlerFailed{_,error}:Trace.Ready{Trace.ScheduleStarted{namespace,name} <> List.append(&2,Trace.TraceEvent<String>,events(facts,False{},None{}),[Trace.ScheduleEnded{Trace.EndFailed{error}}])}
    case _:Trace.Ready{Trace.ScheduleStarted{namespace,name} <> List.append(&2,Trace.TraceEvent<String>,events(facts,False{},None{}),[Trace.ScheduleEnded{Trace.EndOk{}}])}
def captured(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,name:String,value:Context.MarkerResult<S,K,V,Q,C,R,E,runner>) -> Classic.MarkerResult<S,K,V,Q,C,R,E,runner> & Trace.Batch<String>:
  match value:
    case Context.MarkerResult{result,steps,observations,Facts.Off{}}:(Classic.MarkerResult{result,steps,observations},Trace.Disabled{})
    case Context.MarkerResult{B.Returned{B.Bundle{+namespace,entries},world,+status},steps,observations,Facts.On{facts}}:(Classic.MarkerResult{B.Returned{B.Bundle{namespace,entries},world,status},steps,observations},named(~Q,namespace,name,status,List.reverse(&2,Facts.Fact,facts)))
    case Context.MarkerResult{B.InternalOwnerRemainder{+namespace,recovery,world,+status},steps,observations,Facts.On{facts}}:(Classic.MarkerResult{B.InternalOwnerRemainder{namespace,recovery,world,status},steps,observations},named(~Q,namespace,name,status,List.reverse(&2,Facts.Fact,facts)))
