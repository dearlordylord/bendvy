import Base
import ./observation-main.bend as Observation
import ./public.bend as Public
import ./serialize.bend as Serialize
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

# Complete common public output; full physical supplements remain Observation.main.
def item(value:Observation.Item) -> J.Value:
  match value:
    case Observation.Workshop{operation,name,Public.Whole{public,_}}:Serialize.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(public)}])
    case Observation.Garden{operation,name,Public.Whole{public,_}}:Serialize.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(public)}])
def items(values:List<&2,Observation.Item>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> rest:item(value) <> items(rest)
def main() -> Serialize.Encoded:Serialize.encode(J.Items{items(Observation.main())})
