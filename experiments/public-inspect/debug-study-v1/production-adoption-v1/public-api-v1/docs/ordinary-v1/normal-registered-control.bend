import Base
import ./normal-dispatch.bend as Dispatch
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import ./canonical-schema.bend as Schema
import ./canonical-retained.bend as Retained
import ./canonical-app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
# Real registered dispatch; context keeps the rest of the actual App/SP owner.
def Registry() -> Type:
  Sys.Registry<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,Application.runner>
type Context is Data:
  Context{debug:App.Debug,namespace:U32,name:String,steps:List<&2,Sch.Step>,declaration:Schema.Params<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,entries:List<&2,Schema.Entry<Game.GameSchema>>,ownerNeeds:List<&2,SP.Requirement<Game.GameSchema>>,needs:List<&2,SP.Requirement<Game.GameSchema>>}
type Outcome is Type:
  Succeeded{world:Application.World(),app:Application.Application(),instance:I.Instance<Game.GameSchema>,result:Result<&2,&2,Unit,Bool>}
  Rejected{world:Application.World(),app:Application.Application(),args:I.Instance<Game.GameSchema> & Unit}
  Failed{world:Application.World(),app:Application.Application(),error:Unit}
def restored(ctx:Context,registry:Registry()) -> Application.Application():
  match ctx:
    case Context{debug,namespace,name,steps,declaration,entries,ownerNeeds,needs}:App.Application{debug,SP.Provisioned{Sch.Schedule{namespace,name,steps,Retained.Registered{registry,declaration,entries,ownerNeeds}},needs}}
def dispatched(ctx:Context,result:Sys.RunResult<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,Application.runner>) -> Outcome:
  match result:
    case Sys.RegistrationRejected{registry,world,args}:Rejected{world,restored(ctx,registry),args}
    case Sys.Completed{registry,Sys.Failed{world,error}}:Failed{world,restored(ctx,registry),error}
    case Sys.Completed{registry,Sys.Succeeded{world,(instance,result)}}:Succeeded{world,restored(ctx,registry),instance,result}
def run(world:Application.World(),owner:Application.Application()) -> Outcome:
  match owner:
    case App.Application{debug,SP.Provisioned{Sch.Schedule{namespace,name,steps,Retained.Registered{registry,declaration,entries,ownerNeeds}},needs}}:dispatched(Context{debug,namespace,name,steps,declaration,entries,ownerNeeds,needs},Dispatch.run(~Game.GameSchema,~Unit,~Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,~U32,~(I.Instance<Game.GameSchema> & Unit),~Unit,~(I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>),~Application.runner,registry,world,(I.Fresh{},Unit{})))
