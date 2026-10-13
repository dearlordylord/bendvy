import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type CaseTag is Data:Array3{} Array128{} Array256{} LateInvalid{} Struct64{} NullableNull{} NestedValid{} NestedMissing{}
type Spec is Data:Spec{caseTag:CaseTag,name:String,input:D.Raw,seed:D.Raw}
type Item is Data:Workshop{operation:String,name:String,value:Public.View}
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
    case Spec{caseTag,name,input,seed}:Workshop{"insert",name,Public.view(~Owner.First,run_case(~Owner.First,caseTag,Gameplay.Insert{},input,seed))}
def specs() -> List<&2,Spec>:[
  Spec{Array3{},"array3",Cases.input(Cases.array3()),Cases.resource(Cases.array3())},
  Spec{Array128{},"array128",Cases.input(Cases.array128()),Cases.resource(Cases.array128())},
  Spec{Array256{},"array256",Cases.input(Cases.array256()),Cases.resource(Cases.array256())},
  Spec{LateInvalid{},"lateInvalid",Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())},
  Spec{Struct64{},"struct64",Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())},
  Spec{NullableNull{},"nullableNull",Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())},
  Spec{NestedValid{},"nestedValid",Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())},
  Spec{NestedMissing{},"nestedMissing",Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing())}
]
def collect(values:List<&2,Spec>,previous:List<&2,Item>) -> List<&2,Item>:
  match values:
    case []:List.reverse(&2,Item,previous)
    case value <> rest:collect(rest,execute(value) <> previous)
def main() -> List<&2,Item>:collect(specs(),[])
