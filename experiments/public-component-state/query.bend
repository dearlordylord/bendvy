import Base
import ../../src/ecs/state.bend as A
import state.bend as V
import schema.bend as S
import gameplay.bend as G
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/system.bend as Sys

def Frame(~Schema: Data) -> Type: Q.Frame<Schema,S.Store<Schema>,Unit,Unit>
def write_phase(~Schema: Data) -> Cap.Write<Frame(~Schema),V.Phase,V.Phase>:
  Q.write_family(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.PhaseRest<Schema>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~Schema),~S.put_phase(~Schema),~S.project_phase,~S.phase_family(~Schema))
# Closed provider reports the actual transaction error after the public write.
# No read-presence prerequisite: a live absent family remains a legal upsert.
def write_status(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & A.WriteStatus<W.WorldError>:
  match frame:
    case Q.Frame{tx,handle,None{},cursor}: (Q.Frame{tx,handle,None{},cursor},A.WriteAccepted{})
    case Q.Frame{tx,handle,Some{+error},cursor}: (Q.Frame{tx,handle,Some{error},cursor},A.WriteRejected{error})
def requested_phase(~Schema: Data,frame: Frame(~Schema),value: V.Phase) -> Frame(~Schema) & A.WriteStatus<W.WorldError>:
  match frame:
    case Q.Frame{tx,handle,None{},cursor}: write_status(~Schema,Cap.set(~Frame(~Schema),~V.Phase,~V.Phase,~write_phase(~Schema),Q.Frame{tx,handle,None{},cursor},value))
    case Q.Frame{tx,handle,Some{+error},cursor}: (Q.Frame{tx,handle,Some{error},cursor},A.WriteRejected{error})
def phase_request(~Schema: Data) -> Cap.Request<Frame(~Schema),V.Phase,A.WriteStatus<W.WorldError>>:
  Cap.Request{requested_phase(~Schema)}
def match_phase(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.family_match(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.PhaseRest<Schema>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~Schema),~S.put_phase(~Schema),~S.project_phase,~S.phase_family(~Schema),~Q.Required{},frame)
def write_mode(~Schema: Data) -> Cap.Write<Frame(~Schema),V.Mode,V.Mode>:
  Q.write_family(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.ModeRest<Schema>,~V.Mode,~V.Mode,~S.ModeToken,~S.take_mode(~Schema),~S.put_mode(~Schema),~S.project_mode,~S.mode_family(~Schema))
def requested_mode(~Schema: Data,frame: Frame(~Schema),value: V.Mode) -> Frame(~Schema) & A.WriteStatus<W.WorldError>:
  match frame:
    case Q.Frame{tx,handle,None{},cursor}: write_status(~Schema,Cap.set(~Frame(~Schema),~V.Mode,~V.Mode,~write_mode(~Schema),Q.Frame{tx,handle,None{},cursor},value))
    case Q.Frame{tx,handle,Some{+error},cursor}: (Q.Frame{tx,handle,Some{error},cursor},A.WriteRejected{error})
def mode_request(~Schema: Data) -> Cap.Request<Frame(~Schema),V.Mode,A.WriteStatus<W.WorldError>>:
  Cap.Request{requested_mode(~Schema)}
def match_mode(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.family_match(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.ModeRest<Schema>,~V.Mode,~V.Mode,~S.ModeToken,~S.take_mode(~Schema),~S.put_mode(~Schema),~S.project_mode,~S.mode_family(~Schema),~Q.Required{},frame)
def read_neighbor(~Schema: Data) -> Cap.Read<Frame(~Schema),S.NeighborView>:
  Q.read_family(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.NeighborRest<Schema>,~S.Neighbor,~S.NeighborView,~S.NeighborToken,~S.take_neighbor(~Schema),~S.put_neighbor(~Schema),~S.project_neighbor,~S.neighbor_family(~Schema))
def match_neighbor(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.family_match(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.NeighborRest<Schema>,~S.Neighbor,~S.NeighborView,~S.NeighborToken,~S.take_neighbor(~Schema),~S.put_neighbor(~Schema),~S.project_neighbor,~S.neighbor_family(~Schema),~Q.Required{},frame)
def pair_match(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.both(~Schema,~S.Store<Schema>,~Unit,~Unit,~match_phase(~Schema),~match_mode(~Schema),frame)
def matches(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.both(~Schema,~S.Store<Schema>,~Unit,~Unit,~pair_match(~Schema),~match_neighbor(~Schema),frame)
def plan(~Schema: Data) -> Q.Plan<Schema,S.Store<Schema>,Unit,Unit,G.Caps>:
  Q.Plan{G.Ops{write_phase(~Schema),write_mode(~Schema),read_neighbor(~Schema),phase_request(~Schema),mode_request(~Schema)},matches(~Schema)}
def each(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,action: G.Action) -> Q.Executed<W.World<Schema,S.Store<Schema>,Unit,Unit>,Q.Error<G.Error>,String>:
  Q.each(~Schema,~S.Store<Schema>,~Unit,~Unit,~G.Caps,~G.Action,~G.Error,~String,~plan(~Schema),~G.body,action,world)
def finish(~Schema: Data,result: Q.Executed<W.World<Schema,S.Store<Schema>,Unit,Unit>,Q.Error<G.Error>,String>) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  match result:
    case Q.Executed{world,T.Success{},+outputs}: Sys.Succeeded{world,outputs}
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,"Rejected"}
def runner(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,action: G.Action) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  finish(~Schema,each(~Schema,world,action))

def read_phase(~Schema: Data) -> Cap.Read<Frame(~Schema),V.Phase>:
  Q.read_family(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.PhaseRest<Schema>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~Schema),~S.put_phase(~Schema),~S.project_phase,~S.phase_family(~Schema))
def changed(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.lifecycle_match(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.PhaseRest<Schema>,~V.Phase,~V.Phase,~S.PhaseToken,~S.take_phase(~Schema),~S.put_phase(~Schema),~S.project_phase,~S.phase_family(~Schema),~Q.Changed{},frame)
def watch_plan(~Schema: Data) -> Q.Plan<Schema,S.Store<Schema>,Unit,Unit,G.ReadCaps>:
  Q.Plan{read_phase(~Schema),changed(~Schema)}
def read_mode(~Schema: Data) -> Cap.Read<Frame(~Schema),V.Mode>:
  Q.read_family(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.ModeRest<Schema>,~V.Mode,~V.Mode,~S.ModeToken,~S.take_mode(~Schema),~S.put_mode(~Schema),~S.project_mode,~S.mode_family(~Schema))
def mode_changed(~Schema: Data,frame: Frame(~Schema)) -> Frame(~Schema) & Bool:
  Q.lifecycle_match(~Schema,~S.Store<Schema>,~Unit,~Unit,~S.ModeRest<Schema>,~V.Mode,~V.Mode,~S.ModeToken,~S.take_mode(~Schema),~S.put_mode(~Schema),~S.project_mode,~S.mode_family(~Schema),~Q.Changed{},frame)
def mode_watch_plan(~Schema: Data) -> Q.Plan<Schema,S.Store<Schema>,Unit,Unit,G.ModeReadCaps>:
  Q.Plan{read_mode(~Schema),mode_changed(~Schema)}
def values(items: List<&2,String>) -> String:
  match items:
    case []: ""
    case value <> []: value
    case value <> rest: value ++ "," ++ values(rest)
def mode_watch_finished(~Schema: Data,+phases: List<&2,String>,result: Q.Executed<W.World<Schema,S.Store<Schema>,Unit,Unit>,Q.Error<G.Error>,String>) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  match result:
    case Q.Executed{world,T.Success{},+modes}: Sys.Succeeded{world,["phase=" ++ values(phases) ++ ";mode=" ++ values(modes)]}
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,"Rejected"}
def phase_watch_finished(~Schema: Data,+cursor: U32,result: Q.Executed<W.World<Schema,S.Store<Schema>,Unit,Unit>,Q.Error<G.Error>,String>) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  match result:
    case Q.Executed{world,T.Success{},+phases}: mode_watch_finished(~Schema,phases,Q.each_since(~Schema,~S.Store<Schema>,~Unit,~Unit,~G.ModeReadCaps,~Unit,~G.Error,~String,~mode_watch_plan(~Schema),~G.mode_watch_body,Unit{},world,cursor))
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,"Rejected"}
def watcher_inner(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,+cursor: U32) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  phase_watch_finished(~Schema,cursor,Q.each_since(~Schema,~S.Store<Schema>,~Unit,~Unit,~G.ReadCaps,~Unit,~G.Error,~String,~watch_plan(~Schema),~G.watch_body,Unit{},world,cursor))
def watcher(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,cursor: U32) -> Sys.Outcome<W.World<Schema,S.Store<Schema>,Unit,Unit>,String,List<&2,String>>:
  match cursor:
    case +cursor: watcher_inner(~Schema,world,cursor)
