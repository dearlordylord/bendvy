import Base
import ./world.bend as W
import ./lifecycle.bend as Life

type Tag is Data:Tag{}
type Record<S:Data,P:Type> is Type:
  Record{handle:W.Handle<S>,stamp:Life.Stamp,payload:Maybe<P>}
type Replacement<World:Type,S:Data,P:Type> is Type:
  Applied{world:World,previous:Record<S,P>}
  Refused{world:World,incoming:Maybe<P>,error:W.WorldError}
