import Base
import schema.bend as S
import state.bend as V
import observe.bend as O
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W

def World() -> Type: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>
def other_rows(+lines: List<&2,String>,observed: World() & String) -> List<&2,String>:
  (_,row) = observed
  List.append(&2,String,lines,["other|" ++ row])
def home_rows(other: World(),+lines: List<&2,String>,observed: World() & String) -> List<&2,String>:
  (_,row) = observed
  other_rows(List.append(&2,String,lines,["home|" ++ row]),O.rows(~S.SchemaA,other))
def recovered(home: World(),other: World(),+lines: List<&2,String>,observed: S.Neighbor & S.NeighborView) -> List<&2,String>:
  (_,S.NeighborView{values}) = observed
  home_rows(other,List.append(&2,String,lines,["recovered-neighbor|[" ++ O.cells(values) ++ "]"]),O.rows(~S.SchemaA,home))
def neighbor_replaced(other: World(),+lines: List<&2,String>,result: C.Replacement<World(),S.Neighbor>) -> List<&2,String>:
  match result:
    case C.ReplaceRejected{home,Some{incoming},W.MissingEntity{}}: recovered(home,other,List.append(&2,String,lines,["foreign-neighbor|MissingEntity"]),S.project_neighbor(incoming))
    case _: ["unexpected-neighbor-result"]
def phase_replaced(other: World(),+handle: W.Handle<S.SchemaA>,+lines: List<&2,String>,result: C.Replacement<World(),V.Phase>) -> List<&2,String>:
  match result:
    case C.ReplaceRejected{home,Some{V.Active{}},W.MissingEntity{}}:
      neighbor_replaced(other,List.append(&2,String,lines,["foreign-state|MissingEntity:recovered-active"]),C.replace(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~S.NeighborRest<S.SchemaA>,~S.Neighbor,~S.NeighborView,~S.NeighborToken,~S.take_neighbor(~S.SchemaA),~S.put_neighbor(~S.SchemaA),~S.project_neighbor,S.neighbor_family(~S.SchemaA),home,handle,Some{S.neighbor()}))
    case _: ["unexpected-state-result"]
def looked(other: World(),+handle: W.Handle<S.SchemaA>,observed: World() & C.Access<V.Phase>) -> List<&2,String>:
  match observed:
    case (home,C.MissingEntity{}): phase_replaced(other,handle,["foreign-lookup|MissingEntity"],C.replace(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~S.PhaseRest<S.SchemaA>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~S.SchemaA),~S.put_phase(~S.SchemaA),~S.project_phase,S.phase_family(~S.SchemaA),home,handle,Some{V.Active{}}))
    case _: ["unexpected-lookup-result"]
def namespace(home: World(),observed: World() & U32) -> List<&2,String>:
  (other,+ns) = observed
  looked(other,W.Handle{ns,1},S.get_phase(~S.SchemaA,home,W.Handle{ns,1}))
def second(home: World(),created: W.Creation<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> List<&2,String>:
  match created:
    case W.Created{_,other}: namespace(home,W.namespace(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,W.barrier(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,S.seed(~S.SchemaA,other))))
    case _: ["creation-failed"]
def first(created: W.Creation<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> List<&2,String>:
  match created:
    case W.Created{factory,home}: second(W.barrier(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,S.seed(~S.SchemaA,home)),S.create(~S.SchemaA,factory))
    case _: ["creation-failed"]
def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),unit => print_lines(rest))
def main() -> IO(Unit):
  print_lines(first(S.create(~S.SchemaA,W.factory())))
