import Base
import ./types.bend as T
import ./storage.bend as S
import ./cache.bend as CC
import ./cached-payload.bend as CP
import ./transaction.bend as X
import ./audited-invoker.bend as AI

def motion_return(result:T.Reservation<AI.Wrapped<X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,CC.Cache<T.Position,T.PositionView>>) -> T.Reservation<AI.Wrapped<X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  match result:
    case T.Reserved{owner,handle}: T.Reserved{owner,handle}
    case T.ReserveRejected{owner,CC.Cache{raw,_}}: T.ReserveRejected{owner,raw}
def motion_spawn_main(owner:AI.Wrapped<X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>>,raw:T.Position) -> T.Reservation<AI.Wrapped<X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  motion_return(AI.motion_spawn_main(owner,CP.position_new(raw)))

def health_return(result:T.Reservation<AI.Wrapped<X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,CC.Cache<T.Vitals,T.VitalsView>>) -> T.Reservation<AI.Wrapped<X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  match result:
    case T.Reserved{owner,handle}: T.Reserved{owner,handle}
    case T.ReserveRejected{owner,CC.Cache{raw,_}}: T.ReserveRejected{owner,raw}
def health_spawn_main(owner:AI.Wrapped<X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>>,raw:T.Vitals) -> T.Reservation<AI.Wrapped<X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  health_return(AI.health_spawn_main(owner,CP.vitals_new(raw)))
