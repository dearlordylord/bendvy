import Base
import ./schema.bend as S
import ../../src/ecs/local.bend as L

def duplicate(instance: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner> & L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>:
  (instance,instance)
