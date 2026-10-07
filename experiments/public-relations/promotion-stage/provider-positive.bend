import Base
import ../../../src/ecs/relation-providers.bend as P
import ../../../src/ecs/relation-commands.bend as A
import owned-world.bend as O
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X

def queued(-H: Type,result: H & A.QueueStatus) -> H & Unit:
  (owner,_) = result
  (owner,Unit{})
def write_body(~S: Data,-H: Type,caps: P.Writable<H,S>,args: P.Targets<S>,owner: H) -> H & Unit:
  queued(H,P.relate_live(H,S,caps,owner,args))
def read_body(~S: Data,-H: Type,caps: P.ReadOnly<H,S>,target: W.Handle<S>,owner: H) -> H & Maybe<&2,List<&2,W.Handle<S>>>:
  P.read_live(H,S,caps,owner,target)
def invoked(~S: Data,world: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,targets: P.Targets<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Unit:
  P.invoke_write(~S,~O.Components<S>,~U32,~U32,~G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},~Unit,~write_body(~S),targets,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world))
