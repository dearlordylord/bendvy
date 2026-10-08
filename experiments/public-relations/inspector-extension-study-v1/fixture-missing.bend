import Base
import fixture-state.bend as State
import fixture-consumer.bend as C
import fixture-driver.bend as Driver
import fixture-registration.bend as Reg
import root-source/system.bend as Sys
import root-source/schedule.bend as Sch
import machine-requirements.bend as Req
import root-source/world.bend as W
import root-source/inspector.bend as I
import root-source/inspector-metadata.bend as Meta
import root-source/machine.bend as M
import root-source/machine-stream.bend as St

# Closed setup assigns Flow1/Level2. Only Flow is actually installed here.
# Available validates real slot presence, not names or a separate boolean flag.
def present(~S:Data,~K:Data,slot:M.Slot<S,K,U32>) -> Bool:
  match slot:
    case M.Missing{}:False{}
    case M.Present{_,_,_,_}:True{}
def available(~S:Data,+flow:M.Slot<S,State.FlowToken,U32>,+level:M.Slot<S,State.LevelToken,U32>,requirement:Req.Requirement<S>) -> Bool:
  match requirement:
    case Req.Resource{Meta.Resource{id,_}}:U32.is_eq(id,1)
    case Req.MachineRequirement{+id,_}:Bool.or(Bool.and(U32.is_eq(id,1),present(~S,~State.FlowToken,flow)),Bool.and(U32.is_eq(id,2),present(~S,~State.LevelToken,level)))
# Runtime slot metadata cannot be captured by an erased template; explicit
# shrinking list helper threads the Data environment through each check.
def missing(~S:Data,remaining:List<&2,Req.Requirement<S>>,+flow:M.Slot<S,State.FlowToken,U32>,+level:M.Slot<S,State.LevelToken,U32>) -> List<&2,Req.Requirement<S>>:
  match remaining:
    case []:[]
    case +head <> rest:Req.keep(~S,available(~S,flow,level,head),head,missing(~S,rest,flow,level))
def required(~S:Data,+name:String) -> List<&2,Req.Requirement<S>>:
  [Req.MachineRequirement{1,name ++ "/Flow"},Req.MachineRequirement{2,name ++ "/Level"}]
def resource_missing(~S:Data,requirements:List<&2,Req.Requirement<S>>,resources:State.Resources<S>) -> State.Resources<S> & List<&2,Req.Requirement<S>>:
  match resources:
    case State.Resources{owned,+flow,+level,ran,flowStream,levelStream}:(State.Resources{owned,flow,level,ran,flowStream,levelStream},missing(~S,requirements,flow,level))
def observed_missing(~S:Data,requirements:List<&2,Req.Requirement<S>>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & List<&2,Req.Requirement<S>>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:W.observe_resource_finish(~S,~State.Store<S>,~State.Resources<S>,~U32,~List<&2,Req.Requirement<S>>,resource_missing(~S,requirements,resources),ns,next,high,live,capacity,depth,store,events,commands,registrations,nextSystem,clock)
type MissingRun<S:Data> is Type:
  MissingRun{world:W.World<S,State.Store<S>,State.Resources<S>,U32>,instance:I.Instance<S>,args:List<&2,U32>,missing:List<&2,Req.Requirement<S>>,bodies:U32,result:Maybe<&2,C.Values<S>>}
type Output<S:Data> is Type:
  Completed{factory:W.Factory,run:MissingRun<S>}
  CreationRefused{factory:W.Factory,resources:State.Resources<S>}
def schedule_invoked(~S:Data,instance:I.Instance<S>,args:List<&2,U32>,result:Sch.RunResult<S,State.Store<S>,State.Resources<S>,U32,C.Holder<S>,String>) -> MissingRun<S>:
  match result:
    case Sch.Finished{_,world,_}:MissingRun{world,instance,args,[],1,None{}}
    case Sch.Failed{_,world,_,_}:MissingRun{world,instance,args,[],1,None{}}
    case Sch.Rejected{_,world}:MissingRun{world,instance,args,[],0,None{}}
def schedule_built(~S:Data,instance:I.Instance<S>,args:List<&2,U32>,result:Reg.BuiltGate<S>) -> MissingRun<S>:
  match result:
    case Reg.Ran{result}:schedule_invoked(~S,instance,args,result)
    case Reg.Invalid{world,_}:MissingRun{world,instance,args,[],0,None{}}
def registered(~S:Data,instance:I.Instance<S>,args:List<&2,U32>,result:Reg.GateResult<S>) -> MissingRun<S>:
  match result:
    case Reg.Registered{Sys.Registered{world,registry}}:schedule_built(~S,instance,args,Reg.gate(~S,world,C.Holder{registry},1))
    case Reg.Registered{Sys.RegistrationFailed{world}}:MissingRun{world,instance,args,[],0,None{}}
def invoked(~S:Data,instance:I.Instance<S>,args:List<&2,U32>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> MissingRun<S>:
  registered(~S,instance,args,Reg.register(~S,world))
def gated(~S:Data,gate:Req.Gate<S,W.World<S,State.Store<S>,State.Resources<S>,U32>,I.Instance<S>,List<&2,U32>>) -> MissingRun<S>:
  match gate:
    case Req.Missing{world,instance,args,requirements}:MissingRun{world,instance,args,requirements,0,None{}}
    case Req.Ready{world,instance,args}:invoked(~S,instance,args,world)
def preflighted(~S:Data,instance:I.Instance<S>,args:List<&2,U32>,observed:W.World<S,State.Store<S>,State.Resources<S>,U32> & List<&2,Req.Requirement<S>>) -> MissingRun<S>:
  (world,requirements)=observed
  gated(~S,Req.gate(~S,~W.World<S,State.Store<S>,State.Resources<S>,U32>,~I.Instance<S>,~List<&2,U32>,requirements,world,instance,args))
def created(~S:Data,name:String,result:W.Creation<S,State.Store<S>,State.Resources<S>,U32>) -> Output<S>:
  match result:
    case W.Created{factory,world}:Completed{factory,preflighted(~S,I.Fresh{},[91,19],observed_missing(~S,required(~S,name),world))}
    case W.CreateRejected{factory,resources}:CreationRefused{factory,resources}
def resources(~S:Data) -> State.Resources<S>:
  State.Resources{Array.set(U32,Array.set(U32,Array.new(U32,1n,0),0,3),1,13),M.Present{0,M.NoPending{},None{},False{}},M.Missing{},0,St.empty(~U32),St.empty(~U32)}
def run(~S:Data,name:String) -> Output<S>:
  created(~S,name,W.create(~S,~State.Store<S>,~State.Resources<S>,~U32,~Driver.empty_store(~S),W.factory(),resources(~S)))
def workshop() -> Output<State.Workshop>:
  run(~State.Workshop,"Workshop")
def garden() -> Output<State.Garden>:
  run(~State.Garden,"Garden")
