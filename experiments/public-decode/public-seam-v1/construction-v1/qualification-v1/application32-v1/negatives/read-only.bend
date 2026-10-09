import Base
import ../application.bend as Gameplay
import ../owner.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def invalid(~H:Type,~cap:Cap.Read<H,D.Raw>,args:Gameplay.Args<Input.First>,ctx:H) -> H & Gameplay.Output<Input.First>:
  Gameplay.gameplay(~Input.First,~H,~Gameplay.Ops{cap,cap},args,ctx)
