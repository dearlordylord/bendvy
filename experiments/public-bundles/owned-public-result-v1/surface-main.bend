import Base
import surface-a.bend as AFlow
import surface-b.bend as BFlow
import ../production-candidate/schema-a.bend as ASeed
import ../production-candidate/schema-b.bend as BSeed
import ../combined-control.bend as A
import ../combined-other.bend as B
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as Creator

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
    a(~(world => AFlow.run(0n,False{},False{},False{},False{},world)),"A-spawn-insert-before")
    a(~(world => AFlow.run(1n,False{},False{},False{},False{},world)),"A-spawn-insert-after")
    a(~(world => AFlow.run(2n,False{},False{},False{},False{},world)),"A-spawn-insert-unwind")
    a(~(world => AFlow.run(0n,True{},False{},False{},False{},world)),"A-invalid-spawn-return")
    a(~(world => AFlow.run(0n,True{},True{},False{},False{},world)),"A-invalid-spawn-retry-before")
    a(~(world => AFlow.run(1n,True{},True{},False{},False{},world)),"A-invalid-spawn-retry-after")
    a(~(world => AFlow.run(0n,False{},False{},True{},False{},world)),"A-rollback-before")
    a(~(world => AFlow.run(1n,False{},False{},True{},False{},world)),"A-rollback-after")
    a(~(world => AFlow.run(0n,False{},False{},False{},True{},world)),"A-cleanup-before")
    a(~(world => AFlow.run(1n,False{},False{},False{},True{},world)),"A-cleanup-after")
    b(~(world => BFlow.run(0n,False{},False{},False{},False{},world)),"B-spawn-insert-before")
    b(~(world => BFlow.run(1n,False{},False{},False{},False{},world)),"B-spawn-insert-after")
    b(~(world => BFlow.run(2n,False{},False{},False{},False{},world)),"B-spawn-insert-unwind")
    b(~(world => BFlow.run(0n,True{},False{},False{},False{},world)),"B-invalid-spawn-return")
    b(~(world => BFlow.run(0n,True{},True{},False{},False{},world)),"B-invalid-spawn-retry-before")
    b(~(world => BFlow.run(1n,True{},True{},False{},False{},world)),"B-invalid-spawn-retry-after")
    b(~(world => BFlow.run(0n,False{},False{},True{},False{},world)),"B-rollback-before")
    b(~(world => BFlow.run(1n,False{},False{},True{},False{},world)),"B-rollback-after")
    b(~(world => BFlow.run(0n,False{},False{},False{},True{},world)),"B-cleanup-before")
    b(~(world => BFlow.run(1n,False{},False{},False{},True{},world)),"B-cleanup-after")
