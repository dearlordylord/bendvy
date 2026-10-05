import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as Q
import ./cache.bend as C
import ./cached-payload.bend as P

def motion_main(raw:Maybe<T.Position>) -> Maybe<C.Cache<T.Position,T.PositionView>>:
  match raw:
    case None{}: None{}
    case Some{raw}: Some{P.position_new(raw)}
def motion_raw_main(owner:Maybe<C.Cache<T.Position,T.PositionView>>) -> Maybe<T.Position>:
  match owner:
    case None{}: None{}
    case Some{C.Cache{raw,_}}: Some{raw}
def motion_bundle(raw:S.Bundle<T.Position,T.Velocity,T.Selected>) -> S.Bundle<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>:
  match raw:
    case S.Bundle{main,aux,flag}: S.Bundle{motion_main(main),aux,flag}
def motion_raw_bundle(owner:S.Bundle<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>) -> S.Bundle<T.Position,T.Velocity,T.Selected>:
  match owner:
    case S.Bundle{main,aux,flag}: S.Bundle{motion_raw_main(main),aux,flag}
def motion_reserve_return(result:T.Reservation<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> T.Reservation<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>:
  match result:
    case T.Reserved{world,handle}: T.Reserved{world,handle}
    case T.ReserveRejected{world,bundle}: T.ReserveRejected{world,motion_raw_bundle(bundle)}
def motion_reserve(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,raw:S.Bundle<T.Position,T.Velocity,T.Selected>) -> T.Reservation<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>:
  motion_reserve_return(Q.reserve(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,motion_bundle(raw)))
def motion_insert_return(result:T.CommandResult<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,C.Cache<T.Position,T.PositionView>>) -> T.CommandResult<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Position>:
  match result:
    case T.CommandQueued{world}: T.CommandQueued{world}
    case T.CommandMissing{world,C.Cache{raw,_}}: T.CommandMissing{world,raw}
def motion_insert(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle:S.Handle<T.MotionSchema>,raw:T.Position) -> T.CommandResult<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Position>:
  motion_insert_return(Q.insert_main(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,handle,P.position_new(raw)))
def motion_ledger(~initialize:Unit -> T.MotionLedger,unit:Unit) -> C.Cache<T.MotionLedger,T.LedgerView>:
  P.motion_ledger_new(initialize(unit))
def motion_create(~initialize:Unit -> T.MotionLedger,factory:S.Factory,mode:T.MotionMode) -> T.Creation<S.Factory,S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
  I.create(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,unit => motion_ledger(~initialize,unit),factory,mode)

def health_main(raw:Maybe<T.Vitals>) -> Maybe<C.Cache<T.Vitals,T.VitalsView>>:
  match raw:
    case None{}: None{}
    case Some{raw}: Some{P.vitals_new(raw)}
def health_raw_main(owner:Maybe<C.Cache<T.Vitals,T.VitalsView>>) -> Maybe<T.Vitals>:
  match owner:
    case None{}: None{}
    case Some{C.Cache{raw,_}}: Some{raw}
def health_bundle(raw:S.Bundle<T.Vitals,T.Armor,T.Tracked>) -> S.Bundle<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>:
  match raw:
    case S.Bundle{main,aux,flag}: S.Bundle{health_main(main),aux,flag}
def health_raw_bundle(owner:S.Bundle<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>) -> S.Bundle<T.Vitals,T.Armor,T.Tracked>:
  match owner:
    case S.Bundle{main,aux,flag}: S.Bundle{health_raw_main(main),aux,flag}
def health_reserve_return(result:T.Reservation<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>) -> T.Reservation<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>:
  match result:
    case T.Reserved{world,handle}: T.Reserved{world,handle}
    case T.ReserveRejected{world,bundle}: T.ReserveRejected{world,health_raw_bundle(bundle)}
def health_reserve(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,raw:S.Bundle<T.Vitals,T.Armor,T.Tracked>) -> T.Reservation<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>:
  health_reserve_return(Q.reserve(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,health_bundle(raw)))
def health_insert_return(result:T.CommandResult<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,C.Cache<T.Vitals,T.VitalsView>>) -> T.CommandResult<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Vitals>:
  match result:
    case T.CommandQueued{world}: T.CommandQueued{world}
    case T.CommandMissing{world,C.Cache{raw,_}}: T.CommandMissing{world,raw}
def health_insert(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle:S.Handle<T.HealthSchema>,raw:T.Vitals) -> T.CommandResult<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Vitals>:
  health_insert_return(Q.insert_main(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,handle,P.vitals_new(raw)))
def health_ledger(~initialize:Unit -> T.HealthLedger,unit:Unit) -> C.Cache<T.HealthLedger,T.LedgerView>:
  P.health_ledger_new(initialize(unit))
def health_create(~initialize:Unit -> T.HealthLedger,factory:S.Factory,mode:T.HealthMode) -> T.Creation<S.Factory,S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
  I.create(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,unit => health_ledger(~initialize,unit),factory,mode)
