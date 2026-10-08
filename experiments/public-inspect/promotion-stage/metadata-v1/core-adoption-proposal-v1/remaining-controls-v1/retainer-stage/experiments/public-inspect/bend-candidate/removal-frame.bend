import Base
import removal-log.bend as L
import ../../../src/ecs/world.bend as W

type FrameWindow is Data:
  FrameWindow{start:U32,boundary:U32}
type Framed<S:Data,Store:Type,R:Type,E:Data,F:Data,H:Type> is Type:
  Framed{world:W.World<S,Store,R,E>,window:FrameWindow,log:L.Log<S,F,H>}
def clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~H:Type,~project:H -> H & List<&2,U32>,window:FrameWindow,log:L.Log<S,F,H>,observed:W.World<S,Store,R,E> & U32) -> Framed<S,Store,R,E,F,H>:
  match window observed:
    case FrameWindow{+oldStart,_},(world,+now):Framed{world,FrameWindow{now,oldStart},L.trim(~S,~F,~H,~project,oldStart,log)}
# Source-faithful frame window: previous captured World tick is the boundary;
# capture the actual current clock for the next frame. This operation does not
# manufacture a publication tick or advance the World clock.
def frame(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~H:Type,~project:H -> H & List<&2,U32>,window:FrameWindow,log:L.Log<S,F,H>,world:W.World<S,Store,R,E>) -> Framed<S,Store,R,E,F,H>:
  clocked(~S,~Store,~R,~E,~F,~H,~project,window,log,W.clock(~S,~Store,~R,~E,world))
def start() -> FrameWindow:
  FrameWindow{0,0}
