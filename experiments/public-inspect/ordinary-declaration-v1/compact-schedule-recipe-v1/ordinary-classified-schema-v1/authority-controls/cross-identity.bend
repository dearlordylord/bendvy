import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as S
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
def invalid(~A:Data,~V:Type,~left:I.Declaration<A,V>,~right:I.Declaration<A,V>,extension:P.Plain<A,V,left>) -> S.Schema<A,Col.Column<A,V>,Unit>:S.component_plain(~A,~V,~right,extension)
def main() -> Unit:Unit{}
