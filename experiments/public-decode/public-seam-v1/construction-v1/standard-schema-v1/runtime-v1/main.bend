import Base
import ./raw-wire.bend as Wire
import ./materialization.bend as Material
import ./resource.bend as Resource
import ./serialize.bend as Show
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
# The only value source is runtime IO.args, never generated Raw literals.
def mode(operation:String) -> Maybe<&2,Material.Mode>:
  match operation:
    case "spawn":Some{Material.Spawn{}}
    case "insert":Some{Material.Insert{}}
    case "failure":Some{Material.Failure{}}
    case "failed-insert":Some{Material.FailedInsert{}}
    case "skip":Some{Material.Skip{}}
    case _:None{}
def invoke(+fuel:Nat,schema:String,action:Material.Mode,+raw:D.Raw) -> IO(Unit):
  match schema:
    case "First":IO.print("{\"runtimeInput\":" ++ Show.show_Raw(~Input.First,fuel,raw) ++ ",\"report\":" ++ Show.show_Observation(~Input.First,fuel,Material.run(~Input.First,raw,action)) ++ "}")
    case "Second":IO.print("{\"runtimeInput\":" ++ Show.show_Raw(~Input.Second,fuel,raw) ++ ",\"report\":" ++ Show.show_Observation(~Input.Second,fuel,Material.run(~Input.Second,raw,action)) ++ "}")
    case _:IO.die(Unit,2,"unknown schema; no World created")
def decoded(fuel:Nat,schema:String,action:Material.Mode,value:Wire.Read<D.Raw>) -> IO(Unit):
  match value:
    case Wire.Read{raw,[]}:invoke(fuel,schema,action,raw)
    case _:IO.die(Unit,2,"invalid/extra Raw frame; no World created")
# Work bound from the actual runtime token count; no fixed accepted-size threshold.
# Each valid Raw token causes at most four parser steps; the larger multiplier also covers stored Object/error values.
def budget(+tokens:List<&2,String>) -> Nat:Nat.add(Nat.mul(16n,List.length(&2,String,tokens)),64n)
def selected(schema:String,+tokens:List<&2,String>,value:Maybe<&2,Material.Mode>) -> IO(Unit):
  match value:
    case None{}:IO.die(Unit,2,"unknown operation; no World created")
    case Some{action}:decoded(budget(tokens),schema,action,Wire.read(budget(tokens),tokens))
def resource_invoke(+fuel:Nat,schema:String,fail:Bool,+raw:D.Raw) -> IO(Unit):
  match schema:
    case "First":IO.print("{\"runtimeInput\":" ++ Show.show_Raw(~Input.First,fuel,raw) ++ ",\"report\":" ++ Show.show_ResourceObservation(~Input.First,fuel,Resource.run(~Input.First,raw,fail)) ++ "}")
    case "Second":IO.print("{\"runtimeInput\":" ++ Show.show_Raw(~Input.Second,fuel,raw) ++ ",\"report\":" ++ Show.show_ResourceObservation(~Input.Second,fuel,Resource.run(~Input.Second,raw,fail)) ++ "}")
    case _:IO.die(Unit,2,"unknown schema; no World created")
def resource_decoded(fuel:Nat,schema:String,fail:Bool,value:Wire.Read<D.Raw>) -> IO(Unit):
  match value:
    case Wire.Read{raw,[]}:resource_invoke(fuel,schema,fail,raw)
    case _:IO.die(Unit,2,"invalid/extra Raw frame; no World created")
def route(schema:String,operation:String,+tokens:List<&2,String>) -> IO(Unit):
  match operation:
    case "resource":resource_decoded(budget(tokens),schema,False{},Wire.read(budget(tokens),tokens))
    case "failed-resource":resource_decoded(budget(tokens),schema,True{},Wire.read(budget(tokens),tokens))
    case _:selected(schema,tokens,mode(operation))
def arguments(value:List<&2,String>) -> IO(Unit):
  match value:
    case schema <> operation <> tail:route(schema,operation,tail)
    case _:IO.die(Unit,2,"schema and operation required; no World created")
def retained_args(value:List<String>) -> List<&2,String>:
  match value:
    case []:[]
    case head <> tail:head <> retained_args(tail)
# Both pinned generated runtimes retain argv[0] in IO.args (comp.ts cli/io_argc).
def program_args(value:List<String>) -> List<&2,String>:
  match value:
    case []:[]
    case _ <> tail:retained_args(tail)
def main() -> IO(Unit):
  do IO<Unit>:
    argv:List<String> <- IO.args()
    arguments(program_args(argv))
