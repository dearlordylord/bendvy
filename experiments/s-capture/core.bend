import Base
import ./payload.bend as P
type Motion is Data:
  Motion{}
type Other is Data:
  Other{}
type World is Type:
  World{payload: P.Payload, events: List<&2, U32>, commands: List<&2, String>, reader: U32}
type Tx is Type:
  Tx{world: World, undo: List<U32>, staged: List<&2, U32>, pending: List<&2, String>}
type Outcome is Data:
  Success{}
  Failure{system: String, code: U32}
type Prepared<-T: Type> is Type:
  Prepared{owner: T, outcome: Outcome, trace: String}
def initial() -> World:
  World{P.Payload{Array.set(U32, Array.set(U32, Array.set(U32, [10 : U32^2n], 1, 20), 2, 30), 3, 40)}, [], [], 0}
def begin(w: World) -> Tx:
  Tx{w, [], [], []}
def rebuild(events: List<&2, U32>, commands: List<&2, String>, reader: U32, undo: List<U32>, staged: List<&2, U32>, pending: List<&2, String>, result: Array<U32> & U32) -> Tx & U32:
  match result:
    case (a, x): (Tx{World{P.Payload{a}, events, commands, reader}, undo, staged, pending}, x)
def read(t: Tx, token: Motion) -> Tx & U32:
  match t token:
    case Tx{World{P.Payload{a}, events, commands, reader}, undo, staged, pending} Motion{}: rebuild(events, commands, reader, undo, staged, pending, Array.get(U32, a, 0))
def set_old(value: U32, result: Tx & U32) -> Tx:
  match result:
    case (Tx{World{P.Payload{a}, events, commands, reader}, undo, staged, pending}, old): Tx{World{P.Payload{Array.set(U32, a, 0, value)}, events, commands, reader}, old <> undo, staged, pending}
def write(t: Tx, token: Motion, value: U32) -> Tx:
  set_old(value, read(t, token))
def stage(t: Tx, value: U32, command: String) -> Tx:
  match t:
    case Tx{w, undo, staged, pending}: Tx{w, undo, List.append(&2, U32, staged, [value]), List.append(&2, String, pending, [command])}
def restore(w: World, old: U32) -> World:
  match w:
    case World{P.Payload{a}, events, commands, reader}: World{P.Payload{Array.set(U32, a, 0, old)}, events, commands, reader}
def unwind(undo: List<U32>, w: World) -> World:
  match undo:
    case Nil{}: w
    case Con{old, rest}: unwind(rest, restore(w, old))
def event_count(xs: List<&2, U32>) -> U32:
  U32.from_nat(List.length(&2, U32, xs))
def saved_reader(which: Bool, previous: U32, events: List<&2, U32>) -> U32:
  match which:
    case False{}: previous
    case True{}: event_count(events)
def commit(which: Bool, w: World, staged: List<&2, U32>, pending: List<&2, String>) -> World:
  match w:
    case World{p, +events, commands, reader}: World{p, List.append(&2, U32, events, staged), List.append(&2, String, commands, pending), saved_reader(which, reader, events)}
def finish(which: Bool, result: Prepared<Tx>) -> Prepared<World>:
  match result:
    case Prepared{Tx{w, _, staged, pending}, Success{}, trace}: Prepared{commit(which, w, staged, pending), Success{}, trace}
    case Prepared{Tx{w, undo, _, _}, Failure{name, code}, trace}: Prepared{unwind(undo, w), Failure{name, code}, trace}
def texts(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, rest}: x ++ "," ++ texts(rest)
def event_text(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case Con{x, rest}: U32.show(x) ++ "," ++ event_text(rest)
def skip_events(xs: List<&2, U32>, n: U32) -> List<&2, U32>:
  match xs n:
    case Nil{} n: []
    case Con{x, rest} 0: x <> rest
    case Con{_, rest} n: skip_events(rest, (n - 1 : U32))
def seen(w: World) -> World & String:
  match w:
    case World{p, +events, commands, +reader}: (World{p, events, commands, reader}, event_text(skip_events(events, reader)))
def observe_payload(events: List<&2, U32>, +commands: List<&2, String>, +reader: U32, result: P.Payload & String) -> World & String:
  match result:
    case (p, text): (World{p, events, commands, reader}, "payload=" ++ text ++ ":commands=" ++ texts(commands))
def observe(w: World) -> World & String:
  match w:
    case World{p, events, commands, reader}: observe_payload(events, commands, reader, P.get(p))
def unread(w: World) -> World & U32:
  match w:
    case World{p, +events, commands, +reader}: (World{p, events, commands, reader}, (event_count(events) - reader : U32))
def projected(events: List<&2, U32>, commands: List<&2, String>, reader: U32, undo: List<U32>, staged: List<&2, U32>, pending: List<&2, String>, result: P.Payload & String) -> Tx & String:
  match result:
    case (p, text): (Tx{World{p, events, commands, reader}, undo, staged, pending}, text)
def project(t: Tx) -> Tx & String:
  match t:
    case Tx{World{p, events, commands, reader}, undo, staged, pending}: projected(events, commands, reader, undo, staged, pending, P.get(p))
def skipped(w: World) -> World:
  match w:
    case World{p, +events, commands, _}: World{p, events, commands, event_count(events)}
def barrier(w: World) -> World:
  match w:
    case World{p, events, _, reader}: World{p, events, [], reader}
def emit_for_skip(w: World) -> World:
  match w:
    case World{p, events, commands, reader}: World{p, List.append(&2, U32, events, [7]), commands, reader}
