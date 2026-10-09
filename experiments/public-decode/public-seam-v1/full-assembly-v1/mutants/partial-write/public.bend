import Base
import ./application.bend as App
import ./request.bend as Deferred
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
# This is the ordinary body boundary: neither Input nor Output contains World.
type Declaration<S:Data> is Data:Declaration{operation:App.Operation,codec:D.Codec,completion:T.Outcome<Unit>}
type Args<S:Data> is Type:Args{target:W.Handle<S>,incoming:Input.Owner}
type Output<S:Data> is Type:
  Completed{output:Deferred.Output<S,Input.Owner>}
  Aborted{output:Deferred.Output<S,Input.Owner>,packets:List<Deferred.Packet<Input.Owner>>,error:Unit}
type Frame<S:Data> is Type:Frame{world:App.World(~S),declaration:Declaration<S>}
def executed(~S:Data,declaration:Declaration<S>,result:App.Executed<S>) -> Frame<S> & Output<S>:
  match result:
    case App.Committed{world,output}:(Frame{world,declaration},Completed{output})
    case App.Aborted{world,output,packets,error}:(Frame{world,declaration},Aborted{output,packets,error})
# Reached mutant: corrupt the physical resource BEFORE retained validation.
def contaminated(~S:Data,world:App.World(~S)) -> App.World(~S):
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,App.Mail{Input.Owner{raw,sentinel},retired,returned,errors},events,pending,registrations,nextSystemId,clock}:W.World{ns,next,high,live,capacity,depth,store,App.Mail{Input.Owner{D.Text{"partial-before-validation"},sentinel},retired,returned,errors},events,pending,registrations,nextSystemId,clock}
def request(~S:Data,frame:Frame<S>,args:Args<S>) -> Frame<S> & Output<S>:
  match frame args:
    case Frame{world,Declaration{+operation,+codec,+completion}} Args{target,incoming}:executed(~S,Declaration{operation,codec,completion},App.request_with_completion(~S,completion,target,operation,codec,contaminated(~S,world),incoming))
def grant(~S:Data) -> Cap.OwnedRequest<Frame<S>,Args<S>,Output<S>>:Cap.OwnedRequest{(frame => args => request(~S,frame,args))}
def invoke(~S:Data,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Args<S>,Output<S>> -> A -> H -> H & U,frame:Frame<S>,args:A) -> Frame<S> & U:
  Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Args<S>,Output<S>>),~A,~U,~body,~Frame<S>,~grant(~S),args,frame)
def body(~S:Data,-H:Type,cap:Cap.OwnedRequest<H,Args<S>,Output<S>>,args:Args<S>,ctx:H) -> H & Output<S>:
  match cap:
    case Cap.OwnedRequest{run}:run(ctx,args)
def provide(~S:Data,frame:Frame<S>,args:Args<S>) -> Frame<S> & Output<S>:
  invoke(~S,~Args<S>,~Output<S>,~(H => cap => args => ctx => body(~S,H,cap,args,ctx)),frame,args)
