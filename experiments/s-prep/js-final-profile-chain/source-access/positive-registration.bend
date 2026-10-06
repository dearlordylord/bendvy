import Base
import /tmp/bendvy-live-first-native/experiments/s-integrate/types.bend as T
import /tmp/bendvy-live-first-native/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-live-first-native/experiments/s-integrate/transaction.bend as X
import /tmp/bendvy-live-first-native/experiments/s-integrate/held.bend as H
import /tmp/bendvy-live-first-native/experiments/s-integrate/cache.bend as CC
import /tmp/bendvy-live-first-native/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-live-first-native/experiments/s-integrate/prototype-static-client.bend as SC

def invoke(owner:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32:
  HA.motion_row(~SC.motion_body,owner)
