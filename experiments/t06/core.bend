import Base
import ./payload.bend as P

type Command is Data:
  Insert{slot: U32}
  Remove{slot: U32}
type Meta is Data:
  Meta{resource: U32, events: List<&2, U32>, commands: List<&2, Command>}
type Columns is Type:
  Columns{positions: Array<U32>, payload: P.Payload}
type Store is Type:
  Store{columns: Columns, meta: Meta}
type View is Data:
  View{position: U32, resource: U32, payload: U32}
type Undo is Data:
  Undo{position: U32, resource: U32, payload: U32}
type Side is Type:
  Side{meta: Meta, undo: List<Undo>, events: List<&2, U32>, commands: List<&2, Command>}
type Tx is Type:
  Tx{columns: Columns, side: Side}
type Outcome is Data:
  Success{}
  Failure{system: String, error: U32}

def initial() -> Store:
  Store{Columns{[1 : U32^1n], P.Payload{[10 : U32^2n]}}, Meta{2, [], []}}
def begin(s: Store) -> Tx:
  match s:
    case Store{columns, meta}: Tx{columns, Side{meta, [], [], []}}
def payload_slot(p: P.Payload) -> Array<U32> & U32:
  match p:
    case P.Payload{a}: Array.get(U32, a, 1)
def read_finish(positions: Array<U32>, a: Array<U32>, side: Side, position: U32, value: U32) -> Tx & View:
  match side:
    case Side{Meta{+r, events, commands}, undo, staged, pending}: (Tx{Columns{positions, P.Payload{a}}, Side{Meta{r, events, commands}, undo, staged, pending}}, View{position, r, value})
def read_payload(positions: Array<U32>, side: Side, position: U32, result: Array<U32> & U32) -> Tx & View:
  match result:
    case (a, x): read_finish(positions, a, side, position, x)
def read_position(payload: P.Payload, side: Side, result: Array<U32> & U32) -> Tx & View:
  match result:
    case (positions, x): read_payload(positions, side, x, payload_slot(payload))
def get(t: Tx) -> Tx & View:
  match t:
    case Tx{Columns{positions, payload}, side}: read_position(payload, side, Array.get(U32, positions, 0))
def set_snapshot(position: U32, resource: U32, payload: U32, result: Tx & View) -> Tx:
  match result:
    case (Tx{Columns{positions, P.Payload{a}}, Side{Meta{_, events, commands}, undo, staged, pending}}, View{old_position, old_resource, old_payload}): Tx{Columns{Array.set(U32, positions, 0, position), P.Payload{Array.set(U32, a, 1, payload)}}, Side{Meta{resource, events, commands}, Undo{old_position, old_resource, old_payload} <> undo, staged, pending}}
def set(t: Tx, position: U32, resource: U32, payload_value: U32) -> Tx:
  set_snapshot(position, resource, payload_value, get(t))
def emit(t: Tx, value: U32) -> Tx:
  match t:
    case Tx{columns, Side{meta, undo, staged, pending}}: Tx{columns, Side{meta, undo, List.append(&2, U32, staged, [value]), pending}}
def command(t: Tx, value: Command) -> Tx:
  match t:
    case Tx{columns, Side{meta, undo, staged, pending}}: Tx{columns, Side{meta, undo, staged, List.append(&2, Command, pending, [value])}}
def restore(s: Store, old: Undo) -> Store:
  match s old:
    case Store{Columns{positions, P.Payload{a}}, Meta{_, events, commands}} Undo{position, resource, payload}: Store{Columns{Array.set(U32, positions, 0, position), P.Payload{Array.set(U32, a, 1, payload)}}, Meta{resource, events, commands}}
def undo_all(undo: List<Undo>, s: Store) -> Store:
  match undo:
    case Nil{}: s
    case Con{old, tail}: undo_all(tail, restore(s, old))
def publish(s: Store, staged: List<&2, U32>, pending: List<&2, Command>) -> Store:
  match s:
    case Store{columns, Meta{resource, events, commands}}: Store{columns, Meta{resource, List.append(&2, U32, events, staged), List.append(&2, Command, commands, pending)}}
def finish(result: Tx & Outcome) -> Store & Outcome:
  match result:
    case (Tx{columns, Side{meta, _, staged, pending}}, Success{}): (publish(Store{columns, meta}, staged, pending), Success{})
    case (Tx{columns, Side{meta, undo, _, _}}, Failure{system, error}): (undo_all(undo, Store{columns, meta}), Failure{system, error})
type Prepared<-T: Type> is Type:
  Prepared{state: T, outcome: Outcome, trace: String, event: Maybe<&2, U32>, command: Maybe<&2, Command>}
def stage_command(t: Tx, value: Maybe<&2, Command>) -> Tx:
  match value:
    case None{}: t
    case Some{c}: command(t, c)
def stage_event(t: Tx, value: Maybe<&2, U32>) -> Tx:
  match value:
    case None{}: t
    case Some{v}: emit(t, v)
def combine(prefix: String, result: Prepared<Tx>) -> Prepared<Tx>:
  match result:
    case Prepared{t, outcome, text, event, queued}: Prepared{t, outcome, prefix ++ text, event, queued}
type StepConfig is Data:
  StepConfig{position: U32, resource: U32, payload: U32, mode: U32}
def next_step(~system: @-T: Type -> (T -> T & View) -> (T -> U32 -> U32 -> U32 -> T) -> (T -> T & View) -> StepConfig -> T -> Prepared<T>, config: StepConfig, first: Prepared<Tx>) -> Prepared<Tx>:
  match first:
    case Prepared{t, Success{}, text, event, queued}: combine(text, system(Tx, get, set, get, config, stage_command(stage_event(t, event), queued)))
    case Prepared{t, Failure{system, error}, text, event, queued}: Prepared{t, Failure{system, error}, text, event, queued}
def view_text(v: View) -> String:
  match v:
    case View{x, r, p}: U32.show(x) ++ ":" ++ U32.show(r) ++ ":" ++ U32.show(p)
def events_text(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, tail}: U32.show(x) ++ "," ++ events_text(tail)
def command_text(c: Command) -> String:
  match c:
    case Insert{x}: "insert:" ++ U32.show(x) ++ ","
    case Remove{x}: "remove:" ++ U32.show(x) ++ ","
def commands_text(xs: List<&2, Command>) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, tail}: command_text(x) ++ commands_text(tail)
def observe_restore(result: Tx & View) -> Store & String:
  match result:
    case (Tx{columns, Side{Meta{resource, +events, +commands}, _, _, _}}, v): (Store{columns, Meta{resource, events, commands}}, view_text(v) ++ ":events=" ++ events_text(events) ++ ":commands=" ++ commands_text(commands))
def observe(s: Store) -> Store & String:
  observe_restore(get(begin(s)))
def full_result(payload: P.Payload, meta: Meta, text: String, result: Array<U32> & U32) -> Store & String:
  match result:
    case (positions, x): (Store{Columns{positions, payload}, meta}, text ++ ":other-position=" ++ U32.show(x))
def full_payload(positions: Array<U32>, meta: Meta, result: P.Payload & String) -> Store & String:
  match result:
    case (payload, text): full_result(payload, meta, text, Array.get(U32, positions, 1))
def observe_full(s: Store) -> Store & String:
  match s:
    case Store{Columns{positions, payload}, meta}: full_payload(positions, meta, P.get(payload))

def prepare_one(~system: @-T: Type -> (T -> T & View) -> (T -> U32 -> U32 -> U32 -> T) -> (T -> T & View) -> StepConfig -> T -> Prepared<T>, config: StepConfig, s: Store) -> Prepared<Tx>:
  system(Tx, get, set, get, config, begin(s))
def prepare_two(~system: @-T: Type -> (T -> T & View) -> (T -> U32 -> U32 -> U32 -> T) -> (T -> T & View) -> StepConfig -> T -> Prepared<T>, first: StepConfig, second: StepConfig, s: Store) -> Prepared<Tx>:
  next_step(~system, second, system(Tx, get, set, get, first, begin(s)))
