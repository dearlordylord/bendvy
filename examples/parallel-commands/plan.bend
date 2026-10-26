import Base
import ../../src/ecs/execution-deferred-plan.bend as D

def reused(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"new"
    case Some{id}:"reuse=" ++ U32.show(id)
def boundary(value:D.Boundary) -> String:
  match value:
    case D.Boundary{before,after,distance,reuse}:U32.show(before) ++ ">" ++ U32.show(after) ++ "@" ++ Nat.show(distance) ++ ":" ++ reused(reuse)
def chain() -> List<&2,D.Node>:
  [D.Node{1,True{},False{},False{},False{}},D.Node{2,False{},False{},False{},False{}},D.Node{3,False{},False{},False{},False{}}]
def explicit() -> List<&2,D.Node>:
  [D.Node{1,True{},False{},False{},False{}},D.Node{2,False{},True{},False{},False{}},D.Node{3,False{},False{},False{},False{}}]
def reuse_nodes() -> List<&2,D.Node>:
  [D.Node{1,True{},False{},False{},False{}},D.Node{2,False{},False{},False{},False{}},D.Node{3,False{},True{},False{},False{}}]
def exclusive() -> List<&2,D.Node>:
  [D.Node{1,True{},False{},False{},False{}},D.Node{2,False{},False{},False{},True{}}]
def edges() -> List<&2,D.Edge>:[D.Edge{1,2,False{}},D.Edge{2,3,False{}}]
def show(value:List<&2,D.Boundary>) -> String:List.show(&2,D.Boundary,boundary,value)
def main() -> IO(Unit):
  IO.print("chain=" ++ show(D.plan(True{},chain(),edges())) ++ "\nignored=" ++ show(D.plan(True{},chain(),[D.Edge{1,2,True{}},D.Edge{2,3,False{}}])) ++ "\nexplicit=" ++ show(D.plan(True{},explicit(),edges())) ++ "\nreuse=" ++ show(D.plan(True{},reuse_nodes(),[D.Edge{1,2,False{}},D.Edge{1,3,False{}}])) ++ "\nexclusive=" ++ show(D.plan(True{},exclusive(),[D.Edge{1,2,True{}}])) ++ "\ndisabled=" ++ show(D.plan(False{},chain(),edges())))
