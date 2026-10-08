import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
# Name the generic actual registration dispatch boundary before specializing it.
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,Store,R,E> -> Args -> Sys.Outcome<W.World<S,Store,R,E>,Error,Out>,registry:Sys.Registry<S,Store,R,E,Args,Error,Out,runner>,world:W.World<S,Store,R,E>,args:Args) -> Sys.RunResult<S,Store,R,E,Args,Error,Out,runner>:
  Sys.run_tracked(~S,~Store,~R,~E,~Args,~Error,~Out,~runner,registry,world,args)
