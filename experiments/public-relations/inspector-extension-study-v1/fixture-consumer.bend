import Base
import fixture-dump.bend as Dump
import root-source/string-equality.bend as SE
import fixture-state.bend as State
import machine-current-adapter.bend as Read
import machine-check-adapter.bend as Check
import root-source/inspector.bend as I
import root-source/world.bend as W
import root-source/capabilities.bend as Cap
import root-source/machine.bend as M
import root-source/machine-world.bend as MW
import root-source/system.bend as Sys
import root-source/schedule.bend as Sch
import root-source/transaction.bend as Tx

type Reads<-H:Type,-S:Data> is Type:
  Reads{flow:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>,level:Cap.ValueRead<H,M.CurrentView<S,State.LevelToken,U32>>}
type Values<S:Data> is Data:
  Values{flow:M.CurrentView<S,State.FlowToken,U32>,level:M.CurrentView<S,State.LevelToken,U32>}
def flow_field(~H:Type,~S:Data,reads:Reads<H,S>) -> Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>:
  match reads:
    case Reads{flow,_}:flow
def level_field(~H:Type,~S:Data,reads:Reads<H,S>) -> Cap.ValueRead<H,M.CurrentView<S,State.LevelToken,U32>>:
  match reads:
    case Reads{_,level}:level
def read_done(~H:Type,~S:Data,flow:M.CurrentView<S,State.FlowToken,U32>,result:H & M.CurrentView<S,State.LevelToken,U32>) -> H & Values<S>:
  (owner,level)=result
  (owner,Values{flow,level})
def read_level(~H:Type,~S:Data,~level:Cap.ValueRead<H,M.CurrentView<S,State.LevelToken,U32>>,result:H & M.CurrentView<S,State.FlowToken,U32>) -> H & Values<S>:
  (owner,flow)=result
  read_done(~H,~S,flow,Cap.value_read(~H,~M.CurrentView<S,State.LevelToken,U32>,~level,owner))
def values(~H:Type,~S:Data,~reads:Reads<H,S>,owner:H) -> H & Values<S>:
  read_level(~H,~S,~level_field(~H,~S,reads),Cap.value_read(~H,~M.CurrentView<S,State.FlowToken,U32>,~flow_field(~H,~S,reads),owner))
def body_done(~S:Data,~H:Type,result:H & Values<S>) -> H & Result<&2,&2,String,Values<S>>:
  (owner,value)=result
  (owner,Done{value})
def body(~S:Data,~H:Type,~reads:Reads<H,S>,args:Unit,owner:H) -> H & Result<&2,&2,String,Values<S>>:
  body_done(~S,~H,values(~H,~S,~reads,owner))
def reads(~S:Data) -> Reads<I.Frame<S,State.Store<S>,State.Resources<S>,U32>,S>:
  Reads{Read.provide(~S,~State.FlowToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.flow(~S)),Read.provide(~S,~State.LevelToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.level(~S))}
def inspect(~S:Data,instance:I.Instance<S>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> I.Observed<S,State.Store<S>,State.Resources<S>,U32,String,Values<S>>:
  I.run(~S,~State.Store<S>,~State.Resources<S>,~U32,~(H => Reads<H,S>),~Unit,~String,~Values<S>,~I.Plan{reads(~S)},~body(~S),instance,Unit{},world)
def accepted(~S:Data,flow:U32,level:U32,value:Values<S>) -> Bool:
  match value:
    case Values{a,b}:Bool.and(M.is_current(~S,~State.FlowToken,~U32,~U32.is_eq,a,flow),M.is_current(~S,~State.LevelToken,~U32,~U32.is_eq,b,level))
def check_done(~S:Data,flow:U32,level:U32,result:Check.Context<S,State.Store<S>,State.Resources<S>,U32> & Values<S>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  (context,value)=result
  Check.finish(~S,~State.Store<S>,~State.Resources<S>,~U32,(context,accepted(~S,flow,level,value)))
def condition_value(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,+id:U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  check_done(~S,id,(id+10:U32),values(~Check.Context<S,State.Store<S>,State.Resources<S>,U32>,~S,~Reads{Check.provide(~S,~State.FlowToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.flow(~S)),Check.provide(~S,~State.LevelToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.level(~S))},Check.Context{world}))
def raw_condition(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,id:U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  condition_value(~S,world,id)
def compared(~S:Data,before:String,allowed:Bool,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  (world,after)=result
  (world,Bool.and(allowed,SE.equal(before,after)))
def checked(~S:Data,before:String,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  (world,allowed)=result
  compared(~S,before,allowed,Dump.world(~S,world))
def check_before(~S:Data,id:U32,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  (world,before)=result
  checked(~S,before,raw_condition(~S,world,id))
def condition(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,id:U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool:
  check_before(~S,id,Dump.world(~S,world))
def succeeded(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Unit) -> Sys.Outcome<W.World<S,State.Store<S>,State.Resources<S>,U32>,String,Unit>:
  (world,value)=result
  Sys.Succeeded{world,value}
def runner(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,args:Unit) -> Sys.Outcome<W.World<S,State.Store<S>,State.Resources<S>,U32>,String,Unit>:
  succeeded(~S,W.observe_resource(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,~State.increment(~S),world))
type Holder<S:Data> is Type:
  Holder{registry:Sys.Registry<S,State.Store<S>,State.Resources<S>,U32,Unit,String,Unit,runner(~S)>}
def dispatched(~S:Data,result:Sys.RunResult<S,State.Store<S>,State.Resources<S>,U32,Unit,String,Unit,runner(~S)>) -> Holder<S> & Sys.Outcome<W.World<S,State.Store<S>,State.Resources<S>,U32>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(Holder{registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(Holder{registry},Sys.Failed{world,"registration-rejected"})
def dispatch(~S:Data,holder:Holder<S>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,id:U32) -> Holder<S> & Sys.Outcome<W.World<S,State.Store<S>,State.Resources<S>,U32>,String,Unit>:
  match holder:
    case Holder{registry}:dispatched(~S,Sys.run(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,~String,~Unit,~runner(~S),registry,world,Unit{}))
# Actual schedule evaluator executes Check before genuine registered dispatch.
def run_schedule(~S:Data,schedule:Sch.Schedule<S,State.Store<S>,State.Resources<S>,U32,Holder<S>>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> Sch.RunResult<S,State.Store<S>,State.Resources<S>,U32,Holder<S>,String>:
  Sch.run(~S,~State.Store<S>,~State.Resources<S>,~U32,~Holder<S>,~String,~dispatch(~S),~condition(~S),schedule,world)
