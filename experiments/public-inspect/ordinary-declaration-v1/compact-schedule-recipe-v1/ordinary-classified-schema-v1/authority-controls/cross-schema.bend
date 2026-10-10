import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as S
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
def invalid(~A:Data,~B:Data,~V:Type,~identity:I.Declaration<A,V>,extension:P.Plain<A,V,identity>) -> S.Schema<B,Col.Column<B,V>,Unit>:S.component_plain(~B,~V,~identity,extension)
def main() -> Unit:Unit{}
