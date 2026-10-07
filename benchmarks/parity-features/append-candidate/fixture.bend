import Base
import ./append.bend as C
import ../../../src/ecs/event-runtime.bend as Ev

def observe(+left:List<&2,U32>,+right:List<&2,U32>) -> String:
  List.show(&2,U32,U32.show,Ev.append(~U32,left,right)) ++ "|" ++ List.show(&2,U32,U32.show,C.append(~U32,left,right))
def main() -> IO(Unit):
  IO.print(observe([],[]) ++ "\n" ++ observe([],[1]) ++ "\n" ++ observe([],[1,2,3]) ++ "\n" ++ observe([],[7,7,0]) ++ "\n" ++ observe([],[0,9]) ++ "\n" ++ observe([1],[]) ++ "\n" ++ observe([1],[1]) ++ "\n" ++ observe([1],[1,2,3]) ++ "\n" ++ observe([1],[7,7,0]) ++ "\n" ++ observe([1],[0,9]) ++ "\n" ++ observe([1,2,3],[]) ++ "\n" ++ observe([1,2,3],[1]) ++ "\n" ++ observe([1,2,3],[1,2,3]) ++ "\n" ++ observe([1,2,3],[7,7,0]) ++ "\n" ++ observe([1,2,3],[0,9]) ++ "\n" ++ observe([7,7,0],[]) ++ "\n" ++ observe([7,7,0],[1]) ++ "\n" ++ observe([7,7,0],[1,2,3]) ++ "\n" ++ observe([7,7,0],[7,7,0]) ++ "\n" ++ observe([7,7,0],[0,9]) ++ "\n" ++ observe([0,9],[]) ++ "\n" ++ observe([0,9],[1]) ++ "\n" ++ observe([0,9],[1,2,3]) ++ "\n" ++ observe([0,9],[7,7,0]) ++ "\n" ++ observe([0,9],[0,9]))
