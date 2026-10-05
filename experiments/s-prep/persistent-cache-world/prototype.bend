import Base
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./persistent-payload.bend as K
import ./uncached-payload.bend as P
import ./cache.bend as C
import ./callbacks.bend as B
import ./observations.bend as O
import ./host-render.bend as R

def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
def pings_text(values:List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{x,tail}: U32.show(x) ++ ";" ++ pings_text(tail)

def motion_placed(result:S.Placement<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  match result:
    case S.Placed{rows}: S.World{7,2,rows,[],Some{K.motion_ledger_new(T.MotionLedger{quad(100),4})},T.MotionOn{}}
    case S.Rejected{rows,_}: S.World{7,2,rows,[],Some{K.motion_ledger_new(T.MotionLedger{quad(100),4})},T.MotionOn{}}
def motion_new() -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  motion_placed(S.rows_place(C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,S.rows_empty(C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected),S.Row{1,Some{K.position_new(T.Position{quad(10),7})},Some{T.Velocity{quad(110),True{}}},Some{T.Selected{8}},3,4}))
def motion_read_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle:S.Handle<T.MotionSchema>) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & T.Access<T.PositionView>:
  S.with_main(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,world,handle,K.position_get)
def motion_ledger_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & Maybe<&2,T.LedgerView>:
  S.with_ledger(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.LedgerView,world,K.motion_ledger_get)
def motion_write_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle:S.Handle<T.MotionSchema>,value:U32) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & T.Access<U32>:
  X.storage_set_main0(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,K.position_swap,world,handle,value)
def motion_ledger_write_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,value:U32) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & Maybe<&2,U32>:
  X.storage_set_ledger0(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,K.motion_ledger_swap,world,value)
def motion_restore_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle:S.Handle<T.MotionSchema>,value:U32) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  X.storage_restore_main0(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,K.position_swap,world,handle,value)
def motion_ledger_restore_world(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,value:U32) -> S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  X.storage_restore_ledger0(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,K.motion_ledger_swap,world,value)
def motion_get(owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,token:T.PositionToken) -> X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & T.Access<T.PositionView>:
  match token:
    case T.PositionToken{}: X.tx_read_main(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,T.PositionView,motion_read_world,owner)
def motion_ledger(owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,token:T.MotionLedgerToken) -> X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & Maybe<&2,T.LedgerView>:
  match token:
    case T.MotionLedgerToken{}: X.tx_read_ledger(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,T.LedgerView,motion_ledger_world,owner)
def motion_set(owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,token:T.PositionToken,value:U32) -> X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>:
  match token:
    case T.PositionToken{}: X.tx_set_main0(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,motion_write_world,owner,value)
def motion_setledger(owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,token:T.MotionLedgerToken,value:U32) -> X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>:
  match token:
    case T.MotionLedgerToken{}: X.tx_set_ledger0(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,motion_ledger_write_world,owner,value)
def motion_invoke(~client:@-Owner:Type -> (Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>) -> (Owner -> T.PositionToken -> U32 -> Owner) -> (Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.MotionLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32:
  client(X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,motion_get,motion_set,motion_ledger,motion_setledger,owner)
def motion_raw_snapshot(+label:String,cached:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,result:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case (world,raw):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":cached:" ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,cached))
        IO.print(label ++ ":raw:" ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,raw))
        return world
def motion_cached_snapshot(label:String,result:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case (world,cached): motion_raw_snapshot(label,cached,O.world(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,K.position_uncached,P.velocity_get,K.motion_ledger_uncached,world))
def motion_snapshot(label:String,world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  motion_cached_snapshot(label,O.world(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,K.position_get,P.velocity_get,K.motion_ledger_get,world))
def motion_published(label:String,result:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,U32>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case (world,pings):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":pings:" ++ pings_text(pings))
        return world
def motion_finish(fail:Bool,tick:U32,owner:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match fail:
    case False{}: motion_published("motion:tick1",X.storage_commit(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,X.tx_stage_ping(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,X.tx_stage_command(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,owner,S.InsertFlag{1,T.Selected{9}}),11)),tick))
    case True{}: motion_published("motion:tick2",X.storage_commit(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,X.tx_finish_failure(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,motion_restore_world,motion_ledger_restore_world,X.tx_stage_ping(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,X.tx_stage_command(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,motion_set(motion_setledger(motion_set(owner,T.PositionToken{},99),T.MotionLedgerToken{},88),T.PositionToken{},77),S.Despawn{1}),12)),tick))
def motion_body_return(fail:Bool,tick:U32,result:X.Tx<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case (owner,sum):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print("motion:sum:" ++ U32.show(sum))
        motion_finish(fail,tick,owner)
def motion_tick(fail:Bool,tick:U32,world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  motion_body_return(fail,tick,motion_invoke(B.motion_body,X.tx_begin(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,world,S.Handle{7,1})))
def motion_case() -> IO(Unit):
  do IO<Unit>:
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_snapshot("motion:init",motion_new())
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_tick(False{},9,world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_snapshot("motion:tick1",world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_tick(True{},10,world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_snapshot("motion:tick2",world)
    return Unit{}

def health_placed(result:S.Placement<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  match result:
    case S.Placed{rows}: S.World{7,2,rows,[],Some{K.health_ledger_new(T.HealthLedger{quad(100),4})},T.HealthOn{}}
    case S.Rejected{rows,_}: S.World{7,2,rows,[],Some{K.health_ledger_new(T.HealthLedger{quad(100),4})},T.HealthOn{}}
def health_new() -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  health_placed(S.rows_place(C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,S.rows_empty(C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked),S.Row{1,Some{K.vitals_new(T.Vitals{quad(10),9,2})},Some{T.Armor{quad(110),3}},Some{T.Tracked{8}},3,4}))
def health_read_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle:S.Handle<T.HealthSchema>) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & T.Access<T.VitalsView>:
  S.with_main(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,world,handle,K.vitals_get)
def health_ledger_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & Maybe<&2,T.LedgerView>:
  S.with_ledger(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.LedgerView,world,K.health_ledger_get)
def health_write_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle:S.Handle<T.HealthSchema>,value:U32) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & T.Access<U32>:
  X.storage_set_main0(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,K.vitals_swap,world,handle,value)
def health_ledger_write_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,value:U32) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & Maybe<&2,U32>:
  X.storage_set_ledger0(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,K.health_ledger_swap,world,value)
def health_restore_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle:S.Handle<T.HealthSchema>,value:U32) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  X.storage_restore_main0(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,K.vitals_swap,world,handle,value)
def health_ledger_restore_world(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,value:U32) -> S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  X.storage_restore_ledger0(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,K.health_ledger_swap,world,value)
def health_get(owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,token:T.VitalsToken) -> X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & T.Access<T.VitalsView>:
  match token:
    case T.VitalsToken{}: X.tx_read_main(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,T.VitalsView,health_read_world,owner)
def health_ledger(owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,token:T.HealthLedgerToken) -> X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & Maybe<&2,T.LedgerView>:
  match token:
    case T.HealthLedgerToken{}: X.tx_read_ledger(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,T.LedgerView,health_ledger_world,owner)
def health_set(owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,token:T.VitalsToken,value:U32) -> X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>:
  match token:
    case T.VitalsToken{}: X.tx_set_main0(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,health_write_world,owner,value)
def health_setledger(owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,token:T.HealthLedgerToken,value:U32) -> X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>:
  match token:
    case T.HealthLedgerToken{}: X.tx_set_ledger0(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,health_ledger_write_world,owner,value)
def health_invoke(~client:@-Owner:Type -> (Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>) -> (Owner -> T.VitalsToken -> U32 -> Owner) -> (Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.HealthLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>) -> X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32:
  client(X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,health_get,health_set,health_ledger,health_setledger,owner)
def health_raw_snapshot(+label:String,cached:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,result:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case (world,raw):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":cached:" ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,cached))
        IO.print(label ++ ":raw:" ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,raw))
        return world
def health_cached_snapshot(label:String,result:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case (world,cached): health_raw_snapshot(label,cached,O.world(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,K.vitals_uncached,P.armor_get,K.health_ledger_uncached,world))
def health_snapshot(label:String,world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  health_cached_snapshot(label,O.world(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,K.vitals_get,P.armor_get,K.health_ledger_get,world))
def health_published(label:String,result:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,U32>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case (world,pings):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":pings:" ++ pings_text(pings))
        return world
def health_finish(fail:Bool,tick:U32,owner:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match fail:
    case False{}: health_published("health:tick1",X.storage_commit(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,X.tx_stage_ping(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,X.tx_stage_command(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,owner,S.InsertFlag{1,T.Tracked{9}}),11)),tick))
    case True{}: health_published("health:tick2",X.storage_commit(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,X.tx_finish_failure(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,health_restore_world,health_ledger_restore_world,X.tx_stage_ping(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,X.tx_stage_command(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,health_set(health_setledger(health_set(owner,T.VitalsToken{},99),T.HealthLedgerToken{},88),T.VitalsToken{},77),S.Despawn{1}),12)),tick))
def health_body_return(fail:Bool,tick:U32,result:X.Tx<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case (owner,sum):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print("health:sum:" ++ U32.show(sum))
        health_finish(fail,tick,owner)
def health_tick(fail:Bool,tick:U32,world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  health_body_return(fail,tick,health_invoke(B.health_body,X.tx_begin(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,world,S.Handle{7,1})))
def health_case() -> IO(Unit):
  do IO<Unit>:
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_snapshot("health:init",health_new())
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_tick(False{},9,world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_snapshot("health:tick1",world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_tick(True{},10,world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_snapshot("health:tick2",world)
    return Unit{}

def main() -> IO(Unit):
  do IO<Unit>:
    motion_case()
    health_case()
