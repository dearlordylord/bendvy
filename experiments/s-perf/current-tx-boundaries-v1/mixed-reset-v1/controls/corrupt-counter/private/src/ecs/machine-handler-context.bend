import Base
import world.bend as W
import machine.bend as M
import system.bend as Sys
import execution-context.bend as Ctx
import trace-facts.bend as Facts
import machine-handlers.bend as H
import machine-handler-engine.bend as Engine

def phase(value:H.Phase) -> Facts.HandlerPhase:
  match value:
    case H.Exit{}:Facts.ExitPhase{}
    case H.Transition{}:Facts.TransitionPhase{}
    case H.Enter{}:Facts.EnterPhase{}
def record(state:Facts.State,namespace:U32,id:U32,name:String,ordinal:U32,phase:Facts.HandlerPhase,result:Facts.FactResult) -> Facts.State:
  match state phase:
    case Facts.Off{} _:Facts.Off{}
    case Facts.On{facts} Facts.InitialEnterPhase{}:Facts.On{Facts.HandlerFact{namespace,id,name,ordinal,Facts.InitialEnterPhase{},Facts.UnavailableValue{},Facts.OpaqueValue{},result} <> facts}
    case Facts.On{facts} phase:Facts.On{Facts.HandlerFact{namespace,id,name,ordinal,phase,Facts.OpaqueValue{},Facts.OpaqueValue{},result} <> facts}
def outcome(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+ordinal:U32,phase:Facts.HandlerPhase,registry:Sys.Registry<S,C,R,E,H.Invocation<V>,String,Unit,runner>,trace:Facts.State,result:Sys.Outcome<W.World<S,C,R,E>,String,Unit>) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match registry result:
    case Sys.Registry{+namespace,+id,+name,access,cursor} Sys.Succeeded{world,output}:(H.Entry{ordinal,Sys.Registry{namespace,id,name,access,cursor}},Sys.Succeeded{Ctx.Context{world,record(trace,namespace,id,name,ordinal,phase,Facts.Applied{})},output})
    case Sys.Registry{+namespace,+id,+name,access,cursor} Sys.Failed{world,+error}:(H.Entry{ordinal,Sys.Registry{namespace,id,name,access,cursor}},Sys.Failed{Ctx.Context{world,record(trace,namespace,id,name,ordinal,phase,Facts.Refused{error})},error})
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,ordinal:U32,phase:Facts.HandlerPhase,result:Sys.RunResult<S,C,R,E,H.Invocation<V>,String,Unit,runner> & Facts.State) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match result:
    case (Sys.Completed{registry,value},trace):outcome(~S,~C,~R,~E,~V,~runner,ordinal,phase,registry,trace,value)
    case (Sys.RegistrationRejected{registry,world,_},trace):outcome(~S,~C,~R,~E,~V,~runner,ordinal,phase,registry,trace,Sys.Failed{world,"HandlerRegistrationRejected"})
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~observed:Facts.State -> W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State,+ordinal:U32,+phase:Facts.HandlerPhase,registry:Sys.Registry<S,C,R,E,H.Invocation<V>,String,Unit,runner>,context:Ctx.Context<W.World<S,C,R,E>>,invocation:H.Invocation<V>) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match registry context:
    case Sys.Registry{+namespace,+id,+name,access,cursor} Ctx.Context{world,trace}:returned(~S,~C,~R,~E,~V,~runner,ordinal,phase,Sys.run_observed(~S,~C,~R,~E,~H.Invocation<V>,~String,~Unit,~runner,~observed,Sys.Registry{namespace,id,name,access,cursor},record(trace,namespace,id,name,ordinal,phase,Facts.Attempted{}),world,invocation))
def invoke_kind(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~observed:Facts.State -> W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State,entry:H.Entry<S,C,R,E,V,runner>,context:Ctx.Context<W.World<S,C,R,E>>,tracePhase:Facts.HandlerPhase,value:H.Phase,from:V,to:V) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match entry:
    case H.Entry{+ordinal,registry}:registered(~S,~C,~R,~E,~V,~runner,~observed,ordinal,tracePhase,registry,context,H.Invocation{value,ordinal,from,to})
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~observed:Facts.State -> W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State,entry:H.Entry<S,C,R,E,V,runner>,context:Ctx.Context<W.World<S,C,R,E>>,value:H.Phase,from:V,to:V) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match value:
    case H.Exit{}:invoke_kind(~S,~C,~R,~E,~V,~runner,~observed,entry,context,Facts.ExitPhase{},H.Exit{},from,to)
    case H.Transition{}:invoke_kind(~S,~C,~R,~E,~V,~runner,~observed,entry,context,Facts.TransitionPhase{},H.Transition{},from,to)
    case H.Enter{}:invoke_kind(~S,~C,~R,~E,~V,~runner,~observed,entry,context,Facts.EnterPhase{},H.Enter{},from,to)
def initial(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~observed:Facts.State -> W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State,entry:H.Entry<S,C,R,E,V,runner>,context:Ctx.Context<W.World<S,C,R,E>>,to:V) -> H.Entry<S,C,R,E,V,runner> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,String,Unit>:
  match entry:
    case H.Entry{+ordinal,registry}:registered(~S,~C,~R,~E,~V,~runner,~observed,ordinal,Facts.InitialEnterPhase{},registry,context,H.InitialEnter{ordinal,to})
def taken(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~K:Data,trace:Facts.State,result:W.World<S,C,R,E> & M.Slot<S,K,V>) -> Ctx.Context<W.World<S,C,R,E>> & M.Slot<S,K,V>:
  match result:
    case (world,slot):(Ctx.Context{world,trace},slot)
def context_take(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~K:Data,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,context:Ctx.Context<W.World<S,C,R,E>>) -> Ctx.Context<W.World<S,C,R,E>> & M.Slot<S,K,V>:
  match context:
    case Ctx.Context{world,trace}:taken(~S,~C,~R,~E,~V,~runner,~K,trace,take(world))
def context_put(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~K:Data,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,context:Ctx.Context<W.World<S,C,R,E>>,slot:M.Slot<S,K,V>) -> Ctx.Context<W.World<S,C,R,E>>:
  match context:
    case Ctx.Context{world,trace}:Ctx.Context{put(world,slot),trace}
def transition_record(state:Facts.State,name:String) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case Facts.On{facts}:Facts.On{Facts.TransitionFact{name,Facts.OpaqueValue{},Facts.OpaqueValue{},Facts.Applied{}} <> facts}
def context_publish(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~name:String,context:Ctx.Context<W.World<S,C,R,E>>,transition:M.Transition<V>) -> Ctx.Context<W.World<S,C,R,E>>:
  match context:
    case Ctx.Context{world,trace}:Ctx.Context{publish(world,transition),transition_record(trace,name)}
def run(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~observed:Facts.State -> W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit> & Facts.State,~K:Data,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~name:String,owners:H.Owners<S,C,R,E,V,runner>,context:Ctx.Context<W.World<S,C,R,E>>,captured:M.Snapshot<V>) -> Engine.HandlerResult<Ctx.Context<W.World<S,C,R,E>>,H.Entry<S,C,R,E,V,runner>,H.Phase>:
  match owners:
    case H.Owners{exit,transition,enter}:Engine.run(~S,~Ctx.Context<W.World<S,C,R,E>>,~H.Entry<S,C,R,E,V,runner>,~H.Phase,~V,~invoke(~S,~C,~R,~E,~V,~runner,~observed),~initial(~S,~C,~R,~E,~V,~runner,~observed),~H.Exit{},~H.Transition{},~H.Enter{},~K,~context_take(~S,~C,~R,~E,~V,~runner,~K,~take),~context_put(~S,~C,~R,~E,~V,~runner,~K,~put),~context_publish(~S,~C,~R,~E,~V,~runner,~publish,~name),~same,Engine.Owners{exit,transition,enter},context,captured)
