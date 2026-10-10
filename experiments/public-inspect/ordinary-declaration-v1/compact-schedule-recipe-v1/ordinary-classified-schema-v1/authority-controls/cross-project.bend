import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as S
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
def invalid(~A:Data,~V:Type,~identity:I.Declaration<A,V>,~left:V -> V & D.Raw,~right:V -> V & D.Raw,extension:P.Constructed<A,V,identity,left>) -> S.Schema<A,Unit,V>:S.resource_constructed(~A,~V,~identity,~right,extension)
def main() -> Unit:Unit{}
