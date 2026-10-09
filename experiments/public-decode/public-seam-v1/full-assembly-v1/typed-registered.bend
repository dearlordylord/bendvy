import Base
import ./application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
# Plain/Transient/constructor-result precedence stays in the existing selector.
# Only an accepted already-typed owner reaches this resource-write registration.
type Args is Type:Args{owner:Input.Owner,canonical:D.Raw}
def succeeded(~S:Data,result:App.World(~S) & App.Output<S>) -> Local.Outcome<App.World(~S),Unit,Unit,App.Output<S>>:
  match result:
    case (world,output):Local.Succeeded{world,Unit{},output}
def runner(~S:Data,world:App.World(~S),local:Unit,args:Args) -> Local.Outcome<App.World(~S),Unit,Unit,App.Output<S>>:
  match args:
    case Args{owner,canonical}:succeeded(~S,App.resource_typed(~S,world,owner,canonical))
def Instance(~S:Data) -> Type:Local.Instance<S,App.Store(~S),App.Mail<S>,Unit,Unit,Args,Unit,App.Output<S>,runner(~S)>
type Context<S:Data> is Type:Context{world:App.World(~S),instance:Instance(~S)}
type Output<S:Data> is Type:
  Completed{output:App.Output<S>}
  RegistrationRefused{owner:Input.Owner,canonical:D.Raw}
  SystemFailed{error:Unit}
def define(~S:Data,world:App.World(~S)) -> Local.Registered<S,App.Store(~S),App.Mail<S>,Unit,Unit,Args,Unit,App.Output<S>,runner(~S)>:
  Local.register(~S,~App.Store(~S),~App.Mail<S>,~Unit,~Unit,~Args,~Unit,~App.Output<S>,~runner(~S),world,"decode-typed-resource",[Identity.key(~S,~Input.Owner,App.resource_identity(~S))],Unit{})
def ran(~S:Data,result:Local.Run<S,App.Store(~S),App.Mail<S>,Unit,Unit,Args,Unit,App.Output<S>,runner(~S)>) -> Context<S> & Output<S>:
  match result:
    case Local.Completed{world,instance,Done{output}}:(Context{world,instance},Completed{output})
    case Local.Completed{world,instance,Fail{error}}:(Context{world,instance},SystemFailed{error})
    case Local.Refused{world,instance,Args{owner,canonical}}:(Context{world,instance},RegistrationRefused{owner,canonical})
def request(~S:Data,context:Context<S>,owner:Input.Owner,canonical:D.Raw) -> Context<S> & Output<S>:
  match context:
    case Context{world,instance}:ran(~S,Local.run(~S,~App.Store(~S),~App.Mail<S>,~Unit,~Unit,~Args,~Unit,~App.Output<S>,~runner(~S),instance,world,Args{owner,canonical}))
