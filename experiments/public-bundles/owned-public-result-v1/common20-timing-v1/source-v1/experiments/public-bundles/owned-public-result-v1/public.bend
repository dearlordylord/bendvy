import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/capabilities.bend as Owned

# Additive owned input/result capability. The existing Data-result API is intact.
type Request<-H:Type,-Input:Type,-Output:Type> is Type:
  Request{run:H -> Input -> H & Output}
def request_field(~H:Type,~Input:Type,~Output:Type,cap:Request<H,Input,Output>) -> H -> Input -> H & Output:
  match cap:
    case Request{run}: run
def apply(~H:Type,~Input:Type,~Output:Type,~cap:Request<H,Input,Output>,ctx:H,input:Input) -> H & Output:
  request_field(~H,~Input,~Output,cap)(ctx,input)
# Output is fixed before universally binding H; it cannot mention opaque H.
# cap is a closed erased template, never a duplicated runtime-owned closure.
def provide(~Owner:Type,~Input:Type,~Output:Type,~Args:Type,~BodyOutput:Type,~request:Owner -> Input -> Owner & Output,~body:@-H:Type -> @-cap:Request<H,Input,Output> -> Args -> H -> H & BodyOutput,args:Args,ctx:Owner) -> Owner & BodyOutput:
  body(Owner,Request{request},args,ctx)
def provision_declared(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,fragment:SF.Fragment<S,Owners>,required:List<&2,SF.Entry<S>>) -> SF.Bound<S,Owners,Output>:
  SF.bind_declared(~S,~Owners,~Output,~build,fragment,required)

# Canonical owned provider; existing Request/apply/provide remain compatible.
def provide_owned(~Owner:Type,~Input:Type,~Output:Type,~Args:Type,~BodyOutput:Type,~request:Owner -> Input -> Owner & Output,~body:@-H:Type -> @-cap:Owned.OwnedRequest<H,Input,Output> -> Args -> H -> H & BodyOutput,args:Args,ctx:Owner) -> Owner & BodyOutput:
  Owned.invoke_owned(~h => Owned.OwnedRequest<h,Input,Output>,~Args,~BodyOutput,~body,~Owner,~Owned.OwnedRequest{request},args,ctx)
