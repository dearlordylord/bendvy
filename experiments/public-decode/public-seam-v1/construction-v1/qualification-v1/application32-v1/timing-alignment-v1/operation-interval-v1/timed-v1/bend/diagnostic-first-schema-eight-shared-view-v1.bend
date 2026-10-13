import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type ReportItem is Data:WorkshopReport{name:String,report:Gameplay.Report<Owner.First>}
type Item is Data:Workshop{name:String,value:Public.View}
def workshop(~codec:D.Codec,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> ReportItem:
  WorkshopReport{name,Gameplay.run(~Owner.First,~codec,mode,input,seed)}
def first_insert_reports() -> List<&2,ReportItem>:[
  workshop(~Cases.codec(Cases.array3()),"array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())),
  workshop(~Cases.codec(Cases.array128()),"array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())),
  workshop(~Cases.codec(Cases.array256()),"array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())),
  workshop(~Cases.codec(Cases.late_invalid()),"lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())),
  workshop(~Cases.codec(Cases.struct64()),"struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())),
  workshop(~Cases.codec(Cases.nullable_null()),"nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())),
  workshop(~Cases.codec(Cases.nested_valid()),"nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())),
  workshop(~Cases.codec(Cases.nested_missing()),"nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))
]
def project(values:List<&2,ReportItem>) -> List<&2,Item>:
  match values:
    case []:[]
    case WorkshopReport{name,report} <> rest:Workshop{name,Public.view(~Owner.First,report)} <> project(rest)
def main() -> List<&2,Item>:project(first_insert_reports())
