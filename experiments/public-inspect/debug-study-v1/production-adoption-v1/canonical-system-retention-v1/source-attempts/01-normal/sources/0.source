import Base
import ./decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
# Generic admission provider. Only the trusted schema author closes decoder,
# owner lens and admitted/refused transition; gameplay is universal in H.
# No callback truthfulness or universal Raw->Output inverse is asserted.
def apply(-H:Type,-Raw:Type,-Observation:Data,cap:Cap.Request<H,Raw,Observation>,raw:Raw,ctx:H) -> H & Observation:
  match cap:
    case Cap.Request{run}: run(ctx,raw)
def provide(~Raw:Type,~Owners:Type,~Observation:Data,~request:Owners -> Raw -> Owners & Observation,~body:@-H:Type -> Cap.Request<H,Raw,Observation> -> Raw -> H -> H & Observation,ctx:Owners,raw:Raw) -> Owners & Observation:
  body(Owners,Cap.Request{request},raw,ctx)
def decoded(~Raw:Type,~Owners:Type,~Observation:Data,~admit:Owners -> D.Receipt<Raw> -> Owners & Observation,value:Owners & D.Receipt<Raw>) -> Owners & Observation:
  match value:
    case (owners,receipt): admit(owners,receipt)
def request(~Raw:Type,~Owners:Type,~Observation:Data,~decode:Owners -> Raw -> Owners & D.Receipt<Raw>,~admit:Owners -> D.Receipt<Raw> -> Owners & Observation,owners:Owners,raw:Raw) -> Owners & Observation:
  decoded(~Raw,~Owners,~Observation,~admit,decode(owners,raw))
def constructed(~Raw:Type,~Owners:Type,~Observation:Data,~decode:Owners -> Raw -> Owners & D.Receipt<Raw>,~admit:Owners -> D.Receipt<Raw> -> Owners & Observation,~body:@-H:Type -> Cap.Request<H,Raw,Observation> -> Raw -> H -> H & Observation,owners:Owners,raw:Raw) -> Owners & Observation:
  provide(~Raw,~Owners,~Observation,~request(~Raw,~Owners,~Observation,~decode,~admit),~body,owners,raw)
# Complete availability is checked before registering or running any callback.
def provision_declared(~S:Data,~Owners:Type,~Output:Type,~launch:Owners -> Output,fragment:SF.Fragment<S,Owners>,required:List<&2,SF.Entry<S>>) -> SF.Bound<S,Owners,Output>:
  SF.bind_declared(~S,~Owners,~Output,~launch,fragment,required)
