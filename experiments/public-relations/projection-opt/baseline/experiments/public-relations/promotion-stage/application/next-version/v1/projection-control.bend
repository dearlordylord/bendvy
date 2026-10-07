import Base
import ./owned-world.bend as O

def final_projection(result: O.Payload & List<&2,U32>) -> String:
  match result:
    case (O.Payload{_,tag},ids): U32.show(tag) ++ ":" ++ O.show_ids(ids)
def repeated(result: O.Payload & List<&2,U32>,before: List<&2,U32>) -> String:
  match result:
    case (O.Payload{cells,+tag},after): "before=" ++ O.show_ids(before) ++ ";after=" ++ O.show_ids(after) ++ ";tag=" ++ U32.show(tag) ++ ";final=" ++ final_projection(O.project_payload(O.Payload{cells,tag}))
def retained(result: O.Payload & List<&2,U32>) -> String:
  match result:
    case (O.Payload{cells,tag},ids): repeated(O.project_payload(O.Payload{Array.set(U32,cells,2,4294967295),tag}),ids)
def partial_done(result: Array<U32> & List<&2,U32>) -> String:
  match result:
    case (cells,ids): "partial=" ++ O.show_ids(ids) ++ ";owner=" ++ final_projection(O.project_payload(O.Payload{cells,77}))
def main() -> IO(Unit):
  IO.print(partial_done(O.project_cells(0n,ALeaf{4294967295},0)) ++ "\n" ++ partial_done(O.project_cells(3n,ANode{ANode{ALeaf{0},ALeaf{1}},ANode{ALeaf{4294967295},ALeaf{3}}},0)) ++ "\n" ++ retained(O.project_payload(O.Payload{ANode{ANode{ALeaf{0},ALeaf{1}},ANode{ALeaf{2},ALeaf{3}}},4294967295})))
