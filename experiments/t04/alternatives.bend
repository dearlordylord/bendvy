import Base

type DataPayload is Data:
  DataPayload{items: List<&2, U32>}
type Box is Type:
  Box{x: U32}
type Owned is Type:
  Owned{items: Array<Box>}

# A take operation must leave an explicit replacement, not an alias.
def take(c: Owned, replacement: Array<Box>) -> Owned & Array<Box>:
  match c:
    case Owned{items}: (Owned{replacement}, items)
def bump(box: Box) -> Box:
  match box:
    case Box{x}: Box{(x + 3 : U32)}
def put_back(r: Array<Box> & Box) -> Array<Box>:
  match r:
    case (a, old): Array.set(Box, a, 1, bump(old))
def update(a: Array<Box>) -> Array<Box>:
  put_back(Array.swap(Box, a, 1, Box{0}))
# Ownership-preserving structural traversal does not require Data elements.
def join_right(a: Array<Box>, text: String, right: Array<Box> & String) -> Array<Box> & String:
  match right:
    case (b, tail): (ANode{a, b}, text ++ tail)
def join(left: Array<Box> & String, right: Array<Box> & String) -> Array<Box> & String:
  match left:
    case (a, text): join_right(a, text, right)
def leaf(box: Box) -> Array<Box> & String:
  match box:
    case Box{+x}: (ALeaf{Box{x}}, U32.show(x) ++ ",")
def traverse(a: Array<Box>) -> Array<Box> & String:
  match a:
    case ALeaf{box}: leaf(box)
    case ANode{a, b}: join(traverse(a), traverse(b))
def observe(prefix: String, r: Array<Box> & String) -> IO(Array<Box>):
  match r:
    case (a, text):
      do IO<Array<Box>>:
        IO.print(prefix ++ text)
        return a
def resume(r: Owned & Array<Box>) -> Array<Box>:
  match r:
    case (placeholder, a): a

def data_show(p: DataPayload) -> String:
  match p:
    case DataPayload{Con{x, Con{y, Nil{}}}}: U32.show(x) ++ "," ++ U32.show(y)
    case DataPayload{_}: "unexpected"
def clone_finish(x: U32, r: Array<U32> & U32) -> String:
  match r:
    case (a, y): U32.show(x) ++ "," ++ U32.show(y)
def clone_read(r: Array<U32> & U32, other: Array<U32>) -> String:
  match r:
    case (a, x): clone_finish(x, Array.get(U32, other, 0))
def clone_test(pair: Array<U32> & Array<U32>) -> String:
  match pair:
    case (a, b): clone_read(Array.get(U32, Array.set(U32, a, 0, 99), 0), b)
def main() -> IO(Unit):
  do IO<Unit>:
    +p : DataPayload = DataPayload{[7, 8]}
    IO.print("data-list:" ++ data_show(p) ++ ":" ++ data_show(p))
    IO.print("clone-independent:" ++ clone_test(Array.clone(U32, [10 : U32^1n])))
    a : Array<Box> = ANode{ALeaf{Box{10}}, ALeaf{Box{20}}}
    a : Array<Box> <- observe("type-setup:", traverse(a))
    a : Array<Box> <- observe("type-step1:", traverse(update(a)))
    a : Array<Box> <- observe("type-step2:", traverse(update(a)))
    a : Array<Box> <- observe("type-step3:", traverse(update(a)))
    a : Array<Box> = resume(take(Owned{a}, ALeaf{Box{0}}))
    a : Array<Box> <- observe("type-take-read:", traverse(a))
    return Unit{}
