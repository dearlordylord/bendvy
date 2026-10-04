import Base
import ./types.bend as T
import ./runtime.bend as R

def rows_count(rows: List<R.Cell>) -> U32:
  match rows:
    case Nil{}: 0
    case Con{_,tail}: (1 + rows_count(tail) : U32)
def reservation_line(handle: Maybe<&2,R.Handle>, world: R.World) -> String:
  match handle world:
    case Some{R.Handle{_,slot}} R.World{_,next,rows,_}: "reserved:" ++ U32.show(slot) ++ ":next:" ++ U32.show(next) ++ ":live:" ++ U32.show(rows_count(rows))
    case None{} R.World{_,next,rows,_}: "rejected:next:" ++ U32.show(next) ++ ":live:" ++ U32.show(rows_count(rows))
def reserve_text(result: R.World & Maybe<&2,R.Handle>) -> String:
  match result:
    case (world,handle): reservation_line(handle,world)
def factory_line(result: R.Factory & Maybe<R.World>) -> String:
  match result:
    case (R.Factory{next},Some{R.World{id,_,_,_}}): "created:" ++ U32.show(id) ++ ":next:" ++ U32.show(next)
    case (R.Factory{next},None{}): "creation-rejected:next:" ++ U32.show(next)
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(reserve_text(R.reserve(4294967295,R.World{0,4294967294,[],[]},7)))
    IO.print(reserve_text(R.reserve(4294967295,R.World{0,4294967295,[],[]},7)))
    IO.print(factory_line(R.create(4294967295,R.Factory{4294967294})))
    IO.print(factory_line(R.create(4294967295,R.Factory{4294967295})))
    IO.print("increment-before-max:" ++ U32.show((4294967294 + 1 : U32)))
    return Unit{}
