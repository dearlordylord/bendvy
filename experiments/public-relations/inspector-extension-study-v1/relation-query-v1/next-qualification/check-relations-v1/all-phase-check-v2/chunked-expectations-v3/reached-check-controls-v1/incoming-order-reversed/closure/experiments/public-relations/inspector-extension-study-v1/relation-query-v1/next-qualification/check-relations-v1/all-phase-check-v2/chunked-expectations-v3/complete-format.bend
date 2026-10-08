import Base
import ../../../../core-v1/src/ecs/check.bend as K
import complete-driver.bend as Complete
import ../../fixture-phase.bend as Phase
import ../../fixture-phase-format.bend as F
import ../../fixture-snapshot.bend as Snap
import ../../gated-observe.bend as Gate
import ../../gated-core/schedule.bend as Sch

def check_bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
# Closed fixture canonical resource names; no arbitrary-string serializer claim.
def resource_name(value:String) -> String:
  "\"" ++ value ++ "\""
def check_error(error:K.Error) -> String:
  match error:
    case K.MissingRuntimeRequirements{resources}:"{\"missingRuntimeRequirements\":" ++ List.show(&2,String,resource_name,resources) ++ "}"
def check_result(value:Result<&2,&2,K.Error,Bool>) -> String:
  match value:
    case Done{value}:"{\"done\":" ++ check_bool(value) ++ "}"
    case Fail{error}:check_error(error)
def snapshot(~S:Data,+value:Snap.Snapshot<S>) -> String:
  "{\"namespace\":" ++ U32.show(F.namespace(~S,value)) ++ ",\"clock\":" ++ U32.show(F.clock(~S,value)) ++ ",\"pending\":" ++ U32.show(F.pending(~S,value)) ++ ",\"owners\":" ++ F.owners(~S,value) ++ "}"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Ran{id}:"{\"ran\":" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"{\"skipped\":" ++ U32.show(id) ++ "}"
    case Sch.Entered{name}:"{\"entered\":\"" ++ name ++ "\"}"
    case Sch.Applied{}:"{\"applied\":true}"
def gate(~S:Data,value:Gate.Record<S>) -> String:
  match value:
    case Gate.Record{before,after,markers,allowed,skipped}:"{\"before\":" ++ snapshot(~S,before) ++ ",\"after\":" ++ snapshot(~S,after) ++ ",\"bodyMarkers\":" ++ U32.show(markers) ++ ",\"allowed\":" ++ List.show(&2,Sch.Observation,observation,allowed) ++ ",\"skipped\":" ++ List.show(&2,Sch.Observation,observation,skipped) ++ "}"
def phases(~S:Data,values:List<&2,Phase.Phase<S>>) -> String:
  match values:
    case [first,second,last]:"[" ++ F.phase(~S,"initial",first) ++ "," ++ F.phase(~S,"queued",second) ++ "," ++ F.phase(~S,"barrier",last) ++ "]"
    case _:"null"
def retained(~S:Data,values:List<&2,Phase.Phase<S>>) -> String:
  match values:
    case [first,_,+last]:",\"retainedInitialInverse\":" ++ F.inverse(~S,2,first) ++ ",\"currentInverse2\":" ++ F.inverse(~S,2,last) ++ ",\"currentInverse4\":" ++ F.inverse(~S,4,last)
    case _:""
def render(~S:Data,name:String,delivery:Complete.Delivery<S>) -> Complete.Delivery<S> & String:
  match delivery:
    case Complete.Delivered{factory,Gate.Finished{world,schedule,+record},foreign,+values,+checks,+foreignBefore,+foreignAfter,+errors}:
      (Complete.Delivered{factory,Gate.Finished{world,schedule,record},foreign,values,checks,foreignBefore,foreignAfter,errors},"{\"schema\":\"" ++ name ++ "\",\"phases\":" ++ phases(~S,values) ++ retained(~S,values) ++ ",\"phaseChecks\":" ++ List.show(&2,Result<&2,&2,K.Error,Bool>,check_result,checks) ++ ",\"gate\":" ++ gate(~S,record) ++ ",\"foreignBefore\":" ++ snapshot(~S,foreignBefore) ++ ",\"foreignAfter\":" ++ snapshot(~S,foreignAfter) ++ ",\"errors\":\"" ++ errors ++ "\"}")
    case delivery:(delivery,"{\"refused\":true}")
