import Base
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/transaction.bend as T

type Scene is Data:
  Scene{}
type Garden is Data:
  Garden{}
def clear(components:Unit,handle:W.Handle<Scene>) -> Unit & List<&2,A.Notice<Scene,U32>>:
  (components,[])
def record(handle:W.Handle<Scene>) -> A.Notice<Scene,U32>:
  match handle:
    case W.Handle{_,id}:A.Original{id}
def forbidden(tx:T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Unit>>,Unit,A.Notice<Scene,U32>>,A.Notice<Scene,U32>>,scope:Sc.Scope<Garden>) -> T.Tx<W.World<Scene,A.Store<Scene,Sc.Store<Scene,Unit>>,Unit,A.Notice<Scene,U32>>,A.Notice<Scene,U32>> & A.QueueStatus:
  Sc.tx_cleanup(~Scene,~Unit,~Unit,~U32,~clear,~record,~[],tx,scope)
