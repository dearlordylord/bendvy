import Base
import ./declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/game.bend as Game
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/legacy-fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp

def read(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw>>:
  Query.read(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def write(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Cap.Write<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload,D.Raw>>:
  Query.write(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def optional(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw>>:
  Query.optional(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def with_component(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Unit>:
  Query.with_component(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def without_component(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Unit>:
  Query.without_component(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def added(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Unit>:
  Query.added(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

def changed(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,Unit>:
  Query.changed(~S,~F.Payload,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>),~D.Raw,~S,~F.declaration(~S),~F.project,~F.project,~Game.take_saved(~S),~Game.put_saved(~S))

# Actual arbitrary-Type component access using the ordinary declaration above.
def application(~S:Data,frame:Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Cmp.Access<D.Raw>:
  Query.execute_read(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~D.Raw,~read(~S),frame)

# Product couples required read, write and optional grants to one declaration.
def combinations(~S:Data) -> Query.Declaration<S,Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,(Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw> & Cap.Write<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload,D.Raw>) & Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw>>:
  Query.pair(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~(Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw> & Cap.Write<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload,D.Raw>),~Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw>,~Query.pair(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~Cap.Read<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,D.Raw>,~Cap.Write<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload,D.Raw>,~read(~S),~write(~S)),~optional(~S))

def replacement(~S:Data,frame:Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,incoming:F.Payload) -> Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>:
  Cap.set(~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~F.Payload,~D.Raw,~Query.grant(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~Cap.Write<Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload,D.Raw>,write(~S)),frame,incoming)
def optional_value(~S:Data,frame:Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Cmp.Access<D.Raw>:
  Query.execute_read(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~D.Raw,~optional(~S),frame)
def filter_match(~S:Data,frame:Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Bool:
  Query.selector(~S,~Q.Frame<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,~Unit,added(~S))(frame)
