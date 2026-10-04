import Base
import ./types.bend as T
import ./storage.bend as S
import ./commands.bend as C
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./systems.bend as U

type Batch<W:Type,Payload:Type> is Type:
  Batch{world:W,rejected:List<Payload>}
def queued(-W:Type,-Payload:Type,rejected:List<Payload>,result:T.CommandResult<W,Payload>) -> Batch<W,Payload>:
  match result:
    case T.CommandQueued{world}: Batch{world,rejected}
    case T.CommandMissing{world,payload}: Batch{world,payload <> rejected}
def motion_stage_remove(owner:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,handle:S.Handle<T.MotionSchema>) -> X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>:
  match handle:
    case S.Handle{namespace,id}: X.tx_stage_command(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,owner,S.RemoveMain{id})
def motion_stage_despawn(owner:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,handle:S.Handle<T.MotionSchema>) -> X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>:
  match handle:
    case S.Handle{namespace,id}: X.tx_stage_command(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,owner,S.Despawn{id})
def motion_cleanup_body(-Tx:Type,set:Tx -> T.PositionToken -> U32 -> Tx,remove:Tx -> Tx,despawn:Tx -> Tx,ping:Tx -> T.MotionPing -> Tx,owner:Tx) -> U.BodyResult<Tx,Unit>:
  U.BodyResult{ping(despawn(remove(set(owner,T.PositionToken{},51))),T.MotionPing{3}),T.Success{},None{},[]}
def motion_cleanup_result(tick:U32,result:U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,Unit>) -> A.RunResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>:
  match result:
    case U.BodyResult{owner,outcome,_,observations}: A.motion_finished(U.BodyResult{owner,outcome,None{},observations},tick)
def motion_cleanup(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,p:S.Handle<T.MotionSchema>,a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,tick:U32) -> A.RunResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>:
  motion_cleanup_result(tick,motion_cleanup_body(X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,A.motion_set_main0,t => motion_stage_remove(t,a),t => motion_stage_despawn(t,b),A.motion_emit,X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,p)))
def motion_insert(owner:Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position>,handle:S.Handle<T.MotionSchema>,payload:T.Position) -> Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,rejected,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle,payload))
def motion_inserts(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,p:S.Handle<T.MotionSchema>,+a:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,p71:T.Position,a80:T.Position,c30:T.Position,a81:T.Position,b90:T.Position) -> Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position>:
  motion_insert(motion_insert(motion_insert(motion_insert(motion_insert(Batch{world,[]},p,p71),a,a80),c,c30),a,a81),b,b90)
def motion_remove(owner:Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>,handle:S.Handle<T.MotionSchema>) -> Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,rejected,C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle))
def motion_despawn(owner:Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>,handle:S.Handle<T.MotionSchema>) -> Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,rejected,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle))
def motion_dispose(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+c:S.Handle<T.MotionSchema>,a:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>) -> Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>:
  motion_despawn(motion_despawn(motion_despawn(motion_despawn(motion_remove(Batch{world,[]},c),a),p),r),c)
def health_stage_remove(owner:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,handle:S.Handle<T.HealthSchema>) -> X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>:
  match handle:
    case S.Handle{namespace,id}: X.tx_stage_command(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,owner,S.RemoveMain{id})
def health_stage_despawn(owner:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,handle:S.Handle<T.HealthSchema>) -> X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>:
  match handle:
    case S.Handle{namespace,id}: X.tx_stage_command(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,owner,S.Despawn{id})
def health_cleanup_body(-Tx:Type,set:Tx -> T.VitalsToken -> U32 -> Tx,remove:Tx -> Tx,despawn:Tx -> Tx,ping:Tx -> T.HealthPing -> Tx,owner:Tx) -> U.BodyResult<Tx,Unit>:
  U.BodyResult{ping(despawn(remove(set(owner,T.VitalsToken{},51))),T.HealthPing{3}),T.Success{},None{},[]}
def health_cleanup_result(tick:U32,result:U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,Unit>) -> A.RunResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>:
  match result:
    case U.BodyResult{owner,outcome,_,observations}: A.health_finished(U.BodyResult{owner,outcome,None{},observations},tick)
def health_cleanup(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,p:S.Handle<T.HealthSchema>,a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,tick:U32) -> A.RunResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>:
  health_cleanup_result(tick,health_cleanup_body(X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,A.health_set_main0,t => health_stage_remove(t,a),t => health_stage_despawn(t,b),A.health_emit,X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,p)))
def health_insert(owner:Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals>,handle:S.Handle<T.HealthSchema>,payload:T.Vitals) -> Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,rejected,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle,payload))
def health_inserts(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,p:S.Handle<T.HealthSchema>,+a:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,p71:T.Vitals,a80:T.Vitals,c30:T.Vitals,a81:T.Vitals,b90:T.Vitals) -> Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals>:
  health_insert(health_insert(health_insert(health_insert(health_insert(Batch{world,[]},p,p71),a,a80),c,c30),a,a81),b,b90)
def health_remove(owner:Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>,handle:S.Handle<T.HealthSchema>) -> Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,rejected,C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle))
def health_despawn(owner:Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>,handle:S.Handle<T.HealthSchema>) -> Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>:
  match owner:
    case Batch{world,rejected}: queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,rejected,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle))
def health_dispose(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+c:S.Handle<T.HealthSchema>,a:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>) -> Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>:
  health_despawn(health_despawn(health_despawn(health_despawn(health_remove(Batch{world,[]},c),a),p),r),c)
