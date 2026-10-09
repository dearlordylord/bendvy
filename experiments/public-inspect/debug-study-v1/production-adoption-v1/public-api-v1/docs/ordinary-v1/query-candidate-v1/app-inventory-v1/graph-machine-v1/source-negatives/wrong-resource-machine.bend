import Base
import ../schema.bend as Schema
import ../types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as Rel
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-schema.bend as Normal
def take(unit:Unit) -> Unit & M.Slot<T.Tag,T.Key,T.State>:
  (unit,M.Missing{})
def put(unit:Unit,slot:M.Slot<T.Tag,T.Key,T.State>) -> Unit:
  unit
def main() -> Schema.Declaration<T.Tag,Unit,Unit> & M.Family<T.Tag,T.Key,T.State,Unit,take,put>:
  Schema.machine_named(~T.Tag,~Unit,~Unit,~T.Key,~T.State,~take,~put,Schema.ordinary(~T.Tag,~Unit,~Unit,Normal.Schema{[]}),T.family())
