import Base
import schema-fragments.bend as SF
import capabilities.bend as Owned

def provision_declared(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,fragment:SF.Fragment<S,Owners>,required:List<&2,SF.Entry<S>>) -> SF.Bound<S,Owners,Output>:
  SF.bind_declared(~S,~Owners,~Output,~build,fragment,required)

def provide_owned(~Owner:Type,~Input:Type,~Output:Type,~Args:Type,~BodyOutput:Type,~request:Owner -> Input -> Owner & Output,~body:@-H:Type -> @-cap:Owned.OwnedRequest<H,Input,Output> -> Args -> H -> H & BodyOutput,args:Args,ctx:Owner) -> Owner & BodyOutput:
  Owned.invoke_owned(~h => Owned.OwnedRequest<h,Input,Output>,~Args,~BodyOutput,~body,~Owner,~Owned.OwnedRequest{request},args,ctx)
