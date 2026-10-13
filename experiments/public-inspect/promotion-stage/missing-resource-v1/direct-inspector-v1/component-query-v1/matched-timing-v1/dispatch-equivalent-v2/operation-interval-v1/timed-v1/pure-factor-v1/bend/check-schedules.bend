import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Ord
import input-writer.bend as Setter
import schema-families.bend as D
import runtime-owners.bend as Owners
import check-execution.bend as C
import check-inputs.bend as Input
import world-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K

def World(~S:Data) -> Type:W.World<S,D.Store<S>,Owners.Resource(~S),U32>
def noop(~S:Data,world:World(~S),_:Unit) -> Sys.Outcome<World(~S),Unit,Unit>:Sys.Succeeded{world,Unit{}}
def Registry(~S:Data) -> Type:Sys.Registry<S,D.Store<S>,Owners.Resource(~S),U32,Unit,Unit,Unit,noop(~S)>
type Holder<S:Data> is Type:
  Holder{registries:List<Registry(~S)>,ran:Nat,setter:Setter.Registry(~S)}
type Started<S:Data> is Type:
  Started{world:World(~S),holder:Holder<S>}
  Rejected{world:World(~S)}
def setter_started(~S:Data,registries:List<Registry(~S)>,result:Sys.RegistrationResult<S,D.Store<S>,Owners.Resource(~S),U32,Owners.CheckInputs<S>,Unit,Unit,Setter.set_world(~S)>) -> Started<S>:
  match result:
    case Sys.Registered{world,registry}:Started{world,Holder{registries,0n,registry}}
    case Sys.RegistrationFailed{world}:Rejected{world}
def register_all(~S:Data,names:List<&2,String>,prior:List<Registry(~S)>,result:Sys.RegistrationResult<S,D.Store<S>,Owners.Resource(~S),U32,Unit,Unit,Unit,noop(~S)>) -> Started<S>:
  match names result:
    case _ Sys.RegistrationFailed{world}:Rejected{world}
    case Nil{} Sys.Registered{world,registry}:setter_started(~S,List.append(&1,Registry(~S),prior,[registry]),Setter.start(~S,world))
    case Con{name,rest} Sys.Registered{world,registry}:register_all(~S,rest,List.append(&1,Registry(~S),prior,[registry]),Sys.register(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Unit,~Unit,~Unit,~noop(~S),world,name,[]))
def start(~S:Data,world:World(~S)) -> Started<S>:
  register_all(~S,["CheckOptionalFourNoop","CheckRequiredPairNoop","CheckFiveAliasNoop","CheckWithWithoutNoop","CheckMultipleWithNoop","CheckMultipleWithoutNoop","CheckRepeatedNoop","CheckContradictoryNoop"],[],Sys.register(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Unit,~Unit,~Unit,~noop(~S),world,"CheckEmptyNoop",[]))
def dispatched(~S:Data,result:Sys.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,Unit,Unit,Unit,noop(~S)>) -> Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(registry,outcome)
    case Sys.RegistrationRejected{registry,world,_}:(registry,Sys.Failed{world,Unit{}})
def dispatch(~S:Data,registry:Registry(~S),world:World(~S),_:U32) -> Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  dispatched(~S,Sys.run_tracked(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Unit,~Unit,~Unit,~noop(~S),registry,world,Unit{}))
def checked(~S:Data,result:K.Checked<S,D.Store<S>,Owners.Resource(~S),U32>) -> World(~S) & Bool:
  match result:
    case K.Checked{world,Done{allowed}}:(world,allowed)
    case K.Checked{world,Fail{_}}:(world,False{})
def kind_code(kind:C.CheckKind) -> U32:
  match kind:
    case C.CheckEmpty{}:0
    case C.CheckOptionalFour{}:1
    case C.CheckRequiredPair{}:2
    case C.CheckFiveAlias{}:3
    case C.CheckWithWithout{}:4
    case C.CheckMultipleWith{}:5
    case C.CheckMultipleWithout{}:6
    case C.CheckRepeated{}:7
    case C.CheckContradictory{}:8
def kind_value(code:U32) -> C.CheckKind:
  match code:
    case 0:C.CheckEmpty{}
    case 1:C.CheckOptionalFour{}
    case 2:C.CheckRequiredPair{}
    case 3:C.CheckFiveAlias{}
    case 4:C.CheckWithWithout{}
    case 5:C.CheckMultipleWith{}
    case 6:C.CheckMultipleWithout{}
    case 7:C.CheckRepeated{}
    case _:C.CheckContradictory{}
def input_read(~S:Data,result:World(~S) & Owners.CheckInputs<S>) -> World(~S) & Bool:
  match result:
    case (world,Owners.CheckInputs{kind,targets,expected}):checked(~S,C.run(~S,kind_value(kind),C.Args{targets,expected},world))
def guarded(~S:Data,world:World(~S),slot:U32) -> World(~S) & Bool:
  match slot:
    case 1:(world,True{})
    case _:input_read(~S,Input.read(~S,world))
def condition(~S:Data,world:World(~S),id:U32) -> World(~S) & Bool:
  guarded(~S,world,id)
def input_value(~S:Data,kind:C.CheckKind,args:C.Args<S>) -> Owners.CheckInputs<S>:
  match args:
    case C.Args{targets,expected}:Owners.CheckInputs{kind_code(kind),targets,expected}
def workshop_condition(world:World(~D.Workshop),id:U32) -> World(~D.Workshop) & Bool:
  condition(~D.Workshop,world,id)
def garden_condition(world:World(~D.Garden),id:U32) -> World(~D.Garden) & Bool:
  condition(~D.Garden,world,id)
def set_inputs(~S:Data,kind:C.CheckKind,args:C.Args<S>,world:World(~S)) -> World(~S):
  match args:
    case C.Args{targets,expected}:Input.set(~S,Owners.CheckInputs{kind_code(kind),targets,expected},world)
type ScheduleOwners<S:Data> is Type:
  ScheduleOwners{registry:Registry(~S),setter:Setter.Registry(~S),input:Owners.CheckInputs<S>,setterId:U32}
def setter_returned(~S:Data,registry:Registry(~S),+input:Owners.CheckInputs<S>,+id:U32,result:Setter.Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>) -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>:
  (setter,outcome)=result
  (ScheduleOwners{registry,setter,input,id},outcome)
def noop_returned(~S:Data,setter:Setter.Registry(~S),input:Owners.CheckInputs<S>,id:U32,result:Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>) -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>:
  (registry,outcome)=result
  (ScheduleOwners{registry,setter,input,id},outcome)
def selected_dispatch(~S:Data,selected:Bool,registry:Registry(~S),setter:Setter.Registry(~S),+input:Owners.CheckInputs<S>,+setterId:U32,world:World(~S),id:U32) -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>:
  match selected:
    case True{}:setter_returned(~S,registry,input,setterId,Setter.run(~S,setter,world,input))
    case False{}:noop_returned(~S,setter,input,setterId,dispatch(~S,registry,world,id))
def schedule_dispatch(~S:Data,owners:ScheduleOwners<S>,world:World(~S),+id:U32) -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>:
  match owners:
    case ScheduleOwners{registry,setter,+input,+setterId}:selected_dispatch(~S,U32.is_eq(id,setterId),registry,setter,input,setterId,world,id)
type Observed<S:Data> is Type:
  Observed{world:World(~S),registry:Registry(~S),setter:Setter.Registry(~S),observations:List<&2,Sch.Observation>}
def finished(~S:Data,result:Sch.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,ScheduleOwners<S>,Unit>) -> Observed<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,ScheduleOwners{registry,setter,_,_}},world,observations}:Observed{world,registry,setter,observations}
    case Sch.Failed{Sch.Schedule{_,_,_,ScheduleOwners{registry,setter,_,_}},world,_,observations}:Observed{world,registry,setter,observations}
    case Sch.Rejected{Sch.Schedule{_,_,_,ScheduleOwners{registry,setter,_,_}},world}:Observed{world,registry,setter,[]}
def built(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,kind:C.CheckKind,args:C.Args<S>,world:World(~S),result:Sch.Build<S,D.Store<S>,Owners.Resource(~S),U32,ScheduleOwners<S>>) -> Observed<S>:
  match result:
    case Sch.Built{schedule}:finished(~S,Sch.run(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~ScheduleOwners<S>,~Unit,~dispatch,~guard,schedule,world))
    case Sch.Invalid{ScheduleOwners{registry,setter,_,_}}:Observed{world,registry,setter,[]}
def ids(values:List<&2,W.RegistrationMeta>) -> List<&2,U32>:
  match values:
    case []:[]
    case W.RegistrationMeta{id,_,_} <> rest:id <> ids(rest)
def cataloged(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,+kind:C.CheckKind,+args:C.Args<S>,registry:Registry(~S),id:U32,setter:Setter.Registry(~S),+setterId:U32,world:World(~S)) -> Observed<S>:
  match world:
    case W.World{+namespace,next,high,live,capacity,depth,store,resource,events,pending,+registrations,nextSystem,clock}:built(~S,~guard,~dispatch,kind,args,W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},Sch.build(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~ScheduleOwners<S>,namespace,"StatelessCheckSchedule",[Sch.System{setterId,1},Sch.System{id,0}],ids(registrations),ScheduleOwners{registry,setter,input_value(~S,kind,args),setterId}))
def identified(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,kind:C.CheckKind,args:C.Args<S>,world:World(~S),setter:Setter.Registry(~S),setterId:U32,result:Registry(~S) & U32) -> Observed<S>:
  (registry,id)=result
  cataloged(~S,~guard,~dispatch,kind,args,registry,id,setter,setterId,world)
def setter_identified(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,kind:C.CheckKind,args:C.Args<S>,world:World(~S),registry:Registry(~S),named:Setter.Registry(~S) & U32) -> Observed<S>:
  (setter,setterId)=named
  identified(~S,~guard,~dispatch,kind,args,world,setter,setterId,Sys.identity(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Unit,~Unit,~Unit,~noop(~S),registry))
def run_one(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,+kind:C.CheckKind,+args:C.Args<S>,world:World(~S),registry:Registry(~S),setter:Setter.Registry(~S)) -> Observed<S>:
  setter_identified(~S,~guard,~dispatch,kind,args,world,registry,Sys.identity(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~Unit,~Unit,~Setter.set_world(~S),setter))
def ran(values:List<&2,Sch.Observation>) -> Bool:
  match values:
    case []:False{}
    case [Sch.Ran{_}]:True{}
    case Sch.Ran{_} <> rest:ran(rest)
    case _ <> rest:ran(rest)
type Batch<S:Data> is Type:
  Batch{world:World(~S),holder:Holder<S>,checks:List<&2,Bool>}
def increment(count:Nat,allowed:Bool) -> Nat:
  match allowed:
    case False{}:count
    case True{}:1n+count
def next(~S:Data,pending:List<Registry(~S)>,retained:List<Registry(~S)>,count:Nat,texts:List<&2,Bool>,continuation:World(~S) -> List<Registry(~S)> -> List<Registry(~S)> -> Nat -> List<&2,Bool> -> Setter.Registry(~S) -> Batch<S>,observed:Observed<S>) -> Batch<S>:
  match observed:
    case Observed{world,registry,setter,+observations}:continuation(world,pending,List.append(&1,Registry(~S),retained,[registry]),increment(count,ran(observations)),List.append(&2,Bool,texts,[ran(observations)]),setter)
def all(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,+targets:List<&2,W.Handle<S>>,kinds:List<&2,C.CheckKind>,records:List<&2,String>,pending:List<Registry(~S)>,retained:List<Registry(~S)>,count:Nat,texts:List<&2,Bool>,world:World(~S),setter:Setter.Registry(~S)) -> Batch<S>:
  match kinds records pending:
    case Nil{} _ pending:Batch{world,Holder{List.append(&1,Registry(~S),retained,pending),count,setter},texts}
    case _ Nil{} pending:Batch{world,Holder{List.append(&1,Registry(~S),retained,pending),count,setter},texts}
    case _ _ Nil{}:Batch{world,Holder{retained,count,setter},texts}
    case Con{kind,kinds} Con{record,records} Con{registry,pending}:next(~S,pending,retained,count,texts,world=>pending=>retained=>count=>texts=>setter=>all(~S,~guard,~dispatch,targets,kinds,records,pending,retained,count,texts,world,setter),run_one(~S,~guard,~dispatch,kind,C.Args{targets,record},world,registry,setter))
def run(~S:Data,~guard:World(~S) -> U32 -> World(~S) & Bool,~dispatch:ScheduleOwners<S> -> World(~S) -> U32 -> ScheduleOwners<S> & Sys.Outcome<World(~S),Unit,Unit>,targets:List<&2,W.Handle<S>>,kinds:List<&2,C.CheckKind>,records:List<&2,String>,world:World(~S),holder:Holder<S>) -> Batch<S>:
  match holder:
    case Holder{registries,count,setter}:all(~S,~guard,~dispatch,targets,kinds,records,registries,[],count,[],world,setter)
def observe_join(~S:Data,head:Registry(~S) & String,tail:List<Registry(~S)> & List<&2,String>) -> List<Registry(~S)> & List<&2,String>:
  (registry,text)=head
  (registries,texts)=tail
  (registry <> registries,text <> texts)
def observe_list(~S:Data,registries:List<Registry(~S)>) -> List<Registry(~S)> & List<&2,String>:
  match registries:
    case []:([],[])
    case registry <> rest:observe_join(~S,Dump.registry(~S,~Unit,~Unit,~Unit,~noop(~S),registry),observe_list(~S,rest))
def observed(~S:Data,+count:Nat,value:List<Registry(~S)> & List<&2,String>,setterView:Setter.Registry(~S) & String) -> Holder<S> & String:
  (registries,texts)=value
  (setter,setterText)=setterView
  (Holder{registries,count,setter},"ran=" ++ Nat.show(count) ++ "|registry=" ++ List.show(&2,String,x=>x,texts) ++ "|setter=" ++ setterText)
def observe(~S:Data,holder:Holder<S>) -> Holder<S> & String:
  match holder:
    case Holder{registries,count,setter}:observed(~S,count,observe_list(~S,registries),Dump.registry(~S,~Owners.CheckInputs<S>,~Unit,~Unit,~Setter.set_world(~S),setter))
def workshop_dispatch(owners:ScheduleOwners<D.Workshop>,world:World(~D.Workshop),id:U32) -> ScheduleOwners<D.Workshop> & Sys.Outcome<World(~D.Workshop),Unit,Unit>:
  schedule_dispatch(~D.Workshop,owners,world,id)
def garden_dispatch(owners:ScheduleOwners<D.Garden>,world:World(~D.Garden),id:U32) -> ScheduleOwners<D.Garden> & Sys.Outcome<World(~D.Garden),Unit,Unit>:
  schedule_dispatch(~D.Garden,owners,world,id)
