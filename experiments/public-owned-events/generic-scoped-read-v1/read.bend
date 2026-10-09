import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# All runtime arguments and result types are fixed before abstract payload H.
def provide(~Owner:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~at:Owner -> Request -> Owner & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,owner:Owner,args:Args) -> Owner & Observation:
  body(Owner,Cap.Request{at},owner,args)
def request(~H:Type,~Request:Type,~Projection:Data,~read:Cap.Request<H,Request,Projection>,owner:H,input:Request) -> H & Projection:
  Cap.request(~H,~Request,~Projection,~read,owner,input)
