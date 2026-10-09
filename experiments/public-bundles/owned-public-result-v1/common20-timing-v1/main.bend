import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/lifecycle-a.bend as AFlow
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/lifecycle-b.bend as BFlow
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/production-candidate/schema-a.bend as ASeed
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/production-candidate/schema-b.bend as BSeed
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/combined-other.bend as B
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world-io.bend as Creator

def a_observed(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,result:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(ASeed.seed(world)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def a(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,ASeed.create(),created => a_observed(~observe,label,created))

def b_observed(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(BSeed.seed(world)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,BSeed.create(),created => b_observed(~observe,label,created))

def main() -> IO(Unit):
  do IO<Unit>:
    a(~(world => AFlow.run(False{},False{},False{},False{},world)),"A-spawn-insert")
    a(~(world => AFlow.run(True{},False{},False{},False{},world)),"A-invalid-return")
    a(~(world => AFlow.run(True{},True{},False{},False{},world)),"A-invalid-retry")
    a(~(world => AFlow.run(False{},False{},True{},False{},world)),"A-rollback")
    a(~(world => AFlow.run(False{},False{},False{},True{},world)),"A-cleanup")
    b(~(world => BFlow.run(False{},False{},False{},False{},world)),"B-spawn-insert")
    b(~(world => BFlow.run(True{},False{},False{},False{},world)),"B-invalid-return")
    b(~(world => BFlow.run(True{},True{},False{},False{},world)),"B-invalid-retry")
    b(~(world => BFlow.run(False{},False{},True{},False{},world)),"B-rollback")
    b(~(world => BFlow.run(False{},False{},False{},True{},world)),"B-cleanup")
