import Base
import ./storage.bend as S
import ./owners.bend as A
def bad(row: S.Row<A.Motion,A.Health,Unit>) -> S.Row<A.Health,A.Motion,Unit>:
  row
