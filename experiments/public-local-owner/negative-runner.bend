import Base
import ./schema.bend as S
import ../../src/ecs/local.bend as L
import ../../src/ecs/world.bend as W

def other_runner(world: W.World<S.Schema,Unit,U32,Unit>,owner: S.Owner,args: S.Args) -> L.Outcome<W.World<S.Schema,Unit,U32,Unit>,S.Owner,Unit,S.Output>:
  L.Succeeded{world,owner,S.Output{[]}}
def change_runner(instance: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,other_runner>:
  instance
