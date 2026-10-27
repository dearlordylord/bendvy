import Base
import ./world.bend as W
import ./system.bend as Sys
import ./event-runtime.bend as Ev
import ./event-runtime-legacy.bend as LegacyEv
import ./ordinary-event-declaration.bend as Event

# Register a reader with declaration-derived access metadata and an independent
# stream cursor. A Event.Write declaration returns RegisterFailed with runtime retained;
# ordinary registration refusal also retains runtime. Success returns runtime,
# reader and registry owners; no body executes while registering.
def register_reader(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,runtime:Ev.Runtime<S,C,R,E>,+declaration:Event.Declaration<S,E>,name:String) -> LegacyEv.Registered<S,C,R,E,A,Error,O,runner>:
  match declaration:
    case Event.Declaration{_,Event.Write{}}:LegacyEv.RegisterFailed{runtime}
    case Event.Declaration{+domain,Event.Read{}}:LegacyEv.register(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,name,[Event.access(~S,~E,Event.Declaration{domain,Event.Read{}})])
# Register a publishing system using declaration-derived access metadata.
# A Event.Read declaration returns RegistrationFailed with world retained; successful
# registration returns the world and registry. No event is sent by registration.
def register_writer(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,world:W.World<S,C,R,E>,+declaration:Event.Declaration<S,E>,name:String) -> Sys.RegistrationResult<S,C,R,E,A,Error,O,runner>:
  match declaration:
    case Event.Declaration{_,Event.Read{}}:Sys.RegistrationFailed{world}
    case Event.Declaration{+domain,Event.Write{}}:Sys.register(~S,~C,~R,~E,~A,~Error,~O,~runner,world,name,[Event.access(~S,~E,Event.Declaration{domain,Event.Write{}})])
