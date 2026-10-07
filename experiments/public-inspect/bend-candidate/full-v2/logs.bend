import Base
import ../removal-log.bend as L
import ../removal-publication.bend as P
import ../removal-transport.bend as T
import ../../../../src/ecs/removals.bend as Rm
import ../../../../src/ecs/world.bend as W

type Streams<S:Data,F:Data,H:Type> is Type:
  Streams{holders:H,removed:L.Log<S,F,Unit>,despawned:L.Log<S,F,Unit>}
type Positions is Data:
  Positions{removed:List<&2,U32>,despawned:List<&2,U32>}
def removed_join(~S:Data,~F:Data,~H:Type,holders:H,despawned:L.Log<S,F,Unit>,result:L.Log<S,F,Unit> & L.Reading<S,F>) -> Streams<S,F,H> & L.Reading<S,F>:
  (removed,reading)=result
  (Streams{holders,removed,despawned},reading)
def read_removed(~S:Data,~F:Data,~H:Type,streams:Streams<S,F,H>,cursor:U32,registered:U32) -> Streams<S,F,H> & L.Reading<S,F>:
  match streams:
    case Streams{holders,removed,despawned}:removed_join(~S,~F,~H,holders,despawned,L.read(~S,~F,~Unit,cursor,registered,removed))
def despawned_join(~S:Data,~F:Data,~H:Type,holders:H,removed:L.Log<S,F,Unit>,result:L.Log<S,F,Unit> & L.Reading<S,F>) -> Streams<S,F,H> & L.Reading<S,F>:
  (despawned,reading)=result
  (Streams{holders,removed,despawned},reading)
def read_despawned(~S:Data,~F:Data,~H:Type,streams:Streams<S,F,H>,cursor:U32,registered:U32) -> Streams<S,F,H> & L.Reading<S,F>:
  match streams:
    case Streams{holders,removed,despawned}:despawned_join(~S,~F,~H,holders,removed,L.read(~S,~F,~Unit,cursor,registered,despawned))
def removed_notice(~S:Data,~F:Data,notice:P.Notice<S,F>) -> Maybe<&2,P.Notice<S,F>>:
  match notice:
    case P.Notice{tick,Rm.Removed{entity,family}}:Some{P.Notice{tick,Rm.Removed{entity,family}}}
    case P.Notice{_,Rm.Despawned{_}}:None{}
def despawned_notice(~S:Data,~F:Data,notice:P.Notice<S,F>) -> Maybe<&2,P.Notice<S,F>>:
  match notice:
    case P.Notice{_,Rm.Removed{_,_}}:None{}
    case P.Notice{tick,Rm.Despawned{entity}}:Some{P.Notice{tick,Rm.Despawned{entity}}}
def choose_notice(~S:Data,~F:Data,item:Maybe<&2,P.Notice<S,F>>,rest:List<&2,P.Notice<S,F>>) -> List<&2,P.Notice<S,F>>:
  match item:
    case None{}:rest
    case Some{value}:value <> rest
def filter(~S:Data,~F:Data,~select:P.Notice<S,F> -> Maybe<&2,P.Notice<S,F>>,items:List<&2,P.Notice<S,F>>) -> List<&2,P.Notice<S,F>>:
  match items:
    case []:[]
    case item <> rest:choose_notice(~S,~F,select(item),filter(~S,~F,~select,rest))
def append(~S:Data,~F:Data,~H:Type,streams:Streams<S,F,H>,+fresh:List<&2,P.Notice<S,F>>) -> Streams<S,F,H>:
  match streams:
    case Streams{holders,removed,despawned}:Streams{holders,T.append(~S,~F,~Unit,removed,filter(~S,~F,~(notice => removed_notice(~S,~F,notice)),fresh)),T.append(~S,~F,~Unit,despawned,filter(~S,~F,~(notice => despawned_notice(~S,~F,notice)),fresh))}
def trim_log(~S:Data,~F:Data,cursors:List<&2,U32>,window:U32,log:L.Log<S,F,Unit>) -> L.Log<S,F,Unit>:
  match log:
    case L.Log{owner,items,dropped,+capacity}:L.trimmed(~S,~F,~Unit,owner,capacity,L.trim_loop(~S,~F,items,L.boundary(cursors,window),dropped,capacity))
def projected(~S:Data,~F:Data,~H:Type,+window:U32,removed:L.Log<S,F,Unit>,despawned:L.Log<S,F,Unit>,result:H & Positions) -> Streams<S,F,H>:
  match result:
    case (holders,Positions{removedCursors,despawnedCursors}):Streams{holders,trim_log(~S,~F,removedCursors,window,removed),trim_log(~S,~F,despawnedCursors,window,despawned)}
def trim(~S:Data,~F:Data,~H:Type,~project:H -> H & Positions,+window:U32,streams:Streams<S,F,H>) -> Streams<S,F,H>:
  match streams:
    case Streams{holders,removed,despawned}:projected(~S,~F,~H,window,removed,despawned,project(holders))
def start(~S:Data,~F:Data,~H:Type,holders:H,+capacity:Nat) -> Streams<S,F,H>:
  Streams{holders,L.Log{Unit{},[],0,capacity},L.Log{Unit{},[],0,capacity}}

# A closed declared-family predicate is required when F has several families.
# The despawn domain remains independent of that predicate.
def selected_removed(~S:Data,~F:Data,+tick:U32,+entity:W.Handle<S>,family:F,selected:Bool) -> Maybe<&2,P.Notice<S,F>>:
  match selected:
    case True{}:Some{P.Notice{tick,Rm.Removed{entity,family}}}
    case False{}:None{}
def family_notice(~S:Data,~F:Data,~select:F -> Bool,notice:P.Notice<S,F>) -> Maybe<&2,P.Notice<S,F>>:
  match notice:
    case P.Notice{tick,Rm.Removed{entity,+family}}:selected_removed(~S,~F,tick,entity,family,select(family))
    case P.Notice{_,Rm.Despawned{_}}:None{}
def append_family(~S:Data,~F:Data,~H:Type,~select:F -> Bool,streams:Streams<S,F,H>,+fresh:List<&2,P.Notice<S,F>>) -> Streams<S,F,H>:
  match streams:
    case Streams{holders,removed,despawned}:Streams{holders,T.append(~S,~F,~Unit,removed,filter(~S,~F,~(notice => family_notice(~S,~F,~select,notice)),fresh)),T.append(~S,~F,~Unit,despawned,filter(~S,~F,~(notice => despawned_notice(~S,~F,notice)),fresh))}
