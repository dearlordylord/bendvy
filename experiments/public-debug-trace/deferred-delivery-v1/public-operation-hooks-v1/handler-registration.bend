import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/machine-handlers.bend as H
def registered_enter(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,exit:H.Entry<S,C,R,E,V,runner>,transition:H.Entry<S,C,R,E,V,runner>,result:Sys.RegistrationResult<S,C,R,E,H.Invocation<V>,String,Unit,runner>) -> Maybe<&1,W.World<S,C,R,E> & H.Owners<S,C,R,E,V,runner>>:
  match result:
    case Sys.Registered{world,registry}:Some{(world,H.Owners{[exit],[transition],[H.Entry{2,registry}]})}
    case Sys.RegistrationFailed{_}:None{}
def registered_transition(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,exit:H.Entry<S,C,R,E,V,runner>,access:List<&2,String>,result:Sys.RegistrationResult<S,C,R,E,H.Invocation<V>,String,Unit,runner>) -> Maybe<&1,W.World<S,C,R,E> & H.Owners<S,C,R,E,V,runner>>:
  match result:
    case Sys.Registered{world,registry}:registered_enter(~S,~C,~R,~E,~V,~runner,exit,H.Entry{1,registry},Sys.register(~S,~C,~R,~E,~H.Invocation<V>,~String,~Unit,~runner,world,"enter",access))
    case Sys.RegistrationFailed{_}:None{}
def registered_exit(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+access:List<&2,String>,result:Sys.RegistrationResult<S,C,R,E,H.Invocation<V>,String,Unit,runner>) -> Maybe<&1,W.World<S,C,R,E> & H.Owners<S,C,R,E,V,runner>>:
  match result:
    case Sys.Registered{world,registry}:registered_transition(~S,~C,~R,~E,~V,~runner,H.Entry{0,registry},access,Sys.register(~S,~C,~R,~E,~H.Invocation<V>,~String,~Unit,~runner,world,"transition",access))
    case Sys.RegistrationFailed{_}:None{}
def register(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,world:W.World<S,C,R,E>,+access:List<&2,String>) -> Maybe<&1,W.World<S,C,R,E> & H.Owners<S,C,R,E,V,runner>>:registered_exit(~S,~C,~R,~E,~V,~runner,access,Sys.register(~S,~C,~R,~E,~H.Invocation<V>,~String,~Unit,~runner,world,"exit",access))
