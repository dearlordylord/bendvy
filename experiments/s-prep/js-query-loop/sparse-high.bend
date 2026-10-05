import Base
import ./types.bend as T
import ./storage.bend as S
import ./query.bend as Q
import ./uncached-payload.bend as P

# No callback should execute: all slots are dead, but retained high-water is 65538.
def sparse_client(~Main: Type,~Aux: Type,get: Main -> T.PositionToken -> Main & T.PositionView,aux_get: Aux -> Aux & Maybe<&2,T.VelocityView>,handle: S.Handle<T.MotionSchema>,flag: Maybe<&2,T.Selected>,main: Main,aux: Aux) -> Main & (Aux & U32):
  (main,(aux,999))
def sparse_finished(result: S.Rows<T.Position,T.Velocity,T.Selected> & List<&2,U32>) -> IO(Unit):
  match result:
    case (S.Rows{_,_,_,131072,17n,65538},Nil{}): IO.print("SPARSE-HIGH-PASS")
    case _: IO.print("SPARSE-HIGH-FAIL")
def sparse_grown(rows: S.Rows<T.Position,T.Velocity,T.Selected>) -> IO(Unit):
  match rows:
    case S.Rows{main,aux,metadata,capacity,depth,_}:
      sparse_finished(Q.read_rows(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~T.PositionView,~T.VelocityView,~U32,~P.position_get,~P.velocity_get,~sparse_client,S.Rows{main,aux,metadata,capacity,depth,65538},Q.Optional{},1))
def main() -> IO(Unit):
  sparse_grown(S.grow(17n,T.Position,T.Velocity,T.Selected,65538,S.rows_empty(T.Position,T.Velocity,T.Selected)))
