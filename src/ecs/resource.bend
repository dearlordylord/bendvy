import Base
import ./world.bend as W

def restore_join(~S: Data,~C: Type,~R: Type,~E: Data,replaced: W.World<S,C,R,E> & R) -> W.World<S,C,R,E>:
  (world,discarded) = replaced
  world

def restore(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,old: R) -> W.World<S,C,R,E>:
  restore_join(~S,~C,~R,~E,W.replace_resource(~S,~C,~R,~E,world,old))
