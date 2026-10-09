import Base
import query.bend as Q
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/check.bend as K
import core-v1/src/ecs/world.bend as W
def inspect_handles_joined(~S:Data,~Store:Type,~R:Type,~E:Data,cursor:U32,observed:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> I.Frame<S,Store,R,E> & List<&2,W.Handle<S>>:
  (world,value)=observed
  (I.Frame{world,cursor},value)
def inspect_handles(~S:Data,~Store:Type,~R:Type,~E:Data,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & List<&2,W.Handle<S>>:
  match frame:
    case I.Frame{world,cursor}:inspect_handles_joined(~S,~Store,~R,~E,cursor,W.handles(~S,~Store,~R,~E,world))
def inspect_valid_joined(~S:Data,~Store:Type,~R:Type,~E:Data,cursor:U32,observed:W.World<S,Store,R,E> & Bool) -> I.Frame<S,Store,R,E> & Bool:
  (world,value)=observed
  (I.Frame{world,cursor},value)
def inspect_valid(~S:Data,~Store:Type,~R:Type,~E:Data,frame:I.Frame<S,Store,R,E>,target:W.Handle<S>) -> I.Frame<S,Store,R,E> & Bool:
  match frame:
    case I.Frame{world,cursor}:inspect_valid_joined(~S,~Store,~R,~E,cursor,W.valid(~S,~Store,~R,~E,world,target))
def inspect_world(~S:Data,~Store:Type,~R:Type,~E:Data) -> Q.WorldRead<I.Frame<S,Store,R,E>,S>:
  Q.WorldRead{inspect_handles(~S,~Store,~R,~E),inspect_valid(~S,~Store,~R,~E)}
def check_handles_joined(~S:Data,~Store:Type,~R:Type,~E:Data,observed:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> K.Frame<S,Store,R,E> & List<&2,W.Handle<S>>:
  (world,value)=observed
  (K.Frame{world},value)
def check_handles(~S:Data,~Store:Type,~R:Type,~E:Data,frame:K.Frame<S,Store,R,E>) -> K.Frame<S,Store,R,E> & List<&2,W.Handle<S>>:
  match frame:
    case K.Frame{world}:check_handles_joined(~S,~Store,~R,~E,W.handles(~S,~Store,~R,~E,world))
def check_valid_joined(~S:Data,~Store:Type,~R:Type,~E:Data,observed:W.World<S,Store,R,E> & Bool) -> K.Frame<S,Store,R,E> & Bool:
  (world,value)=observed
  (K.Frame{world},value)
def check_valid(~S:Data,~Store:Type,~R:Type,~E:Data,frame:K.Frame<S,Store,R,E>,target:W.Handle<S>) -> K.Frame<S,Store,R,E> & Bool:
  match frame:
    case K.Frame{world}:check_valid_joined(~S,~Store,~R,~E,W.valid(~S,~Store,~R,~E,world,target))
def check_world(~S:Data,~Store:Type,~R:Type,~E:Data) -> Q.WorldRead<K.Frame<S,Store,R,E>,S>:
  Q.WorldRead{check_handles(~S,~Store,~R,~E),check_valid(~S,~Store,~R,~E)}
