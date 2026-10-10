import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev

# The ordinary typed event domain is supplied once to grants and registration.
type Domain<S:Data,E:Data> is Data:
  Domain{key:String}
type Mode is Data:
  Read{}
  Write{}
type Declaration<S:Data,E:Data> is Data:
  Declaration{domain:Domain<S,E>,mode:Mode}
def domain(~S:Data,~E:Data,key:String) -> Domain<S,E>:Domain{key}
def read(~S:Data,~E:Data,domain:Domain<S,E>) -> Declaration<S,E>:Declaration{domain,Read{}}
def write(~S:Data,~E:Data,domain:Domain<S,E>) -> Declaration<S,E>:Declaration{domain,Write{}}
def access(~S:Data,~E:Data,declaration:Declaration<S,E>) -> String:
  match declaration:
    case Declaration{Domain{key},Read{}}:String.concat([key,":read"])
    case Declaration{Domain{key},Write{}}:String.concat([key,":write"])
def reading(~S:Data,~E:Data,~H:Type,~observe:H -> H & Ev.Reading<E>,declaration:Declaration<S,E>) -> Maybe<&2,Ev.ReadAccess<H,E,observe>>:
  match declaration:
    case Declaration{_,Read{}}:Some{Ev.ReadAccess{}}
    case Declaration{_,Write{}}:None{}
def publishing(~S:Data,~E:Data,~H:Type,~publish:H -> E -> H,declaration:Declaration<S,E>) -> Maybe<&2,Ev.WriteAccess<H,E,publish>>:
  match declaration:
    case Declaration{_,Write{}}:Some{Ev.WriteAccess{}}
    case Declaration{_,Read{}}:None{}
def register_reader(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,runtime:Ev.Runtime<S,C,R,E>,+declaration:Declaration<S,E>,name:String) -> Ev.Registered<S,C,R,E,A,Error,O,runner>:
  match declaration:
    case Declaration{_,Write{}}:Ev.RegisterFailed{runtime}
    case Declaration{+domain,Read{}}:Ev.register(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,name,[access(~S,~E,Declaration{domain,Read{}})])
def register_writer(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,world:W.World<S,C,R,E>,+declaration:Declaration<S,E>,name:String) -> Sys.RegistrationResult<S,C,R,E,A,Error,O,runner>:
  match declaration:
    case Declaration{_,Read{}}:Sys.RegistrationFailed{world}
    case Declaration{+domain,Write{}}:Sys.register(~S,~C,~R,~E,~A,~Error,~O,~runner,world,name,[access(~S,~E,Declaration{domain,Write{}})])

def read_grant(~S:Data,~E:Data,~H:Type,~observe:H -> H & Ev.Reading<E>,_:Domain<S,E>) -> Ev.ReadAccess<H,E,observe>:Ev.ReadAccess{}
def write_grant(~S:Data,~E:Data,~H:Type,~publish:H -> E -> H,_:Domain<S,E>) -> Ev.WriteAccess<H,E,publish>:Ev.WriteAccess{}
