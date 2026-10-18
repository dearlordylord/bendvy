import Base
import ../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
type Sample is Data:
  Sample{group:String,kind:String,iteration:Maybe<&2,U32>,phase:Maybe<&2,U32>,who:Maybe<&2,U32>,cursor:Maybe<&2,U32>,ordinal:Nat,committed:Bool,tx:Meter.Report}
def maybe(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"null"
    case Some{x}:U32.show(x)
def render(value:Sample) -> String:
  match value:
    case Sample{group,+kind,iteration,phase,who,cursor,ordinal,committed,tx}:"{\"group\":\"" ++ group ++ "\",\"kind\":\"" ++ kind ++ "\",\"iteration\":" ++ maybe(iteration) ++ ",\"phase\":" ++ maybe(phase) ++ ",\"who\":" ++ maybe(who) ++ ",\"cursor\":" ++ maybe(cursor) ++ ",\"ordinal\":" ++ Nat.show(ordinal) ++ ",\"committed\":" ++ Meter.boolean(committed) ++ ",\"tx\":" ++ Meter.render(kind,tx) ++ "}"
def tail(values:List<&2,Sample>) -> String:
  match values:
    case []:"]"
    case value <> rest:"," ++ render(value) ++ tail(rest)
def samples(values:List<&2,Sample>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ render(value) ++ tail(rest)
