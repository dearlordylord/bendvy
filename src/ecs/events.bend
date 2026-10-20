import Base
import ./world.bend as W

# Legacy independent affine readers for the append-only event log.
# Registered bounded retention/lag/skip/disposal use event-runtime.bend.
# Affine payload streams use the separate owned-event APIs.
# Legacy independent reader for one World's append-only Data event log.
# Owns a namespace and list offset, not a registered retention lease. Use
# event-runtime or typed family readers for bounded retention/lag/skip/disposal.
type Reader<S: Data> is Type:
  Reader{namespace: U32,offset: Nat}
# Read returns World, advanced reader and detached unread Data events;
# ForeignReader returns World and the original reader without reading the log.
# Neither result carries affine event payload ownership.
type Observed<S: Data,C: Type,R: Type,E: Data> is Type:
  Read{world: W.World<S,C,R,E>,reader: Reader<S>,events: List<&2,E>}
  ForeignReader{world: W.World<S,C,R,E>,reader: Reader<S>}

def create_join(~S: Data,~C: Type,~R: Type,~E: Data,named: W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Reader<S>:
  (world,namespace) = named
  (world,Reader{namespace,0n})

# Create an independent append-only reader at offset zero, returning World.
# Existing events are initially unread. This creates no system registration or
# bounded-retention lease; raw Reader construction remains trusted setup.
def create(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>) -> W.World<S,C,R,E> & Reader<S>:
  create_join(~S,~C,~R,~E,W.namespace(~S,~C,~R,~E,world))

def read_events(~S: Data,~C: Type,~R: Type,~E: Data,+namespace: U32,+offset: Nat,observed: W.World<S,C,R,E> & List<&2,E>) -> Observed<S,C,R,E>:
  (world,+events) = observed
  Read{world,Reader{namespace,List.length(&2,E,events)},List.drop(&2,E,events,offset)}

def read_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,world: W.World<S,C,R,E>,reader: Reader<S>) -> Observed<S,C,R,E>:
  match allowed reader:
    case False{} reader: ForeignReader{world,reader}
    case True{} Reader{+namespace,+offset}: read_events(~S,~C,~R,~E,namespace,offset,W.events_view(~S,~C,~R,~E,world))

def read_named(~S: Data,~C: Type,~R: Type,~E: Data,named: W.World<S,C,R,E> & U32,reader: Reader<S>) -> Observed<S,C,R,E>:
  match named reader:
    case (world,actual) Reader{+namespace,+offset}: read_checked(~S,~C,~R,~E,U32.is_eq(actual,namespace),world,Reader{namespace,offset})

# Read the unread append-only suffix and return the reader at current log
# length, preserving event order. Namespace mismatch returns ForeignReader
# without accessing events. No registered lifecycle cursor or stream retention
# state is advanced. This legacy path has no lag/refusal protocol for log reset.
# Example: examples/user-simulation/driver.bend; bounded readers: event-runtime.
def read(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,reader: Reader<S>) -> Observed<S,C,R,E>:
  read_named(~S,~C,~R,~E,W.namespace(~S,~C,~R,~E,world),reader)
