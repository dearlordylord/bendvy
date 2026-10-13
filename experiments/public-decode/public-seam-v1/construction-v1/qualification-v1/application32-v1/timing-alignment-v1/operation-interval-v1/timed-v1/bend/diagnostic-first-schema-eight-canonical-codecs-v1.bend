import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type ReportItem is Data:WorkshopReport{name:String,report:Gameplay.Report<Owner.First>}
type Item is Data:Workshop{name:String,value:Public.View}
def array_codec() -> D.Codec:D.ArrayValue{D.Integer{}}
def structure_codec() -> D.Codec:D.Struct{Cases.fields(64n,0)}
def nested_codec() -> D.Codec:Cases.nested()
def workshop(~codec:D.Codec,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> ReportItem:
  WorkshopReport{name,Gameplay.run(~Owner.First,~codec,mode,input,seed)}
def first_insert_reports() -> List<&2,ReportItem>:[
  workshop(~array_codec(),"array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())),
  workshop(~array_codec(),"array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128())),
  workshop(~array_codec(),"array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256())),
  workshop(~array_codec(),"lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid())),
  workshop(~structure_codec(),"struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())),
  workshop(~nested_codec(),"nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null())),
  workshop(~nested_codec(),"nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid())),
  workshop(~nested_codec(),"nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))
]
def project(values:List<&2,ReportItem>) -> List<&2,Item>:
  match values:
    case []:[]
    case WorkshopReport{name,report} <> rest:Workshop{name,Public.view(~Owner.First,report)} <> project(rest)
def main() -> List<&2,Item>:project(first_insert_reports())
