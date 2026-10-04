import Base
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./audited-invoker.bend as AI
import ./dispatcher.bend as D
import ./systems.bend as U
import ./measurement-failure-callbacks.bend as F

def MotionTx() -> Type: AI.Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>
def motion_finish(tick:U32,result:U.BodyResult<MotionTx(),S.Handle<T.MotionSchema>>) -> IO(AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  AI.motion_finished(tick,True{},result)
def motion_invoke(iteration:U32,twice:Bool,outcome:T.Outcome,count:U32,tick:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  IO.bind(U.BodyResult<MotionTx(),S.Handle<T.MotionSchema>>,AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,
    F.motion_body(MotionTx(),S.Handle<T.MotionSchema>,twice,iteration,count,outcome,
      AI.motion_read_main,AI.motion_set_main0,AI.motion_read_main,AI.motion_set_main0,AI.motion_read_main,
      AI.motion_read_ledger,AI.motion_set_ledger0,AI.motion_read_ledger,AI.motion_spawn_main,AI.motion_emit,AI.motion_log,
      AI.Wrapped{X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,selected),audit}),result => motion_finish(tick,result))

def HealthTx() -> Type: AI.Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>
def health_finish(tick:U32,result:U.BodyResult<HealthTx(),S.Handle<T.HealthSchema>>) -> IO(AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  AI.health_finished(tick,True{},result)
def health_invoke(iteration:U32,twice:Bool,outcome:T.Outcome,count:U32,tick:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  IO.bind(U.BodyResult<HealthTx(),S.Handle<T.HealthSchema>>,AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,
    F.health_body(HealthTx(),S.Handle<T.HealthSchema>,twice,iteration,count,outcome,
      AI.health_read_main,AI.health_set_main0,AI.health_read_main,AI.health_set_main0,AI.health_read_main,
      AI.health_read_ledger,AI.health_set_ledger0,AI.health_read_ledger,AI.health_spawn_main,AI.health_emit,AI.health_log,
      AI.Wrapped{X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,selected),audit}),result => health_finish(tick,result))
