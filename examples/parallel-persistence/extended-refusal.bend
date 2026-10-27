import Base
import ./extended-flow.bend as Flow
import ./extended-execution.bend as Execution
import ./extended-resume.bend as Resume
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-save.bend as Save
import ./extended-main.bend as Observe
import ./declarations.bend as O
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-save-data.bend as Basic
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/restore-graph-data.bend as Graph
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick

type Outcome<-S:Data> is Type:
  SourceRefused{result:Flow.Outcome<S>}
  DefinitionRefused{source:Resume.Source<S>,schema:Admission.Recipes(~S),valid:Extended.Snapshot<S>,result:Execution.Defined<S>}
  Unexpected{source:Resume.Source<S>,valid:Extended.Snapshot<S>,result:Execution.Restoration<S>}
  SaveRefused{source:Resume.Source<S>,valid:Extended.Snapshot<S>,invalid:Extended.Snapshot<S>,reason:Admission.Reason,schema:Admission.Recipes(~S),app:Execution.Application(~S),result:Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>}
  Retried{invalid:Extended.Snapshot<S>,reason:Admission.Reason,refused:Extended.Snapshot<S>,result:Resume.Outcome<S>}
# Corrupt detached source data using one of its actual saved full-generation keys.
# The ordinary hierarchy validator must reject self-membership before mutation.
def malformed(~S:Data,input:Extended.Snapshot<S>) -> Extended.Snapshot<S>:
  match input:
    case Extended.Snapshot{Basic.Snapshot{version,metadata,Basic.Entity{+key,fields} <> rest,resources},_,machines}:Extended.Snapshot{Basic.Snapshot{version,metadata,Basic.Entity{key,fields} <> rest,resources},[Graph.Relation{"restore-parent",[Graph.Group{key,[key]}]}],machines}
    case input:input
def resumed(~S:Data,invalid:Extended.Snapshot<S>,reason:Admission.Reason,refused:Extended.Snapshot<S>,result:Resume.Outcome<S>) -> Outcome<S>:Retried{invalid,reason,refused,result}
def saved(~S:Data,native:Bool,source:Resume.Source<S>,valid:Extended.Snapshot<S>,invalid:Extended.Snapshot<S>,reason:Admission.Reason,held:Execution.Held<S>,result:Admission.Recipes(~S) & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(world,Gate.Saved{snapshot})):IO.bind(Resume.Outcome<S>,Outcome<S>,Resume.restored(~S,native,source,Execution.restore(~S,schema,valid,Execution.rejoin(~S,held,world))),result => IO.pure(Outcome<S>,resumed(~S,invalid,reason,snapshot,result)))
    case (schema,(world,result)):IO.pure(Outcome<S>,SaveRefused{source,valid,invalid,reason,schema,Execution.rejoin(~S,held,world),result})
def refused(~S:Data,native:Bool,source:Resume.Source<S>,valid:Extended.Snapshot<S>,result:Execution.Restoration<S>) -> IO(Outcome<S>):
  match result:
    case Execution.InputRefused{Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred},schema,invalid,reason}:saved(~S,native,source,valid,invalid,reason,Execution.Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred},Save.save(~S,schema,world))
    case result:IO.pure(Outcome<S>,Unexpected{source,valid,result})
def defined(~S:Data,native:Bool,source:Resume.Source<S>,schema:Admission.Recipes(~S),+valid:Extended.Snapshot<S>,result:Execution.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Execution.Defined{app}:refused(~S,native,source,valid,Execution.restore(~S,schema,malformed(~S,valid),app))
    case result:IO.pure(Outcome<S>,DefinitionRefused{source,schema,valid,result})
def prepared(~S:Data,native:Bool,result:Flow.Outcome<S>) -> IO(Outcome<S>):
  match result:
    case Flow.Prepared{source,previous,reader,receipt,schema,input,target}:defined(~S,native,Resume.Source{source,previous,receipt},schema,input,Execution.setup(~S,target,reader))
    case result:IO.pure(Outcome<S>,SourceRefused{result})
def run(~S:Data,native:Bool) -> IO(Outcome<S>):IO.bind(Flow.Outcome<S>,Outcome<S>,Flow.prepare(~S),result => prepared(~S,native,result))
def time(~S:Data,input:Extended.Snapshot<S>) -> String:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,Metadata.Metadata{_,_,clock,_},_,_},_,_}:Tick.show(Clock.now(clock))
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Retried{invalid,Admission.GraphRefused{Graph.InvalidRelation{name,_,_}},+refused,result}:"refused=" ++ name ++ "/clock=" ++ time(~S,refused) ++ "/actualReceiver=" ++ Observe.snapshot(~S,refused) ++ "/retry=" ++ Resume.observed(~S,result)
    case Retried{_,_,_,_}:"unexpected-refusal-reason"
    case SourceRefused{_}:"source-refused"
    case DefinitionRefused{_,_,_,_}:"definition-refused"
    case Unexpected{_,_,_}:"unexpected-outcome"
    case SaveRefused{_,_,_,_,_,_,_}:"save-refused"
def main() -> IO(Unit):IO.bind(Outcome<O.Alpha>,Unit,run(~O.Alpha,False{}),a => IO.bind(Unit,Unit,IO.print("alpha-serial " ++ observed(~O.Alpha,a)),u => IO.bind(Outcome<O.Beta>,Unit,run(~O.Beta,True{}),b => IO.print("beta-native " ++ observed(~O.Beta,b)))))
