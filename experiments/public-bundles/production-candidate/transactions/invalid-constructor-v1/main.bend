import Base
import schema-a.bend as AFlow
import schema-b.bend as BFlow
import ../../schema-a.bend as ASeed
import ../../schema-b.bend as BSeed
import ../../../combined-control.bend as A
import ../../../combined-other.bend as B
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/world-io.bend as Creator

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
    a(~AFlow.setup_before,"A-setup-before")
    a(~AFlow.spawn_before,"A-invalid-spawn-before")
    a(~AFlow.spawn_after,"A-invalid-spawn-after")
    a(~AFlow.spawn_retry,"A-invalid-spawn-retry")
    a(~AFlow.insert_before,"A-invalid-insert-before")
    a(~AFlow.insert_after,"A-invalid-insert-after")
    a(~AFlow.insert_retry,"A-invalid-insert-retry")
    b(~BFlow.setup_before,"B-setup-before")
    b(~BFlow.spawn_before,"B-invalid-spawn-before")
    b(~BFlow.spawn_after,"B-invalid-spawn-after")
    b(~BFlow.spawn_retry,"B-invalid-spawn-retry")
    b(~BFlow.insert_before,"B-invalid-insert-before")
    b(~BFlow.insert_after,"B-invalid-insert-after")
    b(~BFlow.insert_retry,"B-invalid-insert-retry")
