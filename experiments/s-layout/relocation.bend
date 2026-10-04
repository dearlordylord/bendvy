import Base
import ../t08/core.bend as C
import ./core.bend as B

type Store is Type:
  Store{rows: Array<C.Row>, map: Array<U32>, members: List<&2, U32>}
type Located is Type:
  Located{store: Store, slot: U32, row: C.Row}
def initial() -> Store:
  Store{Array.set(C.Row, Array.set(C.Row, Array.set(C.Row, [C.Row{4294967295, None{}, 0, 0} : C.Row^3n], 0, C.Row{0, Some{10}, 0, 0}), 1, C.Row{1, Some{20}, 0, 0}), 2, C.Row{2, Some{30}, 0, 0}), Array.set(U32, Array.set(U32, [0 : U32^3n], 1, 1), 2, 2), [0, 1, 2]}
def located_row(map: Array<U32>, members: List<&2, U32>, slot: U32, result: Array<C.Row> & C.Row) -> Located:
  match result:
    case (rows, row): Located{Store{rows, map, members}, slot, row}
def locate_slot(valid: Bool, rows: Array<C.Row>, map: Array<U32>, members: List<&2, U32>, +slot: U32) -> Located:
  match valid:
    case False{}: Located{Store{rows, map, members}, 8, C.Row{4294967295, None{}, 0, 0}}
    case True{}: located_row(map, members, slot, Array.get(C.Row, rows, slot))
def mapped(rows: Array<C.Row>, members: List<&2, U32>, result: Array<U32> & U32) -> Located:
  match result:
    case (map, +slot): locate_slot((slot < 8 : U32), rows, map, members, slot)
def locate_valid(valid: Bool, id: U32, s: Store) -> Located:
  match valid s:
    case False{} s: Located{s, 8, C.Row{4294967295, None{}, 0, 0}}
    case True{} Store{rows, map, members}: mapped(rows, members, Array.get(U32, map, id))
def locate(+id: U32, s: Store) -> Located:
  locate_valid((id < 8 : U32), id, s)
def move_finish(valid: Bool, id: U32, old: U32, +target: U32, row: C.Row, map: Array<U32>, members: List<&2, U32>, rows: Array<C.Row>) -> Store & String:
  match valid:
    case False{}: (Store{rows, map, members}, "occupied")
    case True{}: (Store{Array.set(C.Row, Array.set(C.Row, rows, old, C.Row{4294967295, None{}, 0, 0}), target, row), Array.set(U32, map, id, target), members}, "moved")
def vacancy(id: U32, old: U32, +target: U32, row: C.Row, map: Array<U32>, members: List<&2, U32>, result: Array<C.Row> & C.Row) -> Store & String:
  match result:
    case (rows, C.Row{key, _, _, _}): move_finish(U32.is_eq(key, 4294967295), id, old, target, row, map, members, rows)
def move_ready(valid: Bool, id: U32, old: U32, +target: U32, row: C.Row, rows: Array<C.Row>, map: Array<U32>, members: List<&2, U32>) -> Store & String:
  match valid:
    case False{}: (Store{rows, map, members}, "MissingEntity")
    case True{}: vacancy(id, old, target, row, map, members, Array.get(C.Row, rows, target))
def move_located(+id: U32, +target: U32, located: Located) -> Store & String:
  match located:
    case Located{Store{rows, map, members}, +old, +row}: move_ready(Bool.and((old < 8 : U32), U32.is_eq(id, B.row_id(row))), id, old, target, row, rows, map, members)
def move_valid(valid: Bool, +id: U32, target: U32, s: Store) -> Store & String:
  match valid:
    case False{}: (s, "bounds")
    case True{}: move_located(id, target, locate(id, s))
def move(+id: U32, +target: U32, s: Store) -> Store & String:
  move_valid(Bool.and((id < 8 : U32), (target < 8 : U32)), id, target, s)
def query_value(valid: Bool, row: C.Row) -> String:
  match valid row:
    case False{} _: "MissingEntity;"
    case True{} C.Row{id, Some{x}, _, _}: U32.show(id) ++ "=" ++ U32.show(x) ++ ";"
    case True{} _: ""
def query_located(id: U32, prefix: String, located: Located) -> Store & String:
  match located:
    case Located{s, _, +row}: (s, query_value(U32.is_eq(id, B.row_id(row)), row) ++ prefix)
def query_next(+id: U32, result: Store & String) -> Store & String:
  match result:
    case (s, tail): query_located(id, tail, locate(id, s))
def query_ids(ids: List<&2, U32>, s: Store) -> Store & String:
  match ids:
    case Nil{}: (s, "")
    case Con{id, tail}: query_next(id, query_ids(tail, s))
def query(s: Store) -> Store & String:
  match s:
    case Store{rows, map, +members}: query_ids(members, Store{rows, map, members})
def component_members(id: U32, value: Maybe<&2, U32>, members: List<&2, U32>) -> List<&2, U32>:
  match value:
    case None{}: B.member_remove(members, id)
    case Some{_}: B.member_insert(members, id)
def component_ready(valid: Bool, +id: U32, slot: U32, +value: Maybe<&2, U32>, rows: Array<C.Row>, map: Array<U32>, members: List<&2, U32>) -> Store:
  match valid:
    case False{}: Store{rows, map, members}
    case True{}: Store{Array.set(C.Row, rows, slot, C.Row{id, value, 0, 0}), map, component_members(id, value, members)}
def component_located(+id: U32, value: Maybe<&2, U32>, located: Located) -> Store:
  match located:
    case Located{Store{rows, map, members}, +slot, row}: component_ready(Bool.and((slot < 8 : U32), U32.is_eq(id, B.row_id(row))), id, slot, value, rows, map, members)
def component(+id: U32, value: Maybe<&2, U32>, s: Store) -> Store:
  component_located(id, value, locate(id, s))
def print_result(prefix: String, result: Store & String) -> IO(Store):
  match result:
    case (s, text):
      do IO<Store>:
        IO.print(prefix ++ text)
        return s
def main() -> IO(Unit):
  do IO<Unit>:
    s : Store <- print_result("before:", query(initial()))
    s : Store <- print_result("relocate:", move(1, 5, s))
    s : Store <- print_result("after:", query(s))
    s : Store <- print_result("vacated-component:", query(component(1, None{}, s)))
    s : Store <- print_result("reinsert:", query(component(1, Some{20}, s)))
    s : Store <- print_result("occupied:", move(1, 2, s))
    s : Store <- print_result("target-bound:", move(1, 8, s))
    s : Store <- print_result("id-bound:", move(8, 4, s))
    s : Store <- print_result("preserved:", query(s))
    return Unit{}
