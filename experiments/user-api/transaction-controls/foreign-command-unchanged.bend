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
def clear(store: Unit,handle: W.Handle<Unit>) -> Unit:
  store

def rejected(result: T.Tx<W.World<Unit,Unit,Array<U32>,U32>,U32> & W.Status) -> U32:
  match result:
    case (T.Tx{_,_,commands,_},W.Rejected{W.MissingEntity{}}): U32.from_nat(List.length(&1,(W.World<Unit,Unit,Array<U32>,U32> -> W.World<Unit,Unit,Array<U32>,U32>),commands))
    case _: 99

def main() -> U32:
  world = {W.World{1,2,1,Array.new(Bool,1n,True{}),2,1n,Unit{},[0 : U32^0n],[],[],[],1} : W.World<Unit,Unit,Array<U32>,U32>}
  tx = T.begin(~W.World<Unit,Unit,Array<U32>,U32>,~U32,world)
  tx = T.stage(~W.World<Unit,Unit,Array<U32>,U32>,~U32,tx,w => w)
  rejected(C.tx_despawn_with(~Unit,~Unit,~Array<U32>,~U32,~clear,tx,W.Handle{2,1}))
