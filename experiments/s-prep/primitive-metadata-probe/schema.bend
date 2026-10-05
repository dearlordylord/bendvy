import Base
import ./transport.bend as T

type Motion is Data:
  Motion{}
type Health is Data:
  Health{}
type ReadPermit<-S: Data> is Type:
  ReadPermit{}
type Scoped<-S: Data,-M: Type,-A: Type,-F: Data> is Type:
  Scoped{rows: T.Columns<M,A,F>}
def read_done(-S: Data,-M: Type,-A: Type,-F: Data,p: ReadPermit<S>,result: T.Columns<M,A,F> & Maybe<&2,T.Metadata<F>>) -> ReadPermit<S> & (Scoped<S,M,A,F> & Maybe<&2,T.Metadata<F>>):
  match result:
    case (rows,observation): (p,(Scoped{rows},observation))
def read(-S: Data,-M: Type,-A: Type,-F: Data,p: ReadPermit<S>,scoped: Scoped<S,M,A,F>,id: U32) -> ReadPermit<S> & (Scoped<S,M,A,F> & Maybe<&2,T.Metadata<F>>):
  match scoped:
    case Scoped{rows}: read_done(S,M,A,F,p,T.columns_read(M,A,F,rows,id))
