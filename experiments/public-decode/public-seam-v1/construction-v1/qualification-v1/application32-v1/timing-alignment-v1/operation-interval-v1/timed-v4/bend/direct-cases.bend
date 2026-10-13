import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Schema is Data:WorkshopSchema{} GardenSchema{}
type CaseTag is Data:Array3{} Array128{} Array256{} LateInvalid{} Struct64{} NullableNull{} NestedValid{} NestedMissing{}
type Spec is Data:Spec{schema:Schema,caseTag:CaseTag,operation:String,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw}
type Item is Data:Workshop{operation:String,name:String,value:Public.View} Garden{operation:String,name:String,value:Public.View}
def array_codec() -> D.Codec:D.ArrayValue{D.Integer{}}
def structure_codec() -> D.Codec:D.Struct{[D.NamedCodec{"f0",D.Integer{}},
  D.NamedCodec{"f1",D.Integer{}},
  D.NamedCodec{"f2",D.Integer{}},
  D.NamedCodec{"f3",D.Integer{}},
  D.NamedCodec{"f4",D.Integer{}},
  D.NamedCodec{"f5",D.Integer{}},
  D.NamedCodec{"f6",D.Integer{}},
  D.NamedCodec{"f7",D.Integer{}},
  D.NamedCodec{"f8",D.Integer{}},
  D.NamedCodec{"f9",D.Integer{}},
  D.NamedCodec{"f10",D.Integer{}},
  D.NamedCodec{"f11",D.Integer{}},
  D.NamedCodec{"f12",D.Integer{}},
  D.NamedCodec{"f13",D.Integer{}},
  D.NamedCodec{"f14",D.Integer{}},
  D.NamedCodec{"f15",D.Integer{}},
  D.NamedCodec{"f16",D.Integer{}},
  D.NamedCodec{"f17",D.Integer{}},
  D.NamedCodec{"f18",D.Integer{}},
  D.NamedCodec{"f19",D.Integer{}},
  D.NamedCodec{"f20",D.Integer{}},
  D.NamedCodec{"f21",D.Integer{}},
  D.NamedCodec{"f22",D.Integer{}},
  D.NamedCodec{"f23",D.Integer{}},
  D.NamedCodec{"f24",D.Integer{}},
  D.NamedCodec{"f25",D.Integer{}},
  D.NamedCodec{"f26",D.Integer{}},
  D.NamedCodec{"f27",D.Integer{}},
  D.NamedCodec{"f28",D.Integer{}},
  D.NamedCodec{"f29",D.Integer{}},
  D.NamedCodec{"f30",D.Integer{}},
  D.NamedCodec{"f31",D.Integer{}},
  D.NamedCodec{"f32",D.Integer{}},
  D.NamedCodec{"f33",D.Integer{}},
  D.NamedCodec{"f34",D.Integer{}},
  D.NamedCodec{"f35",D.Integer{}},
  D.NamedCodec{"f36",D.Integer{}},
  D.NamedCodec{"f37",D.Integer{}},
  D.NamedCodec{"f38",D.Integer{}},
  D.NamedCodec{"f39",D.Integer{}},
  D.NamedCodec{"f40",D.Integer{}},
  D.NamedCodec{"f41",D.Integer{}},
  D.NamedCodec{"f42",D.Integer{}},
  D.NamedCodec{"f43",D.Integer{}},
  D.NamedCodec{"f44",D.Integer{}},
  D.NamedCodec{"f45",D.Integer{}},
  D.NamedCodec{"f46",D.Integer{}},
  D.NamedCodec{"f47",D.Integer{}},
  D.NamedCodec{"f48",D.Integer{}},
  D.NamedCodec{"f49",D.Integer{}},
  D.NamedCodec{"f50",D.Integer{}},
  D.NamedCodec{"f51",D.Integer{}},
  D.NamedCodec{"f52",D.Integer{}},
  D.NamedCodec{"f53",D.Integer{}},
  D.NamedCodec{"f54",D.Integer{}},
  D.NamedCodec{"f55",D.Integer{}},
  D.NamedCodec{"f56",D.Integer{}},
  D.NamedCodec{"f57",D.Integer{}},
  D.NamedCodec{"f58",D.Integer{}},
  D.NamedCodec{"f59",D.Integer{}},
  D.NamedCodec{"f60",D.Integer{}},
  D.NamedCodec{"f61",D.Integer{}},
  D.NamedCodec{"f62",D.Integer{}},
  D.NamedCodec{"f63",D.Integer{}}]}
def nested_codec() -> D.Codec:Cases.nested()
def run_case(~S:Data,caseTag:CaseTag,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> Gameplay.Report<S>:
  match caseTag:
    case Array3{}:Gameplay.run(~S,~array_codec(),mode,input,seed)
    case Array128{}:Gameplay.run(~S,~array_codec(),mode,input,seed)
    case Array256{}:Gameplay.run(~S,~array_codec(),mode,input,seed)
    case LateInvalid{}:Gameplay.run(~S,~array_codec(),mode,input,seed)
    case Struct64{}:Gameplay.run(~S,~structure_codec(),mode,input,seed)
    case NullableNull{}:Gameplay.run(~S,~nested_codec(),mode,input,seed)
    case NestedValid{}:Gameplay.run(~S,~nested_codec(),mode,input,seed)
    case NestedMissing{}:Gameplay.run(~S,~nested_codec(),mode,input,seed)
def workshop_item(operation:String,name:String,value:Gameplay.Report<Owner.First>) -> Item:Workshop{operation,name,Public.view(~Owner.First,value)}
def garden_item(operation:String,name:String,value:Gameplay.Report<Owner.Second>) -> Item:Garden{operation,name,Public.view(~Owner.Second,value)}
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
