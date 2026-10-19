import Base
import ../connected-performance/lifecycle-motion64/method/actors.bend as A
import ../connected-performance/lifecycle-motion64/consumer/dense-runtime-v1/types.bend as T
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-key.bend as K

def handle(namespace:U32,index:U32,generation:U32) -> W.Handle<T.MotionSchema>:
  W.Handle{namespace,K.EntityKey{index,generation}}
def show(value:Maybe<&2,Nat>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:Nat.show(value)
def entries() -> List<&2,A.Entry>:
  [A.Entry{handle(7,1,0),11n},A.Entry{handle(7,2,0),22n},A.Entry{handle(7,3,0),33n},A.Entry{handle(7,2,0),99n}]
def status(value:A.Actors) -> String:
  match value:
    case A.Actors{entries,next,valid}:show(A.find(entries,handle(7,2,0))) ++ ":" ++ Nat.show(next) ++ ":" ++ Bool.show(valid)
def result() -> String:
  show(A.find([],handle(7,1,0))) ++ "," ++
  show(A.find(entries(),handle(7,1,0))) ++ "," ++
  show(A.find(entries(),handle(7,2,0))) ++ "," ++
  show(A.find(entries(),handle(7,3,0))) ++ "," ++
  show(A.find(entries(),handle(7,4,0))) ++ "," ++
  show(A.find(entries(),handle(8,2,0))) ++ "," ++
  show(A.find(entries(),handle(7,2,1))) ++ "\n" ++
  status(A.add(handle(7,2,0),A.Actors{entries(),100n,True{}})) ++ "\n" ++
  status(A.add(handle(7,4,0),A.Actors{entries(),100n,True{}}))

def main() -> IO(Unit):
  IO.print(result())
