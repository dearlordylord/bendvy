import Base
import ./capture.bend as C

type BodyKind is Data:
  A{}
  B{}
  Fast{}
  Tail{}
  SetOn{}
  SetOff{}
  Cleanup{}
  Snapshot{}
  ForeignLookup{}
  Seed{}
  SeedBeta{}
  Inserts{}
  Dispose{}
  SpawnS{}
  ReadOnlyLate{}
type System is Data:
  System{base: U32,name: String,kind: BodyKind,ledger: Bool,audit: Bool,gated: Bool,reader: Bool}
type Mode is Data:
  Normal{}
  BFail{}
  Retry{}
  Observe{}
  ObserveFail{}
type Node is Data:
  Call{system: System,mode: Mode}
  Nested{steps: List<&2,Node>}
  Deferred{}
  StateTransition{}
type Entry is Type:
  Entry{system: System,local: C.Local}
type Registry is Type:
  Registry{next: U32,entries: List<Entry>}
type Registered is Type:
  Registered{registry: Registry,system: System}
def initial() -> Registry:
  Registry{1,[]}
def register(registry: Registry,name: String,kind: BodyKind,ledger: Bool,audit: Bool,gated: Bool,reader: Bool) -> Registered:
  match registry:
    case Registry{+next,entries}:
      +system = {System{next,name,kind,ledger,audit,gated,reader} : System}
      Registered{Registry{U32.add(next,1),Entry{system,C.initial()} <> entries},system}
# Bounds on constructor count and clock/capture increments are fixture parameters.
# Schedule copies retain System.base; registry Local owners are not copied.
