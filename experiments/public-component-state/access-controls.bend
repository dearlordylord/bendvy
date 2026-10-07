import Base
import ../../src/ecs/state.bend as A
import state.bend as V
import schema.bend as S
import query.bend as Q
import observe.bend as O
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Compose
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/commands.bend as Cmd

def World() -> Type: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>
def classified(~H: Type,pair: H & A.Outcome<V.Phase,W.WorldError>) -> H & String:
  match pair:
    case (owner,A.StateMoved{}): (owner,"Moved")
    case (owner,A.StateAccessRejected{C.ComponentAbsent{}}): (owner,"ComponentAbsent")
    case (owner,A.StateAccessRejected{C.MissingEntity{}}): (owner,"MissingEntity")
    case (owner,_): (owner,"unexpected-result")
def body(~H: Type,~write: Cap.Read<H,V.Phase>,~request: Cap.Request<H,V.Phase,A.WriteStatus<W.WorldError>>,owner: H) -> H & String:
  classified(~H,A.transition(~H,~V.Phase,~V.Move,~W.WorldError,~V.phase_equal,~V.endpoints,~write,~request,owner,V.ReadyWindup{}))
def returned(+status: String,result: T.Returned<World(),Unit>) -> World() & String:
  match result:
    case T.Returned{world,T.Success{}}: (world,status)
    case T.Returned{world,T.Failure{_}}: (world,"unexpected-transaction-failure")
def frame_finished(pair: Q.Frame(~S.SchemaA) & String) -> World() & String:
  match pair:
    case (Compose.Frame{tx,_,_,_},status): returned(status,Cmd.tx_finish(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~Unit,tx,T.Success{}))
def access(world: World(),handle: W.Handle<S.SchemaA>) -> World() & String:
  frame_finished(body(~Q.Frame(~S.SchemaA),~Q.read_phase(~S.SchemaA),~Q.phase_request(~S.SchemaA),Compose.Frame{T.begin(~World(),~Unit,world),handle,None{},0}))
def other_shown(+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (_,row) = pair
  List.append(&2,String,lines,["other|" ++ row])
def home_shown(other: World(),+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (_,row) = pair
  other_shown(List.append(&2,String,lines,["home|" ++ row]),O.rows(~S.SchemaA,other))
def foreign_done(other: World(),+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  home_shown(other,List.append(&2,String,lines,["foreign|" ++ status]),O.rows(~S.SchemaA,home))
def absent_done(other: World(),+foreign: U32,+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  foreign_done(other,List.append(&2,String,lines,["absent|" ++ status]),access(home,W.Handle{foreign,1}))
def valid_done(other: World(),+homeNS: U32,+foreign: U32,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  absent_done(other,foreign,["valid|" ++ status],access(home,W.Handle{homeNS,2}))
def home_named(other: World(),+foreign: U32,pair: World() & U32) -> List<&2,String>:
  (home,+ns) = pair
  valid_done(other,ns,foreign,access(home,W.Handle{ns,1}))
def other_named(home: World(),pair: World() & U32) -> List<&2,String>:
  (other,+ns) = pair
  home_named(other,ns,W.namespace(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,home))
def created_other(home: World(),created: W.Creation<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> List<&2,String>:
  match created:
    case W.Created{_,other}: other_named(home,W.namespace(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,W.barrier(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,S.seed(~S.SchemaA,other))))
    case _: ["creation-failed"]
def created_home(created: W.Creation<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> List<&2,String>:
  match created:
    case W.Created{factory,home}: created_other(W.barrier(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,S.seed(~S.SchemaA,home)),S.create(~S.SchemaA,factory))
    case _: ["creation-failed"]
def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),u => print_lines(rest))
def main() -> IO(Unit):
  print_lines(created_home(S.create(~S.SchemaA,W.factory())))
