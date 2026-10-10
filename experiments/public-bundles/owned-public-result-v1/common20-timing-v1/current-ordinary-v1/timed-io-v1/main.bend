import Base
import /workspace/formal-proofs/bendvy/benchmarks/parity-features/timing.bend as Bench
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/registered-lifecycle-v1/lifecycle-a.bend as AFlow
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/registered-lifecycle-v1/lifecycle-b.bend as BFlow
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-a.bend as ASeed
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-b.bend as BSeed
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-other.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as Creator

import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

def registry(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(text => text),access) ++ ":" ++ U32.show(cursor)
def a_seed_runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Unit) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  Sys.Succeeded{ASeed.seed(world),Unit{}}
def a_seed_ran(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,Unit,a_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,Unit{}}}:Bench.capture(label ++ "|seed-registry=" ++ registry(ns,id,name,access,cursor) ++ "=" ++ observe(world))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_EXECUTION")
def a_seed_registered(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,result:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,Unit,a_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,registration}:a_seed_ran(~observe,label,Sys.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~Unit,~a_seed_runner,registration,world,Unit{}))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_REGISTRATION")
def a_observed(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String,result:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}:a_seed_registered(~observe,label,Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~Unit,~a_seed_runner,world,"bundle-seed",["bundle.spawn","write:a","write:front","write:b","write:tag","write:value"]))
    case _:Bench.capture(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def a(~observe:W.World<A.Schema,A.Store,A.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,Creator.create(~A.Schema,~A.Store,~A.Mail,~U32,~ASeed.empty,ASeed.resource()),created => a_observed(~observe,label,created))
def b_seed_runner(world:W.World<B.Schema,B.Store,B.Mail,U32>,args:Unit) -> Sys.Outcome<W.World<B.Schema,B.Store,B.Mail,U32>,Unit,Unit>:
  Sys.Succeeded{BSeed.seed(world),Unit{}}
def b_seed_ran(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,result:Sys.RunResult<B.Schema,B.Store,B.Mail,U32,Unit,Unit,Unit,b_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,Unit{}}}:Bench.capture(label ++ "|seed-registry=" ++ registry(ns,id,name,access,cursor) ++ "=" ++ observe(world))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_EXECUTION")
def b_seed_registered(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,result:Sys.RegistrationResult<B.Schema,B.Store,B.Mail,U32,Unit,Unit,Unit,b_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,registration}:b_seed_ran(~observe,label,Sys.run_tracked(~B.Schema,~B.Store,~B.Mail,~U32,~Unit,~Unit,~Unit,~b_seed_runner,registration,world,Unit{}))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_REGISTRATION")
def b_observed(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}:b_seed_registered(~observe,label,Sys.register(~B.Schema,~B.Store,~B.Mail,~U32,~Unit,~Unit,~Unit,~b_seed_runner,world,"bundle-seed",["bundle.spawn","write:a","write:front","write:b","write:tag","write:value"]))
    case _:Bench.capture(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b(~observe:W.World<B.Schema,B.Store,B.Mail,U32> -> String,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,Creator.create(~B.Schema,~B.Store,~B.Mail,~U32,~BSeed.empty,BSeed.resource()),created => b_observed(~observe,label,created))

def lifecycle() -> IO(Unit):
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
def main() -> IO(Unit):
  do IO<Unit>:
    Bench.begin()
    lifecycle()
    Bench.end()
