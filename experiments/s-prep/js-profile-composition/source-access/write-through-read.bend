import Base
import /tmp/bendvy-live-first-native/experiments/s-integrate/types.bend as T
import /tmp/bendvy-live-first-native/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-live-first-native/experiments/s-integrate/transaction.bend as X
import /tmp/bendvy-live-first-native/experiments/s-integrate/held.bend as H
import /tmp/bendvy-live-first-native/experiments/s-integrate/cache.bend as CC
import /tmp/bendvy-live-first-native/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-live-first-native/experiments/s-integrate/prototype-static-client.bend as SC

def invoke(owner:H.Held<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,CC.Cache<T.Position,T.PositionView>,CC.Cache<T.MotionLedger,T.LedgerView>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> H.Held<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,CC.Cache<T.Position,T.PositionView>,CC.Cache<T.MotionLedger,T.LedgerView>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32:
  SC.motion_body(~H.Held<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,CC.Cache<T.Position,T.PositionView>,CC.Cache<T.MotionLedger,T.LedgerView>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,~HA.motion_get,~HA.motion_get,~HA.motion_ledger,~HA.motion_setledger,owner)
