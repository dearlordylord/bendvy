import Base
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/relation-commands.bend as A
import ../../../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../setup.bend as NormalSetup
import ../input.bend as I

def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> NormalSetup.Ready<S>:
  match result:
    case W.Created{_,world}:NormalSetup.Ready{world,NormalSetup.Statistics{0,0,0}}
    case W.CreateRejected{_,_}:NormalSetup.CreationRefused{}
def run(~S:Data,_:I.Input) -> NormalSetup.Ready<S>:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~NormalSetup.empty(~S),W.factory(),77))
