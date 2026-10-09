import Base
import ../application.bend as Gameplay
import ../owner.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def invalid(~H:Type,~ops:Gameplay.Ops<Input.First,H>,args:Gameplay.Args<Input.First>,ctx:H) -> Gameplay.Args<Input.First> & (H & Gameplay.Output<Input.First>):
  (args,Gameplay.gameplay(~Input.First,~H,~ops,args,ctx))
