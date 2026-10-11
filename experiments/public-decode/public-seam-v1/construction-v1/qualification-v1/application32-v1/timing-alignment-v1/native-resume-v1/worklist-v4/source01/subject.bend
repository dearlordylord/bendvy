import Base
import ../full-format-v2/format.bend as Format
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/serialize.bend as Encode
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/public.bend as Public
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/application.bend as Gameplay
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/owner.bend as Owner
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/cases.bend as Cases
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Schema is Data:Workshop{} Garden{}
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
def execute(value:Spec) -> Item:
  match value:
    case Spec{schema,caseTag,operation,name,mode,input,seed}:
      match schema:
        case Workshop{}:Item.Workshop{operation,name,run_case(~Owner.First,caseTag,mode,input,seed)}
        case Garden{}:Item.Garden{operation,name,run_case(~Owner.Second,caseTag,mode,input,seed)}
def specs() -> List<&2,Spec>:[
  Spec{Workshop{},Array3{},"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{Workshop{},Array128{},"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{Workshop{},Array256{},"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{Workshop{},LateInvalid{},"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{Workshop{},Struct64{},"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{Workshop{},NullableNull{},"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{Workshop{},NestedValid{},"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{Workshop{},NestedMissing{},"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{Workshop{},Array3{},"spawn","array3",Gameplay.Spawn{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{Workshop{},Array128{},"spawn","array128",Gameplay.Spawn{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{Workshop{},Array256{},"spawn","array256",Gameplay.Spawn{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{Workshop{},LateInvalid{},"spawn","lateInvalid",Gameplay.Spawn{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{Workshop{},Struct64{},"spawn","struct64",Gameplay.Spawn{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{Workshop{},NullableNull{},"spawn","nullableNull",Gameplay.Spawn{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{Workshop{},NestedValid{},"spawn","nestedValid",Gameplay.Spawn{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{Workshop{},NestedMissing{},"spawn","nestedMissing",Gameplay.Spawn{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{Workshop{},Array3{},"resource","array3",Gameplay.ResourceWrite{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{Workshop{},Array128{},"resource","array128",Gameplay.ResourceWrite{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{Workshop{},Array256{},"resource","array256",Gameplay.ResourceWrite{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{Workshop{},LateInvalid{},"resource","lateInvalid",Gameplay.ResourceWrite{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{Workshop{},Struct64{},"resource","struct64",Gameplay.ResourceWrite{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{Workshop{},NullableNull{},"resource","nullableNull",Gameplay.ResourceWrite{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{Workshop{},NestedValid{},"resource","nestedValid",Gameplay.ResourceWrite{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{Workshop{},NestedMissing{},"resource","nestedMissing",Gameplay.ResourceWrite{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())},
  Spec{Garden{},Array3{},"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{Garden{},Array128{},"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{Garden{},Array256{},"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{Garden{},LateInvalid{},"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{Garden{},Struct64{},"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{Garden{},NullableNull{},"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{Garden{},NestedValid{},"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{Garden{},NestedMissing{},"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())}
]
def collect(values:List<&2,Spec>,previous:List<&2,Item>) -> List<&2,Item>:
  match values:
    case []:List.reverse(&2,Item,previous)
    case value <> rest:collected_item(rest,previous,execute(value))
def collected_item(rest:List<&2,Spec>,previous:List<&2,Item>,value:Item) -> List<&2,Item>:collect(rest,value <> previous)
def item(value:Item) -> String:
  match value:
    case Workshop{operation,name,report}:Format.completed(Encode.encode(Format.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole(~Owner.First,report)}])))
    case Garden{operation,name,report}:Format.completed(Encode.encode(Format.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole(~Owner.Second,report)}])))
def work(values:List<&2,Item>,separator:String) -> String:
  match values:
    case []:""
    case value <> rest:separator ++ item(value) ++ work(rest,",")
def main() -> String:"[" ++ work(collect(specs(),[]),"") ++ "]"
