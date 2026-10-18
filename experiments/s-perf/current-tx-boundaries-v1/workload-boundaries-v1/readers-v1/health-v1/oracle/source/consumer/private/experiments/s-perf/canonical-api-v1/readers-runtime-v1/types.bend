import Base

# Payload constructors carry no world/handle authority. World, factory, handles
# and transaction constructors are deliberately absent from this shared seam.
type MotionSchema is Data:
  MotionSchema{}
type HealthSchema is Data:
  HealthSchema{}
type PositionToken is Data:
  PositionToken{}
type VitalsToken is Data:
  VitalsToken{}
type Position is Type:
  Position{coordinates: Array<U32>, frame: U32}
type Velocity is Type:
  Velocity{rates: Array<U32>, moving: Bool}
type Vitals is Type:
  Vitals{levels: Array<U32>, reserve: U32, class: U32}
type Armor is Type:
  Armor{layers: Array<U32>, grade: U32}
type MotionLedger is Type:
  MotionLedger{totals: Array<U32>, epoch: U32}
type HealthLedger is Type:
  HealthLedger{totals: Array<U32>, epoch: U32}
type Selected is Data:
  Selected{group: U32}
type Tracked is Data:
  Tracked{group: U32}
type MotionPing is Data:
  MotionPing{code: U32}
type HealthPing is Data:
  HealthPing{code: U32}
type Four is Data:
  Four{a: U32, b: U32, c: U32, d: U32}
type PositionView is Data:
  PositionView{coordinates: Four, frame: U32}
type VitalsView is Data:
  VitalsView{levels: Four, reserve: U32, class: U32}
type VelocityView is Data:
  VelocityView{rates: Four, moving: Bool}
type ArmorView is Data:
  ArmorView{layers: Four, grade: U32}
type LedgerView is Data:
  LedgerView{totals: Four, epoch: U32}
type Outcome is Data:
  Success{}
  Failure{code: U32}
type CommandStatus is Data:
  Queued{}
  MissingEntity{}

# Generic envelopes thread opaque owners; exported envelopes do not mint them.
type Creation<-F: Type, -W: Type> is Type:
  Created{factory: F, world: W}
  CreateRejected{factory: F}
type Reservation<-W: Type, -H: Data, -P: Type> is Type:
  Reserved{world: W, handle: H}
  ReserveRejected{world: W, payload: P}
type CommandResult<-W: Type, -P: Type> is Type:
  CommandQueued{world: W}
  CommandMissing{world: W, payload: P}
type Invocation<-Tx: Type, -Capture: Type> is Type:
  Invocation{transaction: Tx, capture: Capture, outcome: Outcome}

# Reader clock metadata is Data; actual registry/log/reader owners stay opaque.
type ReaderState is Data:
  ReaderState{registeredAt: U32, lastRun: U32, streamLastRun: U32}
type ReadBoundary is Data:
  ReadBoundary{since: U32, streamSince: U32, thisRun: U32}
type MotionLedgerToken is Data:
  MotionLedgerToken{}
type HealthLedgerToken is Data:
  HealthLedgerToken{}
type MotionMode is Data:
  MotionOn{}
  MotionOff{}
type HealthMode is Data:
  HealthOn{}
  HealthOff{}
type VelocityToken is Data:
  VelocityToken{}
type ArmorToken is Data:
  ArmorToken{}
type MainView is Data:
  MotionMain{position: PositionView}
  HealthMain{vitals: VitalsView}

# Public observation only. Actual nominal H binds in trusted storage/provisioning;
# abstract callbacks do not obtain concrete world/Tx constructors.
type Access<-O: Data> is Data:
  Found{value: O}
  Mismatch{}
  Missing{}
