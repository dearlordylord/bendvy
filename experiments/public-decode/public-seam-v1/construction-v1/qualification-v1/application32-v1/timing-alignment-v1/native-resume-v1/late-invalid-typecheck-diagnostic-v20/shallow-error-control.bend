import Base
import /workspace/formal-proofs/bendvy-worktrees/decode46-native-resume-v1/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/native-resume-v1/late-invalid-typecheck-diagnostic-v20/source/decode-construction-mutant-shallow-error.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build

type Input is Type:Input{raw:D.Raw}
type Owner is Type:Owner{raw:D.Raw,original:D.Raw}
def undo(value:Owner) -> Input:
  match value:
    case Owner{_,original}:Input{original}
def build(value:Input,canonical:D.Raw) -> Build.Construction<Input,Owner,D.Error>:
  match value:
    case Input{raw}:Build.Constructed{Owner{canonical,raw},undo}
def main() -> Build.Construction<Input,Owner,D.Error>:
  Constructor.checked(~Input,~Owner,~build,D.Receipt{Input{D.Array{[]}},D.Rejected{D.Invalid{"$[127]","integer",D.Text{"late-invalid"}}}})
