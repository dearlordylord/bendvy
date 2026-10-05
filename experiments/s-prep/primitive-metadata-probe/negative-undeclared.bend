import Base
import ./schema.bend as S
import ./transport.bend as T
def undeclared(rows: S.Scoped<S.Motion,U32,U32,U32>) -> S.ReadPermit<S.Motion> & (S.Scoped<S.Motion,U32,U32,U32> & Maybe<&2,T.Metadata<U32>>):
  S.read(S.Motion,U32,U32,U32,rows,1)
