import Base
import ../../../trace-value.bend as J
import ../../../trace-boundary.bend as Boundary
import ../../force.bend as Phase2Force
import serialize.bend as Serialize
import ../../input.bend as I
import ../../setup.bend as Setup
import ../../application.bend as Phase2App
import ../../../../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/relation-commands.bend as A

def encoded(result:Serialize.EncodeResult) -> IO(Unit):
  match result:
    case Serialize.EncodeComplete{text}:IO.print(text)
    case Serialize.EncodeIncomplete{}:IO.print("TRACE_SERIALIZATION_INCOMPLETE")
def completed(summary:Phase2Force.Summary,population:U32,trace:J.Value) -> IO(Unit):
  match summary:
    case Phase2Force.Summary{nodes,characters,sum}:IO.bind(Unit,Unit,Boundary.complete(nodes,characters,sum),_ => encoded(Serialize.encode(population,trace)))
def forced(result:Phase2Force.ForceResult,population:U32,trace:J.Value) -> IO(Unit):
  match result:
    case Phase2Force.ForceComplete{summary}:completed(summary,population,trace)
    case Phase2Force.ForceIncomplete{_}:IO.print("TRACE_WALK_INCOMPLETE")
def materialized(+population:U32,+trace:J.Value) -> IO(Unit):
  forced(Phase2Force.force(population,trace),population,trace)
def metadata(root:String,statistics:Setup.Statistics) -> J.Value:
  match statistics:
    case Setup.Statistics{spawns,payloads,relations}:J.Object{[J.Field{"root",J.Text{root}},J.Field{"worldCreates",J.Number{1}},J.Field{"registeredSystems",J.Number{2}},J.Field{"spawnCommands",J.Number{spawns}},J.Field{"payloadOwners",J.Number{payloads}},J.Field{"seedRelations",J.Number{relations}},J.Field{"barriers",J.Number{2}}]}
def input_value(input:I.Input) -> J.Value:
  match input:
    case I.Input{family,population,span,seed}:J.Object{[J.Field{"family",J.Text{I.family_name(family)}},J.Field{"population",J.Number{population}},J.Field{"span",J.Number{span}},J.Field{"payloadSeed",J.Number{seed}}]}
def trace(first:W.World<O.Workshop,A.Store<O.Workshop,O.Components<O.Workshop>>,U32,A.Notice<O.Workshop,U32>>,second:W.World<O.Other,A.Store<O.Other,O.Components<O.Other>>,U32,A.Notice<O.Other,U32>>,firstStats:Setup.Statistics,secondStats:Setup.Statistics,+input:I.Input) -> J.Value:
  J.Object{[
    J.Field{"input",input_value(input)},
    J.Field{"setup",J.Items{[metadata("Workshop",firstStats),metadata("Other",secondStats)]}},
    J.Field{"roots",J.Items{[Phase2App.run(~O.Workshop,first,"Workshop",input),Phase2App.run(~O.Other,second,"Other",input)]}}
  ]}
def begun(first:W.World<O.Workshop,A.Store<O.Workshop,O.Components<O.Workshop>>,U32,A.Notice<O.Workshop,U32>>,second:W.World<O.Other,A.Store<O.Other,O.Components<O.Other>>,U32,A.Notice<O.Other,U32>>,firstStats:Setup.Statistics,secondStats:Setup.Statistics,+input:I.Input) -> IO(Unit):
  match input:
    case I.Input{family,+population,span,seed}:IO.bind(Unit,Unit,Boundary.begin(),_ => materialized(population,trace(first,second,firstStats,secondStats,I.Input{family,population,span,seed})))
def prepared(first:Setup.Ready<O.Workshop>,second:Setup.Ready<O.Other>,input:I.Input) -> IO(Unit):
  match first second:
    case Setup.Ready{world1,statistics1} Setup.Ready{world2,statistics2}:begun(world1,world2,statistics1,statistics2,input)
    case _ _:IO.print("SETUP_REFUSED")
def parsed(result:I.Parsed) -> IO(Unit):
  match result:
    case I.Valid{+input}:prepared(Setup.run(~O.Workshop,input),Setup.run(~O.Other,input),input)
    case I.Invalid{}:IO.print("INPUT_REFUSED")
def main() -> IO(Unit):
  IO.bind(List<&1,String>,Unit,IO.args(),args => parsed(I.parse(args)))
