import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
type Error is Data:Denied{code:U32}
def build(input:Input.Input,canonical:D.Raw) -> Build.Construction<Input.Input,Input.Owner,Error>:
  match input canonical:
    case input,D.Number{403}:Build.Invalid{input,Denied{403}}
    case Input.Input{original,words,flags},canonical:Build.Constructed{Input.Owner{canonical,original,words,flags},Input.undo}
