import Base
import ./main.bend as Cases
import ./public.bend as Public
import ./owner.bend as Owner
import ./full-format.bend as Format
import ./serialize.bend as Encode
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J

type Item is Data:Workshop{operation:String,name:String,value:Public.Whole<Owner.First>} Garden{operation:String,name:String,value:Public.Whole<Owner.Second>}
def observe(item:Cases.Item) -> Item:
  match item:
    case Cases.Workshop{operation,name,value}:Workshop{operation,name,Public.whole(~Owner.First,value)}
    case Cases.Garden{operation,name,value}:Garden{operation,name,Public.whole(~Owner.Second,value)}
def items(value:List<&2,Cases.Item>) -> List<&2,Item>:
  match value:
    case []:[]
    case item <> rest:observe(item) <> items(rest)
def observations() -> List<&2,Item>:items(Cases.main())

def formatted_item(value:Item) -> String:
  match value:
    case Workshop{operation,name,value}:Format.completed(Encode.encode(Format.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole_value(~Owner.First,value)}])))
    case Garden{operation,name,value}:Format.completed(Encode.encode(Format.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole_value(~Owner.Second,value)}])))
def work(values:List<&2,Item>,separator:String) -> String:
  match values:
    case []:""
    case value <> rest:separator ++ formatted_item(value) ++ work(rest,",")
def main() -> String:"[" ++ work(observations(),"") ++ "]"
