import Base
import schema.bend as S
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/events.bend as E
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/query.bend as Q
import ../../src/ecs/provider.bend as Pv

type Row is Data:
  Row{id: U32,position: C.Access<S.PositionView>,velocity: C.Access<S.VelocityView>,health: C.Access<S.HealthView>,armor: C.Access<S.Armor>,tag: C.Access<S.Tag>}
type Snapshot is Data:
  Snapshot{rows: List<&2,Row>,dt: F32,events: List<&2,S.SimEvent>}
def handle_id(handle: W.Handle<S.Schema>) -> U32:
  match handle:
    case W.Handle{_,id}: id
def row_tag(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>, +health: C.Access<S.HealthView>, +armor: C.Access<S.Armor>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.Tag>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+tag) = observed
  (world,Row{handle_id(handle),position,velocity,health,armor,tag})
def row_armor(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>, +health: C.Access<S.HealthView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.Armor>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+armor) = observed
  row_tag(handle,position,velocity,health,armor,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.TagRest,~S.Tag,~S.Tag,~S.TagToken,~S.take_tags,~S.put_tags,~S.project_tag,S.tag(),world,handle))
def row_health(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>, +velocity: C.Access<S.VelocityView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.HealthView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+health) = observed
  row_armor(handle,position,velocity,health,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.ArmorRest,~S.Armor,~S.Armor,~S.ArmorToken,~S.take_armors,~S.put_armors,~S.project_armor,S.armor(),world,handle))
def row_velocity(+handle: W.Handle<S.Schema>, +position: C.Access<S.PositionView>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.VelocityView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+velocity) = observed
  row_health(handle,position,velocity,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.HealthRest,~S.Health,~S.HealthView,~S.HealthToken,~S.take_healths,~S.put_healths,~S.project_health,S.health(),world,handle))
def row_position(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & C.Access<S.PositionView>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  (world,+position) = observed
  row_velocity(handle,position,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,S.velocity(),world,handle))
def row(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Row:
  row_position(handle,C.get(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,S.position(),world,handle))
def row_accumulate(+prior: List<&2,Row>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Row) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>:
  (world,+head) = observed
  (world,head <> prior)
def rows(handles: List<&2,W.Handle<S.Schema>>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & List<&2,Row>:
  match handles:
    case []:
      (world,+prior) = observed
      (world,List.reverse(&2,Row,prior))
    case +handle <> rest:
      (world,+prior) = observed
      rows(rest,row_accumulate(prior,row(world,handle)))
def resource_view(dt: F32) -> F32 & F32:
  match dt:
    case F32{+data}: (F32{data},F32{data})
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
  snapshot_rows(rows(handles,(world,[])))
def snapshot(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot:
  snapshot_handles(W.handles(~S.Schema,~S.Store,~F32,~S.SimEvent,world))


# Observation owns an independent library reader; no application event cursor.
type Observation is Type:
  Observation{world: W.World<S.Schema,S.Store,F32,S.SimEvent>,reader: E.Reader<S.Schema>,snapshot: Snapshot}
  ObservationRejected{world: W.World<S.Schema,S.Store,F32,S.SimEvent>,reader: E.Reader<S.Schema>}
def observed_events(+rows: List<&2,Row>,+dt: F32,result: E.Observed<S.Schema,S.Store,F32,S.SimEvent>) -> Observation:
  match result:
    case E.Read{world,reader,events}: Observation{world,reader,Snapshot{rows,dt,events}}
    case E.ForeignReader{world,reader}: ObservationRejected{world,reader}
def observed_snapshot(reader: E.Reader<S.Schema>,result: W.World<S.Schema,S.Store,F32,S.SimEvent> & Snapshot) -> Observation:
  match result:
    case (world,Snapshot{+rows,+dt,_}): observed_events(rows,dt,E.read(~S.Schema,~S.Store,~F32,~S.SimEvent,world,reader))
def observe(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,reader: E.Reader<S.Schema>) -> Observation:
  observed_snapshot(reader,snapshot(world))

type UserError is Data:
  UnsupportedFixture{}
  Rejected{}
def movement_write(~H: Type,~set: H -> S.Position -> H,ctx: H,owner: Maybe<&1,S.Position>) -> H & T.Outcome<UserError>:
  match owner:
    case None{}: (ctx,T.Failure{UnsupportedFixture{}})
    case Some{owner}: (set(ctx,owner),T.Success{})
def movement_numbers(~H: Type,~set: H -> S.Position -> H,+x: F32,+trail: List<&2,U32>,+dx: F32,observed: H & F32) -> H & T.Outcome<UserError>:
  (ctx,+dt) = observed
  movement_write(~H,~set,ctx,S.position_owner(S.PositionView{(x + dx * dt : F32),trail}))
def movement_velocity(~H: Type,~set: H -> S.Position -> H,+x: F32,+trail: List<&2,U32>,velocity: S.VelocityView,observed: H & F32) -> H & T.Outcome<UserError>:
  match velocity:
    case S.VelocityView{+dx,_}: movement_numbers(~H,~set,x,trail,dx,observed)
def movement_dt(~H: Type,~set: H -> S.Position -> H,position: S.PositionView,velocity: S.VelocityView,observed: H & F32) -> H & T.Outcome<UserError>:
  match position:
    case S.PositionView{+x,+trail}: movement_velocity(~H,~set,x,trail,velocity,observed)
def movement_aux(~H: Type,~set: H -> S.Position -> H,~resource_get: H -> H & F32,+position: S.PositionView,observed: H & C.Access<S.VelocityView>) -> H & T.Outcome<UserError>:
  match observed:
    case (ctx,C.Found{+velocity}): movement_dt(~H,~set,position,velocity,resource_get(ctx))
    case (ctx,_): (ctx,T.Failure{UnsupportedFixture{}})
def movement_get(~H: Type,~set: H -> S.Position -> H,~aux: H -> H & C.Access<S.VelocityView>,~resource_get: H -> H & F32,observed: H & C.Access<S.PositionView>) -> H & T.Outcome<UserError>:
  match observed:
    case (ctx,C.Found{+position}): movement_aux(~H,~set,~resource_get,position,aux(ctx))
    case (ctx,_): (ctx,T.Failure{UnsupportedFixture{}})
def movement_body(~H: Type,~get: H -> H & C.Access<S.PositionView>,~set: H -> S.Position -> H,~aux: H -> H & C.Access<S.VelocityView>,~resource_get: H -> H & F32,args: Unit,handle: W.Handle<S.Schema>,ctx: H) -> H & T.Outcome<UserError>:
  movement_get(~H,~set,~aux,~resource_get,get(ctx))
def movement(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> T.Returned<W.World<S.Schema,S.Store,F32,S.SimEvent>,Pv.Error<UserError>>:
  Q.each_rw_read_resource(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,~F32,~resource_view,~S.Bundle,~S.populate,~S.clear,~Unit,~UserError,~movement_body,S.position(),S.velocity(),Q.Required{},world,Unit{})
def damage_publish(~H: Type,~emit: H -> S.SimEvent -> H,~despawn: H -> H,+id: U32,+amount: F32,+hp: F32,dead: Bool,ctx: H) -> H & T.Outcome<UserError>:
  match dead:
    case False{}: (emit(ctx,S.Hit{id,amount,hp}),T.Success{})
    case True{}: (despawn(emit(emit(ctx,S.Hit{id,amount,hp}),S.Death{id})),T.Success{})
def damage_write(~H: Type,~set: H -> S.Health -> H,~emit: H -> S.SimEvent -> H,~despawn: H -> H,+id: U32,+amount: F32,+hp: F32,ctx: H,owner: Maybe<&1,S.Health>) -> H & T.Outcome<UserError>:
  match owner:
    case None{}: (ctx,T.Failure{UnsupportedFixture{}})
    case Some{owner}: damage_publish(~H,~emit,~despawn,id,amount,hp,F32.is_le(hp,0.0),set(ctx,owner))
def damage_amount(~H: Type,~set: H -> S.Health -> H,~emit: H -> S.SimEvent -> H,~despawn: H -> H,+id: U32,+amount: F32,health: S.HealthView,ctx: H) -> H & T.Outcome<UserError>:
  match health:
    case S.HealthView{+hp,+history}: damage_write(~H,~set,~emit,~despawn,id,amount,(hp - amount : F32),ctx,S.health_owner(S.HealthView{(hp - amount : F32),history}))
def armor_value(armor: C.Access<S.Armor>) -> F32:
  match armor:
    case C.Found{S.Armor{value}}: value
    case _: 0.0
def damage_aux(~H: Type,~set: H -> S.Health -> H,~emit: H -> S.SimEvent -> H,~despawn: H -> H,+id: U32,+health: S.HealthView,observed: H & C.Access<S.Armor>) -> H & T.Outcome<UserError>:
  (ctx,+armor) = observed
  damage_amount(~H,~set,~emit,~despawn,id,(2.0 - armor_value(armor) : F32),health,ctx)
def damage_get(~H: Type,~set: H -> S.Health -> H,~aux: H -> H & C.Access<S.Armor>,~emit: H -> S.SimEvent -> H,~despawn: H -> H,+id: U32,observed: H & C.Access<S.HealthView>) -> H & T.Outcome<UserError>:
  match observed:
    case (ctx,C.Found{+health}): damage_aux(~H,~set,~emit,~despawn,id,health,aux(ctx))
    case (ctx,_): (ctx,T.Failure{UnsupportedFixture{}})
def damage_body(~H: Type,~get: H -> H & C.Access<S.HealthView>,~set: H -> S.Health -> H,~aux: H -> H & C.Access<S.Armor>,~resource_get: H -> H & F32,~resource_set: H -> F32 -> H,~emit: H -> S.SimEvent -> H,~despawn: H -> H,~spawn: H -> S.Bundle -> H & W.Reservation<S.Schema>,args: Unit,handle: W.Handle<S.Schema>,ctx: H) -> H & T.Outcome<UserError>:
  damage_get(~H,~set,~aux,~emit,~despawn,handle_id(handle),get(ctx))
def damage(world: W.World<S.Schema,S.Store,F32,S.SimEvent>) -> T.Returned<W.World<S.Schema,S.Store,F32,S.SimEvent>,Pv.Error<UserError>>:
  Q.each_rw_read(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.HealthRest,~S.Health,~S.HealthView,~S.HealthToken,~S.take_healths,~S.put_healths,~S.project_health,~S.ArmorRest,~S.Armor,~S.Armor,~S.ArmorToken,~S.take_armors,~S.put_armors,~S.project_armor,~F32,~resource_view,~S.Bundle,~S.populate,~S.clear,~Unit,~UserError,~damage_body,S.health(),S.armor(),Q.Optional{},world,Unit{})
def retry_spawned(~H: Type,observed: H & W.Reservation<S.Schema>) -> H & T.Outcome<UserError>:
  (ctx,_) = observed
  (ctx,T.Failure{Rejected{}})
def retry_owner(~H: Type,~set: H -> S.Position -> H,~resource_set: H -> F32 -> H,~emit: H -> S.SimEvent -> H,~spawn: H -> S.Bundle -> H & W.Reservation<S.Schema>,ctx: H,owner: Maybe<&1,S.Position>) -> H & T.Outcome<UserError>:
  match owner:
    case None{}: (ctx,T.Failure{UnsupportedFixture{}})
    case Some{owner}: retry_spawned(~H,spawn(emit(resource_set(set(ctx,owner),9.0),S.Hit{999,999.0,999.0}),S.ghost()))
def retry_view(~H: Type,~set: H -> S.Position -> H,~resource_set: H -> F32 -> H,~emit: H -> S.SimEvent -> H,~spawn: H -> S.Bundle -> H & W.Reservation<S.Schema>,ctx: H,position: S.PositionView) -> H & T.Outcome<UserError>:
  match position:
    case S.PositionView{_,+trail}: retry_owner(~H,~set,~resource_set,~emit,~spawn,ctx,S.position_owner(S.PositionView{999.0,trail}))
def retry_get(~H: Type,~set: H -> S.Position -> H,~resource_set: H -> F32 -> H,~emit: H -> S.SimEvent -> H,~spawn: H -> S.Bundle -> H & W.Reservation<S.Schema>,observed: H & C.Access<S.PositionView>) -> H & T.Outcome<UserError>:
  match observed:
    case (ctx,C.Found{position}): retry_view(~H,~set,~resource_set,~emit,~spawn,ctx,position)
    case (ctx,_): (ctx,T.Failure{UnsupportedFixture{}})
def retry_body(~H: Type,~get: H -> H & C.Access<S.PositionView>,~set: H -> S.Position -> H,~aux: H -> H & C.Access<S.VelocityView>,~resource_get: H -> H & F32,~resource_set: H -> F32 -> H,~emit: H -> S.SimEvent -> H,~despawn: H -> H,~spawn: H -> S.Bundle -> H & W.Reservation<S.Schema>,args: Bool,handle: W.Handle<S.Schema>,ctx: H) -> H & T.Outcome<UserError>:
  match args:
    case False{}: (resource_set(ctx,1.0),T.Success{})
    case True{}: retry_get(~H,~set,~resource_set,~emit,~spawn,get(ctx))
def retry(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,fail: Bool) -> T.Returned<W.World<S.Schema,S.Store,F32,S.SimEvent>,Pv.Error<UserError>>:
  Q.each_rw_read(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,~S.VelocityRest,~S.Velocity,~S.VelocityView,~S.VelocityToken,~S.take_velocities,~S.put_velocities,~S.project_velocity,~F32,~resource_view,~S.Bundle,~S.populate,~S.clear,~Bool,~UserError,~retry_body,S.position(),S.velocity(),Q.Required{},world,fail)
