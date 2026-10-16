import Base
import ./consumer-state.bend as App
import ./consumer-spawn.bend as Spawn
import ./runtime-spawn.bend as SpawnRuntime
import ./consumer-gameplay.bend as Gameplay
import ./consumer-barrier.bend as Barrier
import ./damage-body.bend as Damage

type Operation is Data:
  SpawnOperation{}
  BarrierOperation{}
  GameplayOperation{}
  ReadersOperation{failB: Bool}
  RetryReaderBOperation{}
type Command is Data: Command{label: String,operation: Operation}
type ScenarioResult<-S: Data> is Data:
  SpawnResult{completion: SpawnRuntime.Completion<S>}
  BarrierResult{}
  GameplayResult{completion: Gameplay.Completion}
  ReadersResult{completion: App.ReaderResults}
def spawned(~S: Data,observed: App.Application<S> & SpawnRuntime.Completion<S>) -> App.Application<S> & ScenarioResult<S>:
  match observed:
    case (app,completion): (app,SpawnResult{completion})
def played(~S: Data,observed: App.Application<S> & Gameplay.Completion) -> App.Application<S> & ScenarioResult<S>:
  match observed:
    case (app,completion): (app,GameplayResult{completion})
def read(~S: Data,observed: App.Application<S> & App.ReaderResults) -> App.Application<S> & ScenarioResult<S>:
  match observed:
    case (app,completion): (app,ReadersResult{completion})
def execute(~S: Data,operation: Operation,app: App.Application<S>) -> App.Application<S> & ScenarioResult<S>:
  match operation:
    case SpawnOperation{}: spawned(~S,Spawn.run(~S,app))
    case BarrierOperation{}: (Barrier.barrier(~S,app),BarrierResult{})
    case GameplayOperation{}: played(~S,Gameplay.run(~S,app,1,Damage.DamageArgs{2,1}))
    case ReadersOperation{failB}: read(~S,App.read(~S,app,failB))
    case RetryReaderBOperation{}: read(~S,App.retry_b(~S,app))
# Exact frozen fourteen-checkpoint TS schedule; initialization supplies phase1.
def commands(unit: Unit) -> List<&2,Command>:
  [Command{"queue-spawn",SpawnOperation{}},Command{"spawn-barrier",BarrierOperation{}},Command{"step-1-damage",GameplayOperation{}},Command{"step-1-readers",ReadersOperation{False{}}},Command{"step-1-barrier",BarrierOperation{}},Command{"step-2-damage",GameplayOperation{}},Command{"step-2-reader-failure",ReadersOperation{True{}}},Command{"step-2-reader-retry",RetryReaderBOperation{}},Command{"step-2-barrier",BarrierOperation{}},Command{"step-3-damage",GameplayOperation{}},Command{"step-3-readers",ReadersOperation{False{}}},Command{"step-3-barrier",BarrierOperation{}},Command{"empty-readers",ReadersOperation{False{}}}]
