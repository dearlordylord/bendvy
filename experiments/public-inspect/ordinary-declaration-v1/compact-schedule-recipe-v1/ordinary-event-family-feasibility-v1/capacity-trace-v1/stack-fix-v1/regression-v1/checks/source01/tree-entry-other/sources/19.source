import Base
import tree-consumer-other.bend as C
import tree-setup-other.bend as Setup
import observer-other.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

type Row is Data:
  Row{enabled:Bool,inventory:Maybe<&2,List<&2,String>>,completion:Maybe<&2,C.Observation>,physical:String}
def snapshot_observed(+enabled:Bool,inventory:Maybe<&2,List<&2,String>>,+completion:Maybe<&2,C.Observation>,returned:C.Fixture & String) -> C.Fixture & Row:
  match returned:
    case (fixture,text):(fixture,Row{enabled,inventory,completion,text})
def snapshot_runtime(enabled:Bool,completion:Maybe<&2,C.Observation>,factory:W.Factory,publisher:C.PublisherRegistry(),first:C.FirstReader(),firstRegistry:C.FirstRegistry(),slow:C.FirstReader(),slowRegistry:C.FirstRegistry(),second:C.SecondReader(),secondRegistry:C.SecondRegistry(),returned:Setup.Runtime() & Maybe<&2,List<&2,String>>) -> C.Fixture & Row:
  match returned:
    case (runtime,inventory):snapshot_observed(enabled,inventory,completion,O.fixture(C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}))
def snapshot(+enabled:Bool,completion:Maybe<&2,C.Observation>,fixture:C.Fixture) -> C.Fixture & Row:
  match fixture:
    case C.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:snapshot_runtime(enabled,completion,factory,publisher,first,firstRegistry,slow,slowRegistry,second,secondRegistry,Setup.inspect(enabled,runtime))
    case fixture:snapshot_observed(enabled,None{},completion,O.fixture(fixture))
def prepend(row:Row,returned:C.Fixture & List<&2,Row>) -> C.Fixture & List<&2,Row>:
  match returned:
    case (fixture,rest):(fixture,row <> rest)
def flags_join(next:C.Fixture -> C.Fixture & List<&2,Row>,returned:C.Fixture & Row) -> C.Fixture & List<&2,Row>:
  match returned:
    case (fixture,row):prepend(row,next(fixture))
def flags(enabled:List<&2,Bool>,+completion:Maybe<&2,C.Observation>,fixture:C.Fixture) -> C.Fixture & List<&2,Row>:
  match enabled:
    case []:(fixture,[])
    case flag <> rest:flags_join((fixture => flags(rest,completion,fixture)),snapshot(flag,completion,fixture))
def observe(completion:Maybe<&2,C.Observation>,fixture:C.Fixture) -> C.Fixture & List<&2,Row>:flags([False{},True{},True{},False{}],completion,fixture)
def appended(rows:List<&2,Row>,returned:C.Fixture & List<&2,Row>) -> C.Fixture & List<&2,Row>:
  match returned:
    case (fixture,rest):(fixture,List.append(&2,Row,rows,rest))
def observed_join(next:C.Fixture -> C.Fixture & List<&2,Row>,returned:C.Fixture & List<&2,Row>) -> C.Fixture & List<&2,Row>:
  match returned:
    case (fixture,rows):appended(rows,next(fixture))
def acted(next:C.Fixture -> C.Fixture & List<&2,Row>,returned:C.Fixture & C.Observation) -> C.Fixture & List<&2,Row>:
  match returned:
    case (fixture,completion):observed_join(next,observe(Some{completion},fixture))
def sequence(actions:List<&2,C.Action>,fixture:C.Fixture) -> C.Fixture & List<&2,Row>:
  match actions:
    case []:(fixture,[])
    case action <> rest:acted((fixture => sequence(rest,fixture)),C.step(action,fixture))
def actions() -> List<&2,C.Action>:
  [C.ReadFirst{False{},False{}},C.Publish{False{}},C.ReadFirst{False{},False{}},C.ReadSecond{False{}},C.Publish{True{}},C.ReadFirst{True{},True{}},C.Publish{False{}},C.Frame{},C.Publish{False{}},C.Frame{},C.ReadFirst{True{},False{}},C.ReadFirst{False{},False{}},C.ReadSecond{False{}},C.Frame{},C.Frame{},C.ReadFirst{False{},False{}},C.ReadSecond{True{}},C.ReadSecond{False{}},C.Frame{}]
def scenario() -> C.Fixture & List<&2,Row>:observed_join((fixture => sequence(actions(),fixture)),observe(None{},C.setup()))
