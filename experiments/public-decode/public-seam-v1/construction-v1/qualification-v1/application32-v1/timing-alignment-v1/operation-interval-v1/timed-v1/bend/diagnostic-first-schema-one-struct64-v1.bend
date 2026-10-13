import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Item is Data:Workshop{name:String,value:Public.View}
def structure_codec() -> D.Codec:D.Struct{Cases.fields(64n,0)}
def main() -> List<&2,Item>:
  [Workshop{"struct64",Public.view(~Owner.First,Gameplay.run(~Owner.First,~structure_codec(),Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64())))}]
