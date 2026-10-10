import Base
import schema-families.bend as D
import runtime-owners.bend as Owners
import owner-observer.bend as OwnerDump
import world-observer.bend as Dump
import gate-instrumentation.bend as Instrument
import phase-driver.bend as Phase
import core/world.bend as W
import core/system.bend as Sys
import core/schedule.bend as Sch

type Args is Type:
  Args{first:Array<U32>,second:Array<U32>,ran:U32}
def runner(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,args:Args) -> Sys.Outcome<W.World<S,D.Store<S>,Owners.Resource<S>,U32>,Unit,Args>:
  match args:
    case Args{first,second,ran}:Sys.Succeeded{world,Args{first,second,(ran + 1 : U32)}}
type Holder<S:Data> is Type:
  Holder{registry:Sys.Registry<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)>,args:Args}
  NoArgs{registry:Sys.Registry<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)>}
type Registered<S:Data> is Type:
  Registered{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,holders:List<Holder<S>>,errors:String}
type Gate<S:Data> is Type:
  Gate{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,holder:Holder<S>,observations:List<&2,Sch.Observation>,before:String,after:String,errors:String}
def args_join(+ran:U32,observedFirst:Array<U32> & String,observedSecond:Array<U32> & String) -> Args & String:
  (first,a)=observedFirst
  (second,b)=observedSecond
  (Args{first,second,ran},a ++ ";" ++ b ++ ";ran=" ++ U32.show(ran))
def args(value:Args) -> Args & String:
  match value:
    case Args{first,second,ran}:args_join(ran,OwnerDump.u32_array(first),OwnerDump.u32_array(second))
def holder_join(~S:Data,observedRegistry:Sys.Registry<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)> & String,observedArgs:Args & String) -> Holder<S> & String:
  (registry,a)=observedRegistry
  (args,b)=observedArgs
  (Holder{registry,args},a ++ ";args=" ++ b)
def no_args(~S:Data,observed:Sys.Registry<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)> & String) -> Holder<S> & String:
  (registry,text)=observed
  (NoArgs{registry},text ++ ";UNEXPECTED_RUNNER_FAILURE_NO_ARGS")
def holder(~S:Data,value:Holder<S>) -> Holder<S> & String:
  match value:
    case NoArgs{registry}:no_args(~S,Dump.registry(~S,~Args,~Unit,~Args,~runner(~S),registry))
    case Holder{registry,value}:holder_join(~S,Dump.registry(~S,~Args,~Unit,~Args,~runner(~S),registry),args(value))
def registered(~S:Data,holders:List<Holder<S>>,errors:String,value:Sys.RegistrationResult<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)>) -> Registered<S>:
  match value:
    case Sys.Registered{world,registry}:Registered{world,List.append(&1,Holder<S>,holders,[Holder{registry,Args{Array.new(U32,1n,401),Array.new(U32,2n,501),0}}]),errors}
    case Sys.RegistrationFailed{world}:Registered{world,holders,errors ++ "system-registration-refused;"}
def register_name(~S:Data,prefix:String,name:String,value:Registered<S>) -> Registered<S>:
  match value:
    case Registered{world,holders,errors}:registered(~S,holders,errors,Sys.register(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Args,~Unit,~Args,~runner(~S),world,prefix ++ "/ComponentQueryGate/" ++ name,[]))
def register(~S:Data,+prefix:String,names:List<&2,String>,value:Registered<S>) -> Registered<S>:
  match names:
    case []:value
    case name <> rest:register(~S,prefix,rest,register_name(~S,prefix,name,value))
def register_all(~S:Data,prefix:String,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> Registered<S>:
  register(~S,prefix,["empty","optionalFour","requiredPair","fiveAlias","withWithout","multipleWith","multipleWithout","repeated","contradictory"],Registered{world,[],""})
def dispatched(~S:Data,value:Sys.RunResult<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)>) -> Holder<S> & Sys.Outcome<W.World<S,D.Store<S>,Owners.Resource<S>,U32>,String,Unit>:
  match value:
    case Sys.Completed{registry,Sys.Succeeded{world,args}}:(Holder{registry,args},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,_}}:(NoArgs{registry},Sys.Failed{world,"UNREACHABLE_RUNNER_FAILURE"})
    case Sys.RegistrationRejected{registry,world,args}:(Holder{registry,args},Sys.Failed{world,"registration-rejected"})
def dispatch(~S:Data,value:Holder<S>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,id:U32) -> Holder<S> & Sys.Outcome<W.World<S,D.Store<S>,Owners.Resource<S>,U32>,String,Unit>:
  match value:
    case NoArgs{registry}:(NoArgs{registry},Sys.Failed{world,"prior-runner-failure-no-args"})
    case Holder{registry,args}:dispatched(~S,Sys.run(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Args,~Unit,~Args,~runner(~S),registry,world,args))
def observed_holder(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,observations:List<&2,Sch.Observation>,before:String,errors:String,observed:Holder<S> & String) -> Gate<S>:
  (holder,after)=observed
  Gate{world,holder,observations,before,after,errors}
def finished(~S:Data,before:String,value:Sch.RunResult<S,D.Store<S>,Owners.Resource<S>,U32,Holder<S>,String>) -> Gate<S>:
  match value:
    case Sch.Finished{Sch.Schedule{_,_,_,current},world,observations}:observed_holder(~S,world,observations,before,"",holder(~S,current))
    case Sch.Failed{Sch.Schedule{_,_,_,current},world,error,observations}:observed_holder(~S,world,observations,before,"schedule-failed:" ++ error,holder(~S,current))
    case Sch.Rejected{Sch.Schedule{_,_,_,current},world}:observed_holder(~S,world,[],before,"schedule-rejected;",holder(~S,current))
def built(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,before:String,value:Sch.Build<S,D.Store<S>,Owners.Resource<S>,U32,Holder<S>>) -> Gate<S>:
  match value:
    case Sch.Built{schedule}:finished(~S,before,Sch.run(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Holder<S>,~String,~dispatch(~S),~Instrument.condition(~S),schedule,world))
    case Sch.Invalid{current}:observed_holder(~S,world,[],before,"schedule-build-invalid;",holder(~S,current))
def named(~S:Data,slot:U32,+id:U32,value:Holder<S>,before:String,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & U32) -> Gate<S>:
  (world,namespace)=observed
  built(~S,world,before,Sch.build(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Holder<S>,namespace,"ComponentQueryGate",[Sch.System{id,slot}],[id],value))
def identified(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,slot:U32,args:Args,before:String,observed:Sys.Registry<S,D.Store<S>,Owners.Resource<S>,U32,Args,Unit,Args,runner(~S)> & U32) -> Gate<S>:
  (registry,id)=observed
  named(~S,slot,id,Holder{registry,args},before,W.namespace(~S,~D.Store<S>,~Owners.Resource<S>,~U32,world))
def prepared(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,slot:U32,observed:Holder<S> & String) -> Gate<S>:
  match observed:
    case (NoArgs{registry},+before):Gate{world,NoArgs{registry},[],before,before,"prior-runner-failure-no-args;"}
    case (Holder{registry,args},before):identified(~S,world,slot,args,before,Sys.identity(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Args,~Unit,~Args,~runner(~S),registry))
def preloaded(~S:Data,value:Holder<S>,slot:U32,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Unit) -> Gate<S>:
  (world,_)=observed
  prepared(~S,world,slot,holder(~S,value))
def run(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,value:Holder<S>,slot:U32,targets:List<&2,W.Handle<S>>,record:String) -> Gate<S>:
  preloaded(~S,value,slot,Instrument.preload(~S,targets,record,world))
def workshop(world:W.World<D.Workshop,D.Store<D.Workshop>,Owners.Resource<D.Workshop>,U32>,value:Holder<D.Workshop>,slot:U32,targets:List<&2,W.Handle<D.Workshop>>,record:String) -> Gate<D.Workshop>:
  run(~D.Workshop,world,value,slot,targets,record)
def garden(world:W.World<D.Garden,D.Store<D.Garden>,Owners.Resource<D.Garden>,U32>,value:Holder<D.Garden>,slot:U32,targets:List<&2,W.Handle<D.Garden>>,record:String) -> Gate<D.Garden>:
  run(~D.Garden,world,value,slot,targets,record)
def main() -> Unit:
  Unit{}
