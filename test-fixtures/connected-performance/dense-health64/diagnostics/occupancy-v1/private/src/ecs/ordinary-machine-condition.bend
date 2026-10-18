import Base
import ordinary-machine-initialization.bend as Init
import ordinary-machine-declaration.bend as OD
import machine.bend as M
import world.bend as W
import system.bend as Sys

# Each ordinary condition is an actual registered system plus its own revision.
# The revision is separate from the Registry's real World-clock cursor.
def present(~S:Data,~K:Data,~V:Data,slot:M.Slot<S,K,V>) -> Bool:
  match slot:
    case M.Missing{}:False{}
    case _:True{}
def revision_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,pair:R & Init.State<S,K,V>) -> R & (Nat & Bool):
  match pair:
    case (resource,Init.State{+slot,stream,+revision}):(put(resource,Init.State{slot,stream,revision}),(revision,present(~S,~K,~V,slot)))
def observed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,prior:Nat,pair:W.World<S,C,R,E> & (Nat & Bool)) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Nat & Bool>:
  match pair:
    case (world,(+current,present)):Sys.Succeeded{world,(current,Bool.and(present,Nat.is_lt(prior,current)))}
def runner(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,prior:Nat) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Nat & Bool>:
  observed(~S,~K,~V,~R,~take,~put,~C,~E,prior,W.observe_resource(~S,~C,~R,~E,~(Nat & Bool),~(resource => revision_taken(~S,~K,~V,~R,~take,~put,~C,~E,take(resource))),world))
type Instance<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data,-take:R -> R & Init.State<S,K,V>,-put:R -> Init.State<S,K,V> -> R> is Type:
  Instance{registry:Sys.Registry<S,C,R,E,Nat,Unit,Nat & Bool,runner(~S,~K,~V,~R,~take,~put,~C,~E)>,lastRevision:Nat}
type Definition<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data,-take:R -> R & Init.State<S,K,V>,-put:R -> Init.State<S,K,V> -> R> is Type:
  Defined{world:W.World<S,C,R,E>,instance:Instance<S,K,V,C,R,E,take,put>}
  DefinitionRejected{world:W.World<S,C,R,E>}
def registered(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,result:Sys.RegistrationResult<S,C,R,E,Nat,Unit,Nat & Bool,runner(~S,~K,~V,~R,~take,~put,~C,~E)>) -> Definition<S,K,V,C,R,E,take,put>:
  match result:
    case Sys.Registered{world,registry}:Defined{world,Instance{registry,0n}}
    case Sys.RegistrationFailed{world}:DefinitionRejected{world}
def define(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,world:W.World<S,C,R,E>,name:String) -> Definition<S,K,V,C,R,E,take,put>:
  registered(~S,~K,~V,~R,~take,~put,~C,~E,Sys.register(~S,~C,~R,~E,~Nat,~Unit,~(Nat & Bool),~runner(~S,~K,~V,~R,~take,~put,~C,~E),world,name,["machine." ++ OD.name(~S,~K,~V,~R,~Init.take_slot(~S,~K,~V,~R,~take,~put),declaration) ++ ".changed"]))
type Observed<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data,-take:R -> R & Init.State<S,K,V>,-put:R -> Init.State<S,K,V> -> R> is Type:
  Observed{world:W.World<S,C,R,E>,instance:Instance<S,K,V,C,R,E,take,put>,value:Maybe<&2,Bool>}
  RegistrationRejected{world:W.World<S,C,R,E>,instance:Instance<S,K,V,C,R,E,take,put>}
def completed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,prior:Nat,result:Sys.RunResult<S,C,R,E,Nat,Unit,Nat & Bool,runner(~S,~K,~V,~R,~take,~put,~C,~E)>) -> Observed<S,K,V,C,R,E,take,put>:
  match result:
    case Sys.Completed{registry,Sys.Measured{inner,_}}:completed(~S,~K,~V,~R,~take,~put,~C,~E,prior,Sys.Completed{registry,inner})
    case Sys.Completed{registry,Sys.Succeeded{world,(revision,value)}}:Observed{world,Instance{registry,revision},Some{value}}
    case Sys.Completed{registry,Sys.Failed{world,_}}:Observed{world,Instance{registry,prior},None{}}
    case Sys.RegistrationRejected{registry,world,_}:RegistrationRejected{world,Instance{registry,prior}}
def run(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,instance:Instance<S,K,V,C,R,E,take,put>,world:W.World<S,C,R,E>) -> Observed<S,K,V,C,R,E,take,put>:
  match instance:
    case Instance{registry,+prior}:completed(~S,~K,~V,~R,~take,~put,~C,~E,prior,Sys.run_tracked(~S,~C,~R,~E,~Nat,~Unit,~(Nat & Bool),~runner(~S,~K,~V,~R,~take,~put,~C,~E),registry,world,prior))
def run_if(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,enabled:Bool,instance:Instance<S,K,V,C,R,E,take,put>,world:W.World<S,C,R,E>) -> Observed<S,K,V,C,R,E,take,put>:
  match enabled:
    case False{}:Observed{world,instance,None{}}
    case True{}:run(~S,~K,~V,~R,~take,~put,~C,~E,instance,world)
