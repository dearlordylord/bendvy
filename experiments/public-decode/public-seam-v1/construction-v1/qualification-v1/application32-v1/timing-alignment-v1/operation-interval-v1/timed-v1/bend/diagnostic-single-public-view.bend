import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public

def main() -> Public.View:
  Public.view(~Owner.First,Gameplay.run(~Owner.First,~Cases.codec(Cases.array3()),Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3())))
