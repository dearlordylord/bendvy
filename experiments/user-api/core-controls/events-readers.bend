import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/events.bend as E

def empty(_: Unit) -> Unit: Unit{}
def counted(observed: E.Observed<Unit,Unit,Unit,U32>) -> U32:
  match observed:
    case E.ForeignReader{_,_}: 99
    case E.Read{world,reader,+events}:
      U32.from_nat(List.length(&2,U32,events))
def reread(observed: E.Observed<Unit,Unit,Unit,U32>,other: E.Reader<Unit>,+prior: U32) -> List<&2,U32>:
  match observed:
    case E.ForeignReader{_,_}: [99]
    case E.Read{world,reader,+events}:
      [prior,U32.from_nat(List.length(&2,U32,events)),counted(E.read(~Unit,~Unit,~Unit,~U32,world,other))]
def first(observed: E.Observed<Unit,Unit,Unit,U32>,other: E.Reader<Unit>) -> List<&2,U32>:
  match observed:
    case E.ForeignReader{_,_}: [99]
    case E.Read{world,reader,+events}:
      n = U32.from_nat(List.length(&2,U32,events))
      reread(E.read(~Unit,~Unit,~Unit,~U32,world,reader),other,n)
def readers(pair: W.World<Unit,Unit,Unit,U32> & E.Reader<Unit>,other: E.Reader<Unit>) -> List<&2,U32>:
  (world,reader) = pair
  first(E.read(~Unit,~Unit,~Unit,~U32,W.event_publish(~Unit,~Unit,~Unit,~U32,world,[7,8]),reader),other)
def second(pair: W.World<Unit,Unit,Unit,U32> & E.Reader<Unit>) -> List<&2,U32>:
  (world,reader) = pair
  readers(E.create(~Unit,~Unit,~Unit,~U32,world),reader)
def created(result: W.Creation<Unit,Unit,Unit,U32>) -> List<&2,U32>:
  match result:
    case W.CreateRejected{_,_}: [99]
    case W.Created{_,world}: second(E.create(~Unit,~Unit,~Unit,~U32,world))
def main() -> List<&2,U32>:
  created(W.create(~Unit,~Unit,~Unit,~U32,~empty,W.factory(),Unit{}))
