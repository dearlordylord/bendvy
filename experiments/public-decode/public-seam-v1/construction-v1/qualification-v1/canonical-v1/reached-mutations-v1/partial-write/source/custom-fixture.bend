import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/partial-write/core/decode-construction.bend as Constructor
import ./fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Error is Data:Denied{code:U32}
def denied(value:Input.Input,canonical:D.Raw) -> Build.Construction<Input.Input,Input.Owner,Error>:Build.Invalid{value,Denied{403}}
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input.Input,Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>>,input:Input.Input,ctx:H) -> H & Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>:
  Cap.owned_request(~H,~Input.Input,~Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>,~cap,ctx,input)
type Report is Data:Refused{owner:Input.InputView,error:Constructor.Error<Error>} UnexpectedConstructed{}
def refused(error:Constructor.Error<Error>,value:Input.Input & Input.InputView) -> Report:
  match value:
    case (_,view):Refused{view,error}
def observed(result:Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>) -> Report:
  match result:
    case Build.Invalid{raw,error}:refused(error,Input.input_view(raw))
    case Build.Constructed{_,_}:UnexpectedConstructed{}
def joined(~S:Data,result:Constructor.FallibleFactory<S,Input.Input,Input.Owner,Error,Input.identity(~S),Input.project,Input.incoming,denied> & Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>) -> Report:
  match result:
    case (_,result):observed(result)
def run(~S:Data,raw:D.Raw) -> Report:
  joined(~S,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input.Input,Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>>),~Input.Input,~Build.Construction<Input.Input,Input.Owner,Constructor.Error<Error>>,~(H => cap => input => ctx => body(~H,~cap,input,ctx)),~Constructor.FallibleFactory<S,Input.Input,Input.Owner,Error,Input.identity(~S),Input.project,Input.incoming,denied>,~Constructor.fallible_grant(~S,~Input.Input,~Input.Owner,~Error,~Input.identity(~S),~Input.project,~Input.incoming,~denied),Input.input(raw),Constructor.fallible_factory(~S,~Input.Input,~Input.Owner,~Error,~Input.identity(~S),~Input.project,~Input.incoming,~denied,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,D.Integer{}))))
type Cases is Data:Cases{constructorDenied:Report,decoderRefused:Report}
def cases(~S:Data) -> Cases:Cases{run(~S,D.Number{7}),run(~S,D.Text{"bad"})}
type Candidate is Data:Candidate{first:Cases,second:Cases}
def main() -> Candidate:Candidate{cases(~Input.First),cases(~Input.Second)}
