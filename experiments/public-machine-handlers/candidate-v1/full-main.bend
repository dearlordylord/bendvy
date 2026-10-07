import Base
import full-marker.bend as Mark
import full-readers.bend as R
import full-steps.bend as Step
import event-stream.bend as ES
import ../../public-machines/stream.bend as St
import ../../../src/ecs/event-runtime.bend as Ev
import full-context.bend as Ctx
import ../../../src/ecs/transaction.bend as Tx
import full-provider.bend as P
import full-actions.bend as A
import full-observe.bend as O
import handlers-tracked.bend as H
import full-locals.bend as Local
import ../../public-machines/machine.bend as M
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

type Spec is Data:
  Spec{ordinal:U32,name:String}
type Built<S:Data,-failure:H.Phase -> U32 -> Bool> is Type:
  Built{world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,entries:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>>}
def build_join(~S:Data,~failure:H.Phase -> U32 -> Bool,head:H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,built:Built<S,failure>) -> Built<S,failure>:
  match built:
    case Built{world,entries}: Built{world,head <> entries}
def registered(~S:Data,~failure:H.Phase -> U32 -> Bool,ordinal:U32,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~failure)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> Built<S,failure>) -> Built<S,failure>:
  match result:
    case Sys.RegistrationFailed{world}: Built{world,[]}
    case Sys.Registered{world,Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      build_join(~S,~failure,H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},next(Local.install(~S,world,id)))
def build(~S:Data,~failure:H.Phase -> U32 -> Bool,specs:List<&2,Spec>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> Built<S,failure>:
  match specs:
    case []: Built{world,[]}
    case Spec{ordinal,name} <> rest: registered(~S,~failure,ordinal,A.register(~S,~failure,world,name),world => build(~S,~failure,rest,world))
type Extras<S:Data> is Type:
  Extras{level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>}
type OwnedApp<S:Data,-failure:H.Phase -> U32 -> Bool> is Type:
  OwnedApp{world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,extra:Extras<S>,rows:List<&2,String>,+status:String}

def registry_view(~S:Data,~Args:Type,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> Args -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner>) -> Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner> & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def entry_view(~S:Data,~V:Data,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Invocation<V> -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,entry:H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>) -> H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner> & String:
  match entry:
    case H.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      (H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},U32.show(ordinal) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def entries_join(~S:Data,~V:Data,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Invocation<V> -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,head:H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner> & String,tail:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>) -> List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>:
  (entry,a)=head
  (rest,b)=tail
  (entry <> rest,a <> b)
def entries_view(~S:Data,~V:Data,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Invocation<V> -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,entries:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>>) -> List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>:
  match entries:
    case []: ([],[])
    case head <> rest: entries_join(~S,~V,~runner,entry_view(~S,~V,~runner,head),entries_view(~S,~V,~runner,rest))
def owners_join(~S:Data,~V:Data,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Invocation<V> -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,a:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>,b:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>,c:List<&1,H.Entry<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>> & List<&2,String>) -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner> & String:
  (exit,a)=a
  (transition,b)=b
  (enter,c)=c
  (H.Owners{exit,transition,enter},"exit=" ++ List.show(&2,String,O.text,a) ++ ";transition=" ++ List.show(&2,String,O.text,b) ++ ";enter=" ++ List.show(&2,String,O.text,c))
def owners_view(~S:Data,~V:Data,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Invocation<V> -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner>) -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,V,runner> & String:
  match owners:
    case H.Owners{exit,transition,enter}: owners_join(~S,~V,~runner,entries_view(~S,~V,~runner,exit),entries_view(~S,~V,~runner,transition),entries_view(~S,~V,~runner,enter))
def extras_join(~S:Data,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)> & String,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)> & String,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)> & String,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)> & String,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)> & String,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)> & String) -> Extras<S> & String:
  (level,levelText)=level
  (fast,fastText)=fast
  (slow,slowText)=slow
  (flaky,flakyText)=flaky
  (seed,seedText)=seed
  (queue,queueText)=queue
  (Extras{level,fast,slow,flaky,seed,queue},"level=" ++ levelText ++ ";" ++ "fast=" ++ fastText ++ ";" ++ "slow=" ++ slowText ++ ";" ++ "flaky=" ++ flakyText ++ ";" ++ "seed=" ++ seedText ++ ";" ++ "queue=" ++ queueText)
def extras_view(~S:Data,extra:Extras<S>) -> Extras<S> & String:
  match extra:
    case Extras{level,fast,slow,flaky,seed,queue}: extras_join(~S,owners_view(~S,~P.Level,~A.level_runner(~S),level),registry_view(~S,~R.Input,~R.runner(~S),fast),registry_view(~S,~R.Input,~R.runner(~S),slow),registry_view(~S,~R.Input,~R.runner(~S),flaky),registry_view(~S,~Unit,~Step.seed_runner(~S),seed),registry_view(~S,~Unit,~Step.queue_runner(~S),queue))
def checkpoint_join(~S:Data,~failure:H.Phase -> U32 -> Bool,label:String,rows:List<&2,String>,+status:String,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> & String,extra:Extras<S> & String) -> OwnedApp<S,failure>:
  (world,a)=world
  (owners,b)=owners
  (extra,c)=extra
  OwnedApp{world,owners,extra,List.append(&2,String,rows,[label ++ "|" ++ status ++ "|" ++ a ++ ";" ++ b ++ ";" ++ c]),status}
def checkpoint(~S:Data,~failure:H.Phase -> U32 -> Bool,label:String,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,extra,rows,status}: checkpoint_join(~S,~failure,label,rows,status,O.world(~S,world),owners_view(~S,~P.Flow,~A.runner(~S,~failure),owners),extras_view(~S,extra))
def registered_queue(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:queue"]
    case Sys.Registered{world,registry}: next(world,owners,Extras{H.Owners{[],[],[H.Entry{2,level}]},fast,slow,flaky,seed,registry})
def register_queue(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_queue(~S,~failure,owners,level,fast,slow,flaky,seed,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~String,~Unit,~Step.queue_runner(~S),world,"queue",["machine.Flow.next","machine.Level.next","command.spawn"]),next)
def registered_seed(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:seed"]
    case Sys.Registered{world,registry}: register_queue(~S,~failure,owners,level,fast,slow,flaky,registry,world,next)
def register_seed(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_seed(~S,~failure,owners,level,fast,slow,flaky,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~String,~Unit,~Step.seed_runner(~S),world,"seed",["command.spawn"]),next)
def registered_flaky(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:flaky"]
    case Sys.Registered{world,registry}: register_seed(~S,~failure,owners,level,fast,slow,registry,world,next)
def register_flaky(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_flaky(~S,~failure,owners,level,fast,slow,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),world,"flaky",["event.Ping.read","transition.Flow.read","transition.Level.read"]),next)
def registered_slow(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:slow"]
    case Sys.Registered{world,registry}: register_flaky(~S,~failure,owners,level,fast,registry,world,next)
def register_slow(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_slow(~S,~failure,owners,level,fast,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),world,"slow",["event.Ping.read","transition.Flow.read","transition.Level.read"]),next)
def registered_fast(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:fast"]
    case Sys.Registered{world,registry}: register_slow(~S,~failure,owners,level,registry,world,next)
def register_fast(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_fast(~S,~failure,owners,level,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),world,"fast",["event.Ping.read","transition.Flow.read","transition.Level.read"]),next)
def registered_level_owner(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: register_fast(~S,~failure,owners,Sys.Registry{ns,id,name,access,cursor},Local.install(~S,world,id),next)
def registered_level(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,result:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Level>,String,Unit,A.level_runner(~S)>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match result:
    case Sys.RegistrationFailed{_}: ["REGISTRATION_FAILED:level"]
    case Sys.Registered{world,registry}: registered_level_owner(~S,~failure,owners,world,registry,next)
def register_level(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  registered_level(~S,~failure,owners,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~H.Invocation<P.Level>,~String,~Unit,~A.level_runner(~S),world,"level0",["component.Cells.write","resource.Owned.write","event.Ping.read","event.Ping.emit","machine.Flow.read","machine.Level.read","machine.Flow.next","transition.Flow.read","transition.Level.read"]),next)
def assembled(~S:Data,~failure:H.Phase -> U32 -> Bool,built:Built<S,failure>,next:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> -> Extras<S> -> List<&2,String>) -> List<&2,String>:
  match built:
    case Built{world,a <> b <> c <> d <> e <> f <> []}: register_level(~S,~failure,H.Owners{[a,b],[c,d],[e,f]},world,next)
    case Built{_,_}: ["FLOW_REGISTRATION_FAILED"]

def stream_values(stream:ES.Stream<P.Ping>) -> List<&2,P.Ping>:
  match stream:
    case ES.Stream{batches,_,_,_}: Ev.values(~P.Ping,batches)
def sync_events(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,+ping,attempts,deliveries,phase,position,enabled}},_,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}},stream_values(ping),commands,registrations,nextSystem,clock}
def begin_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,extra,rows,_}: OwnedApp{sync_events(~S,P.frame(~S,world)),owners,extra,rows,"ok"}
def phase_marker_result(~S:Data,~failure:H.Phase -> U32 -> Bool,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,result:Mark.MarkerResult<S,failure>) -> OwnedApp<S,failure>:
  match result:
    case Mark.MarkerResult{world,owners,level,status}: OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,status}
def marker(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}:
      phase_marker_result(~S,~failure,fast,slow,flaky,seed,queue,rows,Mark.marker(~S,~failure,owners,level,world))
def deferred(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,extra,rows,_}: OwnedApp{P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,world)),owners,extra,rows,"ok"}

def run_outcome(~S:Data,~Args:Type,~Out:Type,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> Args -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner>,outcome:Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,next:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> String -> Out) -> Out:
  match outcome:
    case Sys.Succeeded{world,_}: next(registry,world,"ok")
    case Sys.Failed{world,error}: next(registry,world,error)
def run_result(~S:Data,~Args:Type,~Out:Type,~runner:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> Args -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>,result:Sys.RunResult<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner>,next:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Args,String,Unit,runner> -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> -> String -> Out) -> Out:
  match result:
    case Sys.Completed{registry,outcome}: run_outcome(~S,~Args,~Out,~runner,registry,outcome,next)
    case Sys.RegistrationRejected{registry,world,_}: next(registry,world,"RegistrationRejected")
def done_fast(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,status:String) -> OwnedApp<S,failure>:
  OwnedApp{world,owners,Extras{level,registry,slow,flaky,seed,queue},rows,status}
def run_fast_registry(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,fail:Bool) -> OwnedApp<S,failure>:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: run_result(~S,~R.Input,~OwnedApp<S,failure>,~R.runner(~S),Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),Sys.Registry{ns,id,name,access,cursor},world,R.Input{id,name,fail}),registry => world => status => done_fast(~S,~failure,owners,level,slow,flaky,seed,queue,rows,registry,world,status))
def run_fast(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>,fail:Bool) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}: run_fast_registry(~S,~failure,owners,level,slow,flaky,seed,queue,rows,fast,world,fail)
def done_slow(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,status:String) -> OwnedApp<S,failure>:
  OwnedApp{world,owners,Extras{level,fast,registry,flaky,seed,queue},rows,status}
def run_slow_registry(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,fail:Bool) -> OwnedApp<S,failure>:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: run_result(~S,~R.Input,~OwnedApp<S,failure>,~R.runner(~S),Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),Sys.Registry{ns,id,name,access,cursor},world,R.Input{id,name,fail}),registry => world => status => done_slow(~S,~failure,owners,level,fast,flaky,seed,queue,rows,registry,world,status))
def run_slow(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>,fail:Bool) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}: run_slow_registry(~S,~failure,owners,level,fast,flaky,seed,queue,rows,slow,world,fail)
def done_flaky(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,status:String) -> OwnedApp<S,failure>:
  OwnedApp{world,owners,Extras{level,fast,slow,registry,seed,queue},rows,status}
def run_flaky_registry(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,fail:Bool) -> OwnedApp<S,failure>:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: run_result(~S,~R.Input,~OwnedApp<S,failure>,~R.runner(~S),Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~R.Input,~String,~Unit,~R.runner(~S),Sys.Registry{ns,id,name,access,cursor},world,R.Input{id,name,fail}),registry => world => status => done_flaky(~S,~failure,owners,level,fast,slow,seed,queue,rows,registry,world,status))
def run_flaky(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>,fail:Bool) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}: run_flaky_registry(~S,~failure,owners,level,fast,slow,seed,queue,rows,flaky,world,fail)
def done_seed(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,status:String) -> OwnedApp<S,failure>:
  OwnedApp{world,owners,Extras{level,fast,slow,flaky,registry,queue},rows,status}
def run_seed_registry(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,queue:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,_:Bool) -> OwnedApp<S,failure>:
  run_result(~S,~Unit,~OwnedApp<S,failure>,~Step.seed_runner(~S),Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~String,~Unit,~Step.seed_runner(~S),registry,world,Unit{}),registry => world => status => done_seed(~S,~failure,owners,level,fast,slow,flaky,queue,rows,registry,world,status))
def run_seed(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>,fail:Bool) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}: run_seed_registry(~S,~failure,owners,level,fast,slow,flaky,queue,rows,seed,world,fail)
def done_queue(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,status:String) -> OwnedApp<S,failure>:
  OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,registry},rows,status}
def run_queue_registry(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,fast:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,slow:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,flaky:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,R.Input,String,Unit,R.runner(~S)>,seed:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.seed_runner(~S)>,rows:List<&2,String>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,Unit,String,Unit,Step.queue_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,_:Bool) -> OwnedApp<S,failure>:
  run_result(~S,~Unit,~OwnedApp<S,failure>,~Step.queue_runner(~S),Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~Unit,~String,~Unit,~Step.queue_runner(~S),registry,world,Unit{}),registry => world => status => done_queue(~S,~failure,owners,level,fast,slow,flaky,seed,rows,registry,world,status))
def run_queue(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>,fail:Bool) -> OwnedApp<S,failure>:
  match app:
    case OwnedApp{world,owners,Extras{level,fast,slow,flaky,seed,queue},rows,_}: run_queue_registry(~S,~failure,owners,level,fast,slow,flaky,seed,rows,queue,world,fail)

def initial_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"initial",run_slow(~S,~failure,run_fast(~S,~failure,deferred(~S,~failure,run_seed(~S,~failure,begin_frame(~S,~failure,app),False{})),False{}),False{}))
def queued_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"queued",run_queue(~S,~failure,begin_frame(~S,~failure,app),False{}))
def failure_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"handler-failure",marker(~S,~failure,begin_frame(~S,~failure,app)))
def reader_failure_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"reader-failure",run_flaky(~S,~failure,begin_frame(~S,~failure,app),True{}))
def retry_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"handler-retry",marker(~S,~failure,begin_frame(~S,~failure,app)))
def reader_retry_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"reader-retry",run_flaky(~S,~failure,begin_frame(~S,~failure,app),False{}))
def late_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"later-marker",run_slow(~S,~failure,run_fast(~S,~failure,marker(~S,~failure,begin_frame(~S,~failure,app)),False{}),False{}))
def repeated_frame(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> OwnedApp<S,failure>:
  checkpoint(~S,~failure,"repeat-readers",run_slow(~S,~failure,run_fast(~S,~failure,begin_frame(~S,~failure,app),False{}),False{}))
def rendered(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> List<&2,String>:
  match app:
    case OwnedApp{_,_,_,rows,_}: rows

def missing(present:Bool,name:String,rest:List<&2,String>) -> List<&2,String>:
  match present:
    case True{}: rest
    case False{}: name <> rest
def slot_present(~S:Data,~K:Data,~V:Data,slot:M.Slot<S,K,V>) -> Bool:
  match slot:
    case M.Missing{}: False{}
    case _: True{}
def required(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & List<&2,String>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{None{},+flow,+level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{None{},flow,level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},missing(slot_present(~S,~P.FlowToken,~P.Flow,flow),"stateMachine.Flow",missing(slot_present(~S,~P.LevelToken,~P.Level,level),"stateMachine.Level",["resource.Owned"])))
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{Some{owned},+flow,+level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{Some{owned},flow,level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},missing(slot_present(~S,~P.FlowToken,~P.Flow,flow),"stateMachine.Flow",missing(slot_present(~S,~P.LevelToken,~P.Level,level),"stateMachine.Level",[])))
type Admission<S:Data,-failure:H.Phase -> U32 -> Bool> is Type:
  Admitted{app:OwnedApp<S,failure>}
  Refused{app:OwnedApp<S,failure>,requirements:List<&2,String>}
def admitted(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,extra:Extras<S>,rows:List<&2,String>,status:String,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & List<&2,String>) -> Admission<S,failure>:
  match pair:
    case (world,[]): Admitted{OwnedApp{world,owners,extra,rows,status}}
    case (world,requirements): Refused{OwnedApp{world,owners,extra,rows,"MissingRuntimeRequirements"},requirements}
def enter(~S:Data,~failure:H.Phase -> U32 -> Bool,app:OwnedApp<S,failure>) -> Admission<S,failure>:
  match app:
    case OwnedApp{world,owners,extra,rows,status}: admitted(~S,~failure,owners,extra,rows,status,required(~S,world))
def admission_frames(~S:Data,~failure:H.Phase -> U32 -> Bool,result:Admission<S,failure>) -> List<&2,String>:
  match result:
    case Admitted{app}: rendered(~S,~failure,repeated_frame(~S,~failure,late_frame(~S,~failure,reader_retry_frame(~S,~failure,retry_frame(~S,~failure,reader_failure_frame(~S,~failure,failure_frame(~S,~failure,queued_frame(~S,~failure,initial_frame(~S,~failure,app)))))))))
    case Refused{_,requirements}: ["MissingRuntimeRequirements:" ++ List.show(&2,String,O.text,requirements)]
def run_initialized(~S:Data,~failure:H.Phase -> U32 -> Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,extra:Extras<S>) -> List<&2,String>:
  admission_frames(~S,~failure,enter(~S,~failure,OwnedApp{world,owners,extra,[],"ok"}))
def created(~S:Data,~failure:H.Phase -> U32 -> Bool,result:W.Creation<S,P.Store<S>,P.Resources<S>,P.Ping>) -> List<&2,String>:
  match result:
    case W.Created{_,world}: assembled(~S,~failure,build(~S,~failure,[Spec{0,"exit0"},Spec{1,"exit1"},Spec{0,"transition0"},Spec{1,"transition1"},Spec{0,"enter0"},Spec{1,"enter1"}],world),world => owners => extra => run_initialized(~S,~failure,world,owners,extra))
    case W.CreateRejected{_,_}: ["CREATE_REJECTED"]
def run(~S:Data,~failure:H.Phase -> U32 -> Bool) -> List<&2,String>:
  created(~S,~failure,W.create(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~(u => P.empty_store(~S,u)),W.factory(),P.initial_resources(~S)))

type MissingEvidence is Data:
  MissingEvidence{before:String,after:String,requirements:List<&2,String>,status:String}
def missing_snapshot(~S:Data,~failure:H.Phase -> U32 -> Bool,before:String,requirements:List<&2,String>,status:String,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> & String,extra:Extras<S> & String) -> MissingEvidence:
  (_,a)=world
  (_,b)=owners
  (_,c)=extra
  MissingEvidence{before,a ++ ";" ++ b ++ ";" ++ c,requirements,status}
def missing_after(~S:Data,~failure:H.Phase -> U32 -> Bool,before:String,requirements:List<&2,String>,status:String,app:OwnedApp<S,failure>) -> MissingEvidence:
  match app:
    case OwnedApp{world,owners,extra,_,_}: missing_snapshot(~S,~failure,before,requirements,status,O.world(~S,world),owners_view(~S,~P.Flow,~A.runner(~S,~failure),owners),extras_view(~S,extra))
def missing_seen(~S:Data,~failure:H.Phase -> U32 -> Bool,before:String,result:Admission<S,failure>) -> MissingEvidence:
  match result:
    case Admitted{app}: missing_after(~S,~failure,before,[],"UNEXPECTED_ADMISSION",app)
    case Refused{app,requirements}: missing_after(~S,~failure,before,requirements,"MissingRuntimeRequirements",app)
def missing_before(~S:Data,~failure:H.Phase -> U32 -> Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)> & String,extra:Extras<S> & String) -> MissingEvidence:
  (world,a)=world
  (owners,b)=owners
  (extra,c)=extra
  missing_seen(~S,~failure,a ++ ";" ++ b ++ ";" ++ c,enter(~S,~failure,OwnedApp{world,owners,extra,[],"ok"}))
def missing_render(value:MissingEvidence) -> List<&2,String>:
  match value:
    case MissingEvidence{before,after,requirements,status}: ["before|" ++ before,"after|" ++ after,"requirements|" ++ List.show(&2,String,O.text,requirements),"status|" ++ status]
def missing_initialized(~S:Data,~failure:H.Phase -> U32 -> Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,extra:Extras<S>) -> List<&2,String>:
  missing_render(missing_before(~S,~failure,O.world(~S,world),owners_view(~S,~P.Flow,~A.runner(~S,~failure),owners),extras_view(~S,extra)))
def missing_resources(~S:Data) -> P.Resources<S>:
  P.Resources{None{},M.Present{P.Boot{},M.NoPending{},None{},False{}},M.Missing{},St.empty(~P.Flow),St.empty(~P.Level),0n,0n,[],P.Aux{[],ES.empty(~P.Ping),[],[],0,0,False{}}}
def missing_created(~S:Data,~failure:H.Phase -> U32 -> Bool,result:W.Creation<S,P.Store<S>,P.Resources<S>,P.Ping>) -> List<&2,String>:
  match result:
    case W.Created{_,world}: assembled(~S,~failure,build(~S,~failure,[Spec{0,"exit0"},Spec{1,"exit1"},Spec{0,"transition0"},Spec{1,"transition1"},Spec{0,"enter0"},Spec{1,"enter1"}],world),world => owners => extra => missing_initialized(~S,~failure,world,owners,extra))
    case W.CreateRejected{_,_}: ["CREATE_REJECTED"]
def run_missing(~S:Data,~failure:H.Phase -> U32 -> Bool) -> List<&2,String>:
  missing_created(~S,~failure,W.create(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~(u => P.empty_store(~S,u)),W.factory(),missing_resources(~S)))

def exit0_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),1),U32.is_eq(ordinal,0))
def schemaA_exit0() -> List<&2,String>:
  run(~P.SchemaA,~exit0_failure)
def schemaB_exit0() -> List<&2,String>:
  run(~P.SchemaB,~exit0_failure)

def exit1_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),1),U32.is_eq(ordinal,1))
def schemaA_exit1() -> List<&2,String>:
  run(~P.SchemaA,~exit1_failure)
def schemaB_exit1() -> List<&2,String>:
  run(~P.SchemaB,~exit1_failure)

def transition0_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),2),U32.is_eq(ordinal,0))
def schemaA_transition0() -> List<&2,String>:
  run(~P.SchemaA,~transition0_failure)
def schemaB_transition0() -> List<&2,String>:
  run(~P.SchemaB,~transition0_failure)

def transition1_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),2),U32.is_eq(ordinal,1))
def schemaA_transition1() -> List<&2,String>:
  run(~P.SchemaA,~transition1_failure)
def schemaB_transition1() -> List<&2,String>:
  run(~P.SchemaB,~transition1_failure)

def enter0_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),3),U32.is_eq(ordinal,0))
def schemaA_enter0() -> List<&2,String>:
  run(~P.SchemaA,~enter0_failure)
def schemaB_enter0() -> List<&2,String>:
  run(~P.SchemaB,~enter0_failure)

def enter1_failure(phase:H.Phase,ordinal:U32) -> Bool:
  Bool.and(U32.is_eq(A.phase_code(phase),3),U32.is_eq(ordinal,1))
def schemaA_enter1() -> List<&2,String>:
  run(~P.SchemaA,~enter1_failure)
def schemaB_enter1() -> List<&2,String>:
  run(~P.SchemaB,~enter1_failure)

def schemaA_exit0_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~exit0_failure)

def schemaA_exit1_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~exit1_failure)

def schemaA_transition0_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~transition0_failure)

def schemaA_transition1_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~transition1_failure)

def schemaA_enter0_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~enter0_failure)

def schemaA_enter1_missing() -> List<&2,String>:
  run_missing(~P.SchemaA,~enter1_failure)

def schemaB_exit0_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~exit0_failure)

def schemaB_exit1_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~exit1_failure)

def schemaB_transition0_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~transition0_failure)

def schemaB_transition1_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~transition1_failure)

def schemaB_enter0_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~enter0_failure)

def schemaB_enter1_missing() -> List<&2,String>:
  run_missing(~P.SchemaB,~enter1_failure)

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("schemaA_exit0|" ++ List.show(&2,String,O.text,schemaA_exit0()))
    IO.print("schemaA_exit0_missing|" ++ List.show(&2,String,O.text,schemaA_exit0_missing()))
    IO.print("schemaA_exit1|" ++ List.show(&2,String,O.text,schemaA_exit1()))
    IO.print("schemaA_exit1_missing|" ++ List.show(&2,String,O.text,schemaA_exit1_missing()))
    IO.print("schemaA_transition0|" ++ List.show(&2,String,O.text,schemaA_transition0()))
    IO.print("schemaA_transition0_missing|" ++ List.show(&2,String,O.text,schemaA_transition0_missing()))
    IO.print("schemaA_transition1|" ++ List.show(&2,String,O.text,schemaA_transition1()))
    IO.print("schemaA_transition1_missing|" ++ List.show(&2,String,O.text,schemaA_transition1_missing()))
    IO.print("schemaA_enter0|" ++ List.show(&2,String,O.text,schemaA_enter0()))
    IO.print("schemaA_enter0_missing|" ++ List.show(&2,String,O.text,schemaA_enter0_missing()))
    IO.print("schemaA_enter1|" ++ List.show(&2,String,O.text,schemaA_enter1()))
    IO.print("schemaA_enter1_missing|" ++ List.show(&2,String,O.text,schemaA_enter1_missing()))
    IO.print("schemaB_exit0|" ++ List.show(&2,String,O.text,schemaB_exit0()))
    IO.print("schemaB_exit0_missing|" ++ List.show(&2,String,O.text,schemaB_exit0_missing()))
    IO.print("schemaB_exit1|" ++ List.show(&2,String,O.text,schemaB_exit1()))
    IO.print("schemaB_exit1_missing|" ++ List.show(&2,String,O.text,schemaB_exit1_missing()))
    IO.print("schemaB_transition0|" ++ List.show(&2,String,O.text,schemaB_transition0()))
    IO.print("schemaB_transition0_missing|" ++ List.show(&2,String,O.text,schemaB_transition0_missing()))
    IO.print("schemaB_transition1|" ++ List.show(&2,String,O.text,schemaB_transition1()))
    IO.print("schemaB_transition1_missing|" ++ List.show(&2,String,O.text,schemaB_transition1_missing()))
    IO.print("schemaB_enter0|" ++ List.show(&2,String,O.text,schemaB_enter0()))
    IO.print("schemaB_enter0_missing|" ++ List.show(&2,String,O.text,schemaB_enter0_missing()))
    IO.print("schemaB_enter1|" ++ List.show(&2,String,O.text,schemaB_enter1()))
    IO.print("schemaB_enter1_missing|" ++ List.show(&2,String,O.text,schemaB_enter1_missing()))
