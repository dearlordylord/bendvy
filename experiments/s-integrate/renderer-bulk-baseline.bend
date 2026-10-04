import Base
import ./host-render.bend as R
import ./host-observations.bend as H
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O

def rows(n:Nat,+i:U32,acc:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  match n:
    case 0n: List.reverse(&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,acc)
    case 1n+n: rows(n,(i + 1 : U32),O.QueryRow{S.Handle{71,i},T.PositionView{T.Four{i,(i + 1 : U32),(i + 2 : U32),(i + 3 : U32)},(i + 4 : U32)},Some{T.VelocityView{T.Four{(i + 5 : U32),(i + 6 : U32),(i + 7 : U32),(i + 8 : U32)},True{}}},Some{T.Selected{(i + 9 : U32)}}} <> acc)
def main() -> IO(Unit):
  +values=rows(65537n,1,[])
  do IO<Unit>:
    IO.print(R.render_motion(H.Read{"bulk","Fast",65537,T.ReadBoundary{10,11,12},values,values,values,[],[],[],False{},False{},False{}}))
