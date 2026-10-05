import Base
import ./schema.bend as S
import ./transport.bend as T
# Generic Type-kind positive twin of the omitted/mismatched-permit controls.
def declared(-M: Type,-A: Type,-F: Data,p: S.ReadPermit<S.Motion>,rows: S.Scoped<S.Motion,M,A,F>) -> S.ReadPermit<S.Motion> & (S.Scoped<S.Motion,M,A,F> & Maybe<&2,T.Metadata<F>>):
  S.read(S.Motion,M,A,F,p,rows,1)
