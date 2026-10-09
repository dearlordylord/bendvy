import Base
import ../schema.bend as Schema
import ../types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as Rel
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-schema.bend as Normal
type Other is Data:
  Other{}
def foreign() -> Rel.Descriptor<Other>:
  Rel.Descriptor{7,"Parent","Children",Rel.Hierarchy{}}
def main() -> Schema.Declaration<T.Tag,Unit,Unit> & Rel.Descriptor<T.Tag>:
  Schema.relation(~T.Tag,~Unit,~Unit,Schema.ordinary(~T.Tag,~Unit,~Unit,Normal.Schema{[]}),foreign())
