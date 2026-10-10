import Base
import ./dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
# Transient internal transport. The public Schedule result remains unchanged.
type Owners<S:Data,C:Type,R:Type,E:Data,H:Type,CE:Data,RE:Data> is Type:
  Owners{registered:H,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,Unit>,D.Error<CE,RE>,D.Output<Unit,Unit>>)>,refused:Maybe<D.Arguments<Unit,Unit>>}
def outcome(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,Unit>,D.Error<CE,RE>,D.Output<Unit,Unit>>)>,owners:H,result:Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<Unit,Unit>>) -> Owners<S,C,R,E,H,CE,RE> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match result:
    case Sys.Succeeded{world,output}:(Owners{owners,callbacks,None{}},Sys.Succeeded{world,Unit{}})
    case Sys.Failed{world,error}:(Owners{owners,callbacks,None{}},Sys.Failed{world,Some{error}})
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,Unit>,D.Error<CE,RE>,D.Output<Unit,Unit>>)>,result:D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,Unit>,D.Error<CE,RE>,D.Output<Unit,Unit>>) -> Owners<S,C,R,E,H,CE,RE> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match result:
    case D.Completed{owners,result}:outcome(~S,~C,~R,~E,~H,~CE,~RE,callbacks,owners,result)
    case D.RegistrationRejected{owners,world,args}:(Owners{owners,callbacks,Some{args}},Sys.Failed{world,None{}})
    case D.UnknownSystem{owners,world,id}:(Owners{owners,callbacks,None{}},Sys.Failed{world,None{}})
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,owners:Owners<S,C,R,E,H,CE,RE>,world:W.World<S,C,R,E>,id:U32) -> Owners<S,C,R,E,H,CE,RE> & Sys.Outcome<W.World<S,C,R,E>,Maybe<&2,D.Error<CE,RE>>,Unit>:
  match owners:
    case Owners{owners,actual <> rest,prior}:returned(~S,~C,~R,~E,~H,~CE,~RE,rest,actual(owners,world,id))
    case Owners{owners,[],prior}:(Owners{owners,[],prior},Sys.Failed{world,None{}})
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,owners:Owners<S,C,R,E,H,CE,RE>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match owners:
    case Owners{registered,remaining,refused}:(Sch.Finished{Sch.Schedule{namespace,name,steps,registered},world,observations},refused)
def failed_error(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,error:Maybe<&2,D.Error<CE,RE>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,registered:H,refused:Maybe<D.Arguments<Unit,Unit>>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match error:
    case Some{error}:(Sch.Failed{Sch.Schedule{namespace,name,steps,registered},world,error,observations},refused)
    case None{}:(Sch.Rejected{Sch.Schedule{namespace,name,steps,registered},world},refused)
def failed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,error:Maybe<&2,D.Error<CE,RE>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,observations:List<&2,Sch.Observation>,owners:Owners<S,C,R,E,H,CE,RE>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match owners:
    case Owners{registered,remaining,refused}:failed_error(~S,~C,~R,~E,~H,~CE,~RE,error,namespace,name,steps,world,observations,registered,refused)
def rejected(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,world:W.World<S,C,R,E>,owners:Owners<S,C,R,E,H,CE,RE>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match owners:
    case Owners{registered,remaining,refused}:(Sch.Rejected{Sch.Schedule{namespace,name,steps,registered},world},refused)
def final(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,result:Sch.RunResult<S,C,R,E,Owners<S,C,R,E,H,CE,RE>,Maybe<&2,D.Error<CE,RE>>>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations}:finished(~S,~C,~R,~E,~H,~CE,~RE,namespace,name,steps,world,observations,owners)
    case Sch.Failed{Sch.Schedule{namespace,name,steps,owners},world,error,observations}:failed(~S,~C,~R,~E,~H,~CE,~RE,error,namespace,name,steps,world,observations,owners)
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,owners},world}:rejected(~S,~C,~R,~E,~H,~CE,~RE,namespace,name,steps,world,owners)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RE:Data,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,callbacks:List<(H -> W.World<S,C,R,E> -> U32 -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,Unit>,D.Error<CE,RE>,D.Output<Unit,Unit>>)>,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,D.Error<CE,RE>> & Maybe<D.Arguments<Unit,Unit>>:
  match schedule:
    case Sch.Schedule{namespace,name,steps,owners}:final(~S,~C,~R,~E,~H,~CE,~RE,Sch.run(~S,~C,~R,~E,~Owners<S,C,R,E,H,CE,RE>,~Maybe<&2,D.Error<CE,RE>>,~dispatch(~S,~C,~R,~E,~H,~CE,~RE),~condition,Sch.Schedule{namespace,name,steps,Owners{owners,callbacks,None{}}},world))
