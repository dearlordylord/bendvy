import Base
import ./model.bend as M

def filter_tag(keep: Bool, row: M.Row, rest: List<&2, M.Row>) -> List<&2, M.Row>:
  match keep:
    case True{}: row <> rest
    case False{}: rest
def present(rows: List<&2, M.Row>) -> List<&2, M.Row>:
  match rows:
    case Nil{}: []
    case Con{M.Row{id, value, +tagged}, tail}: filter_tag(tagged, M.Row{id, value, tagged}, present(tail))
def absent(rows: List<&2, M.Row>) -> List<&2, M.Row>:
  match rows:
    case Nil{}: []
    case Con{M.Row{id, value, +tagged}, tail}: filter_tag(Bool.not(tagged), M.Row{id, value, tagged}, absent(tail))
def erase_row(equal: Bool, row: M.Row, tail: List<&2, M.Row>) -> List<&2, M.Row>:
  match equal:
    case True{}: tail
    case False{}: row <> tail
def erase(+slot: Nat, rows: List<&2, M.Row>) -> List<&2, M.Row>:
  match rows:
    case Nil{}: []
    case Con{M.Row{+id, value, tagged}, tail}: erase_row(Nat.is_eq(slot, id), M.Row{id, value, tagged}, erase(slot, tail))
