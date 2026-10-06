import Base
import ../../../src/ecs/column.bend as C
import ../../../src/ecs/lifecycle.bend as L

def bool(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def checked(column: C.Column<Unit,Array<U32>>,stamp: L.Stamp) -> C.Column<Unit,Array<U32>> & Bool:
  match stamp:
    case L.Stamp{a,c}: (column,U32.is_eq(a,3) && U32.is_eq(c,3))
def check_stamp(observed: C.Column<Unit,Array<U32>> & L.Stamp) -> C.Column<Unit,Array<U32>> & Bool:
  (column,stamp) = observed
  checked(column,stamp)
def clear_stamp(observed: C.Column<Unit,Array<U32>> & L.Stamp) -> String:
  match observed:
    case (column,L.Stamp{a,c}): String.append("clear:",bool(U32.is_eq(a,0) && U32.is_eq(c,0)))

def clear_checked(outcome: C.SwapOutcome<Unit,Array<U32>>) -> String:
  match outcome:
    case C.Rejected{_,_}: "clear:false"
    case C.Accepted{column,_}: clear_stamp(C.lifecycle(~Unit,~Array<U32>,column,1))
def clear_after_view(observed: C.Column<Unit,Array<U32>> & Bool) -> String:
  (column,valid) = observed
  String.append(String.append("projection-neutral:",String.append(bool(valid),";")),clear_checked(C.clear(~Unit,~Array<U32>,column,1)))
def after_read(observed: C.Column<Unit,Array<U32>> & Bool) -> String:
  (column,_) = observed
  clear_after_view(check_stamp(C.lifecycle(~Unit,~Array<U32>,column,1)))
def inserted(outcome: C.SwapOutcome<Unit,Array<U32>>) -> String:
  match outcome:
    case C.Rejected{_,_}: "insert:false"
    case C.Accepted{column,_}: after_read(C.has(~Unit,~Array<U32>,C.mark(~Unit,~Array<U32>,column,1,True{},False{},3),1))
def main() -> IO(Unit):
  IO.print(inserted(C.swap(~Unit,~Array<U32>,C.ensure(~Unit,~Array<U32>,C.empty(~Unit,~Array<U32>),1),1,Some{ALeaf{9}})))
