import Base
import ./application.bend as App
import ./declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/game.bend as Game
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/legacy-fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def misuse(value:Query.Declaration<F.Workshop,Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,Cap.Read<Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,D.Raw>>) -> Query.Declaration<F.Workshop,Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,Cap.Read<Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,D.Raw>> & Query.Declaration<F.Workshop,Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,Cap.Read<Q.Frame<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,D.Raw>>:
  (value,value)
