import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
type Error is Data:Denied{code:U32}
# Trusted constructor test boundary deliberately emits an inadmissible resource.
# Downstream resource validation must return its original raw I via undo.
def build(input:Input.Input,canonical:D.Raw) -> Build.Construction<Input.Input,Input.Owner,Error>:
  match input:
    case Input.Input{original,words,flags}:Build.Constructed{Input.Owner{D.Text{"bad-resource"},original,words,flags},Input.undo}
