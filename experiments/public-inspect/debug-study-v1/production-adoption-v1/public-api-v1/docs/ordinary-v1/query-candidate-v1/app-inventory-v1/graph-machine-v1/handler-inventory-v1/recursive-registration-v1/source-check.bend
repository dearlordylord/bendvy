import Base
import ./driver.bend as Driver
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-schema.bend as S
def consume(~A:Type,value:A) -> Unit:
  Unit{}
def main() -> Unit:
  consume(~(Unit & Unit & Unit),(consume(~Driver.Delivery<S.plain_store(),Driver.plain_owners()>,Driver.plain()),consume(~Driver.Delivery<S.transient_store(),Driver.transient_owners()>,Driver.transient()),consume(~Driver.Delivery<S.constructed_store(),Driver.constructed_owners()>,Driver.constructed())))
