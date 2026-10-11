import Base
import ./application.bend as Gameplay
import ./owner.bend as Owner
import ./cases.bend as Cases
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Schema is Data:WorkshopSchema{} GardenSchema{}
type CaseTag is Data:Array3{} Array128{} Array256{} LateInvalid{} Struct64{} NullableNull{} NestedValid{} NestedMissing{}
type Spec is Data:Spec{schema:Schema,caseTag:CaseTag,operation:String,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw}
type Item is Data:Workshop{operation:String,name:String,value:Gameplay.Report<Owner.First>} Garden{operation:String,name:String,value:Gameplay.Report<Owner.Second>}
def run_case(~S:Data,caseTag:CaseTag,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> Gameplay.Report<S>:
  match caseTag:
    case Array3{}:Gameplay.run(~S,~Cases.codec(Cases.array3()),mode,input,seed)
    case Array128{}:Gameplay.run(~S,~Cases.codec(Cases.array128()),mode,input,seed)
    case Array256{}:Gameplay.run(~S,~Cases.codec(Cases.array256()),mode,input,seed)
    case LateInvalid{}:Gameplay.run(~S,~Cases.codec(Cases.late_invalid()),mode,input,seed)
    case Struct64{}:Gameplay.run(~S,~Cases.codec(Cases.struct64()),mode,input,seed)
    case NullableNull{}:Gameplay.run(~S,~Cases.codec(Cases.nullable_null()),mode,input,seed)
    case NestedValid{}:Gameplay.run(~S,~Cases.codec(Cases.nested_valid()),mode,input,seed)
    case NestedMissing{}:Gameplay.run(~S,~Cases.codec(Cases.nested_missing()),mode,input,seed)
def workshop_item(operation:String,name:String,value:Gameplay.Report<Owner.First>) -> Item:Workshop{operation,name,value}
def garden_item(operation:String,name:String,value:Gameplay.Report<Owner.Second>) -> Item:Garden{operation,name,value}
def execute(value:Spec) -> Item:
  match value:
    case Spec{schema,caseTag,operation,name,mode,input,seed}:
      match schema:
        case WorkshopSchema{}:workshop_item(operation,name,run_case(~Owner.First,caseTag,mode,input,seed))
        case GardenSchema{}:garden_item(operation,name,run_case(~Owner.Second,caseTag,mode,input,seed))
def specs() -> List<&2,Spec>:[
  Spec{WorkshopSchema{},Array3{},"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{WorkshopSchema{},Array128{},"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{WorkshopSchema{},Array256{},"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{WorkshopSchema{},LateInvalid{},"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{WorkshopSchema{},Struct64{},"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{WorkshopSchema{},NullableNull{},"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{WorkshopSchema{},NestedValid{},"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{WorkshopSchema{},NestedMissing{},"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{WorkshopSchema{},Array3{},"spawn","array3",Gameplay.Spawn{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{WorkshopSchema{},Array128{},"spawn","array128",Gameplay.Spawn{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{WorkshopSchema{},Array256{},"spawn","array256",Gameplay.Spawn{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{WorkshopSchema{},LateInvalid{},"spawn","lateInvalid",Gameplay.Spawn{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{WorkshopSchema{},Struct64{},"spawn","struct64",Gameplay.Spawn{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{WorkshopSchema{},NullableNull{},"spawn","nullableNull",Gameplay.Spawn{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{WorkshopSchema{},NestedValid{},"spawn","nestedValid",Gameplay.Spawn{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{WorkshopSchema{},NestedMissing{},"spawn","nestedMissing",Gameplay.Spawn{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{WorkshopSchema{},Array3{},"resource","array3",Gameplay.ResourceWrite{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{WorkshopSchema{},Array128{},"resource","array128",Gameplay.ResourceWrite{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{WorkshopSchema{},Array256{},"resource","array256",Gameplay.ResourceWrite{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{WorkshopSchema{},LateInvalid{},"resource","lateInvalid",Gameplay.ResourceWrite{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{WorkshopSchema{},Struct64{},"resource","struct64",Gameplay.ResourceWrite{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{WorkshopSchema{},NullableNull{},"resource","nullableNull",Gameplay.ResourceWrite{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{WorkshopSchema{},NestedValid{},"resource","nestedValid",Gameplay.ResourceWrite{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{WorkshopSchema{},NestedMissing{},"resource","nestedMissing",Gameplay.ResourceWrite{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{GardenSchema{},Array3{},"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{GardenSchema{},Array128{},"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{GardenSchema{},Array256{},"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{GardenSchema{},LateInvalid{},"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{GardenSchema{},Struct64{},"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{GardenSchema{},NullableNull{},"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{GardenSchema{},NestedValid{},"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{GardenSchema{},NestedMissing{},"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())}
]
def collect(values:List<&2,Spec>,previous:List<&2,Item>) -> List<&2,Item>:
  match values:
    case []:List.reverse(&2,Item,previous)
    case value <> rest:collect(rest,execute(value) <> previous)
def main() -> List<&2,Item>:collect(specs(),[])
