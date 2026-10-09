import Base
import ./raw-wire.bend as Wire
import ./serialize.bend as Show
import ./main.bend as Runtime
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
# Transport-only: no ECS World or capability provider is created.
def strings_tail(value:List<&2,String>) -> String:
  match value:
    case []:""
    case head <> tail:"," ++ Show.string(head) ++ strings_tail(tail)
def strings(value:List<&2,String>) -> String:
  match value:
    case []:"[]"
    case [head]:"[" ++ Show.string(head) ++ "]"
    case head <> tail:"[" ++ Show.string(head) ++ strings_tail(tail) ++ "]"
def result(+fuel:Nat,value:Wire.Read<D.Raw>) -> String:
  match value:
    case Wire.Read{raw,[]}:"{\"$\":\"Parsed\",\"raw\":" ++ Show.show_Raw(~Unit,fuel,raw) ++ "}"
    case Wire.Read{raw,rest}:"{\"$\":\"Extra\",\"raw\":" ++ Show.show_Raw(~Unit,fuel,raw) ++ ",\"remaining\":" ++ strings(rest) ++ "}"
    case Wire.Refused{rest}:"{\"$\":\"TransportRefused\",\"remaining\":" ++ strings(rest) ++ "}"
def invoked(+tokens:List<&2,String>) -> IO(Unit):
  IO.print("{\"argv\":" ++ strings(tokens) ++ ",\"result\":" ++ result(Runtime.budget(tokens),Wire.read(Runtime.budget(tokens),tokens)) ++ "}")
def main() -> IO(Unit):
  do IO<Unit>:
    argv:List<String> <- IO.args()
    invoked(Runtime.program_args(argv))
