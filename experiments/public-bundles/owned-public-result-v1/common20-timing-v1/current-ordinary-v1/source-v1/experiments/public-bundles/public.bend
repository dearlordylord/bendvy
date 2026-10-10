import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF

# Trusted schema author closes the concrete callback; gameplay is universal in H.
def apply(-H:Type,-P:Type,-V:Data,cap:Cap.Request<H,P,V>,payload:P,ctx:H) -> H & V:
  match cap:
    case Cap.Request{run}: run(ctx,payload)
def provide(~Owner:Type,~Payload:Type,~Observation:Data,~request:Owner -> Payload -> Owner & Observation,~body:@-H:Type -> Cap.Request<H,Payload,Observation> -> Payload -> H -> H & Unit,payload:Payload,ctx:Owner) -> Owner & Unit:
  body(Owner,Cap.Request{request},payload,ctx)

# Schema author supplies a typed recipe and actual owner pack; no fixed arity.
# On refusal SF returns every actual owner before constructing gameplay grants.
def provision_declared(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,fragment:SF.Fragment<S,Owners>,required:List<&2,SF.Entry<S>>) -> SF.Bound<S,Owners,Output>:
  SF.bind_declared(~S,~Owners,~Output,~build,fragment,required)

# Repeatable gameplay grants are erased closed templates, as in general query
# composition. This never duplicates a runtime closure or an affine context.
def provide_repeatable(~Owner:Type,~Payload:Type,~Observation:Data,~request:Owner -> Payload -> Owner & Observation,~body:@-H:Type -> @-cap:Cap.Request<H,Payload,Observation> -> Payload -> H -> H & Unit,payload:Payload,ctx:Owner) -> Owner & Unit:
  body(Owner,Cap.Request{request},payload,ctx)
