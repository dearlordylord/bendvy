import Base
import /workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/operation-interval-v1/timed-v1/runtime-select-enum-v1/bend/repetition.bend as Repetition
def rendered(value:Maybe<&2,Repetition.Count>) -> String:
  match value:
    case None{}:"INVALID"
    case Some{Repetition.One{}}:"1:20"
    case Some{Repetition.Two{}}:"2:40"
    case Some{Repetition.Four{}}:"4:80"
def invoked(values:List<String>) -> IO(Unit):IO.print(rendered(Repetition.invoked(values)))
def main() -> IO(Unit):IO.bind(List<String>,Unit,IO.args(),invoked)
