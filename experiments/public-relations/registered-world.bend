import Base
import types.bend as G
import providers.bend as P
import provider-positive.bend as B
import world-adapter.bend as A
import owned-world.bend as O
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as X
import ../../src/ecs/system.bend as Sys

def runner_committed(~S: Data,world: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  Sys.Succeeded{world,Unit{}}
def runner_done(~S: Data,result: X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Unit) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  (tx,_) = result
  runner_committed(~S,O.commit(~S,tx,X.Success{}))
def runner(~S: Data,world: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,args: P.Targets<S>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  runner_done(~S,B.invoked(~S,world,args))
def outcome_world(~S: Data,outcome: Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match outcome:
    case Sys.Succeeded{world,_}: world
    case Sys.Failed{world,_}: world
def show_handles(~S: Data,handles: List<&2,W.Handle<S>>) -> String:
  match handles:
    case []: ""
    case W.Handle{ns,id} <> rest: U32.show(ns) ++ ":" ++ U32.show(id) ++ "," ++ show_handles(~S,rest)
def show_snapshot(~S: Data,snapshot: Maybe<&2,List<&2,W.Handle<S>>>) -> String:
  match snapshot:
    case None{}: "none"
    case Some{handles}: show_handles(~S,handles)
def read_finished(~S: Data,result: X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Maybe<&2,List<&2,W.Handle<S>>>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Maybe<&2,List<&2,W.Handle<S>>>>:
  (tx,snapshot) = result
  Sys.Succeeded{O.commit(~S,tx,X.Success{}),snapshot}
def read_runner(~S: Data,world: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,target: W.Handle<S>) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Maybe<&2,List<&2,W.Handle<S>>>>:
  read_finished(~S,P.invoke_read(~S,~O.Components<S>,~U32,~U32,~G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},~Maybe<&2,List<&2,W.Handle<S>>>,~B.read_body(~S),target,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world)))
def changed(~S: Data,result: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,+snapshot: Maybe<&2,List<&2,W.Handle<S>>>) -> String:
  (world,value) = result
  value ++ "|snapshot=" ++ show_snapshot(~S,snapshot) ++ "\n" ++ O.final(~S,O.observe_complete(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,O.commit(~S,O.set(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),3,2),X.Success{})))) ++ "|retained=" ++ show_snapshot(~S,snapshot)
def read_outcome(~S: Data,outcome: Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Maybe<&2,List<&2,W.Handle<S>>>>) -> String:
  match outcome:
    case Sys.Succeeded{world,snapshot}: changed(~S,O.observe_complete(~S,world),snapshot)
    case Sys.Failed{_,_}: "READ_FAILED"
def read_ran(~S: Data,result: Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Maybe<&2,List<&2,W.Handle<S>>>,read_runner(~S)>) -> String:
  match result:
    case Sys.Completed{_,outcome}: read_outcome(~S,outcome)
    case _: "READ_RUN_REJECTED"
def read_before(~S: Data,result: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,registry: Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Maybe<&2,List<&2,W.Handle<S>>>,read_runner(~S)>) -> String:
  (world,value) = result
  value ++ "\n" ++ read_ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Maybe<&2,List<&2,W.Handle<S>>>,~read_runner(~S),registry,world,W.Handle{1,1}))
def read_registered(~S: Data,result: Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,W.Handle<S>,U32,Maybe<&2,List<&2,W.Handle<S>>>,read_runner(~S)>) -> String:
  match result:
    case Sys.Registered{world,registry}: read_before(~S,O.observe_complete(~S,world),registry)
    case _: "READ_REGISTER_REJECTED"
def read_register(~S: Data,world: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  read_registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~W.Handle<S>,~U32,~Maybe<&2,List<&2,W.Handle<S>>>,~read_runner(~S),world,"inverse-reader",["LinkedBy.read"]))
def after_run(~S: Data,result: Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,P.Targets<S>,U32,Unit,runner(~S)>) -> String:
  match result:
    case Sys.Completed{_,outcome}: O.record(~S,O.observe_complete(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,outcome_world(~S,outcome))),read_register(~S))
    case Sys.RegistrationRejected{_,_,_}: "RUN_REJECTED"
def before_run(~S: Data,result: W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,registry: Sys.Registry<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,P.Targets<S>,U32,Unit,runner(~S)>) -> String:
  (world,before) = result
  before ++ "\n" ++ after_run(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~P.Targets<S>,~U32,~Unit,~runner(~S),registry,world,P.Targets{W.Handle{1,3},W.Handle{1,1}}))
def registered(~S: Data,result: Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,P.Targets<S>,U32,Unit,runner(~S)>) -> String:
  match result:
    case Sys.Registered{world,registry}: before_run(~S,O.observe_complete(~S,world),registry)
    case Sys.RegistrationFailed{_}: "REGISTER_REJECTED"
def created(~S: Data,result: W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~P.Targets<S>,~U32,~Unit,~runner(~S),O.spawn(~S,4n,world),"relate-system",["Link.write","LinkedBy.read"]))
    case _: "CREATE_REJECTED"
def run(~S: Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~O.empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print(run(~O.Workshop) ++ "\n" ++ run(~O.Other))
