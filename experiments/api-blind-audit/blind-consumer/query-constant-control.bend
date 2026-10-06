import Base
import ../library/storage.bend as S
import ../library/types.bend as T
import ../library/identity.bend as I
import ../library/commands.bend as C
import ../library/query.bend as Q

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
def position(owner: Position) -> Position & U32:
  match owner:
    case Position{+x}: (Position{x},x)
def velocity(owner: Velocity) -> Velocity & U32:
  match owner:
    case Velocity{+dx}: (Velocity{dx},dx)
def observed(-P: Type,-U: Type,aux: U,result: P & U32) -> P & (U & U32):
  match result:
    case (owner,x): (owner,(aux,x))
def observer(-P: Type,-U: Type,-get: P -> Token -> P & U32,-ag: U -> U & Maybe<&2,U32>,handle: S.Handle<Game>,flag: Maybe<&2,Tag>,owner: P,aux: U) -> P & (U & U32):
  (owner,(aux,42))
def observations(result: World() & List<&2,U32>) -> List<&2,U32>:
  match result:
    case (_,values): values
def query(world: World()) -> List<&2,U32>:
  observations(Q.each(~Game,~Position,~Velocity,~Tag,~Token,~U32,~U32,~U32,~Stats,~Playing,~position,~velocity,~observer,Q.Optional{},world))
def barrier(result: C.CheckedApply<Game,Position,Velocity,Tag,Stats,Playing>) -> List<&2,U32>:
  match result:
    case C.Applied{world,_}: query(world)
    case _: [999]
def reserved(result: T.Reservation<World(),S.Handle<Game>,S.Bundle<Position,Velocity,Tag>>) -> List<&2,U32>:
  match result:
    case T.Reserved{world,_}: barrier(C.apply_checked(Game,Position,Velocity,Tag,Stats,Playing,world,1))
    case _: [998]
def created(result: T.Creation<S.Factory,World()>) -> List<&2,U32>:
  match result:
    case T.Created{_,world}: reserved(C.reserve(Game,Position,Velocity,Tag,Stats,Playing,world,S.Bundle{Some{Position{3}},Some{Velocity{2}},Some{Tag{}}}))
    case _: [997]
def main() -> List<&2,U32>:
  created(I.create(~Game,~Position,~Velocity,~Tag,~Stats,~Playing,~stats,I.factory(),Playing{}))
