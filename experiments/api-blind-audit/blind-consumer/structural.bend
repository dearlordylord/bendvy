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
def barrier(result: C.CheckedApply<Game,Position,Velocity,Tag,Stats,Playing>) -> List<&2,U32>:
  match result:
    case C.Applied{_,changes}: [U32.from_nat(List.length(&2,S.Change<Game>,changes))]
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
