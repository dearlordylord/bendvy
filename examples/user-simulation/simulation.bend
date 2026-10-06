import Base
import schema.bend as S
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W

type Row is Data:
  Row{id: U32,position: C.Access<S.PositionView>,velocity: C.Access<S.VelocityView>,health: C.Access<S.HealthView>,armor: C.Access<S.Armor>,tag: C.Access<S.Tag>}
type Snapshot is Data:
  Snapshot{rows: List<&2,Row>,dt: F32,events: List<&2,S.SimEvent>}
def row_position(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.PositionView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+position) = observed
  row_velocity(handle,position,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,S.velocity(),world,handle))
def row_velocity(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.VelocityView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+velocity) = observed
  row_health(handle,position,velocity,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.HealthRest,~S.Health,~S.HealthView,~S.HealthToken,~S.take_healths,~S.put_healths,~S.project_health,S.health(),world,handle))
def row_health(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.HealthView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+health) = observed
  row_armor(handle,position,velocity,health,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.ArmorRest,~S.Armor,~S.Armor,~S.ArmorToken,~S.take_armors,~S.put_armors,~S.project_armor,S.armor(),world,handle))
def row_armor(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>, +health: C.Access<S.HealthView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.Armor>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+armor) = observed
  row_tag(handle,position,velocity,health,armor,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.TagRest,~S.Tag,~S.Tag,~S.TagToken,~S.take_tags,~S.put_tags,~S.project_tag,S.tag(),world,handle))
def row_tag(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>, +health: C.Access<S.HealthView>, +armor: C.Access<S.Armor>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.Tag>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+tag) = observed
  (world,Row{handle_id(handle),position,velocity,health,armor,tag})
def row(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  row_position(handle,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,S.position(),world,handle))
def rows_join(+rest: List<&2,W.Handle<S.Schema>>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Row) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>:
  (world,+head) = observed
  rows_prepend(head,rows(world,rest))
def rows_prepend(+head: Row,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>:
  (world,+rest) = observed
  (world,head <> rest)
def rows(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,handles: List<&2,W.Handle<S.Schema>>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>:
  match handles:
    case []: (world,[])
    case +handle <> +rest: rows_join(rest,row(world,handle))
def resource_view(+dt: F32) -> F32 & F32:
  (dt,dt)
def snapshot_events(+rows: List<&2,Row>,+dt: F32,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,S.SimEvent>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  (world,+events) = observed
  (world,Snapshot{rows,dt,events})
def snapshot_resource(+rows: List<&2,Row>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & F32) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  (world,+dt) = observed
  snapshot_events(rows,dt,W.events_view(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def snapshot_rows(observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  (world,+rows) = observed
  snapshot_resource(rows,W.observe_resource(~S.Schema,~S.Store,~F32,~S.SimEvent,~F32,~resource_view,world))
def snapshot_handles(observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,W.Handle<S.Schema>>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  (world,+handles) = observed
  snapshot_rows(rows(world,handles))
def snapshot(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  snapshot_handles(W.handles(~S.Schema,~S.Store,~F32,~S.SimEvent,world))

def handle_id(handle: W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id
