import Base

# Optional resource storage retains arbitrary affine Type payloads. Absence is
# data in the detached observation; inspecting it never constructs an error.
type Slot<Payload:Type> is Type:
  Absent{}
  Present{payload:Payload}
def projected(~Payload:Type,~V:Data,result:Payload & V) -> Slot<Payload> & Maybe<&2,V>:
  (payload,value)=result
  (Present{payload},Some{value})
def observe(~Payload:Type,~V:Data,~project:Payload -> Payload & V,slot:Slot<Payload>) -> Slot<Payload> & Maybe<&2,V>:
  match slot:
    case Absent{}:(Absent{},None{})
    case Present{payload}:projected(~Payload,~V,project(payload))
def presence(~Payload:Type,slot:Slot<Payload>) -> Slot<Payload> & Bool:
  match slot:
    case Absent{}:(Absent{},False{})
    case Present{payload}:(Present{payload},True{})
def joined(~R:Type,~Rest:Type,~Payload:Type,~V:Data,~put:Rest -> Slot<Payload> -> R,rest:Rest,result:Slot<Payload> & Maybe<&2,V>) -> R & Maybe<&2,V>:
  (slot,value)=result
  (put(rest,slot),value)
def split(~R:Type,~Rest:Type,~Payload:Type,~V:Data,~put:Rest -> Slot<Payload> -> R,~project:Payload -> Payload & V,result:Rest & Slot<Payload>) -> R & Maybe<&2,V>:
  (rest,slot)=result
  joined(~R,~Rest,~Payload,~V,~put,rest,observe(~Payload,~V,~project,slot))
def read(~R:Type,~Rest:Type,~Payload:Type,~V:Data,~take:R -> Rest & Slot<Payload>,~put:Rest -> Slot<Payload> -> R,~project:Payload -> Payload & V,resources:R) -> R & Maybe<&2,V>:
  split(~R,~Rest,~Payload,~V,~put,~project,take(resources))
def checked_join(~R:Type,~Rest:Type,~Payload:Type,~put:Rest -> Slot<Payload> -> R,rest:Rest,result:Slot<Payload> & Bool) -> R & Bool:
  (slot,present)=result
  (put(rest,slot),present)
def available_split(~R:Type,~Rest:Type,~Payload:Type,~put:Rest -> Slot<Payload> -> R,result:Rest & Slot<Payload>) -> R & Bool:
  (rest,slot)=result
  checked_join(~R,~Rest,~Payload,~put,rest,presence(~Payload,slot))
def available(~R:Type,~Rest:Type,~Payload:Type,~take:R -> Rest & Slot<Payload>,~put:Rest -> Slot<Payload> -> R,resources:R) -> R & Bool:
  available_split(~R,~Rest,~Payload,~put,take(resources))
