import Base
import ./types.bend as T
import ./storage.bend as W
import ./reader-host.bend as H

def route(logs: H.Logs<T.MotionSchema,T.MotionPing>,handle: W.Handle<T.HealthSchema>) -> H.Logs<T.MotionSchema,T.MotionPing>:
  H.append_changes(T.MotionSchema,T.MotionPing,logs,1,[W.MainRemoved{handle}])
