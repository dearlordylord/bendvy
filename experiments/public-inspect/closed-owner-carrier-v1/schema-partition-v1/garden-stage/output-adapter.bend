import Base
import five-phase-driver.bend as Driver
import retry-driver.bend as Retry
import fixture.bend as Fixture
import phase-driver.bend as Phase
import gate-phase.bend as GatePhase
import gates.bend as Gates
import owner-observer.bend as Owners
import world-observer.bend as Dump
import schema-families.bend as D
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/world.bend as W
import runtime-owners.bend as RuntimeOwners
import core-v1/src/ecs/schedule.bend as Sch

# Complete diagnostic serialization. Type owners are disposed only at this closed
# driver endpoint after their final owner-returning observations, never in callbacks.
def lines(+prefix:String,values:List<&2,String>) -> String:
  match values:
    case []:""
    case value <> rest:prefix ++ value ++ "\n" ++ lines(prefix,rest)
def boundary(value:Phase.Boundary) -> String:
  match value:
    case Phase.Boundary{before,after,instanceBefore,instanceAfter}:"queryWorldBefore|" ++ before ++ "\nqueryWorldAfter|" ++ after ++ "\ninstanceBefore|" ++ instanceBefore ++ "\ninstanceAfter|" ++ instanceAfter ++ "\n"
def boundaries(values:List<&2,Phase.Boundary>) -> String:
  match values:
    case []:""
    case value <> rest:boundary(value) ++ boundaries(rest)
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def gate(~S:Data,value:GatePhase.Observation<S>) -> String:
  match value:
    case GatePhase.Observation{observations,before,after,diagnostic}:"observations|" ++ List.show(&2,Sch.Observation,observation,observations) ++ "\nargsBefore|" ++ before ++ "\nargsAfter|" ++ after ++ "\ndiagnostic|" ++ Owners.diagnostic(~S,diagnostic) ++ "\n"
def gates(~S:Data,values:List<&2,GatePhase.Observation<S>>) -> String:
  match values:
    case []:""
    case value <> rest:gate(~S,value) ++ gates(~S,rest)
def record(~S:Data,value:Driver.Record<S>) -> String:
  match value:
    case Driver.Record{name,queries,bs,gs,before,after,registriesBefore,registriesAfter}:"phase|" ++ name ++ "\n" ++ lines("query|",queries) ++ boundaries(bs) ++ gates(~S,gs) ++ "phaseWorldBefore|" ++ before ++ "\nphaseWorldAfter|" ++ after ++ "\n" ++ lines("registryBefore|",registriesBefore) ++ lines("registryAfter|",registriesAfter)
def records(~S:Data,values:List<&2,Driver.Record<S>>) -> String:
  match values:
    case []:""
    case value <> rest:record(~S,value) ++ records(~S,rest)
def final_world(~World:Type,value:World & String) -> String:
  (_,text)=value
  "finalWorld|" ++ text ++ "\n"
def final_instance(~S:Data,value:I.Instance<S> & String) -> String:
  (_,text)=value
  "finalInstance|" ++ text ++ "\n"
def final_instances(~S:Data,values:List<I.Instance<S>>) -> String:
  match values:
    case []:""
    case value <> rest:final_instance(~S,Dump.instance(~S,value)) ++ final_instances(~S,rest)
def final_holders(~S:Data,value:List<Gates.Holder<S>> & List<&2,String>) -> String:
  (_,values)=value
  lines("finalRegistry|",values)
def driver(~S:Data,value:Driver.Built<S>) -> String:
  match value:
    case Driver.Refused{_,_}:"UNEXPECTED_WORLD_CREATION_REFUSAL\n"
    case Driver.Built{Driver.Driver{GatePhase.State{Phase.State{world,_,instances,_,_,error},holders,_,errors},rs}}:records(~S,rs) ++ final_world(~W.World<S,D.Store<S>,RuntimeOwners.Resource<S>,U32>,Dump.world(~S,world)) ++ final_instances(~S,instances) ++ final_holders(~S,Driver.holders(~S,holders)) ++ "errors|" ++ error ++ errors ++ "\n"
def retry_boundary(value:Retry.Boundary) -> String:
  match value:
    case Retry.Boundary{before,after,instanceBefore,instanceAfter,record,failed}:"retryWorldBefore|" ++ before ++ "\nretryWorldAfter|" ++ after ++ "\nretryInstanceBefore|" ++ instanceBefore ++ "\nretryInstanceAfter|" ++ instanceAfter ++ "\nretryQuery|" ++ record ++ "\nretryFailed|" ++ Bool.show(failed) ++ "\n"
def retry_boundaries(values:List<&2,Retry.Boundary>) -> String:
  match values:
    case []:""
    case value <> rest:retry_boundary(value) ++ retry_boundaries(rest)
def retry_finished(~S:Data,value:Retry.Retry<S>) -> String:
  match value:
    case Retry.Retry{world,instance,_,rs}:retry_boundaries(rs) ++ final_world(~W.World<S,D.Store<S>,RuntimeOwners.Resource<S>,U32>,Dump.world(~S,world)) ++ final_instance(~S,Dump.instance(~S,instance))
def retry(~S:Data,value:Fixture.Built<S>) -> String:
  match value:
    case Fixture.BuildRefused{_,_}:"UNEXPECTED_RETRY_WORLD_REFUSAL\n"
    case Fixture.Built{Fixture.Fixture{world,targets,error}}:retry_finished(~S,Retry.run(~S,world,targets)) ++ "retryErrors|" ++ error ++ "\n"

def main() -> String:
  "schema|Garden\n" ++ driver(~D.Garden,Driver.garden()) ++ "retry|Garden\n" ++ retry(~D.Garden,Fixture.garden())
