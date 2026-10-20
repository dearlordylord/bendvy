import Base
import entity-key.bend as Key
import ./snapshot-schema.bend as Schema
import ./snapshot-data.bend as Export
import ./decode-data.bend as D
import ./world.bend as W

def prepend(~C:Type,entity:Export.Entity,observed:C & List<&2,Export.Entity>) -> C & List<&2,Export.Entity>:
  match observed:
    case (owner,entities):(owner,entity <> entities)
def stepped(~C:Type,next:C -> C & List<&2,Export.Entity>,id:Key.Key,observed:C & List<&2,D.Field>) -> C & List<&2,Export.Entity>:
  match observed:
    case (owner,fields):prepend(~C,Export.Entity{id,fields},next(owner))
def rows(~S:Data,~C:Type,~components:U32 -> C -> C & List<&2,D.Field>,handles:List<&2,W.Handle<S>>,owner:C) -> C & List<&2,Export.Entity>:
  match handles:
    case []:(owner,[])
    case W.Handle{_,+id} <> rest:stepped(~C,next => rows(~S,~C,~components,rest,next),id,components(Key.index(id),owner))
# Public call requires the SAME complete ordinary schema to be save-eligible.
# Plain leaves propagate False through product and cannot call this method.
# Export version-1 detached entity/component/resource Data and allocator progress,
# returning the live World owner through every projection. Live handles supply
# saved keys; this is not a runtime checkpoint or an implicit structural barrier.
# The complete schema must carry True eligibility: persisted leaves use declared
# projections/codecs, while explicit transient leaves are omitted. Closed schema
# projections and name bindings remain trusted setup, not arbitrary descriptor
# validation inferred from this wrapper. The save contains no registration owners,
# reader positions or event-log checkpoint. Pending structural commands refuse
# BEFORE any projection, returning the same World/queue as RefusedPending. No
# implicit barrier runs; apply an explicit barrier and retry when appropriate.
# See docs/parity/snapshot-export.md and its ordinary constructor/save consumer.
def save(~S:Data,~C:Type,~R:Type,~E:Data,~components:U32 -> C -> C & List<&2,D.Field>,~resources:R -> R & List<&2,D.Field>,schema:Schema.Schema<S,C,R,True{},components,resources>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Export.Outcome<Export.Snapshot>:
  Export.basic(~S,~C,~R,~E,~rows(~S,~C,~components),~resources,world)
