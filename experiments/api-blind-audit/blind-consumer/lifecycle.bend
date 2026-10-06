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
def finish(result: C.CheckedApply<Game,Position,Velocity,Tag,Stats,Playing>) -> List<&2,U32>:
  match result:
    case C.Applied{_,changes}: [U32.from_nat(List.length(&2,S.Change<Game>,changes))]
    case _: [999]
def gone(result: T.CommandResult<World(),Unit>) -> List<&2,U32>:
  match result:
    case T.CommandQueued{world}: finish(C.apply_checked(Game,Position,Velocity,Tag,Stats,Playing,world,2))
    case _: [996]
def inserted(+handle: S.Handle<Game>,result: T.CommandResult<World(),Position>) -> List<&2,U32>:
  match result:
    case T.CommandQueued{world}: gone(C.despawn(Game,Position,Velocity,Tag,Stats,Playing,world,handle))
    case _: [995]
def removed(+handle: S.Handle<Game>,result: T.CommandResult<World(),Unit>) -> List<&2,U32>:
  match result:
    case T.CommandQueued{world}: inserted(handle,C.insert_main(Game,Position,Velocity,Tag,Stats,Playing,world,handle,Position{7}))
    case _: [994]
def seeded(+handle: S.Handle<Game>,result: C.CheckedApply<Game,Position,Velocity,Tag,Stats,Playing>) -> List<&2,U32>:
  match result:
    case C.Applied{world,_}: removed(handle,C.remove_main(Game,Position,Velocity,Tag,Stats,Playing,world,handle))
    case _: [993]
def reserved(result: T.Reservation<World(),S.Handle<Game>,S.Bundle<Position,Velocity,Tag>>) -> List<&2,U32>:
  match result:
    case T.Reserved{world,handle}: seeded(handle,C.apply_checked(Game,Position,Velocity,Tag,Stats,Playing,world,1))
    case _: [998]
def created(result: T.Creation<S.Factory,World()>) -> List<&2,U32>:
  match result:
    case T.Created{_,world}: reserved(C.reserve(Game,Position,Velocity,Tag,Stats,Playing,world,S.Bundle{Some{Position{3}},Some{Velocity{2}},Some{Tag{}}}))
    case _: [997]
def main() -> List<&2,U32>:
  created(I.create(~Game,~Position,~Velocity,~Tag,~Stats,~Playing,~stats,I.factory(),Playing{}))
