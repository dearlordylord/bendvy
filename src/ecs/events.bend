import Base
import ./world.bend as W

# Independent affine readers for the bounded append-only event log. Retention,
# lag reporting and affine event payloads remain separate core follow-ups.
type Reader<S: Data> is Type:
  Reader{namespace: U32,offset: Nat}
type Observed<S: Data,C: Type,R: Type,E: Data> is Type:
  Read{world: W.World<S,C,R,E>,reader: Reader<S>,events: List<&2,E>}
  ForeignReader{world: W.World<S,C,R,E>,reader: Reader<S>}

def create_join(~S: Data,~C: Type,~R: Type,~E: Data,named: W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Reader<S>:
  (world,namespace) = named
  (world,Reader{namespace,0n})

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

def read(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,reader: Reader<S>) -> Observed<S,C,R,E>:
  read_named(~S,~C,~R,~E,W.namespace(~S,~C,~R,~E,world),reader)
