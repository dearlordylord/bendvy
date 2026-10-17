import Base
import motion-codec-values.bend as V
import motion-domain.bend as D
import motion-observation.bend as Observation
import ../dense-runtime-v1/motion.bend as F
import ../dense-runtime-v1/types.bend as Types
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/schedule.bend as Sch

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
def select_recorded(reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),calls:List<&2,Call>,world:D.World(),+status:CallStatus,+id:U32,text:V.Local,+output:Maybe<&2,D.Output>,owner:Instance(~select_runner),updated:D.Frame & (U32 & List<&2,D.Boundary>)) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match updated:
    case (frame,(digest,boundaries)):(Owners{owner,reserve,dispose,observe,frame,digest,boundaries,List.append(&2,Call,calls,[Call{D.Select{},id,status,text,output}])},system_outcome(world,status))
def select_done(reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,result:Called<select_runner>) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match result:
    case Called{owner,world,status,+output,id,text}:select_recorded(reserve,dispose,observe,calls,world,status,id,text,output,owner,updated_frame(frame,digest,boundaries,output))
def reserve_recorded(select:Instance(~select_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),calls:List<&2,Call>,world:D.World(),+status:CallStatus,+id:U32,text:V.Local,+output:Maybe<&2,D.Output>,owner:Instance(~reserve_runner),updated:D.Frame & (U32 & List<&2,D.Boundary>)) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match updated:
    case (frame,(digest,boundaries)):(Owners{select,owner,dispose,observe,frame,digest,boundaries,List.append(&2,Call,calls,[Call{D.Reserve{},id,status,text,output}])},system_outcome(world,status))
def reserve_done(select:Instance(~select_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,result:Called<reserve_runner>) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match result:
    case Called{owner,world,status,+output,id,text}:reserve_recorded(select,dispose,observe,calls,world,status,id,text,output,owner,updated_frame(frame,digest,boundaries,output))
def dispose_recorded(select:Instance(~select_runner),reserve:Instance(~reserve_runner),observe:Instance(~observe_runner),calls:List<&2,Call>,world:D.World(),+status:CallStatus,+id:U32,text:V.Local,+output:Maybe<&2,D.Output>,owner:Instance(~dispose_runner),updated:D.Frame & (U32 & List<&2,D.Boundary>)) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match updated:
    case (frame,(digest,boundaries)):(Owners{select,reserve,owner,observe,frame,digest,boundaries,List.append(&2,Call,calls,[Call{D.Dispose{},id,status,text,output}])},system_outcome(world,status))
def dispose_done(select:Instance(~select_runner),reserve:Instance(~reserve_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,result:Called<dispose_runner>) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match result:
    case Called{owner,world,status,+output,id,text}:dispose_recorded(select,reserve,observe,calls,world,status,id,text,output,owner,updated_frame(frame,digest,boundaries,output))
def observe_recorded(select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),calls:List<&2,Call>,world:D.World(),+status:CallStatus,+id:U32,text:V.Local,+output:Maybe<&2,D.Output>,owner:Instance(~observe_runner),updated:D.Frame & (U32 & List<&2,D.Boundary>)) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match updated:
    case (frame,(digest,boundaries)):(Owners{select,reserve,dispose,owner,frame,digest,boundaries,List.append(&2,Call,calls,[Call{D.Observe{},id,status,text,output}])},system_outcome(world,status))
def observe_done(select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,result:Called<observe_runner>) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match result:
    case Called{owner,world,status,+output,id,text}:observe_recorded(select,reserve,dispose,calls,world,status,id,text,output,owner,updated_frame(frame,digest,boundaries,output))
def observe_allowed(allowed:Bool,select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),+frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match allowed:
    case True{}:observe_done(select,reserve,dispose,frame,digest,boundaries,calls,invoked(~observe_runner,observe,world,frame))
    case False{}:(Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls},Sys.Failed{world,Unit{}})
def observe_id(select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),+wanted:U32,observed:Instance(~observe_runner) & U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match observed:
    case (observe,id):observe_allowed(U32.is_eq(id,wanted),select,reserve,dispose,observe,frame,digest,boundaries,calls,world,wanted)
def dispatch_observe(owners:Owners,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match owners:
    case Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}:observe_id(select,reserve,dispose,frame,digest,boundaries,calls,world,wanted,identity(~observe_runner,observe))
def dispose_allowed(allowed:Bool,select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),+frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match allowed:
    case True{}:dispose_done(select,reserve,observe,frame,digest,boundaries,calls,invoked(~dispose_runner,dispose,world,frame))
    case False{}:dispatch_observe(Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls},world,wanted)
def dispose_id(select:Instance(~select_runner),reserve:Instance(~reserve_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),+wanted:U32,observed:Instance(~dispose_runner) & U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match observed:
    case (dispose,id):dispose_allowed(U32.is_eq(id,wanted),select,reserve,dispose,observe,frame,digest,boundaries,calls,world,wanted)
def dispatch_dispose(owners:Owners,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match owners:
    case Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}:dispose_id(select,reserve,observe,frame,digest,boundaries,calls,world,wanted,identity(~dispose_runner,dispose))
def reserve_allowed(allowed:Bool,select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),+frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match allowed:
    case True{}:reserve_done(select,dispose,observe,frame,digest,boundaries,calls,invoked(~reserve_runner,reserve,world,frame))
    case False{}:dispatch_dispose(Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls},world,wanted)
def reserve_id(select:Instance(~select_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),+wanted:U32,observed:Instance(~reserve_runner) & U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match observed:
    case (reserve,id):reserve_allowed(U32.is_eq(id,wanted),select,reserve,dispose,observe,frame,digest,boundaries,calls,world,wanted)
def dispatch_reserve(owners:Owners,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match owners:
    case Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}:reserve_id(select,dispose,observe,frame,digest,boundaries,calls,world,wanted,identity(~reserve_runner,reserve))
def select_allowed(allowed:Bool,select:Instance(~select_runner),reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),+frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match allowed:
    case True{}:select_done(reserve,dispose,observe,frame,digest,boundaries,calls,invoked(~select_runner,select,world,frame))
    case False{}:dispatch_reserve(Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls},world,wanted)
def select_id(reserve:Instance(~reserve_runner),dispose:Instance(~dispose_runner),observe:Instance(~observe_runner),frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,Call>,world:D.World(),+wanted:U32,observed:Instance(~select_runner) & U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match observed:
    case (select,id):select_allowed(U32.is_eq(id,wanted),select,reserve,dispose,observe,frame,digest,boundaries,calls,world,wanted)
def dispatch_select(owners:Owners,world:D.World(),wanted:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:
  match owners:
    case Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}:select_id(reserve,dispose,observe,frame,digest,boundaries,calls,world,wanted,identity(~select_runner,select))
def dispatch(owners:Owners,world:D.World(),id:U32) -> Owners & Sys.Outcome<D.World(),Unit,Unit>:dispatch_select(owners,world,id)
def condition(world:D.World(),slot:U32) -> D.World() & Bool:(world,U32.is_eq(slot,0))
