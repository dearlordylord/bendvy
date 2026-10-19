import Base
import core.bend as C
import ../../src/ecs/ordinary-query-declaration.bend as D

def mode(value:D.Mode) -> String:
  match value:
    case D.Read{}:"Read"
    case D.Write{}:"Write"
    case D.Optional{}:"Optional"
    case D.With{}:"With"
    case D.Without{}:"Without"
    case D.Added{}:"Added"
    case D.Changed{}:"Changed"
def clause(value:D.Clause<C.Schema>) -> String:
  match value:
    case D.Clause{name,value}:name ++ ":" ++ mode(value)
def snapshot(value:C.Snapshot) -> String:
  match value:
    case C.Snapshot{left,right,owner,allowLeft,allowRight,selected,clauses}:List.show(&2,U32,U32.show,left) ++ "|" ++ List.show(&2,U32,U32.show,right) ++ "|" ++ List.show(&2,U32,U32.show,owner) ++ "|" ++ Bool.show(allowLeft) ++ "," ++ Bool.show(allowRight) ++ ":" ++ Bool.show(selected) ++ "|" ++ List.show(&2,D.Clause<C.Schema>,clause,clauses)
def main() -> IO(Unit):
  IO.print(List.show(&2,C.Snapshot,snapshot,C.run()))
