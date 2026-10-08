import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./consumer-state.bend as App
import ./consumer-start.bend as Start
import ./consumer-barrier.bend as Barrier
import ./scenario-actions.bend as Actions

type Phase<-S: Data> is Data:
  Phase{observation: App.Observation,result: Actions.ScenarioResult<S>}
type ScenarioRun<-S: Data> is Type:
  ScenarioRun{app: App.Application<S>,phases: List<&2,Phase<S>>}
type ScenarioExecution<-S: Data> is Type:
  ScenarioExecuted{factory: W.Factory,run: ScenarioRun<S>}
  ScenarioInitializationRefused{result: Start.Initialized<S>}
def observed(~S: Data,result: Actions.ScenarioResult<S>,trace: List<&2,Phase<S>>,next: App.Application<S> -> List<&2,Phase<S>> -> ScenarioRun<S>,observation: App.Application<S> & App.Observation) -> ScenarioRun<S>:
  match observation:
    case (app,snapshot): next(app,Phase{snapshot,result} <> trace)
def executed(~S: Data,label: String,trace: List<&2,Phase<S>>,next: App.Application<S> -> List<&2,Phase<S>> -> ScenarioRun<S>,result: App.Application<S> & Actions.ScenarioResult<S>) -> ScenarioRun<S>:
  match result:
    case (app,result): observed(~S,result,trace,next,App.observe(~S,label,app))
def command(~S: Data,command: Actions.Command,app: App.Application<S>,trace: List<&2,Phase<S>>,next: App.Application<S> -> List<&2,Phase<S>> -> ScenarioRun<S>) -> ScenarioRun<S>:
  match command:
    case Actions.Command{label,operation}: executed(~S,label,trace,next,Actions.execute(~S,operation,Barrier.frame(~S,app)))
# This is a schedule driver only: every mutation is an actual registered ECS
# system or explicit ECS barrier; every result and full checkpoint is retained.
def loop(~S: Data,commands: List<&2,Actions.Command>,app: App.Application<S>,trace: List<&2,Phase<S>>) -> ScenarioRun<S>:
  match commands:
    case []: ScenarioRun{app,List.reverse(&2,Phase<S>,trace)}
    case head <> rest: command(~S,head,app,trace,(app => trace => loop(~S,rest,app,trace)))
def initial_observed(~S: Data,result: App.ReaderResults,observed: App.Application<S> & App.Observation) -> ScenarioRun<S>:
  match observed:
    case (app,snapshot): loop(~S,Actions.commands(Unit{}),app,[Phase{snapshot,Actions.ReadersResult{result}}])
def initialized(~S: Data,result: Start.Initialized<S>) -> ScenarioExecution<S>:
  match result:
    case Start.Initialized{factory,app,readers}: ScenarioExecuted{factory,initial_observed(~S,readers,App.observe(~S,"register-readers",app))}
    case result: ScenarioInitializationRefused{result}
def run(~S: Data,factory: W.Factory,capacity: Nat) -> ScenarioExecution<S>:
  initialized(~S,Start.initialize(~S,factory,capacity))
