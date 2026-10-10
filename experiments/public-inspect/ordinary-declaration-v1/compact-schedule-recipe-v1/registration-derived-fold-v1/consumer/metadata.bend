import Base
import ./declarations.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/registration-derived-fold-v1/modules/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/registration-derived-fold-v1/modules/ordinary-app-registration-fields.bend as Stored
def observe(~S:Data,owners:Decl.Owners(~S)) -> Decl.Owners(~S) & List<&2,Stored.Fields<S>>:
  Leaf.pair(~S,~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~Decl.Last(~S),left=>Leaf.pair(~S,~(Unit & Decl.First(~S)),~Decl.Resource(~S),first=>Leaf.pair(~S,~Unit,~Decl.First(~S),Leaf.empty(~S),Leaf.observed(~S,~Decl.FirstToken(~S)),first),Leaf.observed(~S,~Decl.ResourceToken(~S)),left),Leaf.observed(~S,~Decl.LastToken(~S)),owners)
