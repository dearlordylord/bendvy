import Base
import ./main.bend as Cases
import ./public.bend as Public
import ./owner.bend as Owner

type Item is Data:Workshop{operation:String,name:String,value:Public.Whole<Owner.First>} Garden{operation:String,name:String,value:Public.Whole<Owner.Second>}
def observe(item:Cases.Item) -> Item:
  match item:
    case Cases.Workshop{operation,name,value}:Workshop{operation,name,Public.whole(~Owner.First,value)}
    case Cases.Garden{operation,name,value}:Garden{operation,name,Public.whole(~Owner.Second,value)}
def items(value:List<&2,Cases.Item>) -> List<&2,Item>:
  match value:
    case []:[]
    case item <> rest:observe(item) <> items(rest)
def main() -> List<&2,Item>:items(Cases.main())
