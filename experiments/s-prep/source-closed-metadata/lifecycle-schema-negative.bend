import Base
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/streams.bend as S
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/storage.bend as W
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/types.bend as T

def bad(log:S.LifeLog<W.Handle<T.MotionSchema>>) -> S.LifeLog<W.Handle<T.HealthSchema>>:
  S.prototype_closed_stream_append_lifecycle(W.Handle<T.HealthSchema>,log,1,[])
def main() -> U32: 0
