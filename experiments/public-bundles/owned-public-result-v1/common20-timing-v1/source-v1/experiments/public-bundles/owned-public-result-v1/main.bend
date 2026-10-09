import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/owned-public-result-v1/schema-a.bend as AFlow
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/owned-public-result-v1/schema-b.bend as BFlow
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
def a_peer(mode:Nat,retry:Bool,label:String,receiver:W.World<A.Schema,A.Store,A.Mail,U32>,named:W.World<A.Schema,A.Store,A.Mail,U32> & U32) -> IO(Unit):
  match named:
    case (peer,namespace): IO.print(label ++ "=" ++ AFlow.foreign(mode,retry,W.Handle{namespace,1},receiver) ++ "|peer=" ++ AFlow.world_snapshot(peer))
def a_peer_created(mode:Nat,retry:Bool,label:String,receiver:W.World<A.Schema,A.Store,A.Mail,U32>,result:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{peer}: a_peer(mode,retry,label,receiver,W.namespace(~A.Schema,~A.Store,~A.Mail,~U32,ASeed.seed(peer)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_PEER_CREATOR_REFUSAL")
def a_receiver(mode:Nat,retry:Bool,label:String,result:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}: IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,ASeed.create(),created => a_peer_created(mode,retry,label,ASeed.seed(world),created))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_RECEIVER_CREATOR_REFUSAL")
def a_foreign(mode:Nat,retry:Bool,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,ASeed.create(),created => a_receiver(mode,retry,label,created))

def b_observed(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(BSeed.seed(world)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,BSeed.create(),created => b_observed(~observe,label,created))
def b_peer(mode:Nat,retry:Bool,label:String,receiver:W.World<B.Schema,B.Store,B.Mail,U32>,named:W.World<B.Schema,B.Store,B.Mail,U32> & U32) -> IO(Unit):
  match named:
    case (peer,namespace): IO.print(label ++ "=" ++ BFlow.foreign(mode,retry,W.Handle{namespace,1},receiver) ++ "|peer=" ++ BFlow.world_snapshot(peer))
def b_peer_created(mode:Nat,retry:Bool,label:String,receiver:W.World<B.Schema,B.Store,B.Mail,U32>,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{peer}: b_peer(mode,retry,label,receiver,W.namespace(~B.Schema,~B.Store,~B.Mail,~U32,BSeed.seed(peer)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_PEER_CREATOR_REFUSAL")
def b_receiver(mode:Nat,retry:Bool,label:String,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}: IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,BSeed.create(),created => b_peer_created(mode,retry,label,BSeed.seed(world),created))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_RECEIVER_CREATOR_REFUSAL")
def b_foreign(mode:Nat,retry:Bool,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,BSeed.create(),created => b_receiver(mode,retry,label,created))

def main() -> IO(Unit):
  do IO<Unit>:
    a(~(world => AFlow.local(0n,True{},False{},False{},True{},world)),"A-missing-return")
    a(~(world => AFlow.local(0n,True{},False{},True{},True{},world)),"A-missing-retry-before")
    a(~(world => AFlow.local(1n,True{},False{},True{},True{},world)),"A-missing-retry-after")
    a(~(world => AFlow.local(2n,True{},False{},True{},True{},world)),"A-missing-retry-unwind")
    a(~(world => AFlow.local(0n,False{},True{},False{},True{},world)),"A-invalid-return")
    a(~(world => AFlow.local(0n,False{},True{},True{},True{},world)),"A-invalid-retry-before")
    a(~(world => AFlow.local(1n,False{},True{},True{},True{},world)),"A-invalid-retry-after")
    a(~(world => AFlow.local(2n,False{},True{},True{},True{},world)),"A-invalid-retry-unwind")
    a(~(world => AFlow.local(0n,False{},False{},False{},False{},world)),"A-undeclared-return")
    a_foreign(0n,False{},"A-foreign-return")
    a_foreign(1n,True{},"A-foreign-retry-after")
    b(~(world => BFlow.local(0n,True{},False{},False{},True{},world)),"B-missing-return")
    b(~(world => BFlow.local(0n,True{},False{},True{},True{},world)),"B-missing-retry-before")
    b(~(world => BFlow.local(1n,True{},False{},True{},True{},world)),"B-missing-retry-after")
    b(~(world => BFlow.local(2n,True{},False{},True{},True{},world)),"B-missing-retry-unwind")
    b(~(world => BFlow.local(0n,False{},True{},False{},True{},world)),"B-invalid-return")
    b(~(world => BFlow.local(0n,False{},True{},True{},True{},world)),"B-invalid-retry-before")
    b(~(world => BFlow.local(1n,False{},True{},True{},True{},world)),"B-invalid-retry-after")
    b(~(world => BFlow.local(2n,False{},True{},True{},True{},world)),"B-invalid-retry-unwind")
    b(~(world => BFlow.local(0n,False{},False{},False{},False{},world)),"B-undeclared-return")
    b_foreign(0n,False{},"B-foreign-return")
    b_foreign(1n,True{},"B-foreign-retry-after")
