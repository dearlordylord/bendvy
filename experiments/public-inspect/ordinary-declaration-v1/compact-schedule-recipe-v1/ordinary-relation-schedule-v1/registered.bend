import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

def finished(~S:Data,~C:Type,~R:Type,~E:Data,result:T.Returned<Relation.World(~S,~C,~R,~E),Unit>) -> Sys.Outcome<Relation.World(~S,~C,~R,~E),Unit,Unit>:
  match result:
    case T.Returned{world,T.Success{}}:Sys.Succeeded{world,Unit{}}
    case T.Returned{world,T.Failure{error}}:Sys.Failed{world,error}
def read_done(~S:Data,~C:Type,~R:Type,~E:Data,result:T.Tx<Relation.World(~S,~C,~R,~E),A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>) -> Sys.Outcome<Relation.World(~S,~C,~R,~E),Unit,Unit>:
  match result:
    case (frame,_):finished(~S,~C,~R,~E,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,frame,T.Success{}))
def reader(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,world:Relation.World(~S,~C,~R,~E),args:Unit) -> Sys.Outcome<Relation.World(~S,~C,~R,~E),Unit,Unit>:
  read_done(~S,~C,~R,~E,P.read(~T.Tx<Relation.World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_read(~S,~C,~R,~E,~Relation.descriptor(~S,declaration)),T.begin(~Relation.World(~S,~C,~R,~E),~A.Notice<S,E>,world),target))
def Owner(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>) -> Type:
  Sys.Registry<S,A.Store<S,C>,R,A.Notice<S,E>,Unit,Unit,Unit,reader(~S,~C,~R,~E,~declaration,~target)>
def register(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,world:Relation.World(~S,~C,~R,~E),name:String) -> Sys.RegistrationResult<S,A.Store<S,C>,R,A.Notice<S,E>,Unit,Unit,Unit,reader(~S,~C,~R,~E,~declaration,~target)>:
  Sys.register(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,~Unit,~Unit,~reader(~S,~C,~R,~E,~declaration,~target),world,name,Ord.accesses(~S,[declaration]))
def empty_fold(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,owner:Owner(~S,~C,~R,~E,~declaration,~target)) -> Owner(~S,~C,~R,~E,~declaration,~target) & List<&2,Fields.Fields<S>>:
  (owner,[])
def binding(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,owner:Owner(~S,~C,~R,~E,~declaration,~target),slot:String) -> Owner(~S,~C,~R,~E,~declaration,~target) & DTO.Binding<S>:
  match owner:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},DTO.Binding{namespace,id,name,access,cursor,slot,[]})
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,result:Sys.RunResult<S,A.Store<S,C>,R,A.Notice<S,E>,Unit,Unit,Unit,reader(~S,~C,~R,~E,~declaration,~target)>) -> Owner(~S,~C,~R,~E,~declaration,~target) & Sys.Outcome<Relation.World(~S,~C,~R,~E),Maybe<&2,Unit>,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,output}}:(registry,Sys.Succeeded{world,output})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(registry,Sys.Failed{world,Some{error}})
    case Sys.RegistrationRejected{registry,world,args}:(registry,Sys.Failed{world,None{}})
def dispatch_checked(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,allowed:Bool,owner:Owner(~S,~C,~R,~E,~declaration,~target),world:Relation.World(~S,~C,~R,~E)) -> Owner(~S,~C,~R,~E,~declaration,~target) & Sys.Outcome<Relation.World(~S,~C,~R,~E),Maybe<&2,Unit>,Unit>:
  match allowed:
    case False{}:(owner,Sys.Failed{world,None{}})
    case True{}:dispatched(~S,~C,~R,~E,~declaration,~target,Sys.run_tracked(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,~Unit,~Unit,~reader(~S,~C,~R,~E,~declaration,~target),owner,world,Unit{}))
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,owner:Owner(~S,~C,~R,~E,~declaration,~target),world:Relation.World(~S,~C,~R,~E),id:U32) -> Owner(~S,~C,~R,~E,~declaration,~target) & Sys.Outcome<Relation.World(~S,~C,~R,~E),Maybe<&2,Unit>,Unit>:
  match owner:
    case Sys.Registry{namespace,+actual,name,access,cursor}:dispatch_checked(~S,~C,~R,~E,~declaration,~target,U32.is_eq(actual,id),Sys.Registry{namespace,actual,name,access,cursor},world)
