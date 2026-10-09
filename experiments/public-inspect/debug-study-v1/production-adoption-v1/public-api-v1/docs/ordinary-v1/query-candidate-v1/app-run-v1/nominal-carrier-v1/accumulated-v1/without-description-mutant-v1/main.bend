import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario.bend as Scenario
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/output.bend as Output

type Complete is Data:
  Complete{plain:Output.Outcome,transient:Output.Outcome,constructed:Output.Outcome}
def main() -> Complete:
  Complete{Output.plain(Scenario.plain()),Output.transient(Scenario.transient()),Output.constructed(Scenario.constructed())}
