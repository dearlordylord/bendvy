import Base
import schema.bend as S
import simulation.bend as Sim
import ../../src/ecs/component.bend as C

# Labels are trusted closed scenario identifiers (no ASCII controls other than
# escaped newline/carriage-return/tab). This is not a general JSON string API.
# Snapshot floats are finite scenario values; non-finite text fails the oracle.
def escape_char(c: Char) -> String:
  match c:
    case '"': "\\\""
    case '\\': "\\\\"
    case '\n': "\\n"
    case '\r': "\\r"
    case '\t': "\\t"
    case c: SCon{c,SNil{}}
def escape(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{c,rest}: escape_char(c) ++ escape(rest)
def quoted(s: String) -> String:
  "\"" ++ escape(s) ++ "\""
def numbers(xs: List<&2,U32>) -> String:
  List.show(~&2,~U32,~U32.show,xs)
def position(value: C.Access<S.PositionView>) -> String:
  match value:
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
    case C.Found{S.PositionView{x,trail}}: "{\"x\":" ++ F32.show(x) ++ ",\"trail\":" ++ numbers(trail) ++ "}"
def velocity(value: C.Access<S.VelocityView>) -> String:
  match value:
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
    case C.Found{S.VelocityView{dx,history}}: "{\"dx\":" ++ F32.show(dx) ++ ",\"history\":" ++ numbers(history) ++ "}"
def health(value: C.Access<S.HealthView>) -> String:
  match value:
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
    case C.Found{S.HealthView{hp,history}}: "{\"hp\":" ++ F32.show(hp) ++ ",\"history\":" ++ numbers(history) ++ "}"
def armor(value: C.Access<S.Armor>) -> String:
  match value:
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
    case C.Found{S.Armor{value}}: "{\"value\":" ++ F32.show(value) ++ "}"
def tag(value: C.Access<S.Tag>) -> String:
  match value:
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
    case C.Found{_}: "{}"
def row(value: Sim.Row) -> String:
  match value:
    case Sim.Row{id,p,v,h,a,t}: "{\"id\":" ++ U32.show(id) ++ ",\"position\":" ++ position(p) ++ ",\"velocity\":" ++ velocity(v) ++ ",\"health\":" ++ health(h) ++ ",\"armor\":" ++ armor(a) ++ ",\"tag\":" ++ tag(t) ++ "}"
def hit_events(xs: List<&2,S.SimEvent>) -> List<&2,String>:
  match xs:
    case []: []
    case S.Hit{id,amount,hp} <> rest: ("{\"id\":" ++ U32.show(id) ++ ",\"amount\":" ++ F32.show(amount) ++ ",\"hp\":" ++ F32.show(hp) ++ "}") <> hit_events(rest)
    case S.Death{_} <> rest: hit_events(rest)
def death_events(xs: List<&2,S.SimEvent>) -> List<&2,String>:
  match xs:
    case []: []
    case S.Hit{_,_,_} <> rest: death_events(rest)
    case S.Death{id} <> rest: ("{\"id\":" ++ U32.show(id) ++ "}") <> death_events(rest)
def raw(s: String) -> String: s
def snapshot(label: String,value: Sim.Snapshot,filtered: List<&2,U32>) -> String:
  match value:
    case Sim.Snapshot{rows,dt,+events}: "{\"label\":" ++ quoted(label) ++ ",\"entities\":" ++ List.show(~&2,~Sim.Row,~row,rows) ++ ",\"dt\":" ++ F32.show(dt) ++ ",\"filtered\":" ++ numbers(filtered) ++ ",\"events\":{\"hit\":" ++ List.show(~&2,~String,~raw,hit_events(events)) ++ ",\"death\":" ++ List.show(~&2,~String,~raw,death_events(events)) ++ "}}"
