import Base

# Signature canary only: no integrated identity, traversal, or queue subject.
type Cell<-Main: Type> is Type:
  Cell{payload: Main}
type Position is Type:
  Position{coordinates: Array<U32>, frame: U32}
type PositionToken is Data:
  PositionToken{}
type View is Data:
  View{first: U32, frame: U32}
type Access<-Observation: Data> is Data:
  Found{observation: Observation}
  QueryMismatch{}
  MissingEntity{}

# Checks the cross-module shape while leaving world/identity implementation open.
def main_hook(-W: Type, -H: Data, -Main: Type, -O: Data,
  hook: W -> H -> (Main -> Main & O) -> W & Access<O>,
  world: W, handle: H, transform: Main -> Main & O) -> W & Access<O>:
  hook(world, handle, transform)

# Trusted transform consumes the actual owner and immediately reinserts its return.
def reinsert(-Main: Type, -Observation: Data, result: Main & Observation) -> Cell<Main> & Observation:
  match result:
    case (main, observation): (Cell{main}, observation)
def with_cell(-Main: Type, -Observation: Data, transform: Main -> Main & Observation, cell: Cell<Main>) -> Cell<Main> & Observation:
  match cell:
    case Cell{main}: reinsert(Main, Observation, transform(main))

def read_finish(+frame: U32, result: Array<U32> & U32) -> Position & View:
  match result:
    case (coordinates, first): (Position{coordinates, frame}, View{first, frame})
def read(position: Position, token: PositionToken) -> Position & View:
  match position:
    case Position{coordinates, frame}: read_finish(frame, Array.get(U32, coordinates, 0))

# This client remains abstract; no Cell/Position/World/Factory is supplied.
def client(-P: Type, get: P -> PositionToken -> P & View, owner: P) -> P & View:
  get(owner, PositionToken{})
def provider(~callback: @-P: Type -> (P -> PositionToken -> P & View) -> P -> P & View, position: Position) -> Position & View:
  callback(Position, read, position)
def main() -> Cell<Position> & View:
  with_cell(Position, View, p => provider(~client, p), Cell{Position{[10 : U32^2n], 7}})
