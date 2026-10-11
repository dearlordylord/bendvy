import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-removal.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import ../consumer-public.bend as C
def main() -> Access.Declaration<C.A,C.Payload>:Schema.resource(~C.A,~C.Payload,"Position")
