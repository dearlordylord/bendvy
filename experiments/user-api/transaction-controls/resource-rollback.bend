import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/resource.bend as R
import ../../../src/ecs/commands.bend as C

def empty(_: Unit) -> Unit: Unit{}
def project_value(value: Array<U32> & U32) -> Array<U32> & U32:
  (array,value) = value
  (array,value)
def project(array: Array<U32>) -> Array<U32> & U32:
  project_value(array[0])
def populate(world: W.World<Unit,Unit,Array<U32>,U32>,handle: W.Handle<Unit>,payload: Array<U32>) -> W.World<Unit,Unit,Array<U32>,U32>:
  world

def result_value(value: W.World<Unit,Unit,Array<U32>,U32> & U32) -> U32:
  (world,value) = value
  value

def report(result: T.Returned<W.World<Unit,Unit,Array<U32>,U32>,U32>) -> U32:
  match result:
    case T.Returned{world,_}: result_value(W.observe_resource(~Unit,~Unit,~Array<U32>,~U32,~U32,~project,world))

def trial_created(created: W.Creation<Unit,Unit,Array<U32>,U32>) -> U32:
  match created:
    case W.CreateRejected{_,_}: 99
    case W.Created{_,world}:
      tx = T.begin(~W.World<Unit,Unit,Array<U32>,U32>,~U32,world)
      tx = R.tx_replace(~Unit,~Unit,~Array<U32>,~U32,tx,[1 : U32^0n])
      tx = R.tx_replace(~Unit,~Unit,~Array<U32>,~U32,tx,[2 : U32^0n])
      report(C.tx_finish(~Unit,~Unit,~Array<U32>,~U32,~U32,tx,T.Failure{4}))
def main() -> U32:
  trial_created(W.create(~Unit,~Unit,~Array<U32>,~U32,~empty,W.factory(),[0 : U32^0n]))
