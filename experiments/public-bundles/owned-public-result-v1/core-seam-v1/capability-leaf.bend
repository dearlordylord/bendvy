import Base
import ../../../../src/ecs/capabilities.bend as Legacy

# Additive owned input/result capability; existing Data APIs are unchanged.
type OwnedRequest<-H:Type,-Input:Type,-Output:Type> is Type:
  OwnedRequest{run:H -> Input -> H & Output}
def owned_request_field(~H:Type,~Input:Type,~Output:Type,cap:OwnedRequest<H,Input,Output>) -> H -> Input -> H & Output:
  match cap:
    case OwnedRequest{run}: run
def owned_request(~H:Type,~Input:Type,~Output:Type,~cap:OwnedRequest<H,Input,Output>,ctx:H,input:Input) -> H & Output:
  owned_request_field(~H,~Input,~Output,cap)(ctx,input)
# Args and output are fixed before opaque H; no Data restriction on owners.
def invoke_owned(~Ops:Type -> Type,~A:Type,~U:Type,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & U,~H:Type,~caps:Ops(H),args:A,ctx:H) -> H & U:
  body(H,caps,args,ctx)
