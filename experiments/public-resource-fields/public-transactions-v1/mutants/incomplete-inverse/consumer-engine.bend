import Base
import provider.bend as P
import operations.bend as O
import ../../normal/owner-observer.bend as Dump
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../../../src/ecs/schema-fragments.bend as Fragment
def World(~S:Data,~R:Type) -> Type:
  W.World<S,Col.Column<S,Unit>,R,U32>
def Registry(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>) -> Type:
  Sys.Registry<S,Col.Column<S,Unit>,R,U32,Bool,O.Error,O.Output,run>
def Owner(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>) -> Type:
  P.Owner<S,Registry(~S,~R,~run),clauses>
def unit(value:Unit) -> Unit & String:
  (value,"Unit")
def observe_world(~S:Data,~R:Type,~view:R -> R & String,value:World(~S,~R)) -> World(~S,~R) & String:
  Dump.world(~S,~Unit,~R,~U32,~unit,~view,~U32.show,value)
def clause(~S:Data,value:Q.Clause<S>) -> String:
  match value:
    case Q.Clause{name,Q.Read{}}:name ++ ":Read"
    case Q.Clause{name,Q.Write{}}:name ++ ":Write"
    case Q.Clause{name,_}:name ++ ":OTHER"
def owner(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,value:Owner(~S,~R,~run,~clauses)) -> Owner(~S,~R,~run,~clauses) & String:
  match value:
    case P.Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor}}:(P.Owner{Sys.Registry{namespace,id,name,access,cursor}},"owner{" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":access=" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":clauses=" ++ List.show(&2,Q.Clause<S>,clause(~S),clauses) ++ "}")
def snapshot_join(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,label:String,a:Owner(~S,~R,~run,~clauses) & String,b:World(~S,~R) & String) -> Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String):
  (own,oa)=a
  (value,wb)=b
  (own,(value,label ++ "|" ++ oa ++ "|world{" ++ wb ++ "}"))
def snapshot(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,label:String,own:Owner(~S,~R,~run,~clauses),value:World(~S,~R)) -> Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String):
  snapshot_join(~S,~R,~run,~clauses,label,owner(~S,~R,~run,~clauses,own),observe_world(~S,~R,~view,value))
def second(~A:Type,result:A & String) -> String:
  match result:
    case (_,text):text
def output(value:O.Output) -> String:
  match value:
    case O.Output{values}:"Success{" ++ second(~Array<U32>,Dump.u32_array(values)) ++ "}"
def outcome(~S:Data,~R:Type,value:Sys.Outcome<World(~S,~R),O.Error,O.Output>) -> World(~S,~R) & String:
  match value:
    case Sys.Succeeded{world,value}:(world,output(value))
    case Sys.Failed{world,O.Rollback{first,second,afterFirst}}:(world,"Failure{" ++ U32.show(first) ++ ":" ++ U32.show(second) ++ ":" ++ U32.show(afterFirst) ++ "}")
def completed_outcome(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,own:Owner(~S,~R,~run,~clauses),value:World(~S,~R) & String) -> Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String):
  match value:
    case (world,label):snapshot(~S,~R,~run,~clauses,~view,label,own,world)
def completed(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,result:Sys.RunResult<S,Col.Column<S,Unit>,R,U32,Bool,O.Error,O.Output,run>) -> Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String):
  match result:
    case Sys.Completed{registry,value}:completed_outcome(~S,~R,~run,~clauses,~view,P.Owner{registry},outcome(~S,~R,value))
    case Sys.RegistrationRejected{registry,world,_}:snapshot(~S,~R,~run,~clauses,~view,"REGISTRATION_REJECTED",P.Owner{registry},world)
def execute(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,own:Owner(~S,~R,~run,~clauses),world:World(~S,~R),fail:Bool) -> Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String):
  completed(~S,~R,~run,~clauses,~view,P.run(~S,~Col.Column<S,Unit>,~R,~U32,~Bool,~O.Error,~O.Output,~run,~clauses,own,world,fail))
def last(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,pre:String,commit:String,failed:String,result:Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String)) -> String:
  match result:
    case (_,(world,text)):pre ++ "\n" ++ commit ++ "\n" ++ failed ++ "\n" ++ text
def failed(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,pre:String,commit:String,result:Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String)) -> String:
  match result:
    case (own,(world,text)):last(~S,~R,~run,~clauses,pre,commit,text,execute(~S,~R,~run,~clauses,~view,own,world,False{}))
def committed(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,pre:String,result:Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String)) -> String:
  match result:
    case (own,(world,text)):failed(~S,~R,~run,~clauses,~view,pre,text,execute(~S,~R,~run,~clauses,~view,own,world,True{}))
def started(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,result:Owner(~S,~R,~run,~clauses) & (World(~S,~R) & String)) -> String:
  match result:
    case (own,(world,text)):committed(~S,~R,~run,~clauses,~view,text,execute(~S,~R,~run,~clauses,~view,own,world,False{}))
def registered(~S:Data,~R:Type,~run:World(~S,~R) -> Bool -> Sys.Outcome<World(~S,~R),O.Error,O.Output>,~clauses:List<&2,Q.Clause<S>>,~view:R -> R & String,result:P.Defined<S,World(~S,~R),Registry(~S,~R,~run),clauses>) -> String:
  match result:
    case P.Rejected{world}:second(~World(~S,~R),observe_world(~S,~R,~view,world))
    case P.Defined{world,own}:started(~S,~R,~run,~clauses,~view,snapshot(~S,~R,~run,~clauses,~view,"Before",own,world))
def created(~S:Data,~R:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,T.Tx<World(~S,~R),U32>,Ops(T.Tx<World(~S,~R),U32>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<O.Error> & O.Output),~view:R -> R & String,result:W.Creation<S,Col.Column<S,Unit>,R,U32>) -> String:
  match result:
    case W.Created{_,world}:registered(~S,~R,~P.runner(~S,~Col.Column<S,Unit>,~R,~U32,~Ops,~Bool,~O.Error,~O.Output,~declaration,~body),~P.clauses(~S,~T.Tx<World(~S,~R),U32>,~Ops(T.Tx<World(~S,~R),U32>),declaration),~view,P.define(~S,~Col.Column<S,Unit>,~R,~U32,~Ops,~Bool,~O.Error,~O.Output,~declaration,~body,world,"SelectedResources"))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def empty(~S:Data,unit:Unit) -> Col.Column<S,Unit>:
  Col.empty(~S,~Unit)
def scenario(~S:Data,~R:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,T.Tx<World(~S,~R),U32>,Ops(T.Tx<World(~S,~R),U32>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<O.Error> & O.Output),~view:R -> R & String,validation:Fragment.Validation,initial:R) -> String:
  match validation:
    case Fragment.Invalid{_}:"SCHEMA_REJECTED"
    case Fragment.Valid{}:created(~S,~R,~Ops,~declaration,~body,~view,W.create(~S,~Col.Column<S,Unit>,~R,~U32,~empty(~S),W.factory(),initial))
