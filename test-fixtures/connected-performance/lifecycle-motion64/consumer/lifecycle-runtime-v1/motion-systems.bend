import Base
import ../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../src/ecs/trace-facts.bend as Facts
import motion-codec-values.bend as V
import motion-domain.bend as D
import motion-observation.bend as Observation
import ../dense-runtime-v1/motion.bend as F
import ../dense-runtime-v1/types.bend as Types
import ../observers/owner-observer.bend as Dump
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/local.bend as Local
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/schedule.bend as Sch

def select_runner(world:D.World(),owner:Array<U32>,frame:D.Frame) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:D.select(world,D.bump(owner),frame)
def reserve_runner(world:D.World(),owner:Array<U32>,frame:D.Frame) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:D.reserve(world,D.bump(owner),frame)
def dispose_runner(world:D.World(),owner:Array<U32>,frame:D.Frame) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:D.dispose(world,D.bump(owner),frame)
def observe_runner(world:D.World(),owner:Array<U32>,frame:D.Frame) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:Observation.run(world,D.bump(owner),frame)
def Instance(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>) -> Type:Local.Instance<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,run>
type CallStatus is Data:
  Succeeded{}
  Failed{}
  Refused{}
type Call is Data:
  Call{operation:D.Operation,id:U32,status:CallStatus,local:V.Local,output:Maybe<&2,D.Output>}
type Owners is Type:
  Owners{select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>}
def local_text(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,observed:Array<U32> & V.Tree<U32>) -> Instance(~run) & V.Local:
  match observed:
    case (local,view):(Local.Instance{namespace,id,name,access,local},V.Local{namespace,id,name,access,view})
def instance(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,owner:Instance(~run)) -> Instance(~run) & V.Local:
  match owner:
    case Local.Instance{+namespace,+id,+name,+access,local}:local_text(~run,namespace,id,name,access,V.tree(~U32,~U32,~V.u32_value,local))
def identity(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,owner:Instance(~run)) -> Instance(~run) & U32:
  Local.identity(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~run,owner)
type Called<-run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>> is Type:
  Called{instance:Instance(~run),world:D.World(),status:CallStatus,output:Maybe<&2,D.Output>,id:U32,text:V.Local}
def called_text(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,world:D.World(),status:CallStatus,output:Maybe<&2,D.Output>,observed:Instance(~run) & V.Local) -> Called<run>:
  match observed:
    case (Local.Instance{ns,+id,name,access,local},text):Called{Local.Instance{ns,id,name,access,local},world,status,output,id,text}
def called(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,result:Local.Run<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,run>) -> Called<run>:
  match result:
    case Local.Completed{world,owner,Done{output}}:called_text(~run,world,Succeeded{},Some{output},instance(~run,owner))
    case Local.Completed{world,owner,Fail{_}}:called_text(~run,world,Failed{},None{},instance(~run,owner))
    case Local.Refused{world,owner,_}:called_text(~run,world,Refused{},None{},instance(~run,owner))
def invoked(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,owner:Instance(~run),world:D.World(),frame:D.Frame) -> Called<run>:
  called(~run,Local.run(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~run,owner,world,frame))
def updated_frame(old:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,output:Maybe<&2,D.Output>) -> D.Frame & (U32 & List<&2,D.Boundary>):
  match output:
    case None{}:(old,(digest,boundaries))
    case Some{D.Output{frame,None{}}}:(frame,(digest,boundaries))
    case Some{D.Output{frame,Some{+value}}}:(frame,(Observation.mix(digest,Observation.hash(value)),List.append(&2,D.Boundary,boundaries,[value])))
def system_outcome(world:D.World(),status:CallStatus) -> Sys.Outcome<D.World(),Unit,Unit>:
  match status:
    case Succeeded{}:Sys.Succeeded{world,Unit{}}
    case _:Sys.Failed{world,Unit{}}
type Shared is Type:
  Shared{frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,stage:U32}
def Owned() -> Type:(Instance(~select_runner) & Instance(~reserve_runner)) & (Instance(~dispose_runner) & Instance(~observe_runner))
def Runtime() -> Type:Owned() & Shared
def pack(value:Owners) -> Runtime():
  match value:
    case Owners{s,r,d,o,frame,digest,boundaries,calls}:(((s,r),(d,o)),Shared{frame,digest,boundaries,calls,0})
def with_stage(stage:U32,value:Runtime()) -> Runtime():
  match value:
    case (owned,Shared{frame,digest,boundaries,calls,_}):(owned,Shared{frame,digest,boundaries,calls,stage})
def unpack(value:Runtime()) -> Owners:
  match value:
    case (((s,r),(d,o)),Shared{frame,digest,boundaries,calls,_}):Owners{s,r,d,o,frame,digest,boundaries,calls}
def contextual(trace:Facts.State,outcome:Sys.Outcome<D.World(),Unit,Unit>) -> Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  match outcome:
    case Sys.Succeeded{world,value}:Sys.Succeeded{Ctx.Context{world,trace},value}
    case Sys.Failed{world,value}:Sys.Failed{Ctx.Context{world,trace},value}
def harvested(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,+operation:D.Operation,trace:Facts.State,calls:List<&2,Call>,stage:U32,owner:Instance(~run),world:D.World(),+status:CallStatus,+id:U32,text:V.Local,+output:Maybe<&2,D.Output>,updated:D.Frame & (U32 & List<&2,D.Boundary>)) -> Instance(~run) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):
  match updated:
    case (frame,(digest,boundaries)):(owner,(Shared{frame,digest,boundaries,List.append(&2,Call,calls,[Call{operation,id,status,text,output}]),stage},contextual(trace,system_outcome(world,status))))
def returned(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,operation:D.Operation,trace:Facts.State,frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,stage:U32,result:Called<run>) -> Instance(~run) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):
  match result:
    case Called{owner,world,status,+output,id,text}:harvested(~run,operation,trace,calls,stage,owner,world,status,id,text,output,updated_frame(frame,digest,boundaries,output))
def invoke(~run:D.World() -> Array<U32> -> D.Frame -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,operation:D.Operation,owner:Instance(~run),shared:Shared,context:Ctx.Context<D.World()>) -> Instance(~run) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):
  match shared context:
    case Shared{+frame,digest,boundaries,calls,stage},Ctx.Context{world,trace}:returned(~run,operation,trace,frame,digest,boundaries,calls,stage,invoked(~run,owner,world,frame))
def invoke_select(owner:Instance(~select_runner),shared:Shared,context:Ctx.Context<D.World()>) -> Instance(~select_runner) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):invoke(~select_runner,D.Select{},owner,shared,context)
def invoke_reserve(owner:Instance(~reserve_runner),shared:Shared,context:Ctx.Context<D.World()>) -> Instance(~reserve_runner) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):invoke(~reserve_runner,D.Reserve{},owner,shared,context)
def invoke_dispose(owner:Instance(~dispose_runner),shared:Shared,context:Ctx.Context<D.World()>) -> Instance(~dispose_runner) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):invoke(~dispose_runner,D.Dispose{},owner,shared,context)
def invoke_observe(owner:Instance(~observe_runner),shared:Shared,context:Ctx.Context<D.World()>) -> Instance(~observe_runner) & (Shared & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>):invoke(~observe_runner,D.Observe{},owner,shared,context)
