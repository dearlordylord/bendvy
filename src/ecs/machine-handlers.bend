import Base
import ./machine-handler-engine.bend as Engine

import world.bend as W

import system.bend as Sys

import machine.bend as M



type Phase is Data:
  BendvyExit{}
  Transition{}
  Enter{}

type Invocation<V:Data> is Data:
  Invocation{phase:Phase,ordinal:U32,from:V,to:V}
  InitialEnter{ordinal:U32,to:V}

type Entry<S:Data,C:Type,R:Type,E:Data,V:Data,-runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Entry{ordinal:U32,registry:Sys.Registry<S,C,R,E,Invocation<V>,String,Unit,runner>}

type PhaseResult<S:Data,C:Type,R:Type,E:Data,V:Data,-runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Complete{entries:List<&1,Entry<S,C,R,E,V,runner>>,world:W.World<S,C,R,E>}
  Failed{entries:List<&1,Entry<S,C,R,E,V,runner>>,world:W.World<S,C,R,E>,error:String}

type Owners<S:Data,C:Type,R:Type,E:Data,V:Data,-runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Owners{exit:List<&1,Entry<S,C,R,E,V,runner>>,transition:List<&1,Entry<S,C,R,E,V,runner>>,enter:List<&1,Entry<S,C,R,E,V,runner>>}

type HandlerResult<S:Data,C:Type,R:Type,E:Data,V:Data,-runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Completed{owners:Owners<S,C,R,E,V,runner>,world:W.World<S,C,R,E>}
  Stopped{owners:Owners<S,C,R,E,V,runner>,world:W.World<S,C,R,E>,phase:Phase,error:String}

type Prepared<S:Data,K:Data,V:Data> is Data:
  Idle{slot:M.Slot<S,K,V>}
  BendvyReady{slot:M.Slot<S,K,V>,transition:M.Transition<V>,skipSame:Bool}

def invoked(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,ordinal:U32,result:Sys.RunResult<S,C,R,E,Invocation<V>,String,Unit,runner>) -> Entry<S,C,R,E,V,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(Entry{ordinal,registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(Entry{ordinal,registry},Sys.Failed{world,"HandlerRegistrationRejected"})
def invoke_phase(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entry:Entry<S,C,R,E,V,runner>,world:W.World<S,C,R,E>,phase:Phase,from:V,to:V) -> Entry<S,C,R,E,V,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match entry:
    case Entry{+ordinal,registry}:invoked(~S,~C,~R,~E,~V,~runner,ordinal,Sys.run(~S,~C,~R,~E,~Invocation<V>,~String,~Unit,~runner,registry,world,Invocation{phase,ordinal,from,to}))
def invoke_initial(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entry:Entry<S,C,R,E,V,runner>,world:W.World<S,C,R,E>,to:V) -> Entry<S,C,R,E,V,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match entry:
    case Entry{+ordinal,registry}:invoked(~S,~C,~R,~E,~V,~runner,ordinal,Sys.run(~S,~C,~R,~E,~Invocation<V>,~String,~Unit,~runner,registry,world,InitialEnter{ordinal,to}))
def phase_result(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,result:Engine.PhaseResult<W.World<S,C,R,E>,Entry<S,C,R,E,V,runner>>) -> PhaseResult<S,C,R,E,V,runner>:
  match result:
    case Engine.Complete{entries,world}:Complete{entries,world}
    case Engine.Failed{entries,world,error}:Failed{entries,world,error}
def handler_result(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,result:Engine.HandlerResult<W.World<S,C,R,E>,Entry<S,C,R,E,V,runner>,Phase>) -> HandlerResult<S,C,R,E,V,runner>:
  match result:
    case Engine.Completed{Engine.Owners{exit,transition,enter},world}:Completed{Owners{exit,transition,enter},world}
    case Engine.Stopped{Engine.Owners{exit,transition,enter},world,phase,error}:Stopped{Owners{exit,transition,enter},world,phase,error}
def prepared_result(~S:Data,~K:Data,~V:Data,result:Engine.Prepared<S,K,V>) -> Prepared<S,K,V>:
  match result:
    case Engine.Idle{slot}:Idle{slot}
    case Engine.BendvyReady{slot,transition,skipSame}:BendvyReady{slot,transition,skipSame}
def run_phase(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entries:List<&1,Entry<S,C,R,E,V,runner>>,world:W.World<S,C,R,E>,+phase:Phase,+from:V,+to:V,error:Maybe<&2,String>) -> PhaseResult<S,C,R,E,V,runner>:
  phase_result(~S,~C,~R,~E,~V,~runner,Engine.run_phase(~S,~W.World<S,C,R,E>,~Entry<S,C,R,E,V,runner>,~Phase,~V,~invoke_phase(~S,~C,~R,~E,~V,~runner),~invoke_initial(~S,~C,~R,~E,~V,~runner),~BendvyExit{},~Transition{},~Enter{},entries,world,phase,from,to,error))
def run_initial(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entries:List<&1,Entry<S,C,R,E,V,runner>>,world:W.World<S,C,R,E>,+to:V,error:Maybe<&2,String>) -> PhaseResult<S,C,R,E,V,runner>:
  phase_result(~S,~C,~R,~E,~V,~runner,Engine.run_initial(~S,~W.World<S,C,R,E>,~Entry<S,C,R,E,V,runner>,~Phase,~V,~invoke_phase(~S,~C,~R,~E,~V,~runner),~invoke_initial(~S,~C,~R,~E,~V,~runner),~BendvyExit{},~Transition{},~Enter{},entries,world,to,error))
def choose(~S:Data,~K:Data,~V:Data,skip:Bool,+current:V,+value:V,previous:Maybe<&2,V>,+skipSame:Bool) -> Prepared<S,K,V>:
  prepared_result(~S,~K,~V,Engine.choose(~S,~K,~V,skip,current,value,previous,skipSame))
def prepare(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,captured:M.Snapshot<V>) -> Prepared<S,K,V>:
  prepared_result(~S,~K,~V,Engine.prepare(~S,~K,~V,~same,slot,captured))
def committed(~S:Data,~K:Data,~V:Data,slot:M.Slot<S,K,V>,from:V,to:V) -> M.Slot<S,K,V>:
  Engine.committed(~S,~K,~V,slot,from,to)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~K:Data,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,owners:Owners<S,C,R,E,V,runner>,world:W.World<S,C,R,E>,captured:M.Snapshot<V>) -> HandlerResult<S,C,R,E,V,runner>:
  match owners:
    case Owners{exit,transition,enter}:handler_result(~S,~C,~R,~E,~V,~runner,Engine.run(~S,~W.World<S,C,R,E>,~Entry<S,C,R,E,V,runner>,~Phase,~V,~invoke_phase(~S,~C,~R,~E,~V,~runner),~invoke_initial(~S,~C,~R,~E,~V,~runner),~BendvyExit{},~Transition{},~Enter{},~K,~take,~put,~publish,~same,Engine.Owners{exit,transition,enter},world,captured))
