import Base
import logs.bend as Logs
import ../removal-frame.bend as F
import ../../../../src/ecs/world.bend as W

type Framed<S:Data,Store:Type,R:Type,E:Data,Family:Data,H:Type> is Type:
  Framed{world:W.World<S,Store,R,E>,window:F.FrameWindow,logs:Logs.Streams<S,Family,H>}
def clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~Family:Data,~H:Type,~project:H -> H & Logs.Positions,window:F.FrameWindow,logs:Logs.Streams<S,Family,H>,result:W.World<S,Store,R,E> & U32) -> Framed<S,Store,R,E,Family,H>:
  match window result:
    case F.FrameWindow{+oldStart,_},(world,now):Framed{world,F.FrameWindow{now,oldStart},Logs.trim(~S,~Family,~H,~project,oldStart,logs)}
def frame(~S:Data,~Store:Type,~R:Type,~E:Data,~Family:Data,~H:Type,~project:H -> H & Logs.Positions,window:F.FrameWindow,logs:Logs.Streams<S,Family,H>,world:W.World<S,Store,R,E>) -> Framed<S,Store,R,E,Family,H>:
  clocked(~S,~Store,~R,~E,~Family,~H,~project,window,logs,W.clock(~S,~Store,~R,~E,world))
