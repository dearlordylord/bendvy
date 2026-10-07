import Base
import ../../src/ecs/lifecycle.bend as L
import ../../src/ecs/state.bend as A
import state.bend as V
import error-decoders.bend as Decode
import ../public-decode/typed.bend as D
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
    case (owner,A.StateWriteRejected{W.CapacityExceeded{}}): (owner,"WriteRejected:CapacityExceeded")
    case (owner,A.StateAccessRejected{C.ComponentAbsent{}}): (owner,"ComponentAbsent")
    case (owner,A.StateAccessRejected{C.MissingEntity{}}): (owner,"MissingEntity")
    case (owner,_): (owner,"unexpected-result")
def body(~H: Type,~read: Cap.Read<H,V.Phase>,~write: Cap.Request<H,V.Phase,A.WriteStatus<W.WorldError>>,owner: H) -> H & String:
  classified(~H,A.transition(~H,~V.Phase,~V.Move,~W.WorldError,~V.phase_equal,~V.endpoints,~read,~write,owner,V.ReadyWindup{}))
def returned(+status: String,result: T.Returned<World(),W.WorldError>) -> World() & String:
  match result:
    case T.Returned{world,T.Success{}}: (world,status ++ "|transaction=Success")
    case T.Returned{world,T.Failure{W.MissingEntity{}}}: (world,status ++ "|transaction=MissingEntity")
    case T.Returned{world,T.Failure{W.CapacityExceeded{}}}: (world,status ++ "|transaction=CapacityExceeded")
    case T.Returned{world,T.Failure{_}}: (world,"unexpected-transaction-failure")
def frame_finished(pair: Q.Frame(~S.SchemaA) & String) -> World() & String:
  match pair:
    case (Compose.Frame{tx,_,None{},_},status): returned(status,Cmd.tx_finish(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~W.WorldError,tx,T.Success{}))
    case (Compose.Frame{tx,_,Some{error},_},status): returned(status,Cmd.tx_finish(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~W.WorldError,tx,T.Failure{error}))
def access(world: World(),handle: W.Handle<S.SchemaA>) -> World() & String:
  frame_finished(body(~Q.Frame(~S.SchemaA),~Q.read_phase(~S.SchemaA),~Q.phase_request(~S.SchemaA),Compose.Frame{T.begin(~World(),~Unit,world),handle,None{},0}))
def exhausted(world: World()) -> World():
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,_}: W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,4294967295}
def stamp_text(stamp: L.Stamp) -> String:
  match stamp:
    case L.Stamp{added,changed}: "[" ++ U32.show(added) ++ "," ++ U32.show(changed) ++ "]"
def meta_clock(+stamps: String,pair: World() & U32) -> World() & String:
  (world,clock) = pair
  (world,"clock=" ++ U32.show(clock) ++ stamps)
def meta_second(+first: String,pair: World() & L.Stamp) -> World() & String:
  (world,second) = pair
  meta_clock("|phase1=" ++ first ++ "|phase2=" ++ stamp_text(second),W.clock(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,world))
def meta_first(pair: World() & L.Stamp) -> World() & String:
  (world,first) = pair
  meta_second(stamp_text(first),C.lifecycle_world(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~S.PhaseRest<S.SchemaA>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~S.SchemaA),~S.put_phase(~S.SchemaA),~S.project_phase,2,world))
def metadata(world: World()) -> World() & String:
  meta_first(C.lifecycle_world(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~S.PhaseRest<S.SchemaA>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~S.SchemaA),~S.put_phase(~S.SchemaA),~S.project_phase,1,world))
def other_shown(+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (_,row) = pair
  List.append(&2,String,lines,["other|" ++ row])
def after_metadata(other: World(),+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (_,meta) = pair
  other_shown(List.append(&2,String,lines,["after|" ++ meta]),O.rows(~S.SchemaA,other))
def home_shown(other: World(),+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (home,row) = pair
  after_metadata(other,List.append(&2,String,lines,["home|" ++ row]),metadata(home))
def foreign_done(other: World(),+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  home_shown(other,List.append(&2,String,lines,["foreign|" ++ status]),O.rows(~S.SchemaA,home))
def absent_done(other: World(),+foreign: U32,+lines: List<&2,String>,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  foreign_done(other,List.append(&2,String,lines,["absent|" ++ status]),access(home,W.Handle{foreign,1}))
def valid_done(other: World(),+homeNS: U32,+foreign: U32,+before: String,pair: World() & String) -> List<&2,String>:
  (home,status) = pair
  absent_done(other,foreign,["before|" ++ before,"valid|" ++ status],access(home,W.Handle{homeNS,2}))
def before_metadata(other: World(),+ns: U32,+foreign: U32,pair: World() & String) -> List<&2,String>:
  (home,before) = pair
  valid_done(other,ns,foreign,before,access(home,W.Handle{ns,1}))
def home_named(other: World(),+foreign: U32,pair: World() & U32) -> List<&2,String>:
  (home,+ns) = pair
  before_metadata(other,ns,foreign,metadata(exhausted(home)))
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
