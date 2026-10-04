import Base
import ./readers.bend as readers
import ./types.bend as T
import ./storage.bend as S
import ./payload.bend as P
import ./query.bend as Q
import ./schedule.bend as schedule
import ./observations.bend as O
import ./host.bend as H
import ./audited-invoker.bend as V
import ./dispatcher.bend as D
def motion_read(-Owner:Type,-Aux:Type,get:Owner -> T.PositionToken -> Owner & T.PositionView,aux_get:Aux -> Aux & Maybe<&2,T.VelocityView>,handle:S.Handle<T.MotionSchema>,flag:Maybe<&2,T.Selected>,owner:Owner,aux:Aux) -> Owner & (Aux & O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>):
  O.client(T.MotionSchema,T.PositionToken,T.PositionView,T.VelocityView,T.Selected,T.PositionToken{},Owner,Aux,get,aux_get,handle,flag,owner,aux)
def motion_query(owner:H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>) -> H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  H.query(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,T.PositionToken,P.position_get,P.velocity_get,motion_read,Q.Required{},owner)
def motion_closed_a(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  V.motion_a(1,T.Failure{99},2,world,selected,audit)
def motion_closed_b(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  V.motion_b(schedule.BFail{},2,3,world,selected,audit)
def health_read(-Owner:Type,-Aux:Type,get:Owner -> T.VitalsToken -> Owner & T.VitalsView,aux_get:Aux -> Aux & Maybe<&2,T.ArmorView>,handle:S.Handle<T.HealthSchema>,flag:Maybe<&2,T.Tracked>,owner:Owner,aux:Aux) -> Owner & (Aux & O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>):
  O.client(T.HealthSchema,T.VitalsToken,T.VitalsView,T.ArmorView,T.Tracked,T.VitalsToken{},Owner,Aux,get,aux_get,handle,flag,owner,aux)
def health_query(owner:H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>) -> H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>:
  H.query(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,T.VitalsToken,P.vitals_get,P.armor_get,health_read,Q.Required{},owner)
def health_closed_a(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  V.health_a(1,T.Failure{99},2,world,selected,audit)
def health_closed_b(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  V.health_b(schedule.BFail{},2,3,world,selected,audit)

def actual_motion_read(owner:H.MotionHost(),run:readers.Run) -> H.MotionHost() & readers.Run:
  H.motion_read("B",2,owner,run)
def actual_health_read(owner:H.HealthHost(),run:readers.Run) -> H.HealthHost() & readers.Run:
  H.health_read("B",2,owner,run)
