import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
# Transient internal transport. The public Schedule result remains unchanged.
type Owners<S:Data,C:Type,R:Type,E:Data,H:Type,CE:Data,RE:Data,RA:Type,RO:Type> is Type:
  Owners{registered:H,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>)>,refused:Maybe<D.Arguments<Unit,RA>>,outputs:List<D.Output<Unit,RO>>}
def outcome(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>)>,outputs:List<D.Output<Unit,RO>>,owners:H,result:Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<Unit,RO>>) -> Owners<S,C,R,E,H,CE,RE,RA,RO> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match result:
    case Sys.Succeeded{world,output}:(Owners{owners,callbacks,None{},List.append(&1,D.Output<Unit,RO>,outputs,[output])},Sys.Succeeded{world,Unit{}})
    case Sys.Failed{world,error}:(Owners{owners,callbacks,None{},outputs},Sys.Failed{world,Some{error}})
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>)>,outputs:List<D.Output<Unit,RO>>,result:D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>) -> Owners<S,C,R,E,H,CE,RE,RA,RO> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match result:
    case D.Completed{owners,result}:outcome(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,callbacks,outputs,owners,result)
    case D.RegistrationRejected{owners,world,args}:(Owners{owners,callbacks,Some{args},outputs},Sys.Failed{world,None{}})
    case D.UnknownSystem{owners,world,id}:(Owners{owners,callbacks,None{},outputs},Sys.Failed{world,None{}})
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,owners:Owners<S,C,R,E,H,CE,RE,RA,RO>,world:W.World<S,C,R,E>,id:U32) -> Owners<S,C,R,E,H,CE,RE,RA,RO> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match owners:
    case Owners{owners,actual <> rest,prior,outputs}:returned(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,rest,outputs,actual(owners,world,id))
    case Owners{owners,[],prior,outputs}:(Owners{owners,[],prior,outputs},Sys.Failed{world,None{}})
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,owners:Owners<S,C,R,E,H,CE,RE,RA,RO>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match owners:
    case Owners{registered,remaining,refused,outputs}:(Sch.Finished{Sch.Schedule{namespace,name,steps,registered},world,observations},(refused,outputs))
def failed_error(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,error:Maybe<&2,D.Error<CE,RE>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,registered:H,refused:Maybe<D.Arguments<Unit,RA>>,outputs:List<D.Output<Unit,RO>>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match error:
    case Some{error}:(Sch.Failed{Sch.Schedule{namespace,name,steps,registered},world,error,observations},(refused,outputs))
    case None{}:(Sch.Rejected{Sch.Schedule{namespace,name,steps,registered},world},(refused,outputs))
def failed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,error:Maybe<&2,D.Error<CE,RE>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,owners:Owners<S,C,R,E,H,CE,RE,RA,RO>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match owners:
    case Owners{registered,remaining,refused,outputs}:failed_error(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,error,namespace,name,steps,world,observations,registered,refused,outputs)
def rejected(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,owners:Owners<S,C,R,E,H,CE,RE,RA,RO>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match owners:
    case Owners{registered,remaining,refused,outputs}:(Sch.Rejected{Sch.Schedule{namespace,name,steps,registered},world},(refused,outputs))
def final(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,result:Sch.RunResult<S,C,R,E,Owners<S,C,R,E,H,CE,RE,RA,RO>,Maybe<&2,D.Error<CE,RE>>>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations}:finished(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,namespace,name,steps,world,observations,owners)
    case Sch.Failed{Sch.Schedule{namespace,name,steps,owners},world,error,observations}:failed(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,error,namespace,name,steps,world,observations,owners)
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,owners},world}:rejected(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,namespace,name,steps,world,owners)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~RA:Type,~RO:Type,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>)>,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & (Maybe<D.Arguments<Unit,RA>> & List<D.Output<Unit,RO>>):
  match schedule:
    case Sch.Schedule{namespace,name,steps,owners}:final(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO,Sch.run(~S,~C,~R,~E,~Owners<S,C,R,E,H,CE,RE,RA,RO>,~Maybe<&2,D.Error<CE,RE>>,~dispatch(~S,~C,~R,~E,~H,~CE,~RE,~RA,~RO),~condition,Sch.Schedule{namespace,name,steps,Owners{owners,callbacks,None{},[]}},world))
