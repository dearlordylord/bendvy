import Base
import ../library/storage.bend as S
import ../library/types.bend as T
import ../library/identity.bend as I
import ../library/commands.bend as C

type Game is Data:
  Game{}
type Position is Type:
  Position{x: U32}
type Velocity is Type:
  Velocity{dx: U32}
type Tag is Data:
  Tag{}
type Token is Data:
  Token{}
type Stats is Type:
  Stats{hits: U32}
type Playing is Data:
  Playing{}
def World() -> Type:
  S.World<Game,Position,Velocity,Tag,Stats,Playing>
def stats(unit: Unit) -> Stats:
  Stats{0}
type Other is Data:
  Other{}
def remove(world: World(),handle: S.Handle<Game>) -> T.CommandResult<World(),Unit>:
  C.remove_main(Game,Position,Velocity,Tag,Stats,Playing,world,handle)
