import Base
import ./storage.bend as S
import ./owners.bend as A
def bad(rows: S.Rows<A.Motion,A.Health,Unit>) -> S.Rows<A.Motion,A.Health,Unit> & S.Rows<A.Motion,A.Health,Unit>:
  (rows,rows)
