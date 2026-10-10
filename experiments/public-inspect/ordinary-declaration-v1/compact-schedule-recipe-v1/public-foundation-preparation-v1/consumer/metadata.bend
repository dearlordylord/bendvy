import Base
import ./declarations.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Stored
def observe(~S:Data,owners:Decl.Owners(~S)) -> Decl.Owners(~S) & List<&2,Stored.Fields<S>>:
  Leaf.pair(~S,~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~Decl.Last(~S),left=>Leaf.pair(~S,~(Unit & Decl.First(~S)),~Decl.Resource(~S),first=>Leaf.pair(~S,~Unit,~Decl.First(~S),Leaf.empty(~S),Leaf.observed(~S,~Decl.FirstToken(~S)),first),Leaf.observed(~S,~Decl.ResourceToken(~S)),left),Leaf.observed(~S,~Decl.LastToken(~S)),owners)
