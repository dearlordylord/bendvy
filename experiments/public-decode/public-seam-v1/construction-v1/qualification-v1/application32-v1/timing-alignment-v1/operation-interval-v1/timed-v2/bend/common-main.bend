import Base
import ./direct-cases.bend as Cases
import ./serialize.bend as Serialize
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

# The unrolled case entry already stores each direct current public view.
def render(value:Cases.Item) -> J.Value:
  match value:
    case Cases.Workshop{operation,name,value}:Serialize.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(value)}])
    case Cases.Garden{operation,name,value}:Serialize.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(value)}])
def items(values:List<&2,Cases.Item>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case head <> rest:render(head) <> items(rest)
def completed(value:Serialize.Encoded) -> String:
  match value:
    case Serialize.Complete{text}:text
    case Serialize.Incomplete{}:"SERIALIZATION_INCOMPLETE"
def main() -> String:completed(Serialize.encode(J.Items{items(Cases.main())}))
