import Base
import ./identity.bend as I
import ./owned.bend as A
import ./core.bend as B
import ../t05/lifecycle.bend as L

def output(prefix: String, result: I.World<A.Motion> & String) -> IO(I.World<A.Motion>):
  match result:
    case (w, text):
      do IO<I.World<A.Motion>>:
        IO.print(prefix ++ text)
        return w
def exhausted(result: I.World<A.Motion> & Maybe<&2, L.Handle<A.Motion>>) -> IO(Unit):
  match result:
    case (_, None{}): IO.print("capacity:no-reuse")
    case (_, Some{_}): IO.die(Unit, 2, "unexpected reuse")
def reserved_more(first: L.Handle<A.Motion>, result: I.World<A.Motion> & Maybe<&2, L.Handle<A.Motion>>) -> IO(Unit):
  match result:
    case (w, Some{+second}):
      do IO<Unit>:
        w : I.World<A.Motion> <- output("pending:", I.lookup(~A.Motion, w, second))
        w : I.World<A.Motion> <- output("next-schedule:", I.lookup(~A.Motion, I.tick(~A.Motion, w), second))
        w : I.World<A.Motion> <- output("live:", I.lookup(~A.Motion, I.flush(~A.Motion, w), second))
        w : I.World<A.Motion> <- output("remove-pending:", I.lookup(~A.Motion, I.enqueue(~A.Motion, 1, 0, w, second), second))
        w : I.World<A.Motion> <- output("removed:", I.lookup(~A.Motion, I.flush(~A.Motion, w), second))
        w : I.World<A.Motion> <- output("insert-pending:", I.lookup(~A.Motion, I.enqueue(~A.Motion, 0, 9, w, second), second))
        w : I.World<A.Motion> <- output("reinserted:", I.lookup(~A.Motion, I.flush(~A.Motion, w), second))
        w : I.World<A.Motion> <- output("fifo:", I.lookup(~A.Motion, I.flush(~A.Motion, I.enqueue(~A.Motion, 0, 3, I.enqueue(~A.Motion, 0, 2, w, second), second)), second))
        w : I.World<A.Motion> <- output("bound:", I.lookup(~A.Motion, w, L.Handle{0, 2}))
        w : I.World<A.Motion> <- output("max-bound:", I.lookup(~A.Motion, w, L.Handle{0, 4294967295}))
        w : I.World<A.Motion> <- output("despawn:", I.lookup(~A.Motion, I.flush(~A.Motion, I.enqueue(~A.Motion, 2, 0, w, second)), second))
        exhausted(I.reserve(~A.Motion, 88, w))
    case (_, None{}): IO.die(Unit, 2, "reserve failed")
def first(result: I.World<A.Motion> & Maybe<&2, L.Handle<A.Motion>>) -> IO(Unit):
  match result:
    case (w, Some{h}): reserved_more(h, I.reserve(~A.Motion, 7, w))
    case (_, None{}): IO.die(Unit, 2, "reserve failed")
def created(result: L.Factory & Maybe<I.World<A.Motion>>) -> IO(Unit):
  match result:
    case (_, Some{w}): first(I.reserve(~A.Motion, 5, w))
    case (_, None{}): IO.die(Unit, 2, "create failed")
def main() -> IO(Unit):
  created(I.create(~A.Motion, 2, L.Factory{0}))
