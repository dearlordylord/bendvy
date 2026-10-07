import Base
import schema-a.bend as TA
import schema-b.bend as TB
import ../schema-a.bend as SA
import ../schema-b.bend as SB
import ../../../public-bundles/combined-control.bend as A
import ../../../public-bundles/combined-other.bend as B
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as Creator
def a_observed(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(SA.seed(world)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def a_run(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),created => a_observed(~observe,label,created))
def a_prepared(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.snapshot(TA.local(TA.begin(world)))
def a_missing(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: TA.snapshot(TA.call(TA.begin(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}),W.Handle{ns,99},SA.replacement()))
def a_failed_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.system(False{},True{},world)
def a_failed_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.system(True{},True{},world)
def a_commit_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.system(False{},False{},world)
def a_commit_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.system(True{},False{},world)
def a_hostile(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  TA.hostile(world)
def b_observed(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,creation:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(SB.seed(world)))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b_run(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,SB.create(),created => b_observed(~observe,label,created))
def b_prepared(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.snapshot(TB.local(TB.begin(world)))
def b_missing(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: TB.snapshot(TB.call(TB.begin(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}),W.Handle{ns,99},SB.replacement()))
def b_failed_before(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.system(False{},True{},world)
def b_failed_after(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.system(True{},True{},world)
def b_commit_before(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.system(False{},False{},world)
def b_commit_after(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.system(True{},False{},world)
def b_hostile(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> String:
  TB.hostile(world)
def receiver(handle:W.Handle<A.Schema>,sender:W.World<A.Schema,A.Store,A.Mail,U32>,creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print("A-foreign-receiver=" ++ TA.snapshot(TA.call(TA.begin(SA.seed(world)),handle,SA.replacement())) ++ "\nA-foreign-sender=" ++ A.snapshot(sender))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def sender(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),created => receiver(W.Handle{ns,1},W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},created))
def foreign(creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: sender(SA.seed(world))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def a_new_observed(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(world))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def a_new(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),created => a_new_observed(~observe,label,created))
def b_new_observed(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,creation:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print(label ++ "=" ++ observe(world))
    case Creator.Refused{resource}: IO.print(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b_new(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,SB.create(),created => b_new_observed(~observe,label,created))
def pending_receiver(handle:W.Handle<A.Schema>,sender:W.World<A.Schema,A.Store,A.Mail,U32>,creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print("A-pending-foreign-receiver=" ++ TA.pending_foreign(world,handle) ++ "\nA-pending-foreign-sender=" ++ A.snapshot(sender))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def pending_sender(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),created => pending_receiver(W.Handle{ns,1},W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},created))
def pending_foreign(creation:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: pending_sender(SA.seed(world))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def b_pending_receiver(handle:W.Handle<B.Schema>,sender:W.World<B.Schema,B.Store,B.Mail,U32>,creation:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: IO.print("B-pending-foreign-receiver=" ++ TB.pending_foreign(world,handle) ++ "\nB-pending-foreign-sender=" ++ B.snapshot(sender))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def b_pending_sender(world:W.World<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,SB.create(),created => b_pending_receiver(W.Handle{ns,1},W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},created))
def b_pending_foreign(creation:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match creation:
    case Creator.Created{world}: b_pending_sender(SB.seed(world))
    case Creator.Refused{resource}: IO.print("UNEXPECTED_CREATOR_REFUSAL")
def main() -> IO(Unit):
  do IO<Unit>:
    a_run(~a_prepared,"A-frame-prepared")
    a_run(~a_missing,"A-frame-missing")
    a_run(~a_failed_before,"A-failed-before")
    a_run(~a_failed_after,"A-failed-after")
    a_run(~a_commit_before,"A-commit-before")
    a_run(~a_commit_after,"A-commit-after")
    a_run(~a_hostile,"A-hostile-cold")
    b_run(~b_prepared,"B-frame-prepared")
    b_run(~b_missing,"B-frame-missing")
    b_run(~b_failed_before,"B-failed-before")
    b_run(~b_failed_after,"B-failed-after")
    b_run(~b_commit_before,"B-commit-before")
    b_run(~b_commit_after,"B-commit-after")
    b_run(~b_hostile,"B-hostile-cold")
    IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),foreign)
    a_run(~TA.fifo,"A-interleaved-fifo")
    b_run(~TB.fifo,"B-interleaved-fifo")
    a_new(~TA.pending_before,"A-pending-before")
    a_new(~TA.pending_after,"A-pending-after")
    b_new(~TB.pending_before,"B-pending-before")
    b_new(~TB.pending_after,"B-pending-after")
    a_run(~TA.cleanup,"A-cleanup-refusal")
    b_run(~TB.cleanup,"B-cleanup-refusal")
    a_run(~TA.cleanup_retry,"A-cleanup-retry")
    b_run(~TB.cleanup_retry,"B-cleanup-retry")
    a_new(~TA.unified_pending_before,"A-unified-pending-before")
    a_new(~TA.unified_pending_after,"A-unified-pending-after")
    a_new(~TA.unified_pending_failed,"A-unified-pending-failed")
    b_new(~TB.unified_pending_before,"B-unified-pending-before")
    b_new(~TB.unified_pending_after,"B-unified-pending-after")
    b_new(~TB.unified_pending_failed,"B-unified-pending-failed")
    IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,SA.create(),pending_foreign)
    IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,SB.create(),b_pending_foreign)
