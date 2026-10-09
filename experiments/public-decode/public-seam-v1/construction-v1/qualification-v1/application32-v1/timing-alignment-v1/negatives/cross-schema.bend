import Base
import ../application.bend as Gameplay
import ../owner.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def invalid(frame:Gameplay.Frame(~Input.First),args:Gameplay.Args<Input.Second>) -> Gameplay.Frame(~Input.First) & Gameplay.Output<Input.Second>:
  Gameplay.gameplay(~Input.Second,~Gameplay.Frame(~Input.First),~Gameplay.Ops{Gameplay.grants(~Input.First,~D.Integer{}),Gameplay.resource_grants(~Input.First,~D.Integer{})},args,frame)
