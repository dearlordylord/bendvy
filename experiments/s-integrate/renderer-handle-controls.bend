import Base
import ./host-render.bend as R
import ./types.bend as T
import ./storage.bend as S
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
  do IO<Unit>:
    IO.print(R.compact_handles(T.MotionSchema,handles(65537n,1,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,0,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,1,[])))
    IO.print(R.compact_handles(T.MotionSchema,bad_handles(65537n,1,2,[])))
