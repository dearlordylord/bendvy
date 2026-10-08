import Base
import ./gate.bend as G
import ./fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component.bend as Component
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Definition
# Actual component token and persistence Gate share ONE actual nominal index.
def combined(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,token:Component.Token<S,P,declaration>,gate:G.Gate<S,P,declaration>,owner:P) -> P & G.Field:
  G.export_owner(~S,~P,~declaration,gate,owner)
def main() -> U32:
  0
