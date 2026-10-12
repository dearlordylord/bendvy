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
def crossed(app:A.Scheduled()) -> Other.Scheduled():
  Scheduled.enabled(~G.S,~G.Store,~G.Resources,~G.Events(),~D.Owners4(),~D.Rows4(),~D.observe4(),~D.fold4(),~Other.Ids,~Other.program(),app,True{})
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("typed-control")
