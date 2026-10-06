import Base
import ../library/schedule.bend as K
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
def retain(owner: World()) -> World():
  owner
def motion(p: Position,v: Velocity) -> Position & Velocity:
  match p v:
    case Position{x} Velocity{+dx}: (Position{U32.add(x,dx)},Velocity{dx})
def register() -> K.Registered:
  K.register(K.initial(),"movement",K.Fast{},False{},False{},False{},False{})
