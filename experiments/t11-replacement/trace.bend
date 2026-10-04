import Base
import ./types.bend as T
import ./runtime.bend as R

def tag_text(tag: Bool) -> String:
  match tag:
    case True{}: "1"
    case False{}: "0"
def row_text(row: T.Row) -> String:
  match row:
    case T.Row{slot,value,tag}: Nat.show(slot) ++ ":" ++ Nat.show(value) ++ ":" ++ tag_text(tag) ++ ";"
def rows_text(rows: List<&2,T.Row>) -> String:
  match rows:
    case Nil{}: ""
    case Con{row,tail}: row_text(row) ++ rows_text(tail)
def lookup_text(result: T.Lookup) -> String:
  match result:
    case T.Missing{}: "MissingEntity"
    case T.Mismatch{}: "QueryMismatch"
    case T.Found{row}: "match:" ++ row_text(row)
def printed_query(label: String, result: R.World & List<&2,T.Row>) -> IO(R.World):
  match result:
    case (world,rows): do IO<R.World>:
      IO.print(label ++ rows_text(rows))
      return world
def printed_lookup(label: String, result: R.World & T.Lookup) -> IO(R.World):
  match result:
    case (world,result): do IO<R.World>:
      IO.print(label ++ lookup_text(result))
      return world
def checkpoint(+label: String, world: R.World) -> IO(R.World):
  do IO<R.World>:
    world : R.World <- printed_query(label ++ ":any:",R.query(world,T.Any{}))
    world : R.World <- printed_query(label ++ ":present:",R.query(world,T.Present{}))
    world : R.World <- printed_query(label ++ ":absent:",R.query(world,T.Absent{}))
    world : R.World <- printed_lookup(label ++ ":lookup1:",R.lookup(world,R.Handle{0,1},T.Any{}))
    world : R.World <- printed_lookup(label ++ ":lookup2-present:",R.lookup(world,R.Handle{0,2},T.Present{}))
    world : R.World <- printed_lookup(label ++ ":lookup4:",R.lookup(world,R.Handle{0,4},T.Any{}))
    return world
def foreign_checkpoint(foreign: R.Handle, result: R.World & T.Lookup) -> IO(R.World):
  match result:
    case (world,lookup): do IO<R.World>:
      IO.print("foreign-collision:lookup:" ++ lookup_text(lookup))
      world : R.World = R.publish(world,foreign,T.Despawn{})
      world : R.World <- checkpoint("foreign-command-denied",R.flush(world))
      return world
def run(world: R.World, +foreign: R.Handle) -> IO(Unit):
  do IO<Unit>:
    world : R.World <- checkpoint("empty",world)
    world : R.World = R.tick([R.Reserve{1},R.Reserve{2},R.Reserve{3}],8,world)
    world : R.World <- checkpoint("pending",world)
    world : R.World = R.tick([],8,world)
    world : R.World <- checkpoint("next-schedule",world)
    world : R.World = R.flush(world)
    world : R.World <- checkpoint("live",world)
    world : R.World = R.tick([R.Bump{2},R.Publish{R.Handle{0,1},T.Insert{}},R.Publish{R.Handle{0,2},T.Insert{}}],8,world)
    world : R.World <- checkpoint("immediate-and-pending",world)
    world : R.World = R.flush(world)
    world : R.World <- checkpoint("inserted",world)
    world : R.World <- foreign_checkpoint(foreign,R.lookup(world,foreign,T.Any{}))
    world : R.World = R.tick([R.Publish{R.Handle{0,1},T.Insert{}},R.Publish{R.Handle{0,1},T.Remove{}},R.Publish{R.Handle{0,7},T.Despawn{}}],8,world)
    world : R.World <- checkpoint("noncommuting-pending",world)
    world : R.World = R.flush(world)
    world : R.World <- checkpoint("removed",world)
    world : R.World = R.tick([R.Publish{R.Handle{0,1},T.Despawn{}},R.Publish{R.Handle{0,1},T.Insert{}}],8,world)
    world : R.World <- checkpoint("despawn-pending",world)
    world : R.World = R.flush(world)
    world : R.World <- checkpoint("stale",world)
    world : R.World = R.tick([R.Reserve{4}],8,world)
    world : R.World <- checkpoint("respawn-pending",world)
    world : R.World = R.flush(world)
    world : R.World <- checkpoint("new-live",world)
    return Unit{}
def foreign_reserved(world: R.World, result: R.World & Maybe<&2,R.Handle>) -> IO(Unit):
  match result:
    case (_,Some{foreign}): run(world,foreign)
    case (_,None{}): IO.print("unexpected foreign reservation failure")
def second(world: R.World, result: R.Factory & Maybe<R.World>) -> IO(Unit):
  match result:
    case (_,Some{other}): foreign_reserved(world,R.reserve(8,other,99))
    case (_,None{}): IO.print("unexpected second creation failure")
def first(result: R.Factory & Maybe<R.World>) -> IO(Unit):
  match result:
    case (factory,Some{world}): second(world,R.create(8,factory))
    case (_,None{}): IO.print("unexpected first creation failure")
def main() -> IO(Unit):
  first(R.create(8,R.Factory{0}))
