import Base
import ./gameplay.bend as Game
import ./systems.bend as Systems
import ./step.bend as Step
import ./checkpoint.bend as Checkpoint

def returned(~S: Data,movement: Systems.MovementRegistry(~S),damage: Systems.DamageRegistry(~S),observed: Step.World(~S) & Checkpoint.Snapshot) -> Game.Gameplay<S> & Checkpoint.Snapshot:
  match observed:
    case (world,snapshot): (Game.Gameplay{world,movement,damage},snapshot)
def observe(~S: Data,label: String,game: Game.Gameplay<S>) -> Game.Gameplay<S> & Checkpoint.Snapshot:
  match game:
    case Game.Gameplay{world,movement,damage}: returned(~S,movement,damage,Checkpoint.observe(~S,label,world))
