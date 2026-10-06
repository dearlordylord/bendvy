import Base
import ./types.bend as T
import ./storage.bend as W
import ./schedule.bend as K
import ./dispatcher.bend as D
import ./host.bend as H

def original_dispatch(tracked:Bool,step:String,nodes:List<&2,K.Node>,runtime:D.Runtime<H.prototype_packed_MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<H.prototype_packed_MotionHost(),W.Handle<T.MotionSchema>>):
  H.motion_dispatch(tracked,step,nodes,runtime)
