import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public

type Schema is Data:WorkshopSchema{} GardenSchema{}
type Spec is Data:Spec{schema:Schema,entry:Cases.Case,operation:String,mode:Gameplay.Mode}
type Item is Data:Workshop{operation:String,name:String,value:Public.View} Garden{operation:String,name:String,value:Public.View}
def workshop_item(operation:String,mode:Gameplay.Mode,entry:Cases.Case) -> Item:
  match entry:
    case Cases.Case{name,codec,input,seed}:Workshop{operation,name,Public.view(~Owner.First,Gameplay.run(~Owner.First,~codec,mode,input,seed))}
def garden_item(operation:String,mode:Gameplay.Mode,entry:Cases.Case) -> Item:
  match entry:
    case Cases.Case{name,codec,input,seed}:Garden{operation,name,Public.view(~Owner.Second,Gameplay.run(~Owner.Second,~codec,mode,input,seed))}
def execute(value:Spec) -> Item:
  match value:
    case Spec{schema,entry,operation,mode}:
      match schema:
        case WorkshopSchema{}:workshop_item(operation,mode,entry)
        case GardenSchema{}:garden_item(operation,mode,entry)
def specs() -> List<&2,Spec>:[
  Spec{WorkshopSchema{},Cases.array3(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.array128(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.array256(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.late_invalid(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.struct64(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.nullable_null(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.nested_valid(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.nested_missing(),"insert",Gameplay.Insert{}},
  Spec{WorkshopSchema{},Cases.array3(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.array128(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.array256(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.late_invalid(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.struct64(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.nullable_null(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.nested_valid(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.nested_missing(),"spawn",Gameplay.Spawn{}},
  Spec{WorkshopSchema{},Cases.array3(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.array128(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.array256(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.late_invalid(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.struct64(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.nullable_null(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.nested_valid(),"resource",Gameplay.ResourceWrite{}},
  Spec{WorkshopSchema{},Cases.nested_missing(),"resource",Gameplay.ResourceWrite{}},
  Spec{GardenSchema{},Cases.array3(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.array128(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.array256(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.late_invalid(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.struct64(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.nullable_null(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.nested_valid(),"insert",Gameplay.Insert{}},
  Spec{GardenSchema{},Cases.nested_missing(),"insert",Gameplay.Insert{}}
]
def collect(values:List<&2,Spec>,previous:List<&2,Item>) -> List<&2,Item>:
  match values:
    case []:List.reverse(&2,Item,previous)
    case value <> rest:collect(rest,execute(value) <> previous)
def main() -> List<&2,Item>:collect(specs(),[])
