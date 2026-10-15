import Base
import ../provider.bend as P
import fixture.bend as F
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/machine-stream.bend as St
import ../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../src/ecs/ordinary-machine-initialization.bend as Init

def world_type(~S:Data) -> Type:W.World<S,P.Store<S>,F.Resources<S>,Unit>
def level_reading() -> Data:Ev.Reading<M.Transition<P.Level>>
def flow_reading() -> Data:Ev.Reading<M.Transition<P.Flow>>
# The real affine Reader stays in its registered owner across every Sys outcome.
# Only its observed identity is passed to the closed schema runner.
type ReaderInput<-S:Data,-Token:Data> is Data:ReaderInput{namespace:U32,id:U32}

def level_activated(~S:Data,+id:U32,+tick:Nat,rest:F.Resources<S>,slot:M.Slot<S,P.LevelToken,P.Level>,revision:Nat,+active:St.Stream<P.Level>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Level>>:
  (F.put_level(~S,rest,Init.State{slot,St.complete(~P.Level,active,id,tick,True{}),revision}),St.observe(~P.Level,active,id,tick))
def level_taken(~S:Data,+id:U32,+tick:Nat,pair:F.Resources<S> & Init.State<S,P.LevelToken,P.Level>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Level>>:
  match pair:
    case (rest,Init.State{slot,stream,revision}):level_activated(~S,id,tick,rest,slot,revision,St.activate(~P.Level,stream,id,tick))
def level_effect(~S:Data,id:U32,tick:Nat,resource:F.Resources<S>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Level>>:
  level_taken(~S,id,tick,F.take_level(~S,resource))
def level_observed(~S:Data,observed:world_type(~S) & Ev.Reading<M.Transition<P.Level>>) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Level>>>:
  match observed:
    case (world,reading):Sys.Succeeded{world,reading}
def level_clocked(~S:Data,id:U32,observed:world_type(~S) & U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Level>>>:
  match observed:
    case (world,clock):level_observed(~S,Init.with_resource(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Ev.Reading<M.Transition<P.Level>>,resource => level_effect(~S,id,U32.to_nat(clock),resource),world))
def level_checked(~S:Data,allowed:Bool,world:world_type(~S),id:U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Level>>>:
  match allowed:
    case False{}:Sys.Failed{world,"LevelReaderRefused"}
    case True{}:level_clocked(~S,id,W.clock(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def level_named(~S:Data,input:ReaderInput<S,P.LevelToken>,observed:world_type(~S) & U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Level>>>:
  match input observed:
    case ReaderInput{namespace,id}, (world,actual):level_checked(~S,U32.is_eq(namespace,actual),world,id)
def read_level(~S:Data,world:world_type(~S),input:ReaderInput<S,P.LevelToken>) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Level>>>:
  level_named(~S,input,W.namespace(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def level_registry(~S:Data) -> Type:Sys.Registry<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.LevelToken>,String,Ev.Reading<M.Transition<P.Level>>,read_level(~S)>

def flow_activated(~S:Data,+id:U32,+tick:Nat,rest:F.Resources<S>,slot:M.Slot<S,P.FlowToken,P.Flow>,revision:Nat,+active:St.Stream<P.Flow>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Flow>>:
  (F.put_flow(~S,rest,Init.State{slot,St.complete(~P.Flow,active,id,tick,True{}),revision}),St.observe(~P.Flow,active,id,tick))
def flow_taken(~S:Data,+id:U32,+tick:Nat,pair:F.Resources<S> & Init.State<S,P.FlowToken,P.Flow>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Flow>>:
  match pair:
    case (rest,Init.State{slot,stream,revision}):flow_activated(~S,id,tick,rest,slot,revision,St.activate(~P.Flow,stream,id,tick))
def flow_effect(~S:Data,id:U32,tick:Nat,resource:F.Resources<S>) -> F.Resources<S> & Ev.Reading<M.Transition<P.Flow>>:
  flow_taken(~S,id,tick,F.take_flow(~S,resource))
def flow_observed(~S:Data,observed:world_type(~S) & Ev.Reading<M.Transition<P.Flow>>) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Flow>>>:
  match observed:
    case (world,reading):Sys.Succeeded{world,reading}
def flow_clocked(~S:Data,id:U32,observed:world_type(~S) & U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Flow>>>:
  match observed:
    case (world,clock):flow_observed(~S,Init.with_resource(~S,~P.Store<S>,~F.Resources<S>,~Unit,~Ev.Reading<M.Transition<P.Flow>>,resource => flow_effect(~S,id,U32.to_nat(clock),resource),world))
def flow_checked(~S:Data,allowed:Bool,world:world_type(~S),id:U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Flow>>>:
  match allowed:
    case False{}:Sys.Failed{world,"FlowReaderRefused"}
    case True{}:flow_clocked(~S,id,W.clock(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def flow_named(~S:Data,input:ReaderInput<S,P.FlowToken>,observed:world_type(~S) & U32) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Flow>>>:
  match input observed:
    case ReaderInput{namespace,id}, (world,actual):flow_checked(~S,U32.is_eq(namespace,actual),world,id)
def read_flow(~S:Data,world:world_type(~S),input:ReaderInput<S,P.FlowToken>) -> Sys.Outcome<world_type(~S),String,Ev.Reading<M.Transition<P.Flow>>>:
  flow_named(~S,input,W.namespace(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def flow_registry(~S:Data) -> Type:Sys.Registry<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.FlowToken>,String,Ev.Reading<M.Transition<P.Flow>>,read_flow(~S)>

type Fast<S:Data> is Type:
  Fast{registry:level_registry(~S),reader:St.Reader<S,P.LevelToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Level>>>}
type Slow<S:Data> is Type:
  Slow{registry:flow_registry(~S),reader:St.Reader<S,P.FlowToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Flow>>>}
type Owners<S:Data> is Type:Owners{fast:Fast<S>,slow:Slow<S>}
type Registered<S:Data> is Type:Registered{world:world_type(~S),owners:Owners<S>}
type Registration<S:Data> is Type:
  Ready{value:Registered<S>}
  Refused{world:world_type(~S)}
  Partial{world:world_type(~S),fast:Fast<S>}
def slow_namespaced(~S:Data,fast:Fast<S>,registry:flow_registry(~S),id:U32,observed:world_type(~S) & U32) -> Registration<S>:
  match observed:
    case (world,namespace):Ready{Registered{world,Owners{fast,Slow{registry,St.Reader{namespace,id},None{}}}}}
def slow_identified(~S:Data,fast:Fast<S>,world:world_type(~S),identified:flow_registry(~S) & U32) -> Registration<S>:
  match identified:
    case (registry,id):slow_namespaced(~S,fast,registry,id,W.namespace(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def slow_registered(~S:Data,fast:Fast<S>,result:Sys.RegistrationResult<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.FlowToken>,String,Ev.Reading<M.Transition<P.Flow>>,read_flow(~S)>) -> Registration<S>:
  match result:
    case Sys.Registered{world,registry}:slow_identified(~S,fast,world,Sys.identity(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.FlowToken>,~String,~Ev.Reading<M.Transition<P.Flow>>,~read_flow(~S),registry))
    case Sys.RegistrationFailed{world}:Partial{world,fast}
def fast_namespaced(~S:Data,registry:level_registry(~S),id:U32,observed:world_type(~S) & U32) -> Registration<S>:
  match observed:
    case (world,namespace):slow_registered(~S,Fast{registry,St.Reader{namespace,id},None{}},Sys.register(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.FlowToken>,~String,~Ev.Reading<M.Transition<P.Flow>>,~read_flow(~S),world,"condition-readers-slow",["machine.Flow.transition.read"]))
def fast_identified(~S:Data,world:world_type(~S),identified:level_registry(~S) & U32) -> Registration<S>:
  match identified:
    case (registry,id):fast_namespaced(~S,registry,id,W.namespace(~S,~P.Store<S>,~F.Resources<S>,~Unit,world))
def fast_registered(~S:Data,result:Sys.RegistrationResult<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.LevelToken>,String,Ev.Reading<M.Transition<P.Level>>,read_level(~S)>) -> Registration<S>:
  match result:
    case Sys.Registered{world,registry}:fast_identified(~S,world,Sys.identity(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.LevelToken>,~String,~Ev.Reading<M.Transition<P.Level>>,~read_level(~S),registry))
    case Sys.RegistrationFailed{world}:Refused{world}
def register(~S:Data,world:world_type(~S)) -> Registration<S>:
  fast_registered(~S,Sys.register(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.LevelToken>,~String,~Ev.Reading<M.Transition<P.Level>>,~read_level(~S),world,"condition-readers-fast",["machine.Level.transition.read"]))

def fast_result(~S:Data,reader:St.Reader<S,P.LevelToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Level>>>,slow:Slow<S>,result:Sys.RunResult<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.LevelToken>,String,Ev.Reading<M.Transition<P.Level>>,read_level(~S)>) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,reading}}:(Owners{Fast{registry,reader,Some{reading}},slow},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Owners{Fast{registry,reader,last},slow},Sys.Failed{world,error})
    case Sys.RegistrationRejected{registry,world,_}:(Owners{Fast{registry,reader,last},slow},Sys.Failed{world,"FastReaderRegistrationRejected"})
def fast_run(~S:Data,registry:level_registry(~S),reader:St.Reader<S,P.LevelToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Level>>>,slow:Slow<S>,world:world_type(~S)) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match reader:
    case St.Reader{+namespace,+id}:fast_result(~S,St.Reader{namespace,id},last,slow,Sys.run_tracked(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.LevelToken>,~String,~Ev.Reading<M.Transition<P.Level>>,~read_level(~S),registry,world,ReaderInput{namespace,id}))

def slow_result(~S:Data,reader:St.Reader<S,P.FlowToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Flow>>>,fast:Fast<S>,result:Sys.RunResult<S,P.Store<S>,F.Resources<S>,Unit,ReaderInput<S,P.FlowToken>,String,Ev.Reading<M.Transition<P.Flow>>,read_flow(~S)>) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,reading}}:(Owners{fast,Slow{registry,reader,Some{reading}}},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Owners{fast,Slow{registry,reader,last}},Sys.Failed{world,error})
    case Sys.RegistrationRejected{registry,world,_}:(Owners{fast,Slow{registry,reader,last}},Sys.Failed{world,"SlowReaderRegistrationRejected"})
def slow_run(~S:Data,registry:flow_registry(~S),reader:St.Reader<S,P.FlowToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Flow>>>,fast:Fast<S>,world:world_type(~S)) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match reader:
    case St.Reader{+namespace,+id}:slow_result(~S,St.Reader{namespace,id},last,fast,Sys.run_tracked(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.FlowToken>,~String,~Ev.Reading<M.Transition<P.Flow>>,~read_flow(~S),registry,world,ReaderInput{namespace,id}))

def slow_selected(~S:Data,chosen:Bool,fast:Fast<S>,slow:Slow<S>,world:world_type(~S)) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match chosen slow:
    case False{}, slow:(Owners{fast,slow},Sys.Failed{world,"UnknownReaderSystem"})
    case True{}, Slow{registry,reader,last}:slow_run(~S,registry,reader,last,fast,world)
def slow_target(~S:Data,fast:Fast<S>,reader:St.Reader<S,P.FlowToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Flow>>>,world:world_type(~S),target:U32,identified:flow_registry(~S) & U32) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match identified:
    case (registry,actual):slow_selected(~S,U32.is_eq(actual,target),fast,Slow{registry,reader,last},world)
def fast_selected(~S:Data,chosen:Bool,fast:Fast<S>,slow:Slow<S>,world:world_type(~S),target:U32) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match chosen fast slow:
    case True{}, Fast{registry,reader,last}, slow:fast_run(~S,registry,reader,last,slow,world)
    case False{}, fast, Slow{registry,reader,last}:slow_target(~S,fast,reader,last,world,target,Sys.identity(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.FlowToken>,~String,~Ev.Reading<M.Transition<P.Flow>>,~read_flow(~S),registry))
def fast_target(~S:Data,reader:St.Reader<S,P.LevelToken>,last:Maybe<&2,Ev.Reading<M.Transition<P.Level>>>,slow:Slow<S>,world:world_type(~S),+target:U32,identified:level_registry(~S) & U32) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match identified:
    case (registry,actual):fast_selected(~S,U32.is_eq(actual,target),Fast{registry,reader,last},slow,world,target)
def dispatch(~S:Data,owners:Owners<S>,world:world_type(~S),id:U32) -> Owners<S> & Sys.Outcome<world_type(~S),String,Unit>:
  match owners:
    case Owners{Fast{registry,reader,last},slow}:fast_target(~S,reader,last,slow,world,id,Sys.identity(~S,~P.Store<S>,~F.Resources<S>,~Unit,~ReaderInput<S,P.LevelToken>,~String,~Ev.Reading<M.Transition<P.Level>>,~read_level(~S),registry))
def ids(~S:Data,owners:Owners<S>) -> Owners<S> & (U32 & U32):
  match owners:
    case Owners{Fast{Sys.Registry{fn,+fi,fa,fx,fc},fr,fl},Slow{Sys.Registry{sn,+si,sa,sx,sc},sr,sl}}:(Owners{Fast{Sys.Registry{fn,fi,fa,fx,fc},fr,fl},Slow{Sys.Registry{sn,si,sa,sx,sc},sr,sl}},(fi,si))
