import Base
import ./types.bend as T
import ./storage.bend as S
import ./raw-boundaries.bend as B
import ./cached-payload.bend as C
import ./cache.bend as K
import ./payload.bend as P
import ./commands.bend as Q
import ./observations.bend as O
import ./host-render.bend as J

def audit_done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> K.Cache<Raw,View> & View:
  match result:
    case (raw,view): (K.Cache{raw,cached},view)
def audit(-Raw:Type,-View:Data,get:Raw -> Raw & View,owner:K.Cache<Raw,View>) -> K.Cache<Raw,View> & View:
  match owner:
    case K.Cache{raw,cached}: audit_done(Raw,View,cached,get(raw))
def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))

def motion_initial(unit:Unit) -> T.MotionLedger: T.MotionLedger{quad(30),4}
def motion_factory(result:T.Creation<S.Factory,S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.CreateRejected{S.Factory{ns}}: IO.print("motion:factory:" ++ U32.show(ns))
    case _: IO.print("motion:factory:unexpected")
def motion_world_done(label:String,pair:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match pair:
    case (world,view):
      do IO<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":" ++ J.render_world(T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected,T.LedgerView,T.MotionMode,J.render_ledger,J.render_motion_mode,view))
        return world
def motion_world(label:String,world:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  motion_world_done(label,O.world(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,C.position_get,P.velocity_get,C.motion_ledger_get,world))
def motion_insert_observed(world:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,result:T.Position & T.PositionView) -> IO(Unit):
  match result:
    case (raw,view):
      do IO<Unit>:
        IO.print("motion:insert-owner:" ++ J.render_position(view))
        final : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_world("motion:after-insert",world)
        return Unit{}
def motion_insert_return(worldresult:T.CommandResult<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Position>) -> IO(Unit):
  match worldresult:
    case T.CommandMissing{world,raw}: motion_insert_observed(world,P.position_get(raw))
    case _: IO.print("motion:insert:unexpected")
def motion_reserve_aux(world:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,main:T.Position,mv:T.PositionView,flag:T.Selected,pair:T.Velocity & T.VelocityView) -> IO(Unit):
  match pair:
    case (aux,av):
      do IO<Unit>:
        IO.print("motion:reserve-owner:" ++ J.render_position(mv) ++ ":" ++ J.render_velocity(av) ++ ":" ++ J.render_selected(flag))
        next : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_world("motion:after-reserve",world)
        motion_insert_return(B.motion_insert(next,S.Handle{8,1},main))
def motion_reserve_main(world:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,aux:T.Velocity,flag:T.Selected,pair:T.Position & T.PositionView) -> IO(Unit):
  match pair:
    case (main,mv): motion_reserve_aux(world,main,mv,flag,P.velocity_get(aux))
def motion_reserve_return(result:T.Reservation<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.ReserveRejected{world,S.Bundle{Some{main},Some{aux},Some{flag}}}: motion_reserve_main(world,aux,flag,P.position_get(main))
    case _: IO.print("motion:reserve:unexpected")
def motion_probe() -> IO(Unit):
  do IO<Unit>:
    motion_factory(B.motion_create(motion_initial,S.Factory{4294967295},T.MotionOn{}))
    world : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_world("motion:before",S.World{7,4294967295,S.rows_empty(K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected),[S.InsertFlag{1,T.Selected{8}}],None{},T.MotionOn{}})
    motion_reserve_return(B.motion_reserve(world,S.Bundle{Some{T.Position{quad(10),7}},Some{T.Velocity{quad(20),True{}}},Some{T.Selected{9}}}))

def health_initial(unit:Unit) -> T.HealthLedger: T.HealthLedger{quad(30),4}
def health_factory(result:T.Creation<S.Factory,S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.CreateRejected{S.Factory{ns}}: IO.print("health:factory:" ++ U32.show(ns))
    case _: IO.print("health:factory:unexpected")
def health_world_done(label:String,pair:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match pair:
    case (world,view):
      do IO<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":" ++ J.render_world(T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked,T.LedgerView,T.HealthMode,J.render_ledger,J.render_health_mode,view))
        return world
def health_world(label:String,world:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  health_world_done(label,O.world(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,C.vitals_get,P.armor_get,C.health_ledger_get,world))
def health_insert_observed(world:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,result:T.Vitals & T.VitalsView) -> IO(Unit):
  match result:
    case (raw,view):
      do IO<Unit>:
        IO.print("health:insert-owner:" ++ J.render_vitals(view))
        final : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_world("health:after-insert",world)
        return Unit{}
def health_insert_return(worldresult:T.CommandResult<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Vitals>) -> IO(Unit):
  match worldresult:
    case T.CommandMissing{world,raw}: health_insert_observed(world,P.vitals_get(raw))
    case _: IO.print("health:insert:unexpected")
def health_reserve_aux(world:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,main:T.Vitals,mv:T.VitalsView,flag:T.Tracked,pair:T.Armor & T.ArmorView) -> IO(Unit):
  match pair:
    case (aux,av):
      do IO<Unit>:
        IO.print("health:reserve-owner:" ++ J.render_vitals(mv) ++ ":" ++ J.render_armor(av) ++ ":" ++ J.render_tracked(flag))
        next : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_world("health:after-reserve",world)
        health_insert_return(B.health_insert(next,S.Handle{8,1},main))
def health_reserve_main(world:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,aux:T.Armor,flag:T.Tracked,pair:T.Vitals & T.VitalsView) -> IO(Unit):
  match pair:
    case (main,mv): health_reserve_aux(world,main,mv,flag,P.armor_get(aux))
def health_reserve_return(result:T.Reservation<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.ReserveRejected{world,S.Bundle{Some{main},Some{aux},Some{flag}}}: health_reserve_main(world,aux,flag,P.vitals_get(main))
    case _: IO.print("health:reserve:unexpected")
def health_probe() -> IO(Unit):
  do IO<Unit>:
    health_factory(B.health_create(health_initial,S.Factory{4294967295},T.HealthOn{}))
    world : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_world("health:before",S.World{7,4294967295,S.rows_empty(K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked),[S.InsertFlag{1,T.Tracked{8}}],None{},T.HealthOn{}})
    health_reserve_return(B.health_reserve(world,S.Bundle{Some{T.Vitals{quad(10),9,2}},Some{T.Armor{quad(20),3}},Some{T.Tracked{9}}}))

def motion_main_audit(owner:K.Cache<T.Position,T.PositionView>) -> K.Cache<T.Position,T.PositionView> & T.PositionView: audit(T.Position,T.PositionView,P.position_get,owner)
def motion_ledger_audit(owner:K.Cache<T.MotionLedger,T.LedgerView>) -> K.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView: audit(T.MotionLedger,T.LedgerView,P.motion_ledger_get,owner)
def motion_full(+label:String,world:S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  do IO<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
    cached : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_world(label ++ ":cached",world)
    motion_world_done(label ++ ":raw",O.world(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,motion_main_audit,P.velocity_get,motion_ledger_audit,cached))
def motion_applied(label:String,result:Q.CheckedApply<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case Q.Applied{world,_}: motion_full(label,world)
    case _: IO.die(S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,1,"positive apply rejected")
def motion_positive_insert(result:T.CommandResult<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Position>) -> IO(Unit):
  match result:
    case T.CommandQueued{world}:
      do IO<Unit>:
        staged : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_full("motion:positive-insert-staged",world)
        published : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_applied("motion:positive-insert-applied",Q.apply_checked(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,S.publish(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,staged),2))
        return Unit{}
    case _: IO.print("motion:positive-insert:unexpected")
def motion_positive_reserved(result:T.Reservation<S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,S.Handle{+ns,+id}}:
      do IO<Unit>:
        IO.print("motion:positive-handle:" ++ U32.show(ns) ++ ":" ++ U32.show(id))
        staged : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_full("motion:positive-reserve-staged",world)
        published : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_applied("motion:positive-reserve-applied",Q.apply_checked(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,S.publish(T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,staged),1))
        motion_positive_insert(B.motion_insert(published,S.Handle{ns,id},T.Position{quad(100),7}))
    case _: IO.print("motion:positive-reserve:unexpected")
def motion_positive_created(result:T.Creation<S.Factory,S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.Created{S.Factory{next},world}:
      do IO<Unit>:
        IO.print("motion:positive-factory:" ++ U32.show(next))
        initialized : S.World<T.MotionSchema,K.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,K.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_full("motion:positive-factory-world",world)
        motion_positive_reserved(B.motion_reserve(initialized,S.Bundle{Some{T.Position{quad(10),7}},Some{T.Velocity{quad(20),True{}}},Some{T.Selected{9}}}))
    case _: IO.print("motion:positive-create:unexpected")
def motion_positive() -> IO(Unit):
  motion_positive_created(B.motion_create(motion_initial,S.Factory{1},T.MotionOn{}))

def health_main_audit(owner:K.Cache<T.Vitals,T.VitalsView>) -> K.Cache<T.Vitals,T.VitalsView> & T.VitalsView: audit(T.Vitals,T.VitalsView,P.vitals_get,owner)
def health_ledger_audit(owner:K.Cache<T.HealthLedger,T.LedgerView>) -> K.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView: audit(T.HealthLedger,T.LedgerView,P.health_ledger_get,owner)
def health_full(+label:String,world:S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  do IO<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
    cached : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_world(label ++ ":cached",world)
    health_world_done(label ++ ":raw",O.world(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,health_main_audit,P.armor_get,health_ledger_audit,cached))
def health_applied(label:String,result:Q.CheckedApply<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case Q.Applied{world,_}: health_full(label,world)
    case _: IO.die(S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,1,"positive apply rejected")
def health_positive_insert(result:T.CommandResult<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Vitals>) -> IO(Unit):
  match result:
    case T.CommandQueued{world}:
      do IO<Unit>:
        staged : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_full("health:positive-insert-staged",world)
        published : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_applied("health:positive-insert-applied",Q.apply_checked(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,S.publish(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,staged),2))
        return Unit{}
    case _: IO.print("health:positive-insert:unexpected")
def health_positive_reserved(result:T.Reservation<S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,S.Handle{+ns,+id}}:
      do IO<Unit>:
        IO.print("health:positive-handle:" ++ U32.show(ns) ++ ":" ++ U32.show(id))
        staged : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_full("health:positive-reserve-staged",world)
        published : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_applied("health:positive-reserve-applied",Q.apply_checked(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,S.publish(T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,staged),1))
        health_positive_insert(B.health_insert(published,S.Handle{ns,id},T.Vitals{quad(100),9,2}))
    case _: IO.print("health:positive-reserve:unexpected")
def health_positive_created(result:T.Creation<S.Factory,S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.Created{S.Factory{next},world}:
      do IO<Unit>:
        IO.print("health:positive-factory:" ++ U32.show(next))
        initialized : S.World<T.HealthSchema,K.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,K.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_full("health:positive-factory-world",world)
        health_positive_reserved(B.health_reserve(initialized,S.Bundle{Some{T.Vitals{quad(10),9,2}},Some{T.Armor{quad(20),3}},Some{T.Tracked{9}}}))
    case _: IO.print("health:positive-create:unexpected")
def health_positive() -> IO(Unit):
  health_positive_created(B.health_create(health_initial,S.Factory{1},T.HealthOn{}))

def main() -> IO(Unit):
  do IO<Unit>:
    motion_probe()
    health_probe()
    motion_positive()
    health_positive()
