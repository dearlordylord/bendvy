import Base
import /tmp/bendvy-closed-frame-probe-v2/experiments/s-integrate/streams.bend as S
import /tmp/bendvy-closed-frame-probe-v2/experiments/s-integrate/storage.bend as W
import /tmp/bendvy-closed-frame-probe-v2/experiments/s-integrate/types.bend as T

def finish(old:S.Inspection<W.Handle<T.MotionSchema>>,result:S.Buffer<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>) -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  match result:
    case (_,current): (old,current)
def retained(result:S.Buffer<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>) -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  match result:
    case (buffer,old): finish(old,S.observe_buffer(W.Handle<T.MotionSchema>,S.prototype_closed_frame_trim_buffer(W.Handle<T.MotionSchema>,buffer,0,[])))
def main() -> S.Inspection<W.Handle<T.MotionSchema>> & S.Inspection<W.Handle<T.MotionSchema>>:
  retained(S.observe_buffer(W.Handle<T.MotionSchema>,S.prototype_closed_stream_append_buffer(W.Handle<T.MotionSchema>,S.prototype_closed_stream_append_buffer(W.Handle<T.MotionSchema>,S.Buffer{1,0,0,[],[]},1,[W.Handle{7,1}]),2,[W.Handle{8,2}])))
