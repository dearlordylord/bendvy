import Base
import ./identity.bend as I
import ../t05/lifecycle.bend as L
import ./owned.bend as A

def text(result: I.World<A.Motion> & String) -> String:
  match result:
    case (_, text): text
def reserved_collision(foreign: L.Handle<A.Motion>, result: I.World<A.Motion> & Maybe<&2, L.Handle<A.Motion>>) -> String:
  match result:
    case (w, _): text(I.lookup(~A.Motion, I.flush(~A.Motion, w), foreign))
def created_collision(foreign: L.Handle<A.Motion>, result: L.Factory & Maybe<I.World<A.Motion>>) -> String:
  match result:
    case (_, Some{w}): reserved_collision(foreign, I.reserve(~A.Motion, 7, w))
    case (_, None{}): "factory-exhausted"
def reserved_foreign(f: L.Factory, result: I.World<A.Motion> & Maybe<&2, L.Handle<A.Motion>>) -> String:
  match result:
    case (_, Some{h}): created_collision(h, I.create(~A.Motion, 2, f))
    case (_, None{}): "entity-exhausted"
def created_foreign(result: L.Factory & Maybe<I.World<A.Motion>>) -> String:
  match result:
    case (f, Some{w}): reserved_foreign(f, I.reserve(~A.Motion, 99, w))
    case (_, None{}): "factory-exhausted"
def main() -> String:
  created_foreign(I.create(~A.Motion, 2, L.Factory{0}))
