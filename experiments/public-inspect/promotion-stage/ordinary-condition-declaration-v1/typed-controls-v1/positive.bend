import Base
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/alpha/application.bend as A
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/alpha/state.bend as F
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/alpha/bindings.bend as B
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/alpha/base-application.bend as Prior
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/beta/application.bend as Other
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/beta/state.bend as G
import /workspace/formal-proofs/bendvy-worktrees/hierarchy44-public-traversal-v1/experiments/public-inspect/promotion-stage/ordinary-condition-declaration-v1/beta/bindings.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-condition-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-declaration.bend as Condition
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
def retained(app:A.Scheduled()) -> A.Scheduled():
  Scheduled.enabled(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~A.Ids,~A.program(),app,True{})
def materialized(ids:A.Ids) -> Condition.Entries<F.S>:
  Condition.materialize(~F.S,~F.Store,~F.Resources,~F.Events(),~A.Ids,A.program(),ids)
def attached(app:Prior.Previous(),ids:A.Ids) -> Schedule.Attachment<Prior.Previous(),A.Scheduled()>:
  Scheduled.attach(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~A.Ids,~A.program(),app,"Control",ids)
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("typed-control")
