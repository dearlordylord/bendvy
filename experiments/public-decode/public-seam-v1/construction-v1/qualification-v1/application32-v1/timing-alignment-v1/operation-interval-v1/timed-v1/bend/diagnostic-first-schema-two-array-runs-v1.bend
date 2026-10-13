import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type ReportItem is Data:WorkshopReport{name:String,report:Gameplay.Report<Owner.First>}
type Item is Data:Workshop{name:String,value:Public.View}
def array_codec() -> D.Codec:D.ArrayValue{D.Integer{}}
def workshop(~codec:D.Codec,name:String,input:D.Raw,seed:D.Raw) -> ReportItem:
  WorkshopReport{name,Gameplay.run(~Owner.First,~codec,Gameplay.Insert{},input,seed)}
def reports() -> List<&2,ReportItem>:[
  workshop(~array_codec(),"array3",Cases.input(Cases.array3()),Cases.resource(Cases.array3())),
  workshop(~array_codec(),"array256",Cases.input(Cases.array256()),Cases.resource(Cases.array256()))
]
def project(values:List<&2,ReportItem>) -> List<&2,Item>:
  match values:
    case []:[]
    case WorkshopReport{name,report} <> rest:Workshop{name,Public.view(~Owner.First,report)} <> project(rest)
def main() -> List<&2,Item>:project(reports())
