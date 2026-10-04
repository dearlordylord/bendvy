import Base
import ./host-render.bend as R
import ./host-observations.bend as H
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O

def rows(n:Nat,+i:U32,acc:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  match n:
    case 0n: List.reverse(&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,acc)
    case 1n+n: rows(n,(i + 1 : U32),O.QueryRow{S.Handle{71,i},T.PositionView{T.Four{i,(i + 1 : U32),(i + 2 : U32),(i + 3 : U32)},7},Some{T.VelocityView{T.Four{2,3,4,5},True{}}},Some{T.Selected{8}}} <> acc)
def health_rows(n:Nat,+i:U32,acc:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>:
  match n:
    case 0n: List.reverse(&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,acc)
    case 1n+n: health_rows(n,(i + 1 : U32),O.QueryRow{S.Handle{72,i},T.VitalsView{T.Four{i,(i + 1 : U32),(i + 2 : U32),(i + 3 : U32)},9,2},Some{T.ArmorView{T.Four{2,3,4,5},4}},Some{T.Tracked{8}}} <> acc)
def handles(n:Nat,+id:U32,acc:List<&2,S.Handle<T.MotionSchema>>) -> List<&2,S.Handle<T.MotionSchema>>:
  match n:
    case 0n: List.reverse(&2,S.Handle<T.MotionSchema>,acc)
    case 1n+n: handles(n,(id + 1 : U32),S.Handle{77,id} <> acc)
def bad_handle_mode(mode:U32,id:U32) -> S.Handle<T.MotionSchema>:
  match mode:
    case 0: S.Handle{78,id}
    case 1: S.Handle{77,65536}
    case _: S.Handle{77,0}
def bad_handle(+id:U32,mode:U32) -> S.Handle<T.MotionSchema>:
  match id:
    case 65537: bad_handle_mode(mode,id)
    case _: S.Handle{77,id}
def bad_handles(n:Nat,+id:U32,+mode:U32,acc:List<&2,S.Handle<T.MotionSchema>>) -> List<&2,S.Handle<T.MotionSchema>>:
  match n:
    case 0n: List.reverse(&2,S.Handle<T.MotionSchema>,acc)
    case 1n+n: bad_handles(n,(id + 1 : U32),mode,bad_handle(id,mode) <> acc)
def main() -> IO(Unit):
  +values=rows(65537n,1,[])
  do IO<Unit>:
    IO.print(R.compact_motion_event(H.Read{"bulk","Fast",65537,T.ReadBoundary{10,11,12},values,values,values,[],[],[],False{},False{},False{}}))
    IO.print(R.compact_health_event(H.Read{"bulk-health","Slow",65537,T.ReadBoundary{20,21,22},health_rows(65537n,1,[]),[],[],[],[],[],True{},False{},True{}}))
    IO.print(R.compact_handles(T.MotionSchema,handles(65537n,1,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,0,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,1,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,2,[])))
