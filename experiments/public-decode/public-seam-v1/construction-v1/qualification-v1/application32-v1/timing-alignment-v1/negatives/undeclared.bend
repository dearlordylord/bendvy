import Base
import ../application.bend as Gameplay
import ../owner.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def invalid(~H:Type,args:Gameplay.Args<Input.First>,ctx:H) -> H & Gameplay.Output<Input.First>:
  Gameplay.gameplay(~Input.First,~H,~Unit{},args,ctx)
