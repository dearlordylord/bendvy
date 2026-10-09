import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/bundle-requests.bend as Request
import ../../../src/ecs/bundle-insert-adapter.bend as Adapter

# Application-selected retry destination; no repair, constructor or recovery
# policy is supplied by this example. Raw remains arbitrary affine Type.
def retried(~S:Data,~Raw:Type,~Error:Data,~H:Type,~cap:Cap.OwnedRequest<H,Request.Input<S,Raw>,Request.Output<S,Raw,Error>>,target:W.Handle<S>,result:H & Request.Output<S,Raw,Error>) -> H & (Maybe<&2,Adapter.Refusal<Error>> & Request.Output<S,Raw,Error>):
  match result:
    case (ctx,Request.Accepted{handle,spawned}):(ctx,(None{},Request.Accepted{handle,spawned}))
    case (ctx,Request.Refused{raw,error}):
      (ctx,output)=Cap.owned_request(~H,~Request.Input<S,Raw>,~Request.Output<S,Raw,Error>,~cap,ctx,Request.Input{Request.Insert{target},raw})
      (ctx,(Some{error},output))

# Closed schema/payload/result types precede abstract H. The returned owner is
# passed directly to the second actual operation, never projected or rebuilt.
def body(~S:Data,~Raw:Type,~Error:Data,~H:Type,~cap:Cap.OwnedRequest<H,Request.Input<S,Raw>,Request.Output<S,Raw,Error>>,input:Request.Input<S,Raw>,retry_target:W.Handle<S>,ctx:H) -> H & (Maybe<&2,Adapter.Refusal<Error>> & Request.Output<S,Raw,Error>):
  retried(~S,~Raw,~Error,~H,~cap,retry_target,Cap.owned_request(~H,~Request.Input<S,Raw>,~Request.Output<S,Raw,Error>,~cap,ctx,input))
