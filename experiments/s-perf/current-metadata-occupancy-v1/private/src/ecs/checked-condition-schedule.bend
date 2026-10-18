import Base
import ./ordinary-checked-condition.bend as Cond
import ./ordinary-checked-bindings.bend as B
import ./check.bend as K
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Same membership/duplicate/namespace, step and SP needs behavior as
# ordinary-condition-composition. Only selected Check errors differ in transport.
type Error<BodyError:Data> is Data:
  SystemError{error:BodyError}
  CheckError{error:K.Error}
  ConditionUnavailable{}
  ConditionRegistrationRejected{}

type Attachment<S:Data,C:Type,R:Type,E:Data,H:Type,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>> is Type:
  Attached{schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>}
  AttachmentRejected{schedule:Sch.Schedule<S,C,R,E,H>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,allowed:Bool,namespace:U32,name:String,+steps:List<&2,Sch.Step>,owners:H,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,facts:List<&2,B.Description>) -> Attachment<S,C,R,E,H,B,select>:
  match allowed:
    case False{}:AttachmentRejected{Sch.Schedule{namespace,name,steps,owners},bindings}
    case True{}:Attached{Sch.Schedule{namespace,name,steps,(owners,bindings)}}
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,schedule:Sch.Schedule<S,C,R,E,H>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Attachment<S,C,R,E,H,B,select>:
  match schedule bindings:
    case Sch.Schedule{namespace,name,+steps,owners} B.Bindings{state,+facts}:attached(~S,~C,~R,~E,~H,~B,~select,Bool.and(B.unique(facts,[]),B.targets(facts,steps)),namespace,name,steps,owners,B.Bindings{state,facts},facts)

def body_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,owners:H,outcome:Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>) -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match outcome:
    case Sys.Succeeded{world,value}:((owners,bindings),Sys.Succeeded{world,value})
    case Sys.Failed{world,error}:((owners,bindings),Sys.Failed{world,SystemError{error}})
def body_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,returned:H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>) -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match returned:
    case (owners,outcome):body_outcome(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,bindings,owners,outcome)
def body_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,owners:H & B.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,id:U32) -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & Sys.Outcome<W.World<S,C,R,E>,Error<BodyError>,Unit>:
  match owners:
    case (gameplay,bindings):body_returned(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,bindings,dispatch(gameplay,world,id))
def guard_decision_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,next:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,value:Bool,owners:H,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,+id:U32) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match value:
    case False{}:next((owners,bindings),world,List.append(&2,Sch.Observation,observations,[Sch.Skipped{id}]))
    case True{}:Sch.after_dispatch(~S,~C,~R,~E,~(H & B.Bindings<W.World<S,C,R,E>,B,select>),~Error<BodyError>,next,body_dispatch(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,(owners,bindings),world,id),namespace,name,all,observations,id)
def guard_returned_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,next:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,facts:List<&2,B.Description>,owners:H,result:B.Selection<W.World<S,C,R,E>,B>,namespace:U32,name:String,all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,id:U32) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match result:
    case B.Selected{world,state,Done{value}}:guard_decision_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,next,value,owners,B.Bindings{state,facts},world,namespace,name,all,observations,id)
    case B.Unbound{world,state}:guard_decision_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,next,True{},owners,B.Bindings{state,facts},world,namespace,name,all,observations,id)
    case B.Selected{world,state,Fail{Cond.CheckError{error}}}:Sch.Failed{Sch.Schedule{namespace,name,all,(owners,B.Bindings{state,facts})},world,CheckError{error},observations}
    case B.Selected{world,state,Fail{Cond.NoValue{}}}:Sch.Failed{Sch.Schedule{namespace,name,all,(owners,B.Bindings{state,facts})},world,ConditionUnavailable{},observations}
    case B.Selected{world,state,Fail{Cond.InvalidRegistration{}}}:Sch.Failed{Sch.Schedule{namespace,name,all,(owners,B.Bindings{state,facts})},world,ConditionRegistrationRejected{},observations}
    case B.Selected{world,state,Fail{Cond.NoBinding{}}}:guard_decision_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,next,True{},owners,B.Bindings{state,facts},world,namespace,name,all,observations,id)
def guard_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,next:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> List<&2,Sch.Observation> -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>,owners:H & B.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,namespace:U32,name:String,all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,+id:U32) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match owners:
    case (gameplay,B.Bindings{state,facts}):guard_returned_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,next,facts,gameplay,select(state,world,id),namespace,name,all,observations,id)
def execute_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,steps:List<&2,Sch.Step>,owners:H & B.Bindings<W.World<S,C,R,E>,B,select>,world:W.World<S,C,R,E>,+namespace:U32,+name:String,+all:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match steps:
    case []:Sch.Finished{Sch.Schedule{namespace,name,all,owners},world,observations}
    case Sch.Phase{phase} <> rest:execute_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,rest,owners,world,namespace,name,all,List.append(&2,Sch.Observation,observations,[Sch.Entered{phase}]))
    case Sch.Barrier{} <> rest:Sch.after_skip(~S,~C,~R,~E,~(H & B.Bindings<W.World<S,C,R,E>,B,select>),~Error<BodyError>,h => w => obs => execute_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,rest,h,w,namespace,name,all,obs),barrier(owners,world),List.append(&2,Sch.Observation,observations,[Sch.Applied{}]))
    case Sch.System{id,_} <> rest:guard_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,h => w => obs => execute_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,rest,h,w,namespace,name,all,obs),owners,world,namespace,name,all,observations,id)
def run_checked_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,allowed:Bool,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match allowed schedule:
    case False{} schedule:Sch.Rejected{schedule,world}
    case True{} Sch.Schedule{+namespace,+name,+steps,owners}:execute_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,steps,owners,world,namespace,name,steps,[])
def run_namespaced_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,observed:W.World<S,C,R,E> & U32) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match schedule observed:
    case Sch.Schedule{+namespace,name,+steps,(gameplay,B.Bindings{state,+facts})}, (world,actual):run_checked_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,Bool.and(U32.is_eq(namespace,actual),Bool.and(B.unique(facts,[]),B.targets(facts,steps))),Sch.Schedule{namespace,name,steps,(gameplay,B.Bindings{state,facts})},world)
def run_schedule_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  run_namespaced_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,schedule,W.namespace(~S,~C,~R,~E,world))

def provision_checked_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,missing:List<&2,SP.Requirement<S>>,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>,needs:List<&2,SP.Requirement<S>>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match missing:
    case first <> rest:SP.Missing{SP.Provisioned{schedule,needs},world,first <> rest}
    case []:SP.Executed{run_schedule_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,schedule,world),needs}
def provision_available_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,observed:W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,+needs:List<&2,SP.Requirement<S>>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match observed:
    case (world,available):provision_checked_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,SP.missing_requirements(~S,needs,available),schedule,world,needs)
def run_provisioned_with_barrier(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~barrier:(H & B.Bindings<W.World<S,C,R,E>,B,select>) -> W.World<S,C,R,E> -> (H & B.Bindings<W.World<S,C,R,E>,B,select>) & W.World<S,C,R,E>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schedule:SP.Provisioned<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  match schedule:
    case SP.Provisioned{schedule,needs}:provision_available_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~barrier,provision(world),schedule,needs)

def run_schedule(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,schedule:Sch.Schedule<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  run_schedule_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~Sch.default_barrier(~S,~C,~R,~E,~(H & B.Bindings<W.World<S,C,R,E>,B,select>)),schedule,world)

def run_provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~BodyError:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,BodyError,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schedule:SP.Provisioned<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>>,world:W.World<S,C,R,E>) -> SP.ProvisionResult<S,C,R,E,H & B.Bindings<W.World<S,C,R,E>,B,select>,Error<BodyError>>:
  run_provisioned_with_barrier(~S,~C,~R,~E,~H,~B,~select,~BodyError,~dispatch,~Sch.default_barrier(~S,~C,~R,~E,~(H & B.Bindings<W.World<S,C,R,E>,B,select>)),~provision,schedule,world)
