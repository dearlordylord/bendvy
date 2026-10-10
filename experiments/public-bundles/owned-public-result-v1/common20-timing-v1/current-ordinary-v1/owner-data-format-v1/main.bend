import Base
import /workspace/formal-proofs/bendvy/benchmarks/parity-features/timing.bend as Bench
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/lifecycle-a.bend as AFlow
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/lifecycle-b.bend as BFlow
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-a.bend as ASeed
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-b.bend as BSeed
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-other.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as Creator

import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

def registry(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,(text => text),access) ++ ":" ++ U32.show(cursor)
def capture_snapshot(label:String,registration:String,observed:String) -> IO(Unit):
  Bench.capture(label ++ "|seed-registry=" ++ registration ++ "=" ++ observed)
def a_seed_runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Unit) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  Sys.Succeeded{ASeed.seed(world),Unit{}}
def a_seed_ran(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,Unit,a_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,Unit{}}}:capture_snapshot(label,registry(ns,id,name,access,cursor),AFlow.run(invalid,retry,fail,cleanup,world))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_EXECUTION")
def a_seed_registered(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,Unit,a_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,registration}:a_seed_ran(invalid,retry,fail,cleanup,label,Sys.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~Unit,~a_seed_runner,registration,world,Unit{}))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_REGISTRATION")
def a_observed(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Creator.Creation<A.Schema,A.Store,A.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}:a_seed_registered(invalid,retry,fail,cleanup,label,Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~Unit,~a_seed_runner,world,"bundle-seed",["bundle.spawn","write:a","write:front","write:b","write:tag","write:value"]))
    case _:Bench.capture(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def a(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<A.Schema,A.Store,A.Mail,U32>,Unit,Creator.create(~A.Schema,~A.Store,~A.Mail,~U32,~ASeed.empty,ASeed.resource()),created => a_observed(invalid,retry,fail,cleanup,label,created))
def b_seed_runner(world:W.World<B.Schema,B.Store,B.Mail,U32>,args:Unit) -> Sys.Outcome<W.World<B.Schema,B.Store,B.Mail,U32>,Unit,Unit>:
  Sys.Succeeded{BSeed.seed(world),Unit{}}
def b_seed_ran(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Sys.RunResult<B.Schema,B.Store,B.Mail,U32,Unit,Unit,Unit,b_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,Unit{}}}:capture_snapshot(label,registry(ns,id,name,access,cursor),BFlow.run(invalid,retry,fail,cleanup,world))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_EXECUTION")
def b_seed_registered(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Sys.RegistrationResult<B.Schema,B.Store,B.Mail,U32,Unit,Unit,Unit,b_seed_runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,registration}:b_seed_ran(invalid,retry,fail,cleanup,label,Sys.run_tracked(~B.Schema,~B.Store,~B.Mail,~U32,~Unit,~Unit,~Unit,~b_seed_runner,registration,world,Unit{}))
    case _:Bench.capture(label ++ "=UNEXPECTED_SEED_REGISTRATION")
def b_observed(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String,result:Creator.Creation<B.Schema,B.Store,B.Mail,U32>) -> IO(Unit):
  match result:
    case Creator.Created{world}:b_seed_registered(invalid,retry,fail,cleanup,label,Sys.register(~B.Schema,~B.Store,~B.Mail,~U32,~Unit,~Unit,~Unit,~b_seed_runner,world,"bundle-seed",["bundle.spawn","write:a","write:front","write:b","write:tag","write:value"]))
    case _:Bench.capture(label ++ "=UNEXPECTED_CREATOR_REFUSAL")
def b(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,label:String) -> IO(Unit):
  IO.bind(Creator.Creation<B.Schema,B.Store,B.Mail,U32>,Unit,Creator.create(~B.Schema,~B.Store,~B.Mail,~U32,~BSeed.empty,BSeed.resource()),created => b_observed(invalid,retry,fail,cleanup,label,created))

def lifecycle() -> IO(Unit):
  do IO<Unit>:
    a(False{},False{},False{},False{},"A-spawn-insert")
    a(True{},False{},False{},False{},"A-invalid-return")
    a(True{},True{},False{},False{},"A-invalid-retry")
    a(False{},False{},True{},False{},"A-rollback")
    a(False{},False{},False{},True{},"A-cleanup")
    b(False{},False{},False{},False{},"B-spawn-insert")
    b(True{},False{},False{},False{},"B-invalid-return")
    b(True{},True{},False{},False{},"B-invalid-retry")
    b(False{},False{},True{},False{},"B-rollback")
    b(False{},False{},False{},True{},"B-cleanup")
def main() -> IO(Unit):
  do IO<Unit>:
    Bench.begin()
    lifecycle()
    Bench.end()
