import Base
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/streams.bend as S
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/storage.bend as W
import /tmp/bendvy-closed-streams-probe/experiments/s-integrate/types.bend as T

def finish(old:S.Inspection<W.Handle<T.MotionSchema>>,result:S.Buffer<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>) -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  match result:
    case (_,current): (old,current)
def retained(result:S.Buffer<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>) -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  match result:
    case (buffer,old): finish(old,S.observe_buffer(W.Handle<T.MotionSchema>,S.prototype_closed_stream_append_buffer(W.Handle<T.MotionSchema>,buffer,2,[W.Handle{8,2}])) )
def main() -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  retained(S.observe_buffer(W.Handle<T.MotionSchema>,S.prototype_closed_stream_append_buffer(W.Handle<T.MotionSchema>,S.Buffer{8,0,0,[],[]},1,[W.Handle{7,1}])))
