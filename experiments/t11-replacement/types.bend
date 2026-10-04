import Base

type Row is Data:
  Row{slot: Nat, value: Nat, tagged: Bool}
type Handle is Data:
  Handle{world: Nat, slot: Nat}
type Action is Data:
  Insert{}
  Remove{}
  Despawn{}
type Command is Data:
  Spawn{slot: Nat, value: Nat}
  Target{slot: Nat, action: Action}
type World is Data:
  World{id: Nat, next: Nat, rows: List<&2, Row>, pending: List<&2, Command>}
type Factory is Data:
  Factory{next: Nat}
type Creation is Data:
  Created{factory: Factory, world: World}
  Full{factory: Factory}
type Reservation is Data:
  Reserved{world: World, handle: Handle}
  Rejected{world: World}
type Selection is Data:
  Any{}
  Present{}
  Absent{}
type Lookup is Data:
  Missing{}
  Mismatch{}
  Found{row: Row}
type Step is Data:
  Reserve{value: Nat}
  Publish{handle: Handle, action: Action}
  Bump{slot: Nat}
  Barrier{}
type Observation is Data:
  Observation{id: Nat, next: Nat, rows: List<&2, Row>, pending: List<&2, Command>}
type Namespaces is Data:
  Namespaces{first: Nat, second: Nat}
type QueryObservation is Data:
  QueryObservation{world: World, rows: List<&2,Row>}
type LookupObservation is Data:
  LookupObservation{world: World, lookup: Lookup}
