import Base
import full-provider.bend as P
import full-actions.bend as A
import full-main.bend as Main
import full-observe.bend as O
import full-locals.bend as Local
import handlers-tracked.bend as H
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

def args_view(args:H.Invocation<P.Flow>) -> String:
  match args:
    case H.Invocation{phase,ordinal,from,to}: U32.show(A.phase_code(phase)) ++ ":" ++ U32.show(ordinal) ++ ":" ++ O.flow(from) ++ ">" ++ O.flow(to)
# Each tuple observer is consumed through a parameter scrutinee, as Bend requires.
def rejected_source(~S:Data,before:String,after:String,sourceOwner:String,targetOwner:String,args:H.Invocation<P.Flow>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String) -> List<&2,String>:
  (_,worldView)=pair
  ["rejected",before,after,sourceOwner,targetOwner,worldView,args_view(args)]
def rejected_target_registry(~S:Data,before:String,after:String,sourceOwner:String,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,args:H.Invocation<P.Flow>,pair:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)> & String) -> List<&2,String>:
  (_,targetOwner)=pair
  rejected_source(~S,before,after,sourceOwner,targetOwner,args,O.world(~S,source))
def rejected_source_registry(~S:Data,before:String,after:String,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,targetRegistry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,args:H.Invocation<P.Flow>,pair:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)> & String) -> List<&2,String>:
  (_,sourceOwner)=pair
  rejected_target_registry(~S,before,after,sourceOwner,source,args,Main.registry_view(~S,~H.Invocation<P.Flow>,~A.runner(~S,~A.success),targetRegistry))
def rejected_world(~S:Data,before:String,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,targetRegistry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,args:H.Invocation<P.Flow>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String) -> List<&2,String>:
  (_,after)=pair
  rejected_source_registry(~S,before,after,source,targetRegistry,args,Main.registry_view(~S,~H.Invocation<P.Flow>,~A.runner(~S,~A.success),registry))
def result(~S:Data,before:String,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,targetRegistry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,outcome:Sys.RunResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>) -> List<&2,String>:
  match outcome:
    case Sys.RegistrationRejected{registry,world,args}: rejected_world(~S,before,source,registry,targetRegistry,args,O.world(~S,world))
    case Sys.Completed{_,_}: ["UNEXPECTED_CALLBACK_EXECUTION"]
def target_observed(~S:Data,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,targetRegistry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & String) -> List<&2,String>:
  (world,before)=pair
  result(~S,before,source,targetRegistry,Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~H.Invocation<P.Flow>,~String,~Unit,~A.runner(~S,~A.success),registry,world,H.Invocation{H.Exit{},0,P.Boot{},P.Play{}}))
def target_registered(~S:Data,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,registered:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>) -> List<&2,String>:
  match registered:
    case Sys.RegistrationFailed{_}: ["TARGET_REGISTRATION_FAILED"]
    case Sys.Registered{world,targetRegistry}:
      target_observed(~S,source,registry,targetRegistry,O.world(~S,Local.install(~S,world,1)))
def target_created(~S:Data,source:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,registry:Sys.Registry<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>,creation:W.Creation<S,P.Store<S>,P.Resources<S>,P.Ping>) -> List<&2,String>:
  match creation:
    case W.CreateRejected{_,_}: ["TARGET_CREATION_FAILED"]
    case W.Created{_,world}: target_registered(~S,source,registry,A.register(~S,~A.success,world,"foreign-control"))
def source_registered(~S:Data,factory:W.Factory,registered:Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,P.Ping,H.Invocation<P.Flow>,String,Unit,A.runner(~S,~A.success)>) -> List<&2,String>:
  match registered:
    case Sys.RegistrationFailed{_}: ["SOURCE_REGISTRATION_FAILED"]
    case Sys.Registered{world,registry}: target_created(~S,Local.install(~S,world,1),registry,W.create(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~(u => P.empty_store(~S,u)),factory,P.initial_resources(~S)))
def created(~S:Data,creation:W.Creation<S,P.Store<S>,P.Resources<S>,P.Ping>) -> List<&2,String>:
  match creation:
    case W.CreateRejected{_,_}: ["SOURCE_CREATION_FAILED"]
    case W.Created{factory,world}: source_registered(~S,factory,A.register(~S,~A.success,world,"foreign-control"))
def run(~S:Data) -> List<&2,String>:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~(u => P.empty_store(~S,u)),W.factory(),P.initial_resources(~S)))
def schemaA() -> List<&2,String>: run(~P.SchemaA)
def schemaB() -> List<&2,String>: run(~P.SchemaB)
