import Base
import ../fixture.bend as Input
import ../ecs/decode-data.bend as D
import ../ecs/bundle-construction.bend as Build
type Error is Data:Denied{code:U32}
# The copied builder refuses every otherwise decoded input. This makes the
# request result distinguish validation precedence from constructor refusal.
def build(input:Input.Input,canonical:D.Raw) -> Build.Construction<Input.Input,Input.Owner,Error>:
  match input canonical:
    case input,_:Build.Invalid{input,Denied{403}}
