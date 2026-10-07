import Base
import ./world-io.bend as H
import ../../public-schedule-readers/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../public-integration/schema.bend as F

def empty(_:Unit) -> Unit: Unit{}
def inspected(label:String,result:W.World<S.Schema,Unit,Array<U32>,U32> & List<&2,U32>) -> IO(Unit):
  (world,values)=result
  IO.print(label ++ "|resource=" ++ List.show(&2,U32,U32.show,values))
def named(result:W.World<S.Schema,Unit,Array<U32>,U32> & U32) -> IO(Unit):
  (world,ns)=result
  inspected("created:" ++ U32.show(ns),W.observe_resource(~S.Schema,~Unit,~Array<U32>,~U32,~List<&2,U32>,~S.array_view,world))
def refused(result:Array<U32> & List<&2,U32>) -> IO(Unit):
  (resource,values)=result
  IO.print("refused|resource=" ++ List.show(&2,U32,U32.show,values))
def observed(result:H.Creation<S.Schema,Unit,Array<U32>,U32>) -> IO(Unit):
  match result:
    case H.Created{world}: named(W.namespace(~S.Schema,~Unit,~Array<U32>,~U32,world))
    case H.Refused{resource}: refused(S.array_view(resource))
def four(_:Unit) -> IO(Unit):
  IO.bind(H.Creation<S.Schema,Unit,Array<U32>,U32>,Unit,H.create(~S.Schema,~Unit,~Array<U32>,~U32,~empty,[77 : U32*4n]),observed)
def three(_:Unit) -> IO(Unit):
  IO.bind(Unit,Unit,IO.bind(H.Creation<S.Schema,Unit,Array<U32>,U32>,Unit,H.create(~S.Schema,~Unit,~Array<U32>,~U32,~empty,[77 : U32*4n]),observed),four)
def two(_:Unit) -> IO(Unit):
  IO.bind(Unit,Unit,IO.bind(H.Creation<S.Schema,Unit,Array<U32>,U32>,Unit,H.create(~S.Schema,~Unit,~Array<U32>,~U32,~empty,[77 : U32*4n]),observed),three)
def main() -> IO(Unit):
  IO.bind(Unit,Unit,IO.bind(H.Creation<S.Schema,Unit,Array<U32>,U32>,Unit,H.create(~S.Schema,~Unit,~Array<U32>,~U32,~empty,[77 : U32*4n]),observed),two)
