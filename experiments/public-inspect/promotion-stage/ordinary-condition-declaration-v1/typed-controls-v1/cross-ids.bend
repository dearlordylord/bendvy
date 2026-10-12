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
def crossed(ids:Other.Ids) -> Condition.Entries<F.S>:
  Condition.materialize(~F.S,~F.Store,~F.Resources,~F.Events(),~A.Ids,A.program(),ids)
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("typed-control")
