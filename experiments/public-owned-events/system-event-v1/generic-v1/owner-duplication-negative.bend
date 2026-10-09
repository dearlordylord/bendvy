import Base
import second-schema.bend as Second
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

def duplicate(owner:Ordinary.Owner<Second.Schema,Second.Registry()>) -> Ordinary.Owner<Second.Schema,Second.Registry()> & Ordinary.Owner<Second.Schema,Second.Registry()>:
  (owner,owner)
