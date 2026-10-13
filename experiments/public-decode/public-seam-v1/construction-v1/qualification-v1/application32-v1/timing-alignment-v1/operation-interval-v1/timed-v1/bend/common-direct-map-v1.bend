import Base
import ../../../main.bend as Cases
import ../../../public.bend as Public
import ../../../owner.bend as Owner
import ./serialize.bend as Serialize
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

# Public common projection from each full report; physical reports remain in the separately qualified full observer.
type Item is Data:Workshop{operation:String,name:String,value:Public.View} Garden{operation:String,name:String,value:Public.View}
def observe(item:Cases.Item) -> Item:
  match item:
    case Cases.Workshop{operation,name,value}:Workshop{operation,name,Public.view(~Owner.First,value)}
    case Cases.Garden{operation,name,value}:Garden{operation,name,Public.view(~Owner.Second,value)}
def render(value:Item) -> J.Value:
  match value:
    case Workshop{operation,name,value}:Serialize.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(value)}])
    case Garden{operation,name,value}:Serialize.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Serialize.view(value)}])
def rendered(value:Cases.Item) -> J.Value:render(observe(value))
def items(values:List<&2,Cases.Item>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case head <> rest:rendered(head) <> items(rest)
def completed(value:Serialize.Encoded) -> String:
  match value:
    case Serialize.Complete{text}:text
    case Serialize.Incomplete{}:"SERIALIZATION_INCOMPLETE"
def main() -> String:completed(Serialize.encode(J.Items{items(Cases.main())}))
