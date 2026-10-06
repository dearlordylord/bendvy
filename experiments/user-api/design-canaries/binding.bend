import Base

type Schema is Data:
  Schema{}
type Position is Type:
  Position{owned: Array<U32>, x: U32}
type Velocity is Type:
  Velocity{dx: U32}
type Health is Type:
  Health{hp: U32}
type Armor is Type:
  Armor{value: U32}
type Column<S: Data,C: Type> is Type:
  Column{entries: List<&1,Maybe<&1,C>>}
type Store is Type:
  Store{positions: Column<Schema,Position>, velocities: Column<Schema,Velocity>, health: Column<Schema,Health>, armor: Column<Schema,Armor>}
type World<S: Data,T: Type,R: Type,E: Data> is Type:
  World{store: T, resource: R, events: List<&2,E>}
type Resources is Type:
  Resources{tick: U32}
type Hit is Data:
  Hit{amount: U32}
type Registration<S: Data> is Data:
  Registration{id: U32}
type Edit<S: Data,C: Type> is Type:
  Edit{current: C, undo: List<&1,C>}

def replace(-S: Data,-C: Type,edit: Edit<S,C>,replacement: C) -> Edit<S,C>:
  match edit:
    case Edit{current,undo}: Edit{replacement,current <> undo}
def projected(edit: Edit<Schema,Position>) -> Edit<Schema,Position> & U32:
  match edit:
    case Edit{Position{owned,+x},undo}: (Edit{Position{owned,x},undo},x)
def replacement(+x: U32) -> Position:
  Position{[x : U32^1n],x}
def moved(-H: Type,set: H -> Position -> H,result: H & U32) -> H:
  match result:
    case (handle,x): set(handle,replacement((x + 1 : U32)))
def movement(-H: Type,get: H -> H & U32,set: H -> Position -> H,handle: H) -> H:
  moved(H,set,get(handle))
def position_replace(edit: Edit<Schema,Position>,value: Position) -> Edit<Schema,Position>:
  replace(Schema,Position,edit,value)
def registered(~body: @-H: Type -> (H -> H & U32) -> (H -> Position -> H) -> H -> H,registration: Registration<Schema>,edit: Edit<Schema,Position>) -> Edit<Schema,Position>:
  body(Edit<Schema,Position>,projected,position_replace,edit)
type Bound<W: Type,-body: W -> W> is Data:
  Bound{id: U32}
def twice_bound(~W: Type,~body: W -> W,binding: Bound<W,body>,world: W) -> W:
  body(body(world))
def concrete(edit: Edit<Schema,Position>) -> Edit<Schema,Position>:
  registered(~movement,Registration{7},edit)
def main() -> Edit<Schema,Position>:
  twice_bound(~Edit<Schema,Position>,~concrete,Bound{7},Edit{replacement(0),[]})
