import Base
import ./transport.bend as T
def duplicate(-M: Type,-A: Type,-F: Data,rows: T.Columns<M,A,F>) -> T.Columns<M,A,F> & T.Columns<M,A,F>:
  (rows,rows)
